#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'
require 'paypal_helper'

@workThread = nil

describe "ch.oddb.org" do

  before :all do
    @idx = 0
    waitForOddbToBeReady(@browser, OddbUrl)
  end
  
  before :each do
    @browser.goto OddbUrl
    login
  end

  after :each do
    @idx += 1
    createScreenshot(@browser, '_'+@idx.to_s)
    logout
  end

  def check_nutriflex_56091(text)
    expect(text).to match /Bezeichnung/i
    expect(text).to match /Galenische Form/i
    expect(text).to match /Excipiens/i
    expect(text).to match /Wirkstoff/i
    expect(text).to match /Isoleucin/i
    expect(text).to match /Hilfsstoff/i
    expect(text).to match /Citratsäure/i
  end

  describe "admin" do
    before :all do
    end
    before :each do
      @browser.goto OddbUrl
      logout
      login(AdminUser, AdminPassword)
    end
    after :all do
      logout
    end
  it "admin should edit package info" do
    @browser.goto "#{OddbUrl}/de/#{Flavor}/drug/reg/56091/seq/02/pack/04"
    windowSize = @browser.windows.size
    expect(@browser.url).to match OddbUrl
    text = @browser.text.clone
    skip 'check_nutriflex_56091 only works with sequence, not with package'
    check_nutriflex_56091(text)
    expect(text).to match /Patinfo aktivieren/i
    expect(text).to match /Braun Medical/i
    expect(text).to match /Nutriflex Lipid/i
    expect(@browser.url).to match OddbUrl
  end

  it "admin should edit sequence info" do
    @browser.goto "#{OddbUrl}/de/#{Flavor}/drug/reg/56091/seq/02"
    windowSize = @browser.windows.size
    expect(@browser.url).to match OddbUrl
    text = @browser.text.clone
    expect(text).to match /Patinfo aktivieren/i
    expect(text).to match /Braun Medical/i
    expect(text).to match /Nutriflex Lipid/i
    expect(text).to match /Wirkstoffe.+Arginin.+Isoleucin/im # correct sort order
    check_nutriflex_56091(text)
    expect(@browser.url).to match OddbUrl
  end

  it "admin should edit registration info" do
    @browser.goto "#{OddbUrl}/de/#{Flavor}/drug/reg/56091"
    windowSize = @browser.windows.size
    expect(@browser.url).to match OddbUrl
    text = @browser.text.clone
    expect(text).to match /Fachinfo-Upload/i
    expect(text).to match /Braun Medical/i
    expect(text).to match /Nutriflex Lipid/i
    expect(@browser.url).to match OddbUrl
  end
  end
  it "should display the correct color iscador U" do
    @browser.select_list(:name, "search_type").select("Markenname")
    @browser.text_field(:name, "search_query").set('iscador U')
    sleep(0.1)
    @browser.button(:name, "search").click
    @browser.element(:id => 'ikscat_1').wait_until_present
    expect(@browser.element(:id => 'ikscat_1').text).to eq 'A / SL'
    expect(@browser.link(:text => 'FI').exists?).to eq true
    expect(@browser.link(:text => 'PI').exists?).to eq true
    expect(@browser.td(:text => 'A').exists?).to eq true
    expect(@browser.td(:text => 'C').exists?).to eq false
    expect(@browser.link(:text => 'FB').exists?).to eq true
    td = @browser.td(:text => /Iscador/i)
    expect(td.style('background-color')).to match /0, 0, 0, 0/
    @browser.element(:id => 'ikscat_1').hover
    res = @browser.element(:text => /Spezialitätenliste/).wait_until_present
    expect(res.class).to eq Watir::HTMLElement
    @browser.text_field(:text => /Medikamentennamen/).exists?
    res = @browser.element(:text => /Spezialitätenliste/).wait_until_present
    @browser.buttons.first.click # Don't know how to close it else
    @browser.back
  end

  it "should display a limitation link for Sevikar" do
    @browser.select_list(:name, "search_type").select("Markenname")
    @browser.text_field(:name, "search_query").set('Sevikar')
    sleep(0.1)
    @browser.button(:name, "search").click
    @browser.element(:id => 'ikscat_1').wait_until_present
    td = @browser.td(:class =>/^list/, :text => /^Sevikar/)
    expect(td.exist?).to eq true
    expect(td.links.size).to eq 1
    expect(@browser.element(:id => 'ikscat_1').text).to eq 'B / SL'
    expect(@browser.link(:text => 'L').exists?).to eq true
    expect(@browser.link(:text => 'L').href).to match /limitation_text\/reg/
    expect(@browser.link(:text => 'FI').exists?).to eq true
    expect(@browser.link(:text => 'PI').exists?).to eq true
    expect(@browser.td(:text => 'A').exists?).to eq false
    expect(@browser.td(:text => 'C').exists?).to eq false
