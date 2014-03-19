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
    @browser.link(:text=>'Deutsch').click unless /Vergleichen Sie einfach und schnell Medikamentenpreise./.match(@browser.text)
  end
  
  after :each do
    @idx += 1
    createScreenshot(@browser, '_'+@idx.to_s)
    # sleep 
    @browser.goto OddbUrl
  end
  
LinkDefinition = Struct.new(:language, :name, :url)
Links2Test = [
  LinkDefinition.new(:de, "AmiKo für Android", 'https://play.google.com/store/apps/details?id=com.ywesee.amiko.de&feature=search_result#?t=W251bGwsMSwyLDEsImNvbS55d2VzZWUuYW1pa28uZGUiXQ'),
  LinkDefinition.new(:fr, "CoMed pour Android", 'https://play.google.com/store/apps/details?id=com.ywesee.amiko.fr&feature=search_result#?t=W251bGwsMSwyLDEsImNvbS55d2VzZWUuYW1pa28uZGUiXQ'),
  LinkDefinition.new(:de, "AmiKo für OS X",                  'https://itunes.apple.com/us/app/amiko/id708142753?mt=12'),
  LinkDefinition.new(:fr, "CoMed pour OS X",                 'https://itunes.apple.com/us/app/comed/id710472327&mt=12'),
  LinkDefinition.new(:de, "AmiKo für Windows",               'http://pillbox.oddb.org/amikodesk_setup_32bit.exe'),
  LinkDefinition.new(:fr, "CoMed pour Windows",              'http://pillbox.oddb.org/comeddesk_setup_32bit.exe'),
]
  # We don't repeat here the tests that are in the smoketest!
  it "should have a link the various OS variant of AmiKo" do
    Links2Test.each{
      |link|
      next unless link.language.eql?(:de)
      @browser.link(:text=>link.name).exists?.should be true
      @browser.link(:text=>link.name).href.should == link.url
    }
    @browser.link(:text=>'Français').click
    Links2Test.each{
      |link|
      next unless link.language.eql?(:fr)
      @browser.link(:text=>link.name).exists?.should be true
      @browser.link(:text=>link.name).href.should == link.url
    }
  end

  after :all do
    @browser.close
  end
 
end
