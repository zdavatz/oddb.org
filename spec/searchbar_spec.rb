#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'
require 'pp'
require 'tmpdir'
require "selenium-webdriver"

describe "ch.oddb.org" do

  def enter_search_to_field_by_name(search_text, field_name)
    idx = -2
    chooser = @browser.text_field(:name,field_name)
    0.upto(2).each{ 
      |idx|
      break if chooser and chooser.present?
      sleep 1
      chooser = @browser.text_field(:name,field_name)
    }
    unless chooser and chooser.present?
      msg = "idx #{idx} could not find textfield #{field_name} in #{@browser.url}"
      puts msg
      # require 'pry'; binding.pry
      raise msg
    end
    0.upto(30).each{ |idx|
                      begin
                        chooser.set(search_text)
                        sleep idx*0.1
                        chooser.send_keys(:down)
                        sleep idx*0.1
                        chooser.send_keys(:enter)
                        sleep idx*0.1
                        value = chooser.value
                        break unless /#{search_text}/.match(value)
                        sleep 0.5
                      rescue StandardError => e
                        puts "in rescue"
                        createScreenshot(@browser, "rescue_#{search_text}_#{__LINE__}")
                        puts e.inspect
                        puts caller[0..5]
                        return
                      end
                    }
    chooser.set(chooser.value + "\n")
    # puts "chooser value #{chooser.value} text  #{chooser.text}"
    createScreenshot(@browser, "_#{search_text}_#{__LINE__}")
  end
  
  before :all do
    $prescription_test_id = 1
    waitForOddbToBeReady(@browser, OddbUrl)
    login
  end

  before :each do
    @timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    # puts "before #{$prescription_test_id} with #{@browser.windows.size} windows"
    while @browser.windows.size > 1
      @browser.windows.first.use
      @browser.windows.last.close if @browser.windows.last
    end
    @browser.goto OddbUrl
  end

  def enter_fachinfo_search
    if @browser.link(:name=>'fachinfo_search').exists?
      @browser.link(:name=>'fachinfo_search').click;  small_delay

    end
  end
  
  after :each do
    createScreenshot(@browser, '_'+$prescription_test_id.to_s) if @browser
    $prescription_test_id += 1
  end

  { '125Dihydroxycholecalciferol 1000' => '1,25-Dihydroxycholecalciferol',
    '125'                              => '125',
    '125'                              => '1,25-Dihydroxycholecalciferol',
    '125Dihydroxycholecalciferol'      => '1,25-Dihydroxycholecalciferol',
  }.each {
    |searchterm, searchtext|
    it "should be possible to find #{searchtext} when searching via #{searchterm} in analysen" do
      @browser.link(:name,'analysis').click;  small_delay

      small_delay unless @browser.text_field(:name, "search_query").exists?
      @browser.text_field(:name, "search_query").value = searchterm
      @browser.button(:name => 'search').click;  small_delay

      expect(@browser.text).not_to match LeeresResult
      expect(@browser.text).to match /#{searchtext}/
    end
  }  unless ['just-medical'].index(Flavor)

  chapters = {
    'Unerw.Wirkungen' => 'Kopfschmerzen',
    'Dos./Anw.' => 'Kinder',
    'Interakt.' => 'Tocilizumab',
  }
  chapters.each{ |chapter_name, text|
    it "should should work (58868 Actemra) with #{chapter_name} and #{text}" do
      enter_fachinfo_search
      enter_search_to_field_by_name('Actemra', 'searchbar');

      @browser.select_list(:name, "fachinfo_search_type").select(chapter_name)
      @browser.checkbox(:name,'fachinfo_search_full_text').set
      @browser.text_field(:name => 'fachinfo_search_term').set(text)
      @browser.text_field(:name => 'fachinfo_search_term').send_keys :tab
      @browser.button(:id => 'fi_search').click;  small_delay

      expect(@browser.text).to match text
      expect(@browser.text).to match /Actemra/
    end
  }
  it "should should be possible to add and delete several drugs:" do
    enter_fachinfo_search
    expect(@browser.text).not_to match /Actemra/
    expect(@browser.text).not_to match /Aspirin/
    enter_search_to_field_by_name('Actemra', 'searchbar');
    enter_search_to_field_by_name('Aspirin', 'searchbar');
    expect(@browser.text).to match /Actemra/
    expect(@browser.text).to match /Aspirin/
    @browser.element(:id => /minus_Actemra/i).click;  small_delay

    expect(@browser.text).not_to match /Actemra/
    expect(@browser.text).to match /Aspirin/
    @browser.element(:id => /minus_Aspirin/i).click;  small_delay

    expect(@browser.text).not_to match /Actemra/
    expect(@browser.text).not_to match /Aspirin/
    # @browser.url.should match /fachinfo_search\/$/
  end

  it "should should be possible to delete all drugs:" do
    enter_fachinfo_search
    expect(@browser.text).not_to match /Actemra/
    expect(@browser.text).not_to match /Aspirin/
    enter_search_to_field_by_name('Actemra', 'searchbar');
    enter_search_to_field_by_name('Aspirin', 'searchbar');
    enter_search_to_field_by_name('Ponstan', 'searchbar');
    expect(@browser.text).to match /Actemra/
    expect(@browser.text).to match /Aspirin/
    expect(@browser.text).to match /Ponstan/
    @browser.element(:name => 'delete').click;  small_delay
