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
    @browser.link(:text=>'Deutsch').click unless /Vergleichen Sie einfach und schnell Medikamentenpreise./.match(@browser.text)
  end

  after :each do
    @idx += 1
#    createScreenshot(@browser, '_'+@idx.to_s)
    # sleep
#    @browser.goto OddbUrl
  end

    def enter_search_to_field_by_name(search_text, field_name)
      idx = 1
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
      chooser.set(search_text)
      sleep idx*0.1
      chooser.send_keys(:down)
      sleep idx*0.1
      chooser.send_keys(:enter)
      sleep idx*0.1
    end

    Moor = 'Apotheke Moor'
    MoorEAN = '7601001380028'
  # We don't repeat here the tests that are in the smoketest!
  it "check pharmacy" do
#    require 'pry'; binding.pry
    login
    @browser.link(:name, 'pharmacies').click
    enter_search_to_field_by_name('Glarus', 'search_query');
    @browser.text.should match Moor
    @browser.text.should match 'Kantonsspital Glarus AG'
    @browser.text.should match 'St. Fridolin Pharma AG'
    @browser.link(:text =>Moor).click
    # don't know why we need to wait here, but it works!
    sleep 0.5 unless @browser.link(:text => /Lageplan/).exists?
    inhalt = @browser.text
    inhalt.should match Moor
    @browser.url.should match /pharmacy\/ean/
    @browser.url.should match MoorEAN
    inhalt.should match MoorEAN
    inhalt.should match "Zaunplatz 2"
    inhalt.should match "8750 Glarus"
    @browser.link(:text => /map.search/).click
    @browser.url.should match /8750-glarus\/zaunplatz-2/
    @browser.back
  # go back to search result
    @browser.back
  end unless ['just-medical'].index(Flavor)

  after :all do
    @browser.close
  end

end
