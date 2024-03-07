#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'
require 'pp'

describe "ch.oddb.org" do

  RegExpSubstance = /Galenische Form\s*(\w+)[^\n]*\n+(Excipiens\s+([\w\s]+)\n+)*\s+Wirkstoffe\s+Stärke\n+(\w+)/m
  before :all do
    @idx = 0
    waitForOddbToBeReady(@browser, ODDB_URL)
    login
  end

  before :each do
    @browser.goto ODDB_URL
  end

  after :each do
    @idx += 1
    createScreenshot(@browser, '_' + File.basename(__FILE__,'.rb') + '_'+@idx.to_s)
    @browser.goto ODDB_URL
  end

  it "should work as show/reg for sinovial" do
    url = "#{ODDB_URL}/de/#{Flavor}/show/reg/1229109224/seq/09/pack/224"
    @browser.goto url
    expect(@browser.text).to match /Galenische Form\s+Injektionslösung in Fertigspritze/
  end

  it "should work as show/reg for viagra" do
    url = "#{ODDB_URL}/de/#{Flavor}/show/reg/62949/seq/01/pack/001"
    @browser.goto url
    expect(@browser.text).to match RegExpSubstance
  end

  after :all do
    @browser.close if @browser
  end

end
