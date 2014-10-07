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

  it "should download the results of a search to Marcoumar" do
    @browser.goto OddbUrl
    login
    filesBeforeDownload =  Dir.glob(GlobAllDownloads)
    @browser.text_field(:name, "search_query").set('Marcoumar')
    @browser.button(:name, "search").click
    @browser.button(:value,"Resultat als CSV Downloaden").click
    # require 'pry'; binding.pry
    @browser.button(:name => 'proceed_payment').click
    @browser.button(:name => 'checkout_invoice').click
    @browser.url.should_not match  /errors/
    filesAfterDownload =  Dir.glob(GlobAllDownloads)
    diffFiles = (filesAfterDownload - filesBeforeDownload)
    diffFiles.size.should == 1
  end unless ['just-medical'].index(Flavor)

  it "should be possible to run a bin/admin command" do
    cmd = 'registrations.size'
    res = run_bin_admin(cmd)
    # puts "res of cmd #{cmd} is \n#{res}"
    res.should match(/-\> \d+/)
  end

  it "should be possible to download Zulassungsinhaber Desitin as admin user" do
    logout
    login(AdminUser, AdminPassword)
    if false
      @browser.link(:text, "Admin").click
      @browser.link(:text, "Benutzer").click
      @browser.link(:text, AdminUser).click
      @browser.checkbox(:name, "yus_privileges[login|org.oddb.AdminUser]").value.should == "1"
      @browser.goto OddbUrl
    end
    @browser.select_list(:name, "search_type").select("Zulassungsinhaber")
    @browser.text_field(:id, "searchbar").set("Desitin")
    @browser.button(:name,"search").click
    @browser.button(:name,"export_csv").click
    @browser.select_list(:name, "payment_method").select("Rechnung")
    @browser.button(:name, "proceed_payment").click
    link = @browser.button(:name, "checkout_invoice")
    filesBeforeDownload =  Dir.glob(GlobAllDownloads)
    link.click
    @browser.url.should_not match /errors/
    @browser.url.should_not match /appdown/
    filesAfterDownload =  Dir.glob(GlobAllDownloads)
    diffFiles = (filesAfterDownload - filesBeforeDownload)
    diffFiles.size.should == 1
    inhalt = IO.read(diffFiles.first)
    inhalt.should match /Desitin/i
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