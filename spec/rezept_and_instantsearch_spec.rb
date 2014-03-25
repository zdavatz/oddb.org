#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'
require 'pp'

describe "ch.oddb.org" do
 
  def add_one_drug_to_rezept(name)
    chooser = @browser.text_field(:id, 'prescription_searchbar')
    0.upto(10).each{ |idx|
                    chooser.set(name)
                    sleep idx*0.1
                    chooser.send_keys(:down)
                    sleep idx*0.1
                    chooser.send_keys(:enter)
                    sleep idx*0.1
                    value = chooser.value
                    break unless /#{name}/.match(value)
                    sleep 0.5
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
  end

  after :each do
    @idx += 1
    createScreenshot(@browser, '_'+@idx.to_s)
    # sleep
    @browser.goto OddbUrl
  end

  after :all do
    @browser.close
  end
  
  it "should with four medicaments" do
    medis = [ 'Losartan', 'Nolvadex', 'Paroxetin', 'Aspirin']
    @browser.select_list(:name, "search_type").select("Markenname")
    @browser.text_field(:name, "search_query").set(medis.first)
    @browser.button(:name, "search").click
    @browser.link(:href, /rezept/).click
    1.upto(3) { |idx|
        add_one_drug_to_rezept(medis[idx])
        url1 = @browser.url
        sleep(0.5)
        inhalt = @browser.text
        inhalt.match(/#{medis[idx]}/i).should_not be nil
    }
    0.upto(3){ |idx|
      @browser.link(:title => /Löschen/i).click
      sleep(0.5)
    }
    url2 = @browser.url
    inhalt = @browser.text
    0.upto(3){
      |idx|
      inhalt.match(/#{medis[idx]}/i).should be nil
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
                inhalt.match(/#{name}/i).should_not be nil
              }
    url1.match(RegExpTwoMedis).should_not be nil
    @browser.link(:title => /Löschen/i).click
    sleep(0.5)
    url2 = @browser.url
    inhalt = @browser.text
    inhalt.match(/#{TwoMedis.first}/i).should be nil
    inhalt.match(/#{TwoMedis.last}/i).should_not be nil
    url2.match(RegExpTwoMedis).should be nil
    url2.match(RegExpOneMedi).should be nil
    endTime = Time.now
    diff = endTime - startTime
    if ARGV.size > 0 and File.basename(ARGV[0]).eql?(File.basename(__FILE__))
      $stdout.puts "Test with two medicaments took #{diff.to_i} seconds. #{diff}"
    end
  end

  it "should have a working instant search" do
    medi = 'Nolvadex'
    @browser.link(:text=>'Instant').click if @browser.link(:text=>'Instant').exists?
    chooser = @browser.text_field(:id, 'searchbar')
    0.upto(10).each{ |idx|
                    chooser.set(medi)
                    sleep idx*0.1
                    chooser.send_keys(:down)
                    sleep idx*0.1
                    value = chooser.value
                    res = /#{medi}/i.match(value)
                    sleep 0.5
                    break if /#{medi}/i.match(value) and value.length > medi.length
                    }
    @browser.send_keys("\n") # this is different to add_one_drug_to_rezept
    idx = 0
    while idx < 10
      inhalt = @browser.text
      break if inhalt.match(/Preisvergleich für/i)
      sleep(1)
      idx += 1
    end
    url = @browser.url
    inhalt = @browser.text
    inhalt.match(/Preisvergleich für/i).should_not be nil
    inhalt.match(/#{medi}/i).should_not be nil
    inhalt.match(/Zusammensetzung/i).should_not be nil
    inhalt.match(/Filmtabletten/i).should_not be nil
  end
end
