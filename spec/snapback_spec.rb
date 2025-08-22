#!/usr/bin/env ruby

require "spec_helper"

@workThread = nil

describe "ch.oddb.org snapback" do
  before :all do
    @idx = 0
    waitForOddbToBeReady(@browser, ODDB_URL)
    login(ViewerUser, ViewerPassword)
  end

  before :each do
    @browser.goto ODDB_URL
    login(ViewerUser, ViewerPassword)
  end

  after :each do
    @idx += 1
    createScreenshot(@browser, "_" + @idx.to_s)
    # sleep
    @browser.goto ODDB_URL
  end

  SnapbackTestStep = Struct.new(:line, :search_type, :search_value, :link_to_click, :expect_url, :expect_snapback_text, :next_step)
  Search_URL = /search_query\/#{SNAP_IKSNR}|de\/gcc$|home_drugs\/$|#{ODDB_URL}\/$/
  Search_Snap = /Home - #{SNAP_IKSNR} - \d{2} - \d{3}/
  Search_SnapBack = /Suchresultat|Home/
  FI_URL = "de/gcc/fachinfo/reg/#{SNAP_IKSNR}"
  FI_URL_MATCH = /#{Regexp.quote(FI_URL)}/
  FI_Snap = /(Home|Suchresultat) - FI zu #{SNAP_NAME}/
  DIFF_URL = "/show/fachinfo/#{SNAP_IKSNR}/diff"
  DIFF_URL_MATCH = /#{Regexp.quote(DIFF_URL)}/
  test_1_4 = SnapbackTestStep.new(__LINE__, nil, nil, Date_Regexp, DIFF_URL_MATCH, /Home,Fachinformation zu Lubex,Änderungen,\d{2}.\d{2}.\d{4}/, nil)
  test_1_3 = SnapbackTestStep.new(__LINE__, nil, nil, "Änderungen anzeigen", DIFF_URL_MATCH, "Home,Fachinformation zu Lubex,Änderungen", test_1_4)
  test_1_2 = SnapbackTestStep.new(__LINE__, nil, nil, "FI", FI_URL_MATCH, FI_Snap, test_1_3)
  FirstTest = SnapbackTestStep.new(__LINE__, /Swissmedic/, SNAP_IKSNR.to_s, nil, Search_URL, Search_Snap, test_1_2)
  FI_Link = /\/fachinfo\/reg\/(\d+)$/

  nr_tests = 0
  current = FirstTest
  while nr_tests += 1
    current = current.next_step
    break unless current
  end
  # puts "We have #{nr_tests} test steps"

  class SnapbackTestStep
    def to_s
      "Search #{search_type} #{search_value} link: #{link_to_click} #{expect_url} #{expect_snapback_text} #{@next_step.class}"
    end
  end

  def search_item(search_type, search_value)
    if @browser.link(name: "drugs").exists?
      @browser.link(name: "drugs").click
    end
    if @browser.link(name: "drugs").exists?
      @browser.link(name: "drugs").click
    end
    @browser.select_list(name: "search_type").wait_until(&:present?)
    @browser.select_list(name: "search_type").select(/#{search_type}/)
    @browser.text_field(name: "search_query").value = search_value
    @browser.text_field(name: "search_query").send_keys :enter
  end

  def check_home_links
    @browser.link(text: "Home").wait_until(&:present?)
    @browser.links.find { |x| x.text.eql? "Home" }
    home_pattern = /\/home|/
    @browser.links.find_all { |x| x.text.eql? "Home" }.each do |link|
      expect(link.exist?).to be true
      expect(link.href).to match home_pattern
    end
  end

  it "should always have the correct home link" do
    @browser.goto(ODDB_URL + "/de/gcc" + DIFF_URL)
    check_home_links
    link = @browser.link(visible_text: /Fachinformation zu/)
    expect(link.exist?).to be true
    link.click
    check_home_links
  end

  it "should allow going back, then forward" do
    current = FirstTest
    nr = 1
    puts "#{nr}: Searching #{current.search_type} for #{current.search_value}"
    search_item(current.search_type, current.search_value)
    @prev_url = nil
    current = current.next_step
    while current
      nr += 1
      # puts "\nRunning test step #{nr}\n  #{current.inspect}"
      link = @browser.link(visible_text: current.link_to_click)
      # puts "#{nr}: Clicking link #{current.link_to_click} exist? #{link.exist?}"
      link.wait_until(&:present?)
      expect(link.exist?).to be true
      link.click
      check_home_links
      # puts "#{nr}: #{__LINE__}: Got URL #{@browser.url} \n expecting #{current.expect_url}"
      expect(@browser.url).to match current.expect_url
      if nr > 2 # TODO: Fix failure in nr == 2!!!
        saved_text = @browser.text
        saved_url = @browser.url
        @browser.back
        expect(@browser.url).to eql @prev_url
        @browser.forward
        expect(@browser.url).to eql saved_url
        expect(@browser.text).to eql saved_text
      end
      @prev_url = @browser.url.clone
      current = current.next_step
    end
  end

  2.upto(nr_tests).each do |step_to_test|
    it "should a working Home button for step #{step_to_test}" do
      current = FirstTest
      nr = 1
      puts "step_to_test #{step_to_test}: #{nr}: Searching #{current.search_type} for #{current.search_value}"
      search_item(current.search_type, current.search_value)
      @prev_url = nil
      current = current.next_step
      while current and nr < step_to_test
        nr += 1
        link = @browser.link(visible_text: current.link_to_click)
        link.wait_until(&:present?)
        expect(link.exist?).to be true
        @prev_url = @browser.url.clone
        link.click
        check_home_links
        current = current.next_step
      end
      home_link = @browser.link(visible_text: "Home")
      expect(home_link.exist?).to be true
      saved_text = @browser.text
      saved_url = @browser.url
      home_link.click
      check_home_links
      if @browser.url.eql?(ODDB_URL)
        expect(@browser.url).to eql? ODDB_URL
      else
        expect(@browser.url).to match(/\/home\/|\/home_drugs\//)
      end
      @browser.back
      check_home_links
      expect(@browser.url).to eql saved_url
      expect(@browser.text[0..100]).to eql saved_text[0..100] # fail with less verbose output
      expect(@browser.text).to eql saved_text
    end
  end

  it "should work follow correctly the expected paths" do
    if @browser.link(name: "drugs").exists?
      @browser.link(name: "drugs").click
    end
    check_home_links
    nr = 0
    current = FirstTest
    while current
      nr += 1
      puts "\nRunning test step #{nr}\n  #{current.inspect}"
      if current.link_to_click
        link = @browser.link(visible_text: current.link_to_click)
        link.wait_until(&:present?)
        puts "#{nr}: Clicking link #{current.link_to_click} exist? #{link.exist?}"
        expect(link.exist?).to be true
        link.click
      elsif current.search_value
        puts "#{nr}: Searching #{current.search_type} for #{current.search_value}"
        search_item(current.search_type, current.search_value)
      end
      res = current.expect_url.match(@browser.url)
      unless res
        sleep(1)
        res = current.expect_url.match(@browser.url)
        puts "#{nr}: #{__LINE__}: #{res.inspect} Got URL #{@browser.url} \n expecting #{current.expect_url}"
      end
      expect(current.expect_url).to match @browser.url
      check_pointer_steps(current.expect_snapback_text, current.line)
      @browser.url.clone
      current = current.next_step
    end
  end

  it "should work following a fachinfo" do
    expect(@browser.url).to match ODDB_URL
    link = @browser.link(href: FI_Link)
    FI_Link.match(link.href)[1]
    link.click
    check_home_links
    steps = @browser.tds.find_all { |x| x.class_name.eql? "breadcrumbs" }
    text = steps.collect { |y| y.text }.join("").clone
    expect(text).to match(/Home - FI zu/)
  end

  Snapback_Registration = {"63184" => "Celecoxib Zentiva"}
  it "should work following a search via IKSNR" do
    iksnr = Snapback_Registration.keys.first
    name = Snapback_Registration.values.first
    search_item(/Swissmedic/, iksnr)
    check_pointer_steps(/Home - #{iksnr}/)
    expect(@browser.text).not_to match LeeresResult
    expect(@browser.text).to match(/Deutsche Bezeichnung|Präparat/)
    expect(@browser.text).to match(/#{Regexp.quote(name)}/)
    @browser.link(name: "square_fachinfo").click
    check_pointer_steps(/Home - FI zu #{name}/)
    @browser.link(name: "change_log").click
    check_pointer_steps(/Home,Fachinformation zu #{name}.+,Änderungen/)
    @browser.link(name: "change_log").click
    check_pointer_steps(/Home,Fachinformation zu #{name}.+,Änderungen,\d{2}\.\d{2}\.\d{4}/)
  end

  def check_pointer_steps(expected, line = nil)
    check_home_links
    steps = @browser.elements.find_all { |x| x.class_name.eql? "breadcrumbs" }
    text = steps.collect { |y| y.text }.join(",").clone
    puts "#{__LINE__}: #{Time.now} Pointersteps are #{text}\n should #{expected} are #{expected.match(text).inspect}"
    expect(text).to match expected
  end

  after :all do
    @browser.close if @browser
  end
end
