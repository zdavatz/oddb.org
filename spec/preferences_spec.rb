#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'


describe "ch.oddb.org" do
  before :all do
    waitForOddbToBeReady(@browser, OddbUrl)
  end

  after :all do
    @browser.close if @browser
  end

  infos = [
    [nil,nil, 'Spital'],
    [AdminUser, AdminPassword, 'Admin'],
    [ViewerUser, ViewerPassword, 'Arzt' ]
    ].each do |info|
    user = info[0]
    pw = info[1]
    link_text = info[2]
    it "should save the color prefence as user #{user} using link #{link_text}" do
      user ? login(user, pw) : logout
      @browser.link(name: 'de').click
      @browser.link(name: 'preferences').click
      blue = @browser.radio(id:  "blue")
      expect(blue.exist?).to eql true
      red = @browser.radio(id:  "red")
      expect(red.exist?).to eql true
      blue.set
      @browser.radio(id:  "instant").set
      @browser.radio(id:  "st_substance").set
      expect(@browser.button(name: 'update').exist?).to eql true
      @browser.button(name: 'update').click
      expect(@browser.image(src: /blue/).exist?).to eql true
      Watir::Anchor#wait_until(@browser.link(visible_text: link_text)(&:present?))
#      require 'debug'; binding.break
      @browser.link(visible_text: link_text).click
      expect(@browser.image(src: /blue/).exist?).to eql true
      @browser.link(name: 'en').click
      expect(@browser.image(src: /blue/).exist?).to eql true
    end
  end
end

