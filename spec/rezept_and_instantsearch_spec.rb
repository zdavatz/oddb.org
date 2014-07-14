#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'
require 'pp'
require 'tmpdir'
require "selenium-webdriver"

describe "ch.oddb.org" do
  Four_Medis = [ 'Losartan', 'Nolvadex', 'Paroxetin', 'Aspirin']
 
  def add_one_drug_to_rezept(name)
    chooser = @browser.text_field(:id, 'prescription_searchbar')
    0.upto(10).each{ |idx|
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
  end
  
  before :all do
    @idx = 0
    waitForOddbToBeReady(@browser, OddbUrl)
    login
  end

  before :each do
    @browser.goto OddbUrl
    if @browser.link(:text=>'Plus').exists?
      puts "Going from instant to plus"
    @browser.link(:text=>'Plus').click
    end
  end

  after :each do
    @idx += 1
    createScreenshot(@browser, '_'+@idx.to_s) if @browser
    # sleep
    @browser.goto OddbUrl
  end

  after :all do
    @browser.close if @browser
  end
  it "should be possible to print a presciption" do
    @browser.goto(OddbUrl + '/de/gcc/rezept/ean/7680516820922,7680390530474')
    # require 'pry'; binding.pry
    @browser.radio(:name => "prescription_sex", :value => "2").click # Set M for männlich
    @browser.text_field(:name => 'prescription_first_name').set 'Max'
    @browser.text_field(:name => 'prescription_family_name').set 'Müller'
    @browser.text_field(:name => 'prescription_birth_day').set '01.01.1990'
    @browser.textarea(:name => 'prescription_comment[0]').set 'Kommentar zu Merfen'
    @browser.textarea(:name => 'prescription_comment[1]').set 'Kommentar zu Nolvadex'
    oldWindowsSize = @browser.windows
    @browser.button(:name, "print").click
    @browser.windows.last.use if @browser.windows.size != oldWindowsSize   
    inhalt = @browser.text
    inhalt.should     match(/Ausdruck/i)
    ['Ausdruck',
     'Stempel, Unterschrift',
     'Max', 'Müller',
     '01.01.1990', 'Merfen', 'Nolvadex', 
     '7680516820922', '7680390530474',
     'Kommentar zu Merfen',
     'Kommentar zu Nolvadex',
     / m$/, # männlich
    ].each do 
      |name|
      puts puts
      inhalt.should match(name)
    end
  end
  it "should show the interaction between different drugs" do
    medis = Four_Medis
    @browser.select_list(:name, "search_type").select("Markenname")
    @browser.text_field(:name, "search_query").set(medis.first)
    @browser.button(:name, "search").click
    @browser.link(:href, /rezept/).click
    1.upto(3) { |idx|
        add_one_drug_to_rezept(medis[idx])
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
    @browser.button(:name, "search").click
    @browser.link(:href, /rezept/).click
    1.upto(3) { |idx|
        add_one_drug_to_rezept(medis[idx])
        url1 = @browser.url
        sleep(0.5)
        inhalt = @browser.text
        inhalt.should match(/#{medis[idx]}/i)
    }
    0.upto(3){ |idx|
      @browser.link(:title => /Löschen/i).click
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
    @browser.button(:name, "search").click
    @browser.link(:href, /rezept/).click
    add_one_drug_to_rezept(TwoMedis.last)
    url1 = @browser.url
    sleep(0.5)
    inhalt = @browser.text
    TwoMedis.each{ |name|
                inhalt.should match(/#{name}/i)
              }
    url1.match(RegExpTwoMedis).should_not be nil
    @browser.link(:title => /Löschen/i).click
    sleep(0.5)
    url2 = @browser.url
    inhalt = @browser.text
    inhalt.should_not match(/#{TwoMedis.first}/i) # was deleted
    inhalt.should     match(/#{TwoMedis.last}/i)
    url2.match(RegExpTwoMedis).should be nil
    url2.match(RegExpOneMedi).should be nil
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
end
