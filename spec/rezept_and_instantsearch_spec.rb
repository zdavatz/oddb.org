#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'
require 'pp'
require 'tmpdir'
require "selenium-webdriver"

describe "ch.oddb.org" do
  Four_Medis = [ 'Losartan', 'Nolvadex', 'Paroxetin', 'Aspirin']
  QrCodeError = /Error generating QRCode/i
  DrMeier     = /Dr. med. Werner Meier/
  AddToSpan   = "\t"

  def rezeptUrl
    "#{OddbUrl}/de/#{Flavor}/rezept"
  end

  def add_one_drug_to_rezept(name)
    @browser.url.should match(/#{OddbUrl}/i)
    idx = -2
    chooser = @browser.text_field(:id, 'prescription_searchbar')
    0.upto(5).each{ 
      |idx|
      break if chooser and chooser.present?
      sleep 1
      chooser = @browser.text_field(:id, 'prescription_searchbar')
    }
    unless @browser.element(:id => "prescription_searchbar").present?
      binding.pry if BreakIntoPry
    end
    unless chooser and chooser.present?
      msg = "idx #{idx} could not find textfield prescription_searchbar in #{@browser.url}"
      puts msg
      binding.pry if BreakIntoPry
      raise msg
    end
    0.upto(30).each{ |idx|
                      begin
                        chooser.set(name)
                        sleep idx*0.1
                        chooser.send_keys(:down)
                        sleep idx*0.1
                        chooser.send_keys(:enter)
                        sleep idx*0.1
                        value = chooser.value
                        break unless /#{name}/.match(value)
                        sleep 0.5
                      rescue StandardError => e
                        puts "in rescue"
                        createScreenshot(@browser, "rescue_#{name}_#{__LINE__}")
                        puts e.inspect
                        puts caller[0..5]
                        return
                      end
                    }
    chooser.set(chooser.value + "\n")
    createScreenshot(@browser, "_#{name}_#{__LINE__}")
    puts "\nFailed to add_one_drug_to_rezept #{name}:  #{@browser.url}" unless @browser.text.match(/#{name}/i)
    unless /#{name}/i.match(@browser.text)
#      binding.pry if BreakIntoPry
    end
    @browser.text.should match(/#{name}/i)
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
    if @browser.link(:text=>'Plus').exists?
      puts "Going from instant to plus"
      @browser.link(:text=>'Plus').click
    end
  end

  after :each do
    createScreenshot(@browser, '_'+$prescription_test_id.to_s) if @browser
    $prescription_test_id += 1
  end

  after :all do
    @browser.close
  end

  def getTextFieldInAsafeWay(field_name)
    elem = @browser.element(:id, field_name)
    unless elem and elem.present?
      createScreenshot(@browser, "_no_#{field_name}_#{__LINE__}")
      binding.pry if BreakIntoPry
      sleep 10
      exit 3
    end
    @browser.text_field(:id => field_name)
  end
  def genComment(unique)
    "Kommentar #{@timestamp} #{unique}"
  end
  FirstName = 'Max'
  FamilyName = 'Müller'
  Birthday = '31.12.1990'
  def setGeneralInfo(nrMedis=0)
    @browser.url.should match(/#{OddbUrl}/i)
    # we often must send tabs or running the test a first time will fail if you have just restarted oddb.org
    unless @browser.radio(:name => "prescription_sex").present?
      binding.pry if BreakIntoPry
    end
    @browser.radio(:name => "prescription_sex", :value => "2").click # Set M for männlich
    @browser.send_keys :tab
    @browser.text_field(:name => 'prescription_first_name').set FirstName
      # binding.pry if BreakIntoPry
    @browser.text_field(:name => 'prescription_family_name').set FamilyName
    @browser.send_keys :tab
    @browser.text_field(:name => 'prescription_birth_day').set Birthday
    @browser.send_keys :tab
    0.upto(nrMedis-1) {
      |idx|
      field_name = "prescription_comment_#{idx}"
      getTextFieldInAsafeWay(field_name).set genComment(Four_Medis[idx])
      @browser.send_keys :tab
      getTextFieldInAsafeWay(field_name).value.should eql genComment(Four_Medis[idx]) + AddToSpan
    }
  end

  def set_zsr_of_doctor(zsr_id, name)
    nrTries = 0
    @browser.text_field(:name => 'prescription_zsr_id').set zsr_id
    while nrTries < 5 and not @browser.text.index(name)
      small_delay
      nrTries += 1
      text = @browser.text_field(:name => 'prescription_zsr_id').value
      @browser.send_keys :down
      btext1 = @browser.text.clone
      nrWaits = 0
      while nrWaits < 100
        nrWaits += 1
        sleep(0.1)
        break if @browser.text.index(name)
      end
      if @browser.text.index(name)
          puts "Looks okay after #{nrTries} nrTries nrWaits #{nrWaits}. text is #{text} index #{@browser.text.index(name)}"
          break
      end
    end
    corrected = zsr_id.gsub(/[ \.]/, '');
  end

  def checkGeneralInfo(nrMedis=0)
    if @browser.url.index('/print/rezept/')
      inhalt = @browser.text
      inhalt.should_not match QrCodeError
      [FirstName, FamilyName, Birthday, " m\n"].each {
        |what|
        if inhalt.index(what).class == NilClass
          puts "Could not find #{what} in #{inhalt}"
          # binding.pry if BreakIntoPry
        end
        inhalt.index(what).class.should_not == NilClass
      }
      0.upto(nrMedis-1) {
        |idx|
          field_name = "prescription_comment_#{idx}"
          comment = genComment(Four_Medis[idx])
          span_value = @browser.span(:id => field_name).value
          unless span_value == comment
            puts "span_value #{span_value} !=  #{comment} in element with id #{field_name}. nrMedis was #{nrMedis}"
            # binding.pry if BreakIntoPry
          end
          span_value.should eql comment + AddToSpan
      }
    else
      @browser.text_field(:name => 'prescription_first_name').value.index(FirstName).should == 0
      @browser.text_field(:name => 'prescription_family_name').value.index(FamilyName).should == 0
      @browser.text_field(:name => 'prescription_birth_day').value.index(Birthday).should == 0
      @browser.radio(:name => "prescription_sex").value.should_not be nil

      0.upto(nrMedis-1) {
        |idx|
      if getTextFieldInAsafeWay("prescription_comment_#{idx}").value != genComment(Four_Medis[idx])
          binding.pry if BreakIntoPry
      end
          getTextFieldInAsafeWay("prescription_comment_#{idx}").value.index(genComment(Four_Medis[idx])).should == 0
      }
    end
  end

  def showElapsedTime(startTime, comment = caller[0])
    duration = (Time.now - startTime).to_i
    puts "#{comment} took #{duration} seconds"
  end

  def waitForPrintInfo(maxSeconds = 120)
    # now wait should ever be necessary!
    startTime = Time.now
    oldSize = @browser.text.size
    while @browser.text.size < 100
      sleep(1)
      break if Time.now - startTime > maxSeconds
    end
    sleep(1)
  end

  def clickDeleteAll
    @browser.element(:text,  "Alle löschen").click; small_delay
  end

  def clickSearch
    small_delay; @browser.button(:name, "search").click
  end

  def clickRezeptErstellen
    small_delay; @browser.link(:href, /rezept/).click; small_delay
  end

if true
  pending 'should not throw a an error with a problematic combination of drugs' do
    puts "Pending fix for https://github.com/davidshimjs/qrcodejs/issues/26"
    # see https://github.com/davidshimjs/qrcodejs/issues/26
    @browser.goto("#{OddbUrl}/de/#{Flavor}/rezept/ean/7680516801112,7680576730063?")
    oldWindowsSize = @browser.windows.size
    clickDeleteAll
    @browser.button(:name, "print").click; small_delay
    @browser.windows.size.should == oldWindowsSize + 1 # must open a new window
    @browser.windows.last.use
    waitForPrintInfo
    inhalt = @browser.text
    inhalt.should_not match QrCodeError
    inhalt.should_not match /Bemerkungen/
    inhalt.should     match(/Ausdruck/i)
    ['Ausdruck',
     'Stempel, Unterschrift',
     'Merfen', 'Aspirin',
     '7680516801112', '7680576730063?',
     / m$/, # männlich
    ].each do
      |name|
      inhalt.should match(name)
    end
  end
  it 'should be possible to add drugs after delete_all when neither ZSR nor comment given' do
    @browser.goto(rezeptUrl)
    # @browser.text.should_not match DrMeier
    nrMedisToCheck = 0
    add_one_drug_to_rezept(Four_Medis[0])
    add_one_drug_to_rezept(Four_Medis[1])
    @browser.text.should match Four_Medis[0]
    @browser.text.should match Four_Medis[1]
    oldWindowsSize = @browser.windows.size
    clickDeleteAll
    @browser.text.should_not match Four_Medis[0]
    @browser.text.should_not match Four_Medis[1]
    add_one_drug_to_rezept(Four_Medis[0])
    add_one_drug_to_rezept(Four_Medis[1])
    @browser.text.should match Four_Medis[0]
    @browser.text.should match Four_Medis[1]
  end

  it 'should be possible to add drugs after delete_all when ZSR is given but no comment' do
    @browser.goto(rezeptUrl)
    @browser.text.should_not match DrMeier
    nrMedisToCheck = 0
    set_zsr_of_doctor('P006309', 'Meier')
    add_one_drug_to_rezept(Four_Medis[0])
    add_one_drug_to_rezept(Four_Medis[1])
    @browser.text.should match Four_Medis[0]
    @browser.text.should match Four_Medis[1]
    oldWindowsSize = @browser.windows.size
    clickDeleteAll
    @browser.text.should_not match Four_Medis[0]
    @browser.text.should_not match Four_Medis[1]
    add_one_drug_to_rezept(Four_Medis[0])
    add_one_drug_to_rezept(Four_Medis[1])
    @browser.text.should match Four_Medis[0]
    @browser.text.should match Four_Medis[1]
    @browser.text.should match DrMeier
  end

  it 'should be possible to add drugs after delete_all when no ZSR is given but a comment' do
    @browser.goto(rezeptUrl)
#    @browser.text.should_not match DrMeier
    nrMedisToCheck = 0
    add_one_drug_to_rezept(Four_Medis[0])
    add_one_drug_to_rezept(Four_Medis[1])
    @browser.text.should match Four_Medis[0]
    @browser.text.should match Four_Medis[1]
    setGeneralInfo(nrMedisToCheck)
    checkGeneralInfo(nrMedisToCheck)
    oldWindowsSize = @browser.windows.size
    clickDeleteAll
    @browser.text.should_not match Four_Medis[0]
    @browser.text.should_not match Four_Medis[1]
    add_one_drug_to_rezept(Four_Medis[0])
    add_one_drug_to_rezept(Four_Medis[1])
    @browser.text.should match Four_Medis[0]
    @browser.text.should match Four_Medis[1]
  end

  it 'should be possible to add drugs after delete_all when ZSR and comment given' do
    @browser.goto(rezeptUrl)
    nrMedisToCheck = 1
#    @browser.text.should_not match DrMeier
    add_one_drug_to_rezept(Four_Medis[0])
    add_one_drug_to_rezept(Four_Medis[1])
    set_zsr_of_doctor('P006309', 'Meier')
    setGeneralInfo(nrMedisToCheck)
    checkGeneralInfo(nrMedisToCheck)
    oldWindowsSize = @browser.windows.size
    clickDeleteAll
    @browser.text.should_not match Four_Medis[0]
    @browser.text.should_not match Four_Medis[1]
    add_one_drug_to_rezept(Four_Medis[0])
    setGeneralInfo(nrMedisToCheck)
    add_one_drug_to_rezept(Four_Medis[1])
    checkGeneralInfo(nrMedisToCheck)
    @browser.text.should match Four_Medis[0]
    @browser.text.should match Four_Medis[1]
  end

  it "should possible to add first medicament by trademark search, then using instant" do
    nrMedisToCheck = 1
    @browser.goto OddbUrl
    @browser.select_list(:name, "search_type").select("Markenname")
    @browser.text_field(:name, "search_query").set(Four_Medis[0])
    clickSearch
    clickRezeptErstellen
    set_zsr_of_doctor('P006309', 'Meier')
    setGeneralInfo(nrMedisToCheck)
    add_one_drug_to_rezept(Four_Medis[1])
    checkGeneralInfo(nrMedisToCheck)
    @browser.text.should match DrMeier
    oldWindowsSize = @browser.windows.size
    @browser.button(:name, "print").click;  small_delay

    @browser.windows.size.should == oldWindowsSize + 1 # must open a new window
    @browser.windows.last.use
    waitForPrintInfo
    @browser.text.should match DrMeier
    @browser.text.should match /ZSR P006309/i
    @browser.text.should match /EAN 7601000223449/i
    checkGeneralInfo(nrMedisToCheck)
  end
end
  it "after a delete_all it must be possible to add drugs" do
    nrMedisToCheck = 1
    @browser.goto OddbUrl
    @browser.select_list(:name, "search_type").select("Markenname")
    @browser.text_field(:name, "search_query").set(Four_Medis[0])
    clickSearch
    clickRezeptErstellen
    set_zsr_of_doctor('P006309', 'Meier')
    setGeneralInfo(nrMedisToCheck)
    add_one_drug_to_rezept(Four_Medis[1])
    checkGeneralInfo(nrMedisToCheck )
    @browser.text.should match DrMeier
    @browser.link(:id => /delete/i).click;  small_delay
    checkGeneralInfo(0)
    add_one_drug_to_rezept(Four_Medis[0])
    checkGeneralInfo(0)
    @browser.text.should match DrMeier
  end
if true
  it "should print a correct prescription with comments, personal information, doctor info and a drug" do
    @browser.goto OddbUrl
    @browser.select_list(:name, "search_type").select("Markenname")
    @browser.text_field(:name, "search_query").set(Four_Medis.first)
    clickSearch
    clickRezeptErstellen
    @browser.link(:id => /delete/i).click;  small_delay
    add_one_drug_to_rezept(Four_Medis[0])
    setGeneralInfo(1)
    set_zsr_of_doctor('J 0390.19', 'Davatz')
    oldText = @browser.text
    res = oldText.match(/Dr. med. Ursula Davatz/)
    @browser.text.should match /Dr. med. Ursula Davatz/
    set_zsr_of_doctor('P006309', 'Meier')
    @browser.text.should match DrMeier
    oldWindowsSize = @browser.windows.size
    @browser.button(:name, "print").click;  small_delay
    @browser.windows.size.should == oldWindowsSize + 1 # must open a new window
    @browser.windows.last.use
    waitForPrintInfo
    @browser.text.should match DrMeier
    @browser.text.should match /ZSR P006309/i
    @browser.text.should match /EAN 7601000223449/i
  end

  it "should contain remarks or interaction header only when present" do
    @browser.goto("#{OddbUrl}/de/#{Flavor}/rezept/ean")
    add_one_drug_to_rezept('Aspirin')
    add_one_drug_to_rezept('Inderal')
    add_one_drug_to_rezept('Marcoumar')

    # add two remarks
    setGeneralInfo(2)
    oldWindowsSize = @browser.windows.size
    @browser.button(:name, "print").click;  small_delay
    @browser.windows.size.should == oldWindowsSize + 1 # must open a new window
    @browser.windows.last.use
    waitForPrintInfo
    inhalt = @browser.text
    checkGeneralInfo(2)
    inhalt.scan(/\nBemerkungen\n/).size.should == 2
    inhalt.scan(/\nBemerkungen\n/).size.should == 2
    inhalt.scan(/\nInteraktionen\n/).size.should == 2
  end

  it "should print the fachinfo when opening the fachinfo from a prescription" do
    @browser.select_list(:name, "search_type").select("Markenname")
    @browser.text_field(:name, "search_query").set(Four_Medis.first)
    clickSearch
    clickRezeptErstellen
    setGeneralInfo(1)
    @browser.element(:text, 'FI').click;  small_delay
    oldWindowsSize = @browser.windows.size
    @browser.link(:text, /FI/).click; sleep(1)
    @browser.windows.size.should == oldWindowsSize + 1 # must open a new window
    @browser.windows.last.use
    oldWindowsSize = @browser.windows.size
    @browser.link(:text, /Drucken/i).click;  small_delay
    @browser.windows.size.should == oldWindowsSize + 1 # must open a new window
    @browser.windows.last.use
    @browser.url.should_not match /^rezept/i
    @browser.text.should match /^Ausdruck[^\n]+\nFachinformation/
  end

  it "should enable to go back after printing a prescription" do
    @browser.goto OddbUrl
    @browser.select_list(:name, "search_type").select("Markenname")
    @browser.text_field(:name, "search_query").set(Four_Medis.first)
    clickSearch
    clickRezeptErstellen
    setGeneralInfo(1)
    add_one_drug_to_rezept(Four_Medis[1])
    add_one_drug_to_rezept(Four_Medis[2])
    1.upto(4).each { |j|  @browser.back }
    @browser.url.chomp('/').should == OddbUrl
  end

  it "should not loose existing comment after adding a new prescription" do
    @browser.goto OddbUrl
    @browser.select_list(:name, "search_type").select("Markenname")
    @browser.text_field(:name, "search_query").set(Four_Medis.first)
    clickSearch
    clickRezeptErstellen
    setGeneralInfo(1)
    checkGeneralInfo(1)
    add_one_drug_to_rezept(Four_Medis[1])
    checkGeneralInfo(1)
  end

  it "should show the interaction between different drugs" do
    @browser.goto OddbUrl
    @browser.select_list(:name, "search_type").select("Markenname")
    @browser.text_field(:name, "search_query").set(Four_Medis.first)
    clickSearch
    clickRezeptErstellen
    1.upto(3) { |idx|
        add_one_drug_to_rezept(Four_Medis[idx])
        url1 = @browser.url
    }
    inhalt = @browser.text
    inhalt.should match(/C09CA01: Losartan => L02BA01: Tamoxifen Keine bekannte Interaktion/i) 
    inhalt.should match(/A: Keine Massnahmen erforderlich/i) 
    inhalt.should match(/N06AB05: Paroxetin => L02BA01: Tamoxifen Wirkungsverringerung von Tamoxifen/i) 
    inhalt.should match(/X: Kontraindiziert/i) 
    inhalt.should match(/N06AB05: Paroxetin => C09CA01: Losartan Vermutlich keine relevante Interaktion./i) 
    inhalt.should match(/B: Vorsichtsmassnahmen empfohlen/i) 
  end
  it "should with four medicaments" do
    medis = Four_Medis
    @browser.select_list(:name, "search_type").select("Markenname")
    @browser.text_field(:name, "search_query").set(medis.first)
    clickSearch
    clickRezeptErstellen
    1.upto(3) { |idx|
        add_one_drug_to_rezept(medis[idx])
        url1 = @browser.url
        sleep(0.5)
        inhalt = @browser.text
        inhalt.should match(/#{medis[idx]}/i)
    }
    0.upto(3){ |idx|
      @browser.link(:id => /delete_0/i).click;  small_delay
      sleep(0.5)
    }
    url2 = @browser.url
    inhalt = @browser.text
    0.upto(3){
      |idx|
      inhalt.should_not match(/#{medis[idx]}/i)
    }
    url2.match(RegExpTwoMedis).should be nil
    url2.match(RegExpOneMedi).should be nil
  end

  it "should show the correct url after deleting a medicament" do
    @browser.goto OddbUrl
    startTime = Time.now
    @browser.select_list(:name, "search_type").select("Markenname")
    @browser.text_field(:name, "search_query").set(TwoMedis.first)
    clickSearch
    clickRezeptErstellen
    add_one_drug_to_rezept(TwoMedis.last)
    url1 = @browser.url
    sleep(0.5)
    inhalt = @browser.text
    TwoMedis.each{ |name|
                inhalt.should match(/#{name}/i)
              }
    url1.match(RegExpTwoMedis).should_not be nil
    @browser.link(:id => /delete_0/i).click;  small_delay
    sleep(0.5)
    url2 = @browser.url
    inhalt = @browser.text
    inhalt.should_not match(/#{TwoMedis.first}/i) # was deleted
    inhalt.should     match(/#{TwoMedis.last}/i)
    url2.match(RegExpTwoMedis).should be nil
    url2.match(RegExpOneMedi).should_not be nil
    endTime = Time.now
    diff = endTime - startTime
    if ARGV.size > 0 and File.basename(ARGV[0]).eql?(File.basename(__FILE__))
      $stdout.puts "Test with two medicaments took #{diff.to_i} seconds. #{diff}" if $VERBOSE
    end
  end

  it "should have a working instant search" do
    medi = 'Nolvadex'
    @browser.link(:text=>'Instant').click if @browser.link(:text=>'Instant').exists?
    0.upto(10).each{ |idx|
                    begin
                      chooser = @browser.text_field(:id, 'searchbar')
                      chooser.set(medi)
                      sleep idx*0.1
                      chooser.send_keys(:down)
                      sleep idx*0.1
                      value = chooser.value
                      res = medi.match(value)
                      sleep 0.5
                      break if /#{medi}/i.match(value) and value.length > medi.length
                    rescue StandardError => e
                      puts "in rescue"
                      createScreenshot(@browser, "rescue_#{medi}_#{__LINE__}")
                      puts e.inspect
                      puts caller[0..5]
                      next
                     end
                    }
    @browser.send_keys("\n")
    url = @browser.url
    inhalt = @browser.text
    inhalt.should match(/Preisvergleich für/i)
    inhalt.should match(/#{medi}/i)
    inhalt.should match(/Zusammensetzung/i)
    inhalt.should match(/Filmtabletten/i)
  end

  # this tests takes (at the moment) over 2,5 minutes
  it "should be possible to print a presciption with 10 drugs" do
    startTime = Time.now
    nrDrugs = 10
    nrRemarks = 2
    @browser.goto(rezeptUrl)
    Four_Medis.each{ |medi| add_one_drug_to_rezept(medi) }
    # add two remarks
    setGeneralInfo(nrRemarks)
    add_one_drug_to_rezept('Pulmex')
    add_one_drug_to_rezept('Actemra')
    add_one_drug_to_rezept('Dostinex')
    add_one_drug_to_rezept('Yondelis')
    add_one_drug_to_rezept('Bactrim')
    add_one_drug_to_rezept('Badesalz')

    showElapsedTime(startTime, "Generating a prescription with #{nrDrugs}")
    startTime = Time.now
    oldWindowsSize = @browser.windows.size
    @browser.button(:name, "print").click
    @browser.windows.size.should == oldWindowsSize + 1 # must open a new window
    @browser.windows.last.use
    waitForPrintInfo
    showElapsedTime(startTime, "Printing a prescription with  #{nrDrugs} drugs")
    inhalt_alt = @browser.text.clone
    inhalt = @browser.text.clone
    inhalt.should_not match QrCodeError
    inhalt.scan(/\nBemerkungen\n/).size.should == nrRemarks
    inhalt.scan(/\nInteraktionen\n/).size.should == 2
    checkGeneralInfo(nrRemarks)
  end
end
end
