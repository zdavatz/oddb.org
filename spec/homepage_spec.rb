#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'
require 'custom/lookandfeelbase'

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
  # We don't repeat here the tests that are in the smoketest!
  it "should have a link the various OS variant of AmiKo" do
      de = flexmock('session',
                         :flavor => Flavor,
                         :language => 'de')
      lnf_de = ODDB::LookandfeelBase.new(de)
      fr = flexmock('session',
                         :flavor => Flavor,
                         :language => 'fr')
      lnf_fr = ODDB::LookandfeelBase.new(fr)
    @links2Test = [
      LinkDefinition.new(:de, "AmiKo für Android",  lnf_de.lookup(:download_amiko_link)),
      LinkDefinition.new(:fr, "CoMed pour Android", lnf_fr.lookup(:download_amiko_link)),
      LinkDefinition.new(:de, "AmiKo für OS X",     lnf_de.lookup(:download_amiko_os_x_link)),
      LinkDefinition.new(:fr, "CoMed pour OS X",    lnf_fr.lookup(:download_amiko_os_x_link)),
      LinkDefinition.new(:de, "AmiKo für Windows",  lnf_de.lookup(:download_amiko_win_link)),
      LinkDefinition.new(:fr, "CoMed pour Windows", lnf_fr.lookup(:download_amiko_win_link)),
    ]
    @links2Test.each{
      |link|
      next unless link.language.eql?(:de)
      expect(@browser.link(:text=>link.name).exists?).to be true
      expect(@browser.link(:text=>link.name).href).to eq(link.url)
    }
    @browser.link(:text=>'Français').click
    @links2Test.each{
      |link|
      next unless link.language.eql?(:fr)
      expect(@browser.link(:text=>link.name).exists?).to be true
      expect(@browser.link(:text=>link.name).href).to eq(link.url)
    }
  end unless ['just-medical'].index(Flavor)

  after :all do
    @browser.close
  end
 
end
