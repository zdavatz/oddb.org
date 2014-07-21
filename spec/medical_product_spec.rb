#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'
require 'pp'

describe "ch.oddb.org" do

  RegExpSubstance = /Substanz\s+Stärke(\s+.+\s+|\s+)Galenische Form\s*(\w+)/m
  before :all do
    @idx = 0
    waitForOddbToBeReady(@browser, OddbUrl)
    login
  end

  before :each do
    @browser.goto OddbUrl
  end

  after :each do
    @idx += 1
    createScreenshot(@browser, '_' + File.basename(__FILE__,'.rb') + '_'+@idx.to_s)
    @browser.goto OddbUrl
  end

  it "should work as show/reg for sinovial" do
    url = "#{OddbUrl}/de/gcc/show/reg/1229109224/seq/09/pack/224"
    @browser.goto url
    @browser.text.should match RegExpSubstance
  end
  
  it "should work as show/reg for viagra" do
    url = "#{OddbUrl}/de/gcc/show/reg/62949/seq/01/pack/001"
    @browser.goto url
    @browser.text.should match RegExpSubstance
  end

  after :all do
    @browser.close
  end
 
end