#    @browser.link(:text => '10%').exists?.should eq true
    expect(@browser.link(:text => 'FB').exists?).to eq true
  end

  it "should display lamivudin with SO and SG in category (price comparision)" do
    @browser.select_list(:name, "search_type").select("Preisvergleich")
    @browser.text_field(:name, "search_query").set('lamivudin')
    sleep(0.1)
    @browser.button(:name, "search").click
    @browser.element(:id => 'ikscat_1').wait_until_present
    expect(@browser.tds.find{ |x| x.text.eql?('A / SL / SO')}.exists?).to eq true
    expect(@browser.tds.find{ |x| x.text.eql?('A / SL / SG')}.exists?).to eq true

    # Check link to price history for price publie
    td = @browser.td(:class => /pubprice/)
    expect(td.exist?).to eq true
    expect(td.links.size).to eq 1
    expect(td.links.first.href).to match /\/price_history\//

    # Check link to price history for ex factory price
    td = @browser.td(:class => /list right/, :text => /\d+\.\d+/)
    expect(td.exist?).to eq true
    expect(td.links.size).to eq 1
    expect(td.links.first.href).to match /\/price_history\//
  end

  it "should show a registration info" do
    @browser.goto "#{OddbUrl}/de/#{Flavor}/show/reg/56091"
    windowSize = @browser.windows.size
    expect(@browser.url).to match OddbUrl
    text = @browser.text.clone
    expect(text).to match /Braun Medical/i
    expect(text).to match /Nutriflex Lipid/i
    expect(@browser.url).to match OddbUrl
  end

  it "should show a sequence info" do
    @browser.goto "#{OddbUrl}/de/#{Flavor}/show/reg/56091/seq/02"
    windowSize = @browser.windows.size
    expect(@browser.url).to match OddbUrl
    check_nutriflex_56091(@browser.text.clone)
    expect(@browser.url).to match OddbUrl
  end

  it "should show a package info" do
    @browser.goto "#{OddbUrl}/de/#{Flavor}/show/reg/56091/seq/02/pack/04"
    windowSize = @browser.windows.size
    expect(@browser.url).to match OddbUrl
    check_nutriflex_56091(@browser.text.clone)
    expect(@browser.url).to match OddbUrl
  end

  it "should contain Open Drug Database" do
    waitForOddbToBeReady(@browser, OddbUrl)
    expect(@browser.url).to match    OddbUrl      unless ['just-medical'].index(Flavor)
    expect(@browser.title).to match /Open Drug Database/i
  end

  it "should not be offline" do
    expect(@browser.text).not_to match /Es tut uns leid/
  end

  it "should have a link to the migel" do
    @browser.link(:text=>'MiGeL').click
    @browser.link(:name => 'migel_alphabetical').wait_until_present
    expect(@browser.text).to match /Pflichtleistung/
    expect(@browser.text).to match /Mittel und Gegenst/ # Mittel und Gegenstände
  end unless ['just-medical'].index(Flavor)

  it "should find Aspirin" do
    @browser.text_field(:name, "search_query").set("Aspirin")
    @browser.button(:name, "search").click; small_delay
    expect(@browser.text).to match /Aspirin 500|ASS Cardio Actavis 100 mg|Aspirin Cardio 300/
  end

  it "should have a link to the extended search" do
    @browser.link(:text => /erweitert/).click; small_delay
    expect(@browser.url).to match /#{Flavor}\/fachinfo_search/
  end
  
  it "should find inderal" do
    @browser.text_field(:name, "search_query").set("inderal")
    @browser.button(:name, "search").click; sleep(1)
    expect(@browser.text).to match /Inderal 10 mg/
    expect(@browser.text).to match /Inderal 40 mg/
  end

  it "should trigger the limitation after maximal 5 queries" do
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
    expect(@idx -saved).to be <= 6
  end unless ['just-medical'].index(Flavor)

  it "should have a link to the english language versions" do
    english = @browser.link(:text=>'English')
    english.wait_until_present
    english.click
    @browser.button(:name, "search").wait_until_present
    expect(@browser.text).to match /Search for your favorite drug fast and easy/
  end unless ['just-medical'].index(Flavor)

  it "should have a link to the french language versions" do
    @browser.link(:text=>/Français|French/i).click; small_delay
    expect(@browser.text).to match /Comparez simplement et rapidement les prix des médicaments/
  end unless ['just-medical'].index(Flavor)

  it "should have a link to the german language versions" do
    @browser.link(:text=>/Deutsch|German/).click; small_delay
    expect(@browser.text).to match /Vergleichen Sie einfach und schnell Medikamentenpreise./
  end unless ['just-medical'].index(Flavor)

  it "should open print patinfo in a new window" do
    @browser.goto "#{OddbUrl}/de/#{Flavor}/patinfo/reg/51795/seq/01"; small_delay
    windowSize = @browser.windows.size
    expect(@browser.url).to match OddbUrl
    @browser.link(:text, 'Drucken').click; small_delay
    expect(@browser.windows.size).to eq(windowSize + 1)
    @browser.windows.last.use
    sleep(0.5)
    expect(@browser.text).to match /^Ausdruck.*Patienteninformation/im
    expect(@browser.url).to match OddbUrl
    @browser.windows.last.close
  end

  it "should open a sequence specific patinfo" do # 15219 Zymafluor
    @browser.goto "#{OddbUrl}/de/#{Flavor}/show/reg/15219"; small_delay
    expect(@browser.link(:text => 'PI').exist?).to eq true
    @browser.link(:text => 'PI').click; small_delay
    expect(@browser.url).to match /patinfo/i
  end

  it "should open a package specific patinfo" do # 43788 Tramal
    @browser.goto "#{OddbUrl}/de/#{Flavor}/show/reg/43788/seq/01/pack/019"; small_delay
    expect(@browser.link(:text => 'PI').exist?).to eq true
    @browser.link(:text => 'PI').click; small_delay
    # As this opens a new window we must focus on it
    @browser.windows.last.use if @browser.windows.size > 1
    expect(@browser.url).to match /patinfo/i
    expect(@browser.text).not_to match /Die von Ihnen gewünschte Information ist leider nicht mehr vorhanden./
    @browser.windows.last.close if @browser.windows.size > 1
  end

  it "should show correct Tramal Tropfen Lösung zum Einnehmen mit Dosierpumpe (4788/01/035)" do
    @browser.goto "#{OddbUrl}/de/#{Flavor}/show/reg/43788/seq/01/pack/035"; small_delay
    expect(@browser.link(:text => 'PI').exist?).to eq true
    @browser.link(:text => 'PI').click; small_delay
    expect(@browser.url).to match /patinfo/i
    text = @browser.text.clone
    expect(text).to match /Was sind Tramal Tropfen Lösung zum Einnehmen und wann werden sie angewendet/
    expect(text).not_to match /Tramal Tropfen Lösung zum Einnehmen mit Dosierpumpe/
  end

  it "should show correct Tramal Tropfen Lösung zum Einnehmen ohne Dosierpumpe(4788/01/086)" do
    @browser.goto "#{OddbUrl}/de/#{Flavor}/show/reg/43788/seq/01/pack/086"; small_delay
    expect(@browser.link(:text => 'PI').exist?).to eq true
    @browser.link(:text => 'PI').click; small_delay
    expect(@browser.url).to match /patinfo/i
    text = @browser.text.clone
    expect(text).to match /Tramal Tropfen Lösung zum Einnehmen mit Dosierpumpe/
    expect(text).not_to match /Was sind Tramal Tropfen Lösung zum Einnehmen und wann werden sie angewendet/
  end

  it "should open print fachinfo in a new window" do
    @browser.goto "#{OddbUrl}/de/#{Flavor}/fachinfo/reg/51795"; small_delay
    expect(@browser.url).to match OddbUrl
    windowSize = @browser.windows.size
    @browser.windows.last.use
    @browser.link(:text, /Drucken/i).wait_until_present
    @browser.link(:text, /Drucken/i).click;
    small_delay unless @browser.windows.size == windowSize + 1
    expect(@browser.windows.size).to eq(windowSize + 1)
    @browser.windows.last.use
    sleep(1)
    expect(@browser.text).to match /^Ausdruck.*Fachinformation/im
    expect(@browser.url).to match OddbUrl
    @browser.windows.last.close
  end

  it "should download the example" do
    test_medi = 'Aspirin'
    filesBeforeDownload =  Dir.glob(GlobAllDownloads)
    @browser.text_field(:name, "search_query").set(test_medi)
    @browser.button(:name, "search").click; small_delay
    @browser.link(:text, "Beispiel-Download").click; small_delay
    @browser.button(:value,"Resultat als CSV Downloaden").click; small_delay
    filesAfterDownload =  Dir.glob(GlobAllDownloads)
    diffFiles = (filesAfterDownload - filesBeforeDownload)
    expect(diffFiles.size).to eq(1)
    text = IO.read(diffFiles[0])
    expect(text).to match /EAN-Code/
    expect(text).to match /Inderal/
    expect(IO.readlines(diffFiles[0]).size).to be > 5
  end unless ['just-medical'].index(Flavor)

  it "should be possible to subscribe to the mailing list via Services" do
    @browser.link(:name, 'user').click; small_delay
    expect(@browser.text).to match /Mailing-Liste/
    @browser.link(:name, 'mailinglist').click; small_delay
    @browser.text_field(:name, 'email').value = 'ngiger@ywesee.com'
    @browser.button(:name, 'subscribe').click; small_delay
    @browser.button(:name, 'unsubscribe').click; small_delay
  end if false # Zeno remarked on 2014-09-01 that I should not test the mailing list

  it "should be possible to request a new password" do
    @browser.link(:text=>'Abmelden').click if @browser.link(:text=>'Abmelden').exists?
    small_delay
    @browser.link(:text=>'Anmeldung').click; small_delay
    @browser.link(:name=>'password_lost').click
    @browser.text_field(:name, 'email').set 'ngiger@ywesee.com'
    @browser.button(:name, 'password_request').click; small_delay
    url = @browser.url
    text = @browser.text
    expect(url).not_to match /error/i
    expect(text).to match /Bestätigung/
    expect(text).to match /Vielen Dank. Sie erhalten in Kürze ein E-Mail mit weiteren Anweisungen./
  end

  it "should download the results of a search" do
    test_medi = 'Aspirin'
    filesBeforeDownload =  Dir.glob(GlobAllDownloads)
    @browser.text_field(:name, "search_query").set(test_medi)
    @browser.button(:name, "search").click; small_delay
    @browser.button(:value,"Resultat als CSV Downloaden").click; small_delay
    @browser.text_field(:name => /name_last/i).value= "Mustermann"; small_delay
    @browser.text_field(:name => /name_first/i).value= "Max"; small_delay
    paypal_user = PaypalUser.new
    @browser.button(:name => PaypalUser::CheckoutName).click; small_delay
    expect(paypal_user.paypal_buy(@browser)).to eql true
    expect(@browser.url).not_to match  /errors/
    @browser.link(:name => 'download').wait_until_present
    @browser.link(:name => 'download').click
    sleep(1) # Downloading might take some time
    filesAfterDownload =  Dir.glob(GlobAllDownloads)
    diffFiles = (filesAfterDownload - filesBeforeDownload)
    expect(diffFiles.size).to eq(1)
  end unless ['just-medical'].index(Flavor)

  def check_search_with_type
    query =  @browser.text_field(:name, "search_query")
    expect(query.exists?).to eq true
    search_type = @browser.select_list(:name, "search_type")
    expect(search_type.exists?).to eq true
  end

  it "should display search and search_type for fachinfo diff of 28.11.2015" do
    diff_url = "/show/fachinfo/#{SNAP_IKSNR}/diff/28.11.2015"
    @browser.goto(OddbUrl + '/de/gcc' + diff_url)
    check_search_with_type
  end

  it "should display search and search_type for fachinfo diff" do
    diff_url = "/show/fachinfo/#{SNAP_IKSNR}/diff"
    @browser.goto(OddbUrl + '/de/gcc' + diff_url)
    check_search_with_type
    link =  @browser.link(:name, "change_log")
    expect(link.exists?).to eq true
    link.click
    check_search_with_type
  end

  after :all do
    @browser.close
  end
end
