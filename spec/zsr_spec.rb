#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'
require 'pp'
require 'tmpdir'
require "selenium-webdriver"
require 'savon'

describe "ch.oddb.org" do
  ExampleZSR = {'J039019' => 'Davatz' }
  before :all do
    waitForOddbToBeReady(@browser, OddbUrl)
    login
  end

  before :each do
    while @browser.windows.size > 1
      @browser.windows.first.use
      @browser.windows.last.close if @browser.windows.last
    end
    @browser.goto OddbUrl
  end

  after :each do
    createScreenshot(@browser, 'zsr_') if @browser
  end

  it "should work with an exmple json from api.bls.gov" do
    skip 'http://api.bls.gov/publicAPI no longer works'
    @browser.goto("http://api.bls.gov/publicAPI/v1/timeseries/data/CFU0000008000")
    expect(@browser.text).to match /{"status":"REQUEST_SUCCEEDED","responseTime":/
    expect(@browser.text).to match /"Results":{ "series":/
  end

  it "should work with J039019" do
    ExampleZSR.each{
      |key, value|
      url = OddbUrl+ "/de/gcc/zsr/#{key}"
      @browser.goto url
      skip 'ZSR does not work any longer'
      expect(@browser.url).to match /zsr\/#{key}/
      expect(@browser.text).to match /#{value}/i
    }
  end

end
