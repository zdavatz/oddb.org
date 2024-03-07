#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'

@workThread = nil

describe "ch.oddb.org" do

  before :all do
    @idx = 0
    @saved_timeout ||= Watir.default_timeout
    waitForOddbToBeReady(@browser, ODDB_URL)
  end

  before :each do
    Watir.default_timeout = 1
    @browser.goto ODDB_URL
    Dir.glob(GlobAllDownloads).each{|f| FileUtils.rm(f)}
  end

  after :each do
    @idx += 1
  end

  def  check_for_rss_feed(link=nil)
    # chromium just downloads the rss feeds
    if link
      if @browser.name.eql?(:chrome)
        @browser.goto(link)
        content = @browser.text
      else
        # we cannot visit the download link as this would make the watir block
        expect(is_link_valid?(link)).to eq true
        content =  Net::HTTP.get(URI.parse(link))
      end
      expect(/logo_rss.png/.match(content)).not_to eql nil
      expect(/<\/channel>/.match(content)).not_to eql nil
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
      it "should have a working RSS-feed /de/gcc/rss/channel/#{subject}" do
        expect(@browser.url).to match ODDB_URL
        link = @browser.link(:href => /rss\/channel\/#{subject}/)
        debug = /fachinfo/i.match(subject) ? true : false
        expect(is_link_valid?(link.href)).to eq true
        # expect(link.exists?).to be true
        check_for_rss_feed(link.href)
        @browser.back
      end
    }
    # 2021.01.22: Links for fachinfo and fachinfo-2008 failed via SPEC; but worked by hand
    # is the generated file just too big? (185 kB)W
  {
      'fachinfo-2008'   => 'Neue und geänderte Fachinformtionen im Schweizer Gesundheitsmarkt',
      'fachinfo-2023'   => 'Neue und geänderte Fachinformtionen im Schweizer Gesundheitsmarkt',
      'price_rise'      => 'Preiserhöhungen von Produkten in der Spezialitäten-Liste',
  }.each do
    |subject, test_string|
      it "should have a working /de/gcc/rss/channel/#{subject}.rss" do
        @filesBeforeDownload =  Dir.glob(GlobAllDownloads)
        url = ODDB_URL + '/de/gcc/rss/channel/' + subject + '.rss'
        url = "http://"+ url unless /http:/.match(url)
        expect(is_link_valid?(url)).to eq true
        check_for_rss_feed(url)
      end
  end

  after :all do
    Watir.default_timeout = @saved_timeout
    $stdout.puts "#{Time.now}: #{__FILE__} after all. Restored timeout to #{@saved_timeout}"
  end
end
