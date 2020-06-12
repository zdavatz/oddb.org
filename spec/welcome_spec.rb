#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'
require 'pp'
require 'tmpdir'

describe "ch.oddb.org" do

  before :all do
    waitForOddbToBeReady(@browser, OddbUrl)
    logout
    login(ViewerUser, ViewerPassword)
  end

  ViewerDescription = "Willkommen #{A_USER_FIRST_NAME} #{A_USER_NAME}"

  before :each do
    @timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    while @browser.windows.size > 1
      @browser.windows.first.use
      @browser.windows.last.close if @browser.windows.last
    end
    @browser.goto OddbUrl
  end

  [ 'pharmacies', 'doctors', 'interactions', 'migel', 'user', 'hospitals', 'companies'].each do
    |zone|
    it "should be possible to see the sponsored log-in in zone #{zone}" do
      expect(@browser.link(name: zone).exists?).to eq(true)
      expect(@browser.text).to match (ViewerDescription)
      @browser.link(name: zone).click
      sleep(0.1) unless @browser.link(name: "logout").exists?
      expect(@browser.link(name: "logout").exists?).to eq(true)
      expect(@browser.text).to match (ViewerDescription) unless zone.eql?('doctors')
    end
  end

  after :each do
  end

  after :all do
    @browser.close if @browser
  end
end
