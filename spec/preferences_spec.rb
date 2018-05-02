#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'


describe "ch.oddb.org" do
  before :all do
    waitForOddbToBeReady(@browser, OddbUrl)
  end

  after :all do
    @browser.close
  end

  infos = [ [nil,nil],
    [AdminUser, AdminPassword],
    [ViewerUser, ViewerPassword]].each do |info|
    user = info.first
    pw = info.last
    it "should save the color prefence as user #{user}" do
      user ? login(user, pw) : logout
      @browser.link(:name => 'de').click
      @browser.link(:name=>'preferences').click
      blue = @browser.radio(:id, "blue")
      expect(blue.exist?).to eql true
      red = @browser.radio(:id, "red")
      expect(red.exist?).to eql true
      blue.set
      @browser.radio(:id, "instant").set
      @browser.radio(:id, "st_substance").set
      expect(@browser.button(:name => 'update').exist?).to eql true
      @browser.button(:name => 'update').click
      expect(@browser.image(:src => /blue/).exist?).to eql true
      @browser.link(:visible_text => 'Analysen').wait_until_present
      @browser.link(:visible_text => 'Analysen').click
      expect(@browser.image(:src => /blue/).exist?).to eql true
      @browser.link(:name => 'en').click
      expect(@browser.image(:src => /blue/).exist?).to eql true
    end
  end
end

