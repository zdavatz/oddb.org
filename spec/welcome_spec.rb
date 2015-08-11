#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'
require 'pp'
require 'tmpdir'
require "selenium-webdriver"

LeeresResult =  /hat ein leeres Resultat/
# OddbUrl = "http://ch.oddb.org"

describe "ch.oddb.org" do

  before :all do
    $prescription_test_id = 1
    waitForOddbToBeReady(@browser, OddbUrl)
    logout
    login(ViewerUser, ViewerPassword)
  end

  ViewerDescription = 'gesponsorten Login von Desitin Pharma'

  before :each do
    @timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    # puts "before #{$prescription_test_id} with #{@browser.windows.size} windows"
    while @browser.windows.size > 1
      @browser.windows.first.use
      @browser.windows.last.close if @browser.windows.last
    end
    @browser.goto OddbUrl
  end

  [ 'analysis', 'pharmacies', 'doctors', 'interactions', 'migel', 'user', 'hospitals', 'companies'].each do
    |zone|
    it "should be possible to see the sponsored log-in in zone #{zone}" do
      # require 'pry'; binding.pry
      @browser.text.should match (ViewerDescription)
      @browser.link(:name, zone).exists?.should == true
      @browser.link(:name, zone).click
      sleep(0.1) unless @browser.link(:name, "logout").exists?
      @browser.link(:name, "logout").exists?.should == true
      @browser.text.should match (ViewerDescription)
    end
  end

  after :each do
  end

  after :all do
    @browser.close
  end
end