#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'

describe "ch.oddb.org" do
  before :all do
    waitForOddbToBeReady(@browser, OddbUrl)
    login
  end

  after :all do
    @browser.close
  end

  it "should save zsr in preferences" do
    @browser.link(:name=>'preferences').click
    @browser.text.should match /Wählen Sie die Farbe, welche Ihnen am besten gefällt. Ihre Wahl wird automatisch in Ihrem Cookie gespeichert./
    @browser.radio(:id, "blue").set
    @browser.radio(:id, "instant").set
    @browser.radio(:id, "st_substance").set
    @browser.button(:value,"Speichern").click
    @browser.text.should match /ZSR/i
    set_zsr_of_doctor('J 0390.19', 'Davatz', 'zsr_id')
    @browser.text.should match /Davatz/

    # logout and verify that the cookies help to persist
    logout
    @browser.goto("www.google.com")
    sleep(1)
    waitForOddbToBeReady(@browser, OddbUrl)
    login
    @browser.link(:name=>'preferences').click
    @browser.text.should match /Davatz/
    @browser.radio(:id, "blue").checked?.should == true
    puts "plus should not be checked but is #{@browser.radio(:id, "plus").checked?}"
    puts "Instant should be checked but is #{@browser.radio(:id, "instant").checked?}"
#    @browser.radio(:id, "instant").checked?.should == true
    @browser.radio(:id, "st_substance").checked?.should == true

    # logout and verify that the clearing the cookies makes the ZSR lost
    logout
    @browser.cookies.clear
    @browser.goto("www.google.com")
    sleep(1)
    waitForOddbToBeReady(@browser, OddbUrl)
    login
    @browser.link(:name=>'preferences').click
    @browser.text.should_not match /Davatz/
    @browser.radio(:id, "blue").checked?.should == false
    @browser.radio(:id, "instant").checked?.should == false
    @browser.radio(:id, "st_substance").checked?.should == false

  end unless ['just-medical'].index(Flavor)
end

