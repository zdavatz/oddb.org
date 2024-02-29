#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'
require 'pp'
require 'tmpdir'
require "selenium-webdriver"

describe "ch.oddb.org" do
  before :all do
    expect(File.exist?(Oddb_log_file)).to eql true
    waitForOddbToBeReady(@browser, ODDB_URL)
    logout
  end

  before :each do
    @timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    while @browser.windows.size > 1
      @browser.windows.first.use
      @browser.windows.last.close if @browser.windows.last
    end
    @browser.goto ODDB_URL
  end

  AddressCorrections = Struct.new(:name, :url_display, :url_correct)
  root_url = ODDB_URL.sub(':443','')
  it "should be possible to correct an address for a doctor when not logged in" do
    skip "We should add a check for the capital of Switzerland"
  end

  to_check = [
    # TODO: How can we ensure that we have valid EAN and OID?
      AddressCorrections.new('company',  root_url + '/de/gcc/company/ean/7601001392717',),
      AddressCorrections.new('doctor',   root_url + '/de/gcc/doctor/ean/7601000254207',),
      AddressCorrections.new('hospital', root_url + '/de/gcc/hospital/ean/7601002128780',),
      AddressCorrections.new('pharmacy', root_url + '/de/gcc/pharmacy/ean/7601001409958',),
    ]
  to_check.each {
    |correction|
    it "should be possible to correct an address for a #{correction.name}" do
      expect(login).to eq true
      @browser.goto correction.url_display
      sleep(1) unless @browser.button(name:  "correct").exist?
      unless @browser.button(name:  "correct").exist?
        skip "Login failed. Please check your setup"
      end
      @browser.button(name:  "correct").click
      @browser.tr(text: /Einstellung/).wait_until(&:present?)
      expect(@browser.url).to match /\/suggest_address\/.*\/address\//
      @browser.text_field(name:  "email").set("ngiger@ywesee.com")
      @browser.textarea(name:  "message").set("Testbemerkung")
      @browser.textarea(name:  "additional_lines").set("Neue Addresszeile")
      @browser.select_list(name: "address_type").click
      @browser.option(text: 'Arbeitsplatz').click
      @browser.select_list(name: "canton").click
      @browser.option(text: 'GL').click
      @browser.button(value: "Vorschlag senden").click
      expect(@browser.text).not_to match /Die von Ihnen gewünschte Information ist leider nicht mehr vorhanden./
      expect(@browser.text).to match /Vielen Dank, Ihr Vorschlag wurde versendet./
      ean13 = /\d{13}/.match(@browser.url)
      skip "Could not find Oddb_log_file #{Oddb_log_file}" unless File.exist?(Oddb_log_file)
      expect(File.exist?(Oddb_log_file)).to eql true
      cmd = "tail -1 #{Oddb_log_file}"
      log_line =  CGI.unescape(`#{cmd}`).split
      src =  log_line.find{|x| /http(|s):[^\s]+/.match(x) }
      url_from_received_mail = /http(|s):[^\s"]+/.match(src)[0]
      puts "oddb_log_file #{Oddb_log_file} url_from_received_mail #{url_from_received_mail}"
      expect(url_from_received_mail).not_to eq ''

      # As a normal user I must not be view the change
      expect(login(ViewerUser,  ViewerPassword)).to eq true
      @browser.goto url_from_received_mail
      sleep 0.1
      text = @browser.text.to_s.clone
      # puts "URL #{@browser.url} with :#{text}"
      expect(text).not_to match /Momentan Aktive Adresse/

      # As a admin user I should be able view the change
      logout
      expect(login(ADMIN_USER, ADMIN_PASSWORD)).to eq true
      @browser.goto url_from_received_mail
      expect(@browser.url).to eq(url_from_received_mail)
      sleep 1
      text = @browser.text.clone
      expect(@browser.text).not_to match /Die von Ihnen gewünschte Information ist leider nicht mehr vorhanden./
      expect(@browser.button(name: 'accept').exist?).to eq(true)
      expect(@browser.text).to match /Momentan Aktive Adresse/
      expect(@browser.text).to match /E-Mail für Rückfragen/
      expect(@browser.url).to eq(url_from_received_mail)
    end
  }  unless ['just-medical'].index(Flavor)


  after :each do
    logout
  end

  after :all do
    @browser.close if @browser
  end
end
