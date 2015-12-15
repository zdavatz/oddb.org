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
        if @browser.driver.browser.eql?(:firefox)
          Watir.default_timeout = 60 if /fachinfo/i.match(subject) # reading fachinfo takes a long time
          $stdout.puts "#{Time.now}: goto #{link.href} timeout #{Watir.default_timeout}" if debug
          @browser.goto(link.href)
          # We have problem as the fachinfo size is 26MB and goes back to 2006.
          Watir.default_timeout = 600 if /fachinfo/i.match(subject) # reading fachinfo takes a long time
          $stdout.puts "#{Time.now}: #{@browser.url} start reading text timeout #{Watir.default_timeout}" if debug
          content = @browser.text.clone
          File.open(subject + '.rss', 'w+' ) { |f| f.write content }
          expect(content).to match /#{test_string}/
          $stdout.puts "#{Time.now}: #{@browser.url} has is #{content.size} text.size long" if debug
        else
          # chromium just downloads the rss feeds
          filesBeforeDownload =  Dir.glob(GlobAllDownloads)
          @browser.goto(link.href)
          sleep(2)
          filesAfterDownload =  Dir.glob(GlobAllDownloads)
          diff_files = filesAfterDownload - filesBeforeDownload
          expect(diff_files.size).to eql 1
          expect(File.basename(diff_files.first)).to eql subject + '.rss'
        end
        @browser.back
      end
    }
    {
      'fachinfo-2008'   => 'Neue und geänderte Fachinformtionen im Schweizer Gesundheitsmarkt',
  }.each do
    |subject, test_string|
      it "should have a working #{subject}" do
        filesBeforeDownload =  Dir.glob(GlobAllDownloads)
        url = OddbUrl + '/de/gcc/rss/channel/' + subject + '.rss'
        @browser.goto url
        if @browser.driver.browser.eql?(:firefox)
          expect(@browser.url).to eql url
          content = @browser.text.clone
          expect(content).to match /#{test_string}/
        else
          # chromium just downloads the rss feeds
          sleep(2)
          filesAfterDownload =  Dir.glob(GlobAllDownloads)
          diff_files = filesAfterDownload - filesBeforeDownload
          expect(diff_files.size).to eql 1
          expect(File.basename(diff_files.first)).to eql subject + '.rss'
        end
      end
  end

  after :all do
    Watir.default_timeout = @saved_timeout
    $stdout.puts "#{Time.now}: #{__FILE__} after all. Restored timeout to #{@saved_timeout}"
    @browser.close
  end
end
