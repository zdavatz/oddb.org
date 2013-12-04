#!/usr/bin/env ruby
# encoding: utf-8
require 'watir-webdriver'
require 'page-object'
require 'fileutils'
require 'pp'

ImageDest = File.join(Dir.pwd, 'images')
FileUtils.makedirs(ImageDest, :verbose => true) unless File.exists?(ImageDest)
browsers2test ||= [ ENV['ODDB_BROWSER'] ]
browsers2test ||= [ :firefox ] # could be any combination of :ie, :firefox, :chrome
@workThread = nil

def createScreenshot(browser, added=nil)
  if browser.url.index('?')
    name = File.join(ImageDest, File.basename(browser.url.split('?')[0]))
  else
    name = File.join(ImageDest, browser.url.split('/')[-1])
  end
  name = "#{name}#{added}.png"
  browser.screenshot.save (name)
  puts "createScreenshot: #{name} done" if $VERBOSE
end

describe "ch.oddb.org" do
 
  before :all do
    @idx = 0
    @homeUrl ||= ENV['ODDB_URL']
    @homeUrl ||= "oddb-ci2.dyndns.org"
    @browser = Watir::Browser.new
  end
  
  before :each do
    @browser.goto @homeUrl
  end
  
  after :each do
    @idx += 1
    createScreenshot(@browser, '_'+@idx.to_s)
    # sleep 
    @browser.goto @homeUrl
  end
  
  it "should contain oddb.org" do
    @browser.text.should match /oddb.org/
    @browser.title.should match /oddb.org/i
  end

  it "should not be offline" do
    @browser.text.should_not match /Es tut uns leid/
  end

  it "should have a link to the migel" do
    @browser.link(:text=>'MiGeL').click
    @browser.text.should match /Pflichtleistung/
    @browser.text.should match /Mittel und Gegenst/ # Mittel und Gegenstände
  end
  
  it "should find Aspirin" do
    @browser.text_field(:name, "search_query").set("Aspirin")
    @browser.button(:name, "search").click
    @browser.text.should match /Aspirin 500/
    @browser.text.should match /Aspirin Cardio 100/
    @browser.text.should match /Aspirin Cardio 300/
  end
  
  it "should have a link to the extended search" do
    @browser.link(:text => /erweitert/).click
    @browser.url.should match /gcc\/fachinfo_search/
  end
  
  it "should find inderal" do
    @browser.text_field(:name, "search_query").set("inderal")
    @browser.button(:name, "search").click
    @browser.text.should match /Inderal 10 mg/
    @browser.text.should match /Inderal LA 80/
  end
  
  it "should trigger the limitation after maximal 5 queries" do
    names = [ 'Aspirin', 'inderal', 'Sintrom', 'Incivo', 'Certican', 'Glucose']
    res = false
    saved = @idx
    names.each { 
      |name|
        @idx += 1
        @browser.text_field(:name, "search_query").set("inderal")
        @browser.button(:name, "search").click
        createScreenshot(@browser, '_'+@idx.to_s)
        if /Abfragebeschränkung auf 5 Abfragen pro Tag/.match(@browser.text)
          res = true
          break
        end
    }
    (@idx -saved).should <= 5
  end
  
  it "should have a link to the english language versions" do
    @browser.link(:text=>'English').click
    sleep(1) # or should I use something like b.wait_until {b.text.include? /Search for your favorite drug fast and easy/ }
    @browser.text.should match /Search for your favorite drug fast and easy/
  end
  
  it "should have a link to the french language versions" do
    @browser.link(:text=>'Français').click
    sleep(1)
    @browser.text.should match /Comparez simplement et rapidement les prix des médicaments/
  end

  it "should have a link to the german language versions" do
    @browser.link(:text=>'Deutsch').click
    sleep(1)
    @browser.text.should match /Vergleichen Sie einfach und schnell Medikamentenpreise./
  end

  after :all do
    @browser.close
  end
 
end
x=%(
zum schnell von Hand testen
require 'watir'
@idx = 0
@homeUrl ||= "oddb-ci2.dyndns.org"
@browser = Watir::Browser.new
@browser.goto @homeUrl

class OddMain
  include PageObject
  page_url =  "http://ch.oddb.org/"
  text_field(:username, :id => "user_id")
  text_field(:password, :id => "user_password")
  button(:login, :value => "Login")
end
page = OddMain.new(@homeUrl, true)

in homepage
 @browser.selects[0].text
Preisvergleich
Markenname
Inhaltsstoff
Zulassungsinhaber
Anwendung
Interaktion
Unerwünschte Wirkung
Swissmedic-# (5-stellig)
Pharmacode

@browser.select(:name => /search_type/).select('Interaktion')
@browser.buttons[1].click // geht zu paypal
@browser.buttons[1].click // Ihr Such-Stichwort: "HIER Suchbegriff eingeben" hat ein leeres Resultat ergeben.
@browser.forms[0].submit  // Ihr Such-Stichwort: "HIER Suchbegriff eingeben" hat ein leeres Resultat ergeben.
@browser.forms[0].submit alls Sie noch nicht als Benutzer registriert sind, lesen Sie bitte folge

im erweiterten
@browser.selects[0].text
Kapitel in der Fachinfo wählen
Dos./Anw.
Interakt.
Unerw.Wirkungen
)