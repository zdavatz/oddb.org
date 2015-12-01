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
    login(ViewerUser,  ViewerPassword)
  end

  before :all do
    @idx = 0
    waitForOddbToBeReady(@browser, OddbUrl)
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
      url = OddbUrl + '/de/gcc/home_'+kind
      @browser.goto url
      expect(@browser.url).to eq(url)
      expect(@browser.link(:name, link_name).exist?).to eq(true)
      @browser.link(:name, link_name).click
      # require 'pry'; binding.pry unless @browser.url.index(link_name)
      expect(@browser.url.index(link_name)).not_to eq(nil)
      expect(@browser.link(:name => 'range').exist?).to eq(true)
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
    expect(@browser.link(:name, CompanyListName).exist?).to eq(true)
    @browser.link(:name, CompanyListName).click
    expect(@browser.url.index(CompanyListName)).to be > 0
    nr_founds = count_nr_companies_displayed
    if must_have_all
      expect(nr_founds).to be > CompanyLimitListed
    else
      expect(nr_founds).to be <= CompanyLimitListed
    end
  end

  it "in home_companies we should see all companies when logged in as admin" do
    login(AdminUser, AdminPassword)
    @browser.goto OddbUrl + '/de/gcc/home_companies'
    check_nr_companies(true)
  end

  it "in home_companies we should have the link active_companies if logged in as admin" do
    login(AdminUser, AdminPassword)
    @browser.goto OddbUrl + '/de/gcc/home_companies'
    @browser.link(:name, CompanyListName).click
    link = @browser.link(:name, 'listed_companies')
    expect(link.exist?).to eq(true)
    link.click
    expect(count_nr_companies_displayed).to be <= CompanyLimitListed
  end

  it "in home_companies we should see all companies when logged in as user" do
    @browser.goto OddbUrl + '/de/gcc/home_companies'
    check_nr_companies(true)
  end

end
