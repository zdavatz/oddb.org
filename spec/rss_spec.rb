#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'

@workThread = nil

describe "ch.oddb.org" do
 
  before :all do
    @idx = 0
    waitForOddbToBeReady(@browser, OddbUrl)
  end
  
  before :each do
    @browser.goto OddbUrl
  end

  after :each do
    @idx += 1
    createScreenshot(@browser, '_'+@idx.to_s)
    # sleep 
    @browser.goto OddbUrl
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
        @browser.goto OddbUrl
        expect(@browser.url).to match OddbUrl
        link = @browser.link(:href => /rss\/channel\/#{subject}/)
        debug = true
        expect(link.exists?).to be true
        if @browser.driver.browser.eql?(:firefox)
          @browser.goto(link.href)
          # We have problem as the fachinfo size is 26MB and goes back to 2006.
          $stdout.puts "#{Time.now}: #{@browser.url} start reading text" if debug
          content = @browser.text.clone
          File.open(subject + '.rss', 'w+' ) { |f| f.write content }
          expect(content).to match /#{test_string}/
          $stdout.puts "#{Time.now}: #{@browser.url} has is #{content.size} text.size long" if debug
        else
          skip "We know that Chromium handles rss -feeds differently"
        end
        @browser.back
      end
    }

  after :all do
    $stdout.puts "#{Time.now}: #{__FILE__} after all"
    @browser.close
  end
end
