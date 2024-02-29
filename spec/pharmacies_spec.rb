#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'

@workThread = nil

describe "ch.oddb.org" do

  before :all do
    @idx = 0
    waitForOddbToBeReady(@browser, ODDB_URL)
  end

  before :each do
    @browser.goto ODDB_URL
    @browser.link(visible_text: 'Deutsch').click unless /Vergleichen Sie einfach und schnell Medikamentenpreise./.match(@browser.text)
  end

  after :each do
    @idx += 1
#    createScreenshot(@browser, '_'+@idx.to_s)
    # sleep
#    @browser.goto ODDB_URL
  end

  MATCH_THIS_PHARMACY = 'Apotheke im Spital'
  MATCH_THIS_PHARMACYEAN = '7601001409958'
  Strasse = "Burgstrasse 99"

  # We don't repeat here the tests that are in the smoketest!
  it "check pharmacy #{MATCH_THIS_PHARMACY} #{MATCH_THIS_PHARMACYEAN}" do
    login
    @browser.link(name:  'pharmacies').click
    enter_search_to_field_by_name('Glarus', 'search_query');
    @browser.link(text: /Apotheke Gl/).wait_until(&:present?)
    expect(@browser.text).to match 'Kantonsspital Glarus AG'
    expect(@browser.text).to match /#{MATCH_THIS_PHARMACY}/
    @browser.link(visible_text:  /#{MATCH_THIS_PHARMACY}/).click
    # don't know why we need to wait here, but it works!
    @browser.link(visible_text:  /Lageplan/).wait_until(&:present?)
    inhalt = @browser.text
    expect(inhalt).to match MATCH_THIS_PHARMACY
    expect(@browser.url).to match /pharmacy\/ean/
    expect(@browser.url).to match MATCH_THIS_PHARMACYEAN
    expect(inhalt).to match Strasse
    expect(inhalt).to match Strasse.gsub(' ', '.')
    @browser.link(visible_text:  /map.search/).click
    expect(@browser.url).to match /Glarus/
    @browser.back
  # go back to search result
    @browser.back
  end unless ['just-medical'].index(Flavor)

  after :all do
    @browser.close if @browser
  end

end
