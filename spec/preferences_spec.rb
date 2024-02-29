#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'


describe "ch.oddb.org" do
  before :all do
    waitForOddbToBeReady(@browser, ODDB_URL)
  end

  after :all do
    @browser.close if @browser
  end

  def enter_preferences
    @browser.goto(ODDB_URL)
    @browser.link(name: 'de').wait_until(&:present?)
    @browser.link(name: 'de').click
    @browser.link(name: 'preferences').wait_until(&:present?)
    @browser.link(name: 'preferences').click
    @browser.radio(id:  "blue").wait_until(&:present?)
  end
  infos = [
    [nil,nil, 'Spital'],
    [ADMIN_USER, ADMIN_PASSWORD, 'Admin'],
    [ViewerUser, ViewerPassword, 'Arzt' ]
    ].each do |info|
    user = info[0]
    pw = info[1]
    link_text = info[2]
    it "should save the color prefence as #{user ? user : "not logged in"} using link #{link_text}" do
      user ? login(user, pw) : logout
      enter_preferences
      blue = @browser.radio(id:  "blue")
      expect(blue.exist?).to eql true
      red = @browser.radio(id:  "red")
      expect(red.exist?).to eql true
      blue.set
      @browser.radio(id:  "instant").set
      @browser.radio(id:  "st_substance").set
      expect(@browser.button(name: 'update').exist?).to eql true
      @browser.button(name: 'update').click
      @browser.image.wait_until(&:present?)
      @browser.goto(ODDB_URL)
      if user # we are logged in, the settings should be saved
        @browser.image(src: /blue/).wait_until(&:present?)
        expect(@browser.image(src: /blue/).exist?).to eql true
        @browser.link(visible_text: link_text).click
        @browser.image(src: /blue/).wait_until(&:present?)
        expect(@browser.image(src: /blue/).exist?).to eql true
        @browser.link(name: 'en').click
        @browser.image(src: /blue/).wait_until(&:present?)
        expect(@browser.image(src: /blue/).exist?).to eql true
      else
        @browser.image(src: /gcc/).wait_until(&:present?)
        expect(@browser.image(src: /gcc/).exist?).to eql true
        expect(@browser.image(src: /blue/).visible?).to eql false
        @browser.link(visible_text: link_text).click
        @browser.image(src: /gcc/).wait_until(&:present?)
        expect(@browser.image(src: /gcc/).exist?).to eql true
        expect(@browser.image(src: /blue/).visible?).to eql false
      end
    end
  end
end

