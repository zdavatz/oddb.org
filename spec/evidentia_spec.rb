#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'

@workThread = nil

describe "ch.oddb.org" do

  Evidentia_URL = 'http://evidentia.oddb-ci2.dyndns.org'
  HomeURL       = "#{Evidentia_URL}/de/gcc/home_drugs/"
  Lamivudin     = 'Lamivudin-Zidovudin-Mepha'
  Sevikar       = 'Sevikar HCT'

  before :all do
    @idx = 0
    waitForOddbToBeReady(@browser, Evidentia_URL)
    login
  end

  before :each do
    @browser.goto Evidentia_URL
  end

  after :each do
    @idx += 1
    createScreenshot(@browser, '_'+@idx.to_s)
  end

  def select_product_by_trademark(name)
    url = "#{Evidentia_URL}/de/evidentia/search/zone/drugs/search_query/#{name}?"
    @browser.goto url
    @browser.element(:id => 'ikscat_1').wait_until_present
    expect(@browser.url.index(Evidentia_URL)).to eq 0
    expect(@browser.url.index('/de/evidentia')).not_to eq 0
    @text = @browser.text.clone
  end

  it "should not contain a column Fachinfo" do
    select_product_by_trademark(Lamivudin)
    @text.index('Fachinfo')should eq nil
    fi = @browser.td(:class_name => /list /, :text => 'FI')
    expect(fi).to eq nil
  end

  it "should contain a link to the limiation in Sevikar HCT preparation" do
    select_product_by_trademark(Sevikar)
    link = @browser.link(:text => 'L')
    link.href.index('limitation_text').should > 0
    /#{tradename}.*\n.*- L( |$)/.match(@text).class.should == MatchData
  end

  it "should contain a link to the price comparision in price public" do
    # http://ch.oddb.org/de/gcc/search/zone/drugs/search_query/sevikar%20hct/search_type/st_sequence?#best_result
    select_product_by_trademark(Sevikar)
    pubprice = @browser.link(:class_name => /pubprice/)
    pubprice.exist?.should eq true
  end

  it "should contain a link to the fachinfo for Lamivudin-Zidovudin" do
    select_product_by_trademark(Lamivudin)
    prep = @browser.link(:text => Lamivudin)
    expect(prep.exists?)
    prep.href.index('ean').should > 0
    prep.href.index('fachinfo').should > 0
  end

  it "should display a limitation link for #{Sevikar}" do
    select_product_by_trademark(Sevikar)
    @browser.element(:id => 'ikscat_1').text.should eq 'B / SL'
    span = @browser.element(:id => 'deductible_1')
    span.exist?.should eq true
    span.text.should match /\d+%/
    @browser.link(:text => 'L').exists?.should eq true
    @browser.link(:text => 'L').href.should match /limitation_text\/reg/
    @browser.link(:text => 'FI').exists?.should eq false
    @browser.link(:text => 'PI').exists?.should eq false
    @browser.td(:text => 'A').exists?.should eq false
    @browser.td(:text => 'C').exists?.should eq false
  end

  it "should display lamivudin with SO and SG in category (price comparision)" do
    select_product_by_trademark('lamivudin')
    @browser.tds.find{ |x| x.text.eql?('A / SL / SO')}.exists?.should eq true
    @browser.tds.find{ |x| x.text.eql?('A / SL / SG')}.exists?.should eq true
  end

  it "should not contain a link to the drug inside the price comparision" do
    @browser.goto(Evidentia_URL + '/de/evidentia/compare/ean13/7680615190018')
    link = @browser.link(:text => /#{Sevikar}/)
    binding.pry
    expect(link.exist?).to eq false
  end

  after :all do
    @browser.close
  end
end
