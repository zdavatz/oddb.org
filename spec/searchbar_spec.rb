#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'
require 'pp'
require 'tmpdir'
require "selenium-webdriver"

LeeresResult =  /hat ein leeres Resultat/

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
    puts "chooser set to #{chooser.value}"
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
      puts "Going to search FI erweitert"
      @browser.link(:name=>'fachinfo_search').click
    end
  end
  
  after :each do
    createScreenshot(@browser, '_'+$prescription_test_id.to_s) if @browser
    $prescription_test_id += 1
  end

  it "should work with the privatetemplate searchbar" do
    field_name = 'search_query'
    @browser.links.find{ |item| item.href.match(/fachinfo\/swissmedic/) != nil}.click
    @browser.text_field(:name => field_name).text.should == ""
    @browser.text_field(:name => field_name).value.should == "HIER Suchbegriff eingeben"
    @browser.text_field(:name => field_name).value = 'Aspirin'
    @browser.text_field(:name => field_name).send_keys :enter
    @browser.url.should match /search_query/
    @browser.url.should match /Aspirin/
    @browser.text.scan(/aspirin/i).count.should > 10 # was 17 in august 2014
  end if false

  # http://oddb-ci2.dyndns.org/de/gcc/fachinfo/reg/58868
  it "should show the chapter Dos./Anw for Kopfschmerzen and show 58868 Actemra :" do
    enter_fachinfo_search
    enter_search_to_field_by_name('Actemra', 'searchbar');

    @browser.select_list(:name, "fachinfo_search_type").select(/Unerw.Wirk/i)
    @browser.checkbox(:name,'fachinfo_search_full_text').set
    @browser.text_field(:name => 'fachinfo_search_term').set('Kopfschmerzen')
    @browser.text_field(:name => 'fachinfo_search_term').send_keys :tab
    # require 'pry'; binding.pry
    sleep 0.1
    @browser.button(:value,"Suchen").click
    sleep(5)
    @browser.text.should match /Kopfschmerzen/
    @browser.text.should match /Actemra/
  end

  it "should be possible to find Dr. Peter Schönbucher via doctors " do
    @browser.link(:name, "doctors").click
    @browser.text_field(:name, "search_query").value = "Schönbucher"
    @browser.button(:name, 'search').click
    @browser.text.should match /Schönbucher Peter/
  end

  it "should be possible to find Abacavir via Wirkstoffe" do
    @browser.link(:name, 'substances').click
    # @browser.text.should_not match /substance_search_explain/
    @browser.text_field(:name, "search_query").value = "Abacavirum"
    @browser.button(:name, 'search').click
    @browser.text.should_not match LeeresResult
    @browser.text.should match /Deutsche Bezeichnung/
    @browser.text.should match /Abacavir/
  end

  it "should be possible to find the Kantonsspital Glarus via Spital" do
    @browser.link(:name, 'hospitals').click
    # @browser.text.should_not match /substance_search_explain/
    @browser.text_field(:name, "search_query").value = "Glarus"    
    @browser.button(:name, 'search').click
    @browser.text.should_not match LeeresResult
    @browser.text.should match /Abteilung/
    @browser.text.should match /Kantonsspital Glarus/
  end

  it "should be possible to find Krücke via MiGeL" do
    @browser.link(:name, 'migel').click
    # @browser.text.should_not match /substance_search_explain/
    @browser.text_field(:name, "search_query").value = "Krücke"    
    @browser.button(:name, 'search').click
    @browser.text.should_not match LeeresResult
    @browser.text.should match /Beschreibung/
    @browser.text.should match /Krücken/
  end

  it "should be possible to find Novartis via Zulassungsinhaber" do
    @browser.link(:name, 'companies').click
    # @browser.text.should_not match /substance_search_explain/
    @browser.text_field(:name, "search_query").value = "Novartis"    
    @browser.button(:name, 'search').click
    @browser.text.should_not match LeeresResult
    @browser.text.should match /Aktuelle Einträge/
    @browser.text.should match /Novartis Pharma Schweiz AG/
  end

  it "should be possible to find Akute myeloische Leukämie via analysen" do
    @browser.link(:name,'analysis').click
    @browser.text_field(:name, "search_query").value = "Leukämie"
    @browser.button(:name, 'search').click
    # Currently fails. You wee in oddbd HINWEIS:  Textsucheanfrage enthält nur Stoppwörter oder enthält keine Lexeme, ignoriert
    @browser.text.should_not match LeeresResult
    @browser.text.should match /Akute myeloische Leukämie/
  end

if false
  pending "should work with the notify searchbar" do
    false.should == true
  end

  pending "should work with the migel/feedbacks searchbar" do
    false.should == true
  end

  pending "should work with the notify_confirm searchbar" do
    false.should == true
  end

  pending "should work with the drugs/fachinfos searchbar" do
    false.should == true
  end

  pending "should work with the drugs/vaccines searchbar" do
    false.should == true
  end

  pending "should work with the drugs/limitationtexts searchbar" do
    false.should == true
  end

  pending "should work with the drugs/feedbacks searchbar" do
    false.should == true
  end

  pending "should work with the drugs/patinfos searchbar" do
    false.should == true
  end

  pending "should work with the  drugs/sequences searchbar" do
    false.should == true
  end

  pending "should work with the drugs/resultlimit searchbar" do
    false.should == true
  end

  pending "should work with the substances/result searchbar" do
    false.should == true
  end
end
end
