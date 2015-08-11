#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'

@workThread = nil

describe "ch.oddb.org" do

  after :all do
    @browser.close
  end

  after :each do
    logout
  end

  before :all do
    @idx = 0
    waitForOddbToBeReady(@browser, OddbUrl)
    login
  end

  before :each do
    @browser.goto OddbUrl
  end

  {
    'companies'  => 'companylist',
    'hospitals'  => 'hospitallist',
    'pharmacies' => 'pharmacylist',
  }.each {
    |kind, link_name|
    it "in home_#{kind} should be possible consult the corresponding list of #{kind}" do
      login(ViewerUser,  ViewerPassword)
      url = OddbUrl + '/de/gcc/home_'+kind
      @browser.goto url
      @browser.url.should == url
      @browser.link(:name, link_name).exist?.should == true
      @browser.link(:name, link_name).click
      # require 'pry'; binding.pry unless @browser.url.index(link_name)
      @browser.url.index(link_name).should_not == nil
      @browser.link(:name => 'range').exist?.should == true
    end
  }

  CompanyListName = 'companylist'
  CompanyLimitListed = 100
  def count_nr_companies_displayed
    nr_founds = 0
    @browser.links.each{ |link| nr_founds += 1 if  link.name.eql?('name') }
    nr_founds
  end
  def check_nr_companies(must_have_all)
    @browser.link(:name, CompanyListName).exist?.should == true
    @browser.link(:name, CompanyListName).click
    @browser.url.index(CompanyListName).should > 0
    nr_founds = count_nr_companies_displayed
    if must_have_all
      nr_founds.should > CompanyLimitListed
    else
      nr_founds.should <= CompanyLimitListed
    end
  end

  it "in home_companies we should see all companies when logged in as admin" do
    login
    @browser.goto OddbUrl + '/de/gcc/home_companies'
    check_nr_companies(true)
  end

  it "in home_companies we should have the link active_companies if logged in as admin" do
    login
    @browser.goto OddbUrl + '/de/gcc/home_companies'
    @browser.link(:name, CompanyListName).click
    link = @browser.link(:name, 'listed_companies')
    link.exist?.should == true
    link.click
    count_nr_companies_displayed.should <= CompanyLimitListed
  end

  it "in home_companies we should see all companies when logged in as user" do
    login(ViewerUser,  ViewerPassword)
    @browser.goto OddbUrl + '/de/gcc/home_companies'
    check_nr_companies(true)
  end

end