; small_delay
    expect(@browser.text).not_to match /Actemra/
    expect(@browser.text).not_to match /Aspirin/
    expect(@browser.text).not_to match /Ponstan/
    expect(@browser.url).to match /fachinfo_search\/$/
  end

  it "should work with the privatetemplate searchbar" do
    field_name = 'search_query'
    @browser.links.find{ |item| item.href.match(/fachinfo\/reg/) != nil}.click;  small_delay
    expect(@browser.text_field(:name => field_name).text).to eq("")
    expect(@browser.text_field(:name => field_name).value).to eq("HIER Suchbegriff eingeben")
    @browser.text_field(:name => field_name).value = 'Aspirin'
    @browser.text_field(:name => field_name).send_keys :enter
    expect(@browser.url).to match /search_query/
    expect(@browser.url).to match /Aspirin/
    expect(@browser.text.scan(/aspirin/i).count).to be > 10 # was 17 in august 2014
  end unless ['just-medical'].index(Flavor)

  it "should be possible to find Dr. Peter Schönbucher via doctors " do
    @browser.link(:name, "doctors").click;  small_delay

    @browser.text_field(:name, "search_query").value = "Schönbucher"
    @browser.button(:name, 'search').click;  small_delay

    expect(@browser.text).to match /Schönbucher Peter/
  end unless ['just-medical'].index(Flavor)

  it "should be possible to find Abacavir via Wirkstoffe" do
    if  @browser.link(:name, 'substances').exists?
      @browser.link(:name, 'substances').click;  small_delay
    end
    # @browser.text.should_not match /substance_search_explain/
    @browser.text_field(:name, "search_query").value = "Abacavirum"
    @browser.select_list(:name, "search_type").select("Inhaltsstoff")

    expect(@browser.text).not_to match LeeresResult
    expect(@browser.text).to match /Deutsche Bezeichnung|Präparat/
    expect(@browser.text).to match /Abacavir/
  end unless ['just-medical'].index(Flavor)

  it "should return an empty list when entering a non existing name in the drugs-result search button" do
    invalid = "THIS_NAME_SHOULD_NOT_BE_FOUND"
    name = "Keppra"
    @browser.text_field(:name, "search_query").value = name
    @browser.select_list(:name, "search_type").select("Preisvergleich")
    @browser.text_field(:name, "search_query").send_keys :return
    expect(@browser.url).to match /#{name}/i
    expect(@browser.text_field(:text, /#{name}/i).exist?).to eql true
    expect(@browser.text).not_to match LeeresResult

    expect(@browser.text).not_to match LeeresResult
    @browser.text_field(:name, "search_query").value = invalid
    @browser.text_field(:name, "search_query").send_keys :return
    expect(@browser.url).to match(invalid)
    expect(@browser.url).not_to match /#{name}/i
    expect(@browser.text_field(:text, /#{name}/i).exist?).to eql false
  end unless ['just-medical'].index(Flavor)

  it "should be possible to find the Kantonsspital Glarus via Spital" do
    @browser.link(:name, 'hospitals').click;  small_delay

    # @browser.text.should_not match /substance_search_explain/
    @browser.text_field(:name, "search_query").value = "Glarus"    
    @browser.button(:name, 'search').click;  small_delay

    expect(@browser.text).not_to match LeeresResult
    expect(@browser.text).to match /Abteilung/
    expect(@browser.text).to match /Kantonsspital Glarus/
  end unless ['just-medical'].index(Flavor)

  it "should be possible to find Krücke via MiGeL" do
    @browser.link(:name, 'migel').click;  small_delay

    # @browser.text.should_not match /substance_search_explain/
    @browser.text_field(:name, "search_query").value = "Krücke"    
    @browser.button(:name, 'search').click;  small_delay

    expect(@browser.text).not_to match LeeresResult
    expect(@browser.text).to match /Beschreibung/
    expect(@browser.text).to match /Krücken/
  end unless ['just-medical'].index(Flavor)

  it "should be possible to find Novartis via Zulassungsinhaber" do
    @browser.link(:name, 'companies').click;  small_delay

    # @browser.text.should_not match /substance_search_explain/
    @browser.text_field(:name, "search_query").value = "Novartis"
    @browser.button(:name, 'search').click;  small_delay

    expect(@browser.text).not_to match LeeresResult
    text = @browser.text.clone
    # Aktuell Einträge come only when we are logged in as admin user
    expect(text).to match /Zulassungs­inhaber Geschäftsfeld/
    expect(text).to match /Novartis Pharma Schweiz AG/
  end unless ['just-medical'].index(Flavor)

  pending "should work with the notify searchbar" do
    expect(false).to eq(true)
  end

  pending "should work with the notify_confirm searchbar" do
    expect(false).to eq(true)
  end

  pending "should work with the drugs/fachinfos searchbar" do
    expect(false).to eq(true)
  end

  pending "should work with the drugs/vaccines searchbar" do
    expect(false).to eq(true)
  end

  pending "should work with the drugs/limitationtexts searchbar" do
    expect(false).to eq(true)
  end

  pending "should work with the drugs/feedbacks searchbar" do
    expect(false).to eq(true)
  end

  pending "should work with the drugs/patinfos searchbar" do
    expect(false).to eq(true)
  end

  pending "should work with the  drugs/sequences searchbar" do
    expect(false).to eq(true)
  end

  pending "should work with the drugs/resultlimit searchbar" do
    expect(false).to eq(true)
  end

  pending "should work with the substances/result searchbar" do
    expect(false).to eq(true)
  end

  it "should be possible to find Budenofalk and Budesonid Sandoz via combined search" do
    @browser.link(:name, 'drugs').click;  small_delay

    @browser.select_list(:name, "search_type").select("Preisvergleich und Inhaltsstoff")
    @browser.text_field(:name, "search_query").value = "Budesonid"
    @browser.button(:name, 'search').click;  small_delay

    text = @browser.text.clone
    expect(text).not_to match LeeresResult
    expect(text).to match('Budesonid Sandoz') # by price
    expect(text).to match('Budenofalk')       # by component
  end unless ['just-medical'].index(Flavor)

  ['Interaktion',
   'Markenname',
   'Preisvergleich',
   'Inhaltsstoff',
   'Preisvergleich und Inhaltsstoff'][0..0].each do |search_type|
    it "#{search_type} should display not found for Warfarin which is not registered in Switzerland " do
        # @browser.goto OddbUrl
        @browser.select_list(:name, "search_type").select(search_type)
        @browser.text_field(:name, "search_query").value = "Warfarin"
        @browser.button(:name, 'search').click;  small_delay
        puts "Warfarin: URL ist #{@browser.url}"
        text = @browser.text.clone
        skip("Warfarin behaves differently on oddb-ci2 and ch.oddb.org")
        expect(text).to match LeeresResult
      end
  end

  after :all do
    @browser.close
  end
end