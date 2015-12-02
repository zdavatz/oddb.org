#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'
require 'pp'
require 'tmpdir'
require "selenium-webdriver"

describe "ch.oddb.org" do

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
    filesBeforeDownload =  Dir.glob(GlobAllDownloads)
    @browser.text_field(:name, "search_query").set('Marcoumar')
    @browser.button(:name, "search").click
    @browser.button(:value,"Resultat als CSV Downloaden").click
    # require 'pry'; binding.pry
    @browser.button(:name => 'proceed_payment').click
    @browser.button(:name => 'checkout_invoice').click
    expect(@browser.url).not_to match  /errors/
    filesAfterDownload =  Dir.glob(GlobAllDownloads)
    diffFiles = (filesAfterDownload - filesBeforeDownload)
    expect(diffFiles.size).to eq(1)
  end unless ['just-medical'].index(Flavor)

  it "should be possible to run a bin/admin command" do
    cmd = 'registrations.size'
    res = run_bin_admin(cmd)
    # puts "res of cmd #{cmd} is \n#{res}"
    expect(res).to match(/-\> \d+/)
  end

  it "should be possible to download Zulassungsinhaber Desitin as admin user" do
    logout; login(AdminUser, AdminPassword)
    if false
      @browser.link(:text, "Admin").click
      @browser.link(:text, "Benutzer").click
      @browser.link(:text, AdminUser).click
      expect(@browser.checkbox(:name, "yus_privileges[login|org.oddb.AdminUser]").value).to eq("1")
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
    expect(@browser.url).not_to match /errors/
    expect(@browser.url).not_to match /appdown/
    filesAfterDownload =  Dir.glob(GlobAllDownloads)
    diffFiles = (filesAfterDownload - filesBeforeDownload)
    expect(diffFiles.size).to eq(1)
    inhalt = IO.read(diffFiles.first)
    expect(inhalt).to match /Desitin/i
  end

  it "should be possible to run grant_download oddb2.csv" do
    price = 17
    cmd = "grant_download '#{ViewerUser}', 'oddb2.csv', #{price}"
    res = run_bin_admin(cmd)
    wrong_url = /(-> http:\/\/[\w.]+)(.+)/.match(res)
    expect(wrong_url).not_to be nil
    destination = "#{OddbUrl}/#{wrong_url[2]}"
    FileUtils.rm(Dir.glob(File.join(DownloadDir, 'oddb2*.csv')), :verbose => false)
    filesBeforeDownload =  Dir.glob(GlobAllDownloads)
    @browser.goto destination
    expect(@browser.url).not_to match /errors/
    expect(@browser.url).not_to match /appdown/
    filesAfterDownload =  Dir.glob(GlobAllDownloads)
    diffFiles = (filesAfterDownload - filesBeforeDownload)
    expect(diffFiles.size).to eq(1)
    expect(File.size(diffFiles.first)).to be > 10*1024
  end

  after :all do
    @browser.close
  end

end