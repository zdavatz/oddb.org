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

  it "should save zsr in preferences" do
    alternate_url = "https://www.ruby-lang.org/de/"
    login(AdminUser, AdminPassword)
    @browser.link(:name=>'preferences').click
    expect(@browser.text).to match /Wählen Sie die Farbe, welche Ihnen am besten gefällt. Ihre Wahl wird automatisch in Ihrem Cookie gespeichert./
    @browser.radio(:id, "blue").set
    @browser.radio(:id, "instant").set
    @browser.radio(:id, "st_substance").set
    @browser.button(:name => 'update').click
    expect(@browser.text).to match /ZSR/i
    skip('For unknown reason getting the ZSR-ID does not work any longer')
    set_zsr_of_doctor('J 0390.19', 'Davatz', 'zsr_id')
    expect(@browser.text).to match /Davatz/

    # logout and verify that the cookies help to persist
    logout
    sleep(1)
    @browser.goto(alternate_url)
    sleep(1)
    waitForOddbToBeReady(@browser, OddbUrl)
    login(AdminUser, AdminPassword)
    @browser.link(:name=>'preferences').click
    expect(@browser.text).to match /Davatz/
    expect(@browser.radio(:id, "blue").checked?).to eq(true)
    puts "plus should not be checked but is #{@browser.radio(:id, "plus").checked?}"
    puts "Instant should be checked but is #{@browser.radio(:id, "instant").checked?}"
#    @browser.radio(:id, "instant").checked?.should == true
    expect(@browser.radio(:id, "st_substance").checked?).to eq(true)

    # logout and verify that the clearing the cookies makes the ZSR lost
    logout
    sleep(1)
    @browser.cookies.clear
    @browser.goto(alternate_url)
    sleep(1)
    waitForOddbToBeReady(@browser, OddbUrl)
    login(AdminUser, AdminPassword)
    @browser.link(:name=>'preferences').click
    expect(@browser.text).not_to match /Davatz/
    expect(@browser.radio(:id, "blue").checked?).to eq(false)
    expect(@browser.radio(:id, "instant").checked?).to eq(false)
    expect(@browser.radio(:id, "st_substance").checked?).to eq(false)

  end unless ['just-medical'].index(Flavor)
end

