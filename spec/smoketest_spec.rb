#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'

@workThread = nil

describe "ch.oddb.org" do
 
  before :all do
    @idx = 0
    waitForOddbToBeReady(@browser, OddbUrl)
  end
  
  before :each do
    @browser.goto OddbUrl
  end

  after :each do
    @idx += 1
    createScreenshot(@browser, '_'+@idx.to_s)
    # sleep 
    @browser.goto OddbUrl
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
    waitForOddbToBeReady(@browser, OddbUrl)
		logout
    names = [ 'Aspirin', 'inderal', 'Sintrom', 'Incivo', 'Certican', 'Glucose']
    res = false
    saved = @idx
    names.each { 
      |name|
        @idx += 1
				waitForOddbToBeReady(@browser, OddbUrl)
        @browser.text_field(:name, "search_query").set(name)
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
    @browser.text.should match /Search for your favorite drug fast and easy/
  end

  it "should have a link to the french language versions" do
    @browser.goto OddbUrl
    @browser.link(:text=>/Français|French/i).click
    @browser.text.should match /Comparez simplement et rapidement les prix des médicaments/
  end

  it "should have a link to the german language versions" do
    @browser.goto OddbUrl
    @browser.link(:text=>/Deutsch|German/).click
    @browser.text.should match /Vergleichen Sie einfach und schnell Medikamentenpreise./
  end

  it "should open print patinfo in a new window" do
    login
    @browser.goto OddbUrl + '/de/gcc/patinfo/reg/51795/seq/01'
    windowSize = @browser.windows.size
    @browser.link(:text, 'Drucken').click
    @browser.windows.size.should ==windowSize + 1
    @browser.windows.last.use
    @browser.text.should match /^Ausdruck.*Patienteninformation/im
    @browser.windows.last.close
  end

  it "should open print fachinfo in a new window" do
    login
    @browser.goto OddbUrl + '/de/gcc/fachinfo/reg/51795'
    windowSize = @browser.windows.size
    @browser.windows.last.use
    @browser.link(:text, /Drucken/i).click
    @browser.windows.size.should ==windowSize + 1
    @browser.windows.last.use
    @browser.text.should match /^Ausdruck.*Fachinformation/im
    @browser.windows.last.close
  end

  after :all do
    @browser.close
  end
 
end
