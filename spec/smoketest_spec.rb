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

  it "should contain Open Drug Database" do
    waitForOddbToBeReady(@browser, OddbUrl)
    puts OddbUrl
    @browser.url.should match    OddbUrl      unless ['just-medical'].index(Flavor)
    @browser.title.should match /Open Drug Database/i
  end

  it "should not be offline" do
    @browser.text.should_not match /Es tut uns leid/
  end

  it "should have a link to the migel" do
    @browser.link(:text=>'MiGeL').click
    @browser.text.should match /Pflichtleistung/
    @browser.text.should match /Mittel und Gegenst/ # Mittel und Gegenstände
  end unless ['just-medical'].index(Flavor)
  
  it "should find Aspirin" do
    @browser.text_field(:name, "search_query").set("Aspirin")
    @browser.button(:name, "search").click
    @browser.text.should match /Aspirin 500/
    @browser.text.should match /Aspirin Cardio 100/
    @browser.text.should match /Aspirin Cardio 300/
  end

  it "should have a link to the extended search" do
    @browser.link(:text => /erweitert/).click
    @browser.url.should match /#{Flavor}\/fachinfo_search/
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
        waitForOddbToBeReady(@browser, OddbUrl)
        @browser.text_field(:name, "search_query").set(name)
        @browser.button(:name, "search").click
        createScreenshot(@browser, '_'+@idx.to_s)
        if /Abfragebeschränkung auf 5 Abfragen pro Tag/.match(@browser.text)
          res = true
          break
        end
        @idx += 1
    }
    (@idx -saved).should <= 5
  end unless ['just-medical'].index(Flavor)
  
  it "should have a link to the english language versions" do
    @browser.link(:text=>'English').click
    @browser.text.should match /Search for your favorite drug fast and easy/
  end unless ['just-medical'].index(Flavor)

  it "should have a link to the french language versions" do
    @browser.goto OddbUrl
    @browser.link(:text=>/Français|French/i).click
    @browser.text.should match /Comparez simplement et rapidement les prix des médicaments/
  end unless ['just-medical'].index(Flavor)

  it "should have a link to the german language versions" do
    @browser.goto OddbUrl
    @browser.link(:text=>/Deutsch|German/).click
    @browser.text.should match /Vergleichen Sie einfach und schnell Medikamentenpreise./
  end unless ['just-medical'].index(Flavor)

  it "should open print patinfo in a new window" do
    login
    @browser.goto "#{OddbUrl}/de/#{Flavor}/patinfo/reg/51795/seq/01"
    windowSize = @browser.windows.size
    @browser.url.should match OddbUrl
    @browser.link(:text, 'Drucken').click
    @browser.windows.size.should ==windowSize + 1
    @browser.windows.last.use
    @browser.text.should match /^Ausdruck.*Patienteninformation/im
    @browser.url.should match OddbUrl
    @browser.windows.last.close
  end

  it "should open print fachinfo in a new window" do
    login
    @browser.goto "#{OddbUrl}/de/#{Flavor}/fachinfo/reg/51795"
    @browser.url.should match OddbUrl
    windowSize = @browser.windows.size
    @browser.windows.last.use
    @browser.link(:text, /Drucken/i).click
    @browser.windows.size.should ==windowSize + 1
    @browser.windows.last.use
    @browser.text.should match /^Ausdruck.*Fachinformation/im
    @browser.url.should match OddbUrl
    @browser.windows.last.close
  end

  it "should download the example" do
    test_medi = 'Aspirin'
    filesBeforeDownload =  Dir.glob(GlobAllDownloads)
    @browser.goto OddbUrl
    @browser.text_field(:name, "search_query").set(test_medi)
    @browser.button(:name, "search").click
    @browser.link(:text, "Beispiel-Download").click
    @browser.button(:value,"Resultat als CSV Downloaden").click
    filesAfterDownload =  Dir.glob(GlobAllDownloads)
    diffFiles = (filesAfterDownload - filesBeforeDownload)
    diffFiles.size.should == 1
    text = IO.read(diffFiles[0])
    text.should match /EAN-Code/
    text.should match /Inderal/
    IO.readlines(diffFiles[0]).size.should > 5
  end unless ['just-medical'].index(Flavor)

  it "should be possible to subscribe to the mailing list via Services" do
    @browser.link(:name, 'user').click
    @browser.text.should match /Mailing-Liste/
    @browser.link(:name, 'mailinglist').click
    @browser.text_field(:name, 'email').value = 'ngiger@ywesee.com'
    @browser.button(:name, 'subscribe').click
    @browser.button(:name, 'unsubscribe').click
  end if false # Zeno remarked on 2014-09-01 that I should not test the mailing list

  it "should be possible to request a new password" do
    @browser.goto OddbUrl
    @browser.link(:text=>'Abmelden').click if @browser.link(:text=>'Abmelden').exists?
    @browser.link(:text=>'Anmeldung').click
    @browser.link(:name=>'password_lost').click
    @browser.text_field(:name, 'email').value = 'ngiger@ywesee.com'
    @browser.button(:name, 'password_request').click
    url = @browser.url
    text = @browser.text
    url.should_not match /error/i
    text.should match /Bestätigung/
    text.should match /Vielen Dank. Sie erhalten in Kürze ein E-Mail mit weiteren Anweisungen./
  end

  it "should download the results of a search" do
    login
    test_medi = 'Aspirin'
    filesBeforeDownload =  Dir.glob(GlobAllDownloads)
    @browser.goto OddbUrl
    login
    @browser.text_field(:name, "search_query").set(test_medi)
    @browser.button(:name, "search").click
    @browser.button(:value,"Resultat als CSV Downloaden").click
    # require 'pry'; binding.pry
    @browser.button(:name => 'proceed_payment').click
    @browser.button(:name => 'checkout_invoice').click
    @browser.url.should_not match  /errors/
    filesAfterDownload =  Dir.glob(GlobAllDownloads)
    diffFiles = (filesAfterDownload - filesBeforeDownload)
    diffFiles.size.should == 1
  end unless ['just-medical'].index(Flavor)


  after :all do
    @browser.close
  end
end
