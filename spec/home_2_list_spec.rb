#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'

@workThread = nil

describe "ch.oddb.org" do

  after :all do
    @browser.close
  end

  before :all do
    @idx = 0
    waitForOddbToBeReady(@browser, OddbUrl)
    login
  end

  before :each do
    @browser.goto OddbUrl
  end

  {  'hospitals'  => 'hospitallist',
     'pharmacies' => 'pharmacylist',
     'companies'  => 'companylist',
  }.each {
    |kind, link_name|
    it "in home_#{kind} should be possible consult the corresponding list of #{kind}" do
      url = OddbUrl + '/de/gcc/home_'+kind
      @browser.goto url
      @browser.url.should == url
      @browser.link(:name, link_name).exist?.should == true
      @browser.link(:name, link_name).click
      @browser.url.index(link_name).should > 0
      # require 'pry'; binding.pry
      @browser.link(:name => 'range').exist?.should == true
      # @browser.link(:href => /\/#{link_name.sub('list','')}\ean\//).exist?.should == true
    end
  }

end
