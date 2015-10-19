#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'
require 'pp'
require 'tmpdir'
require "selenium-webdriver"

describe "ch.oddb.org" do

  def enter_search_to_field_by_name(search_text, field_name)
    idx = -2
    chooser = @browser.text_field(:name,field_name)
    0.upto(2).each{ 
      |idx|
      break if chooser and chooser.present?
      sleep 1
      chooser = @browser.text_field(:name,field_name)
    }
    unless chooser and chooser.present?
      msg = "idx #{idx} could not find textfield #{field_name} in #{@browser.url}"
      puts msg
      # require 'pry'; binding.pry
      raise msg
    end
    0.upto(30).each{ |idx|
                      begin
                        chooser.set(search_text)
                        sleep idx*0.1
                        chooser.send_keys(:down)
                        sleep idx*0.1
                        chooser.send_keys(:enter)
                        sleep idx*0.1
                        value = chooser.value
                        break unless /#{search_text}/.match(value)
                        sleep 0.5
                      rescue StandardError => e
                        puts "in rescue"
                        createScreenshot(@browser, "rescue_#{search_text}_#{__LINE__}")
                        puts e.inspect
                        puts caller[0..5]
                        return
                      end
                    }
    chooser.set(chooser.value + "\n")
    # puts "chooser value #{chooser.value} text  #{chooser.text}"
    createScreenshot(@browser, "_#{search_text}_#{__LINE__}")
  end
  
  before :all do
    $prescription_test_id = 1
    waitForOddbToBeReady(@browser, OddbUrl)
    logout
  end

  before :each do
    @timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    # puts "before #{$prescription_test_id} with #{@browser.windows.size} windows"
    while @browser.windows.size > 1
      @browser.windows.first.use
      @browser.windows.last.close if @browser.windows.last
    end
    @browser.goto OddbUrl
  end

  AddressCorrections = Struct.new(:name, :url_display, :url_correct, :url_from_received_mail)
  to_check = [
    # TODO: How can we ensure that we have valid EAN and OID?
      AddressCorrections.new('company',
                              OddbUrl + '/de/gcc/company/ean/7601001001121',
                              OddbUrl + '/de/gcc/suggest_address/company/7601001001121/address/0/zone/companies',
                              OddbUrl + '/de/gcc/address_suggestion/company/7601001001121/oid/32401513',
                              ),
      AddressCorrections.new('doctor',
                              OddbUrl + '/de/gcc/doctor/ean/7601000254344',
                              OddbUrl + '/de/gcc/suggest_address/doctor/7601000254344/address/0/zone/doctors',
                              OddbUrl + '/de/gcc/address_suggestion/doctor/7601000254344/oid/32401513',
                             ),
      AddressCorrections.new('hospital',
                            OddbUrl + '/de/gcc/hospital/ean/7601002002592',
                            OddbUrl + '/de/gcc/suggest_address/hospital/7601002002592/address/0/zone/hospitals',
                            OddbUrl + '/de/gcc/address_suggestion/hospital/7601002002592/oid/32401511',
                            ),
      AddressCorrections.new('pharmacy',
                            OddbUrl + '/de/gcc/pharmacy/ean/7601001380028',
                            OddbUrl + '/de/gcc/suggest_address/pharmacy/7601001380028/address/0/zone/pharmacies',
                            OddbUrl + '/de/gcc/address_suggestion/pharmacy/7601001380028/oid/32401536',
                            ),
    ]
  to_check.each {
    |correction|
    it "should be possible to correct an address for a #{correction.name}" do
      login(ViewerUser,  ViewerPassword)
      @browser.goto correction.url_display
      sleep(1) unless @browser.button(:name, "correct").exist?
      unless @browser.button(:name, "correct").exist?
        # require 'pry'; binding.pry
        skip "Login failed. Please check your setup"
      end
      @browser.button(:name, "correct").click
      expect(@browser.url).to eq(correction.url_correct)
      @browser.text_field(:name, "email").set("ngiger@ywesee.com")
      @browser.textarea(:name, "message").set("Testbemerkung")
      @browser.textarea(:name, "additional_lines").set("Neue Addresszeile")
      @browser.button(:value,"Vorschlag senden").click
      sleep(1)
      expect(@browser.text).not_to match /Die von Ihnen gewünschte Information ist leider nicht mehr vorhanden./
      expect(@browser.text).to match /Vielen Dank, Ihr Vorschlag wurde versendet./
    end
  }  unless ['just-medical'].index(Flavor)
  to_check.each {
    |correction|
    it "should be possible to visit the correction for #{correction.name}" do
      login
      @browser.goto correction.url_from_received_mail
      expect(@browser.button(:name => 'accept').exist?).to eq(true)
      expect(@browser.text).to match /Momentan Aktive Adresse/
      expect(@browser.text).to match /E-Mail für Rückfragen/
    end
  }  unless ['just-medical'].index(Flavor)

  after :each do
    logout
  end

  after :all do
    @browser.close
  end
end