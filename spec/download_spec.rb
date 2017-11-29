#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'
require 'pp'
require 'tmpdir'
require "selenium-webdriver"
require 'paypal_helper'

describe "ch.oddb.org" do

  before :all do
    waitForOddbToBeReady(@browser, OddbUrl)
  end

  before :each do
    @timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    while @browser.windows.size > 1
      @browser.windows.first.use
      @browser.windows.last.close if @browser.windows.last
    end
    @browser.goto OddbUrl
  end

  def paypal_login
    paypal_user = PaypalUser.new
    expect(paypal_user.init_paypal_checkout(@browser)).to eql true
    @browser.button(:name => PaypalUser::CheckoutName).click; small_delay
    expect(paypal_user.paypal_buy(@browser)).to eql true
  end

  it "should be possible to run a bin/admin command" do
    cmd = 'registrations.size'
    res = run_bin_admin(cmd)
    # puts "res of cmd #{cmd} is \n#{res}"
    expect(res).to match(/-\> \d+/)
  end

  it "should be possible to run grant_download oddb2.csv" do
    price = 17
    cmd = "grant_download '#{ViewerUser}', 'oddb2.csv', #{price}"
    res = run_bin_admin(cmd)
    wrong_url = /(-> https:\/\/[\w.]+)(.+)/.match(res)
    expect(wrong_url).not_to be nil
    destination = "#{OddbUrl}/#{wrong_url[2]}"
    filesBeforeDownload =  Dir.glob(GlobAllDownloads)
    @browser.goto destination
    sleep(1) # Downloading takes some time
    expect(@browser.url).not_to match /errors/
    expect(@browser.url).not_to match /appdown/
    filesAfterDownload =  Dir.glob(GlobAllDownloads)
    diffFiles = (filesAfterDownload - filesBeforeDownload)
    expect(diffFiles.size).to eq(1)
    expect(File.size(diffFiles.first)).to be > 10*1024
  end

  after :all do
    @browser.close if @browser
  end

end
