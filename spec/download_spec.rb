#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'
require 'pp'
require 'tmpdir'
require "selenium-webdriver"

LeeresResult =  /hat ein leeres Resultat/

describe "ch.oddb.org" do
  ViewerUser     = 'niklaus.giger@hispeed.ch'
  ViewerPassword = 'ng1234'

  before :all do
    waitForOddbToBeReady(@browser, OddbUrl)
    login(ViewerUser,  ViewerPassword)
  end

  before :each do
    @timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    # puts "before #{$prescription_test_id} with #{@browser.windows.size} windows"
    while @browser.windows.size > 1
      @browser.windows.first.use
      @browser.windows.last.close if @browser.windows.last
    end
    @browser.goto OddbUrl
  end

  it "should be possible to run a bin/admin command" do
    cmd = 'registrations.size'
    res = run_bin_admin(cmd)
    # puts "res of cmd #{cmd} is \n#{res}"
    res.should match(/-\> \d+/)
  end

  it "should be possible to run grant_download oddb2.csv" do
    price = 17
    cmd = "grant_download '#{ViewerUser}', 'oddb2.csv', #{price}"
    res = run_bin_admin(cmd)
    wrong_url = /(-> http:\/\/[\w.]+)(.+)/.match(res)
    wrong_url.should_not be nil
    destination = "#{OddbUrl}/#{wrong_url[2]}"
    FileUtils.rm(Dir.glob(File.join(DownloadDir, 'oddb2*.csv')), :verbose => false)
    filesBeforeDownload =  Dir.glob(GlobAllDownloads)
    @browser.goto destination
    @browser.url.should_not match /errors/
    @browser.url.should_not match /appdown/
    filesAfterDownload =  Dir.glob(GlobAllDownloads)
    diffFiles = (filesAfterDownload - filesBeforeDownload)
    diffFiles.size.should == 1
    File.size(diffFiles.first).should > 10*1024
  end

  after :all do
    @browser.close
  end

end