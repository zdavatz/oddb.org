#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'
require 'pp'
require 'tmpdir'
require 'timeout'

describe "ch.oddb.org" do

  before :all do
    waitForOddbToBeReady(@browser, ODDB_URL)
  end

  before :each do
    @timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    while @browser.windows.size > 1
      @browser.windows.first.use
      @browser.windows.last.close if @browser.windows.last
    end
    @browser.goto ODDB_URL
  end

  it "should be possible to run a bin/admin command" do
    cmd = 'registrations.size'
    res = run_bin_admin(cmd)
    # puts "res of cmd #{cmd} is \n#{res}"
    expect(res).to match(/-\> \d+/)
  end

  require 'timeout'
  it "should be possible to run grant_download oddb2.csv" do
    price = 17
    cmd = "grant_download '#{ViewerUser}', 'oddb2.csv', #{price}"
    res = run_bin_admin(cmd)
    wrong_url = /(-> https:\/\/[\w.]+)(.+)/.match(res)
    expect(wrong_url).not_to be nil
    destination = "#{ODDB_URL}/#{wrong_url[2]}"
    filesBeforeDownload =  Dir.glob(GlobAllDownloads)
    Watir.default_timeout = 2
    skip("Going to #{destination} hangs the whole browser, after having downloaded the oddb2csv")
    @browser.goto destination
    expect(@browser.url).not_to match /errors/
    expect(@browser.url).not_to match /appdown/
    filesAfterDownload =  Dir.glob(GlobAllDownloads)
    diffFiles = (filesAfterDownload - filesBeforeDownload)
    expect(diffFiles.size).to eq(1)
    expect(File.size(diffFiles.first)).to be > 500
  end

  after :all do
    @browser.close if @browser
  end

end
