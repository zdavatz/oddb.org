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

  def check_nutriflex_56091(text)
    text.should match /Bezeichnung/i
    text.should match /Galenische Form/i
    text.should match /Excipiens/i
    text.should match /Wirkstoff/i
    text.should match /Isoleucin/i
    text.should match /Hilfsstoff/i
    text.should match /Citratsäure/i
  end

  it "admin should edit package info" do
    login
    @browser.goto "#{OddbUrl}/de/#{Flavor}/drug/reg/56091/seq/02/pack/04"
    windowSize = @browser.windows.size
    @browser.url.should match OddbUrl
    text = @browser.text.clone
    check_nutriflex_56091(text)
    text.should match /Patinfo aktivieren/i
    text.should match /Braun Medical/i
    text.should match /Nutriflex Lipid/i
    @browser.url.should match OddbUrl
  end

if true
  it "admin should edit sequence info" do
    login
    @browser.goto "#{OddbUrl}/de/#{Flavor}/drug/reg/56091/seq/02"
    windowSize = @browser.windows.size
    @browser.url.should match OddbUrl
    text = @browser.text.clone
    check_nutriflex_56091(text)
    text.should match /Patinfo aktivieren/i
    text.should match /Braun Medical/i
    text.should match /Nutriflex Lipid/i
    @browser.url.should match OddbUrl
  end

  it "admin should edit registration info" do
    login
    @browser.goto "#{OddbUrl}/de/#{Flavor}/drug/reg/56091"
    windowSize = @browser.windows.size
    @browser.url.should match OddbUrl
    text = @browser.text.clone
    text.should match /Fachinfo-Upload/i
    text.should match /Braun Medical/i
    text.should match /Nutriflex Lipid/i
    @browser.url.should match OddbUrl
  end

  it "should show a registration info" do
    login
    @browser.goto "#{OddbUrl}/de/#{Flavor}/show/reg/56091"
    windowSize = @browser.windows.size
    @browser.url.should match OddbUrl
    text = @browser.text.clone
    text.should match /Braun Medical/i
    text.should match /Nutriflex Lipid/i
    @browser.url.should match OddbUrl
  end

  it "should show a sequence info" do
    login
    @browser.goto "#{OddbUrl}/de/#{Flavor}/show/reg/56091/seq/02"
    windowSize = @browser.windows.size
    @browser.url.should match OddbUrl
    check_nutriflex_56091(@browser.text.clone)
    @browser.url.should match OddbUrl
  end

  it "should show a package info" do
    login
    @browser.goto "#{OddbUrl}/de/#{Flavor}/show/reg/56091/seq/02/pack/04"
    windowSize = @browser.windows.size
    @browser.url.should match OddbUrl
    check_nutriflex_56091(@browser.text.clone)
    @browser.url.should match OddbUrl
  end

  it "should contain Open Drug Database" do
    waitForOddbToBeReady(@browser, OddbUrl)
    @browser.url.should match    OddbUrl      unless ['just-medical'].index(Flavor)
    @browser.title.should match /Open Drug Database/i
  end

  it "should not be offline" do
    @browser.text.should_not match /Es tut uns leid/
  end

  it "should have a link to the migel" do
    @browser.link(:text=>'MiGeL').when_present.click
    @browser.link(:name => 'migel_alphabetical').wait_until_present
    @browser.text.should match /Pflichtleistung/
    @browser.text.should match /Mittel und Gegenst/ # Mittel und Gegenstände
  end unless ['just-medical'].index(Flavor)

  it "should find Aspirin" do
    @browser.text_field(:name, "search_query").when_present.set("Aspirin")
    @browser.button(:name, "search").click; small_delay
    @browser.text.should match /Aspirin 500|ASS Cardio Actavis 100 mg|Aspirin Cardio 300/
  end

  it "should have a link to the extended search" do
    @browser.link(:text => /erweitert/).when_present.click; small_delay
    @browser.url.should match /#{Flavor}\/fachinfo_search/
  end
  
  it "should find inderal" do
    @browser.text_field(:name, "search_query").when_present.set("inderal")
    @browser.button(:name, "search").when_present.click; sleep(1)
    @browser.text.should match /Inderal 10 mg/
    @browser.text.should match /Inderal 40 mg/
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
        @browser.button(:name, "search").click; small_delay
        createScreenshot(@browser, '_'+@idx.to_s)
        if /Abfragebeschränkung auf 5 Abfragen pro Tag/.match(@browser.text)
          res = true
          break
        end
        @idx += 1
    }
    (@idx -saved).should <= 6
  end unless ['just-medical'].index(Flavor)

  it "should have a link to the english language versions" do
    @browser.link(:text=>'English').when_present.click
    small_delay
    @browser.button(:name, "search").wait_until_present
    @browser.text.should match /Search for your favorite drug fast and easy/
  end unless ['just-medical'].index(Flavor)

  it "should have a link to the french language versions" do
    @browser.goto OddbUrl
    @browser.link(:text=>/Français|French/i).when_present.click; small_delay
    @browser.text.should match /Comparez simplement et rapidement les prix des médicaments/
  end unless ['just-medical'].index(Flavor)

  it "should have a link to the german language versions" do
    @browser.goto OddbUrl
    @browser.link(:text=>/Deutsch|German/).when_present.click; small_delay
    @browser.text.should match /Vergleichen Sie einfach und schnell Medikamentenpreise./
  end unless ['just-medical'].index(Flavor)

  it "should open print patinfo in a new window" do
    login
    @browser.goto "#{OddbUrl}/de/#{Flavor}/patinfo/reg/51795/seq/01"; small_delay
    windowSize = @browser.windows.size
    @browser.url.should match OddbUrl
    @browser.link(:text, 'Drucken').click; small_delay
    @browser.windows.size.should ==windowSize + 1
    @browser.windows.last.use
    sleep(0.5)
    @browser.text.should match /^Ausdruck.*Patienteninformation/im
    @browser.url.should match OddbUrl
    @browser.windows.last.close
  end

  it "should open print fachinfo in a new window" do
    login
    @browser.goto "#{OddbUrl}/de/#{Flavor}/fachinfo/reg/51795"; small_delay
    @browser.url.should match OddbUrl
    windowSize = @browser.windows.size
    @browser.windows.last.use
    @browser.link(:text, /Drucken/i).click; small_delay
    @browser.windows.size.should == windowSize + 1
    @browser.windows.last.use
    sleep(1)
    @browser.text.should match /^Ausdruck.*Fachinformation/im
    @browser.url.should match OddbUrl
    @browser.windows.last.close
  end

  it "should download the example" do
    test_medi = 'Aspirin'
    filesBeforeDownload =  Dir.glob(GlobAllDownloads)
    @browser.goto OddbUrl
    @browser.text_field(:name, "search_query").set(test_medi)
    @browser.button(:name, "search").click; small_delay
    @browser.link(:text, "Beispiel-Download").click; small_delay
    @browser.button(:value,"Resultat als CSV Downloaden").click; small_delay
    filesAfterDownload =  Dir.glob(GlobAllDownloads)
    diffFiles = (filesAfterDownload - filesBeforeDownload)
    diffFiles.size.should == 1
    text = IO.read(diffFiles[0])
    text.should match /EAN-Code/
    text.should match /Inderal/
    IO.readlines(diffFiles[0]).size.should > 5
  end unless ['just-medical'].index(Flavor)

  it "should be possible to subscribe to the mailing list via Services" do
    @browser.link(:name, 'user').click; small_delay
    @browser.text.should match /Mailing-Liste/
    @browser.link(:name, 'mailinglist').click; small_delay
    @browser.text_field(:name, 'email').value = 'ngiger@ywesee.com'
    @browser.button(:name, 'subscribe').click; small_delay
    @browser.button(:name, 'unsubscribe').click; small_delay
  end if false # Zeno remarked on 2014-09-01 that I should not test the mailing list

  it "should be possible to request a new password" do
    @browser.goto OddbUrl
    @browser.link(:text=>'Abmelden').click if @browser.link(:text=>'Abmelden').exists?
    small_delay
    @browser.link(:text=>'Anmeldung').when_present.click; small_delay
    @browser.link(:name=>'password_lost').when_present.click
    @browser.text_field(:name, 'email').when_present.set 'ngiger@ywesee.com'
    @browser.button(:name, 'password_request').when_present.click; small_delay
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
    @browser.button(:name, "search").click; small_delay
    @browser.button(:value,"Resultat als CSV Downloaden").click; small_delay
    # require 'pry'; binding.pry
    @browser.button(:name => 'proceed_payment').click; small_delay
    @browser.button(:name => 'checkout_invoice').click; small_delay
    @browser.url.should_not match  /errors/
    sleep(1)
    filesAfterDownload =  Dir.glob(GlobAllDownloads)
    diffFiles = (filesAfterDownload - filesBeforeDownload)
    diffFiles.size.should == 1
  end unless ['just-medical'].index(Flavor)
end
  after :all do
    @browser.close
  end
end
