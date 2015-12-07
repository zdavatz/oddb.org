#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'

@workThread = nil

describe "ch.oddb.org snapback" do

  before :all do
    @idx = 0
    waitForOddbToBeReady(@browser, OddbUrl)
    login(ViewerUser,  ViewerPassword)
  end

  before :each do
    @browser.goto OddbUrl
    login(ViewerUser,  ViewerPassword)
  end

  after :each do
    @idx += 1
    createScreenshot(@browser, '_'+@idx.to_s)
    # sleep
    @browser.goto OddbUrl
  end

  SnapbackTestStep = Struct.new(:line, :search_type, :search_value, :link_to_click, :expect_url, :expect_snapback_text, :next_step)
  SNAP_IKSNR = 40501
  SNAP_NAME = 'Lubex®'
  Search_URL=  /search_query\/#{SNAP_IKSNR}|de\/gcc$|home_drugs\/$|#{OddbUrl}\/$/
  Search_Snap = /Sie befinden sich in - ,Home,#{SNAP_IKSNR},\d{2},\d{3}/
  Search_SnapBack = /Suchresultat|Home/
  FI_url  = "de/gcc/fachinfo/reg/#{SNAP_IKSNR}"
  FI_Snap = /Sie befinden sich in - ,(Home|Suchresultat),Fachinformation zu #{SNAP_NAME}/
  Diff_URL = /\/show\/fachinfo\/#{SNAP_IKSNR}\/diff/
  Date_Regexp = /\d{2}.\d{2}.\d{4}/
  diff_url = "/show/fachinfo/#{SNAP_IKSNR}/diff"
  test_1_4 = SnapbackTestStep.new(__LINE__, nil, nil, Date_Regexp,  diff_url, /Home,Fachinformation zu Lubex,Änderungen,\d{2}.\d{2}.\d{4}/, nil)
  test_1_3 = SnapbackTestStep.new(__LINE__, nil, nil, "Änderungen anzeigen",diff_url, "Home,Fachinformation zu Lubex,Änderungen", test_1_4)
  test_1_2 = SnapbackTestStep.new(__LINE__, nil, nil, 'FI', FI_url, FI_Snap, test_1_3)
  FirstTest = SnapbackTestStep.new(__LINE__,/Swissmedic/, SNAP_IKSNR.to_s, nil,  Search_URL, Search_Snap, test_1_2)
  FI_Link = /\/fachinfo\/reg\/(\d+)$/

  nr_tests = 0
  current = FirstTest
  while
    nr_tests += 1
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
    if @browser.link(:name, 'drugs').exists?
      @browser.link(:name, 'drugs').click; small_delay
    end
    if @browser.link(:name, 'drugs').exists?
      @browser.link(:name, 'drugs').click; small_delay
    end
    @browser.select_list(:name, "search_type").select(/#{search_type}/)
    @browser.text_field(:name, "search_query").value = search_value
    @browser.text_field(:name, "search_query").send_keys :enter
  end

  def check_home_links
    @browser.links.find_all{|x| x.text.eql? 'Home' }.each do |link|
      home_pattern = /\/home|/
      # puts "link #{link.text} #{link.href}"
      # binding.pry unless link.exist?
      # binding.pry unless home_pattern.match(link.href)
      expect(link.exist?).to be true
      expect(link.href).to match home_pattern
    end
  end

  it "should always have the correct home link" do
    @browser.goto(OddbUrl + '/de/gcc' + diff_url)
    check_home_links
    link = @browser.link(:text => /Fachinformation zu/)
    expect(link.exist?).to be true
    link.click
    check_home_links
  end

  it "should have a working link to Änderungen from the diff" do
    @browser.goto(OddbUrl + '/de/gcc' + diff_url)
    check_home_links
    link = @browser.link(:text => Date_Regexp)
    expect(link.exist?).to be true
    saved_url = @browser.url.to_s.clone
    saved_text = @browser.text
    link.click
    check_home_links
    link = @browser.link(:text => /Änderungen/)
    expect(link.exist?).to be true
    link.click
    check_home_links
    expect(@browser.url.to_s).to eql saved_url.to_s
    expect(@browser.text[0..100]).to eql saved_text[0..100]
    expect(@browser.text).to eql saved_text
  end

  it "should allow going back, then forward" do
    current= FirstTest
    nr = 1
    puts "#{nr}: Searching #{current.search_type} for #{ current.search_value}"
    search_item(current.search_type, current.search_value)
    @prev_url = nil
    current = current.next_step
    while current
      nr += 1
      # puts "\nRunning test step #{nr}\n  #{current.inspect}"
      link = @browser.link(:text => current.link_to_click)
      # puts "#{nr}: Clicking link #{current.link_to_click} exist? #{link.exist?}"
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

  2.upto(nr_tests).each do  |step_to_test|
    it "should a working Home button for step #{step_to_test}" do
      current= FirstTest
      nr = 1
      puts "step_to_test #{step_to_test}: #{nr}: Searching #{current.search_type} for #{ current.search_value}"
      search_item(current.search_type, current.search_value)
      @prev_url = nil
      current = current.next_step
      while current and nr < step_to_test
        nr += 1
        link = @browser.link(:text => current.link_to_click)
        expect(link.exist?).to be true
        @prev_url = @browser.url.clone
        link.click
        check_home_links
        current = current.next_step
      end
      home_link = @browser.link(:text => 'Home')
      expect(home_link.exist?).to be true
      saved_text = @browser.text
      saved_url = @browser.url
      home_link.click
      check_home_links
      if @browser.url.eql?(OddbUrl)
        expect(@browser.url).to eql? OddbUrl
      else
        expect(@browser.url).to match /\/home\/|\/home_drugs\//
      end
      @browser.back
      check_home_links
      expect(@browser.url).to eql saved_url
      expect(@browser.text[0..100]).to eql saved_text[0..100] # fail with less verbose output
      expect(@browser.text).to eql saved_text
    end
  end

  it "should work follow correctly the expected paths" do
    if @browser.link(:name, 'drugs').exists?
      @browser.link(:name, 'drugs').click; small_delay
    end
    check_home_links
    nr = 0
    current= FirstTest
    prev_url = nil
    while current
      nr += 1
      puts "\nRunning test step #{nr}\n  #{current.inspect}"
      if current.link_to_click
        link = @browser.link(:text => current.link_to_click)
        puts "#{nr}: Clicking link #{current.link_to_click} exist? #{link.exist?}"
        expect(link.exist?).to be true
        link.click
      elsif  current.search_value
        puts "#{nr}: Searching #{current.search_type} for #{ current.search_value}"
        search_item(current.search_type, current.search_value)
      end
      puts "#{nr}: #{__LINE__}: Got URL #{@browser.url} \n expecting #{current.expect_url}"
      expect(@browser.url).to match current.expect_url
      check_pointer_steps(current.expect_snapback_text, current.line)
      prev_url = @browser.url.clone
      current = current.next_step
    end
  end

  it "should work following a fachinfo" do
    expect(@browser.url).to match OddbUrl
    link = @browser.link(:href => FI_Link)
    iksnr = FI_Link.match(link.href)[1]
    link.click
    check_home_links
    steps = @browser.tds.find_all{ |x| x.class_name.eql? 'th-pointersteps'}
    text = steps.collect{ |y| y.text }.join('').clone
    expect(text).to match /Sie befinden sich/
  end

  Snapback_Registration = { '63184' => 'Celecoxib Helvepharm'}
  it "should work following a search via IKSNR" do
    iksnr = Snapback_Registration.keys.first
    name = Snapback_Registration.values.first
    search_item(/Swissmedic/, iksnr)
    check_pointer_steps(/Sie befinden sich in - ,Home,#{iksnr}/)

    expect(@browser.text).not_to match LeeresResult
    expect(@browser.text).to match /Deutsche Bezeichnung|Präparat/
    expect(@browser.text).to match name
    @browser.link(:name => 'square_fachinfo').click
    check_pointer_steps(/Sie befinden sich in\s+-\s+,Home,Fachinformation zu #{name}/)
    @browser.link(:name => 'change_log').click
    check_pointer_steps(/Home,Fachinformation zu #{name}.+,Änderungen/)
    @browser.link(:name => 'change_log').click
    check_pointer_steps(/Home,Fachinformation zu #{name}.+,Änderungen,\d{2}\.\d{2}\.\d{4}/)
  end

  def check_pointer_steps(expected, line = nil)
    check_home_links
    steps = @browser.elements.find_all{ |x| x.class_name.eql? 'th-pointersteps'}
    text = steps.collect{ |y| y.text }.join(',').clone
    puts "#{__LINE__}: #{Time.now} Pointersteps are #{text}\n should #{expected} are #{expected.match(text).inspect}"
    expect(text).to match expected
  end

  after :all do
    @browser.close
  end
end
