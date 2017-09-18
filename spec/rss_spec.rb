#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'

@workThread = nil

describe "ch.oddb.org" do
 
  before :all do
    @idx = 0
    @saved_timeout ||= Watir.default_timeout
    waitForOddbToBeReady(@browser, OddbUrl)
  end

  before :each do
    Watir.default_timeout = @saved_timeout
    @browser.goto OddbUrl
    Dir.glob(GlobAllDownloads).each{|f| FileUtils.rm(f)}
  end

  after :each do
    @idx += 1
  end

  def  check_for_rss_feed(link=nil)
    # chromium just downloads the rss feeds
    @filesBeforeDownload =  Dir.glob(GlobAllDownloads)
    @browser.goto(link.href) if link
    if @browser.driver.browser.eql?(:firefox)
      sleep(2)
      text = @browser.text.clone
      expect(/This is a “feed” of frequently changing content on this site.|Subscribe to this/o.match(text)).not_to eql nil
      if false # old
        puts GlobAllDownloads
        filesAfterDownload =  Dir.glob(GlobAllDownloads)
        diff_files = filesAfterDownload - @filesBeforeDownload
        expect(diff_files.size).to eql 1
        expect(File.basename(diff_files.first)).to eql subject + '.rss'
      end
    else
      text = @browser.text.clone
      expect(/logo_rss.png/.match(text)).not_to eql nil
      expect(/<\/channel>/.match(text)).not_to eql nil
    end
  end
  {
    'hpc'             => 'Health Professional Communication \(HPC\)',
    'price_cut'       => 'Preissenkungen von Produkten in der Spezialitäten-Liste',
    'price_rise'      => 'Preiserhöhungen von Produkten in der Spezialitäten-Liste',
    'recall'          => 'Chargenrückrufe',
    'sl_introduction' => 'Neuaufnahme von Produkten in die Spezialitäten-Liste',
    'fachinfo'        => 'Neue und geänderte Fachinformtionen im Schweizer Gesundheitsmarkt',
  }.each{
    |subject, test_string|
      it "should have a working RSS-feed #{subject}" do
        expect(@browser.url).to match OddbUrl
        link = @browser.link(:href => /rss\/channel\/#{subject}/)
        debug = /fachinfo/i.match(subject) ? true : false
        expect(link.exists?).to be true
        check_for_rss_feed(link)
        @browser.back
      end
    }
    {
      'fachinfo-2008'   => 'Neue und geänderte Fachinformtionen im Schweizer Gesundheitsmarkt',
  }.each do
    |subject, test_string|
      it "should have a working #{subject}" do
        @filesBeforeDownload =  Dir.glob(GlobAllDownloads)
        url = OddbUrl + '/de/gcc/rss/channel/' + subject + '.rss'
        @browser.goto url
        check_for_rss_feed
      end
  end

  after :all do
    Watir.default_timeout = @saved_timeout
    $stdout.puts "#{Time.now}: #{__FILE__} after all. Restored timeout to #{@saved_timeout}"
    @browser.close if @browser
  end
end
