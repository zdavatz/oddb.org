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

  AddressCorrections = Struct.new(:name, :url_display, :url_correct)
  to_check = [
    # TODO: How can we ensure that we have valid EAN and OID?
      AddressCorrections.new('company',
                              OddbUrl + '/de/gcc/company/ean/7601001001121',
                              ),
      AddressCorrections.new('doctor',
                              OddbUrl + '/de/gcc/doctor/ean/7601000254344',
                             ),
      AddressCorrections.new('hospital',
                            OddbUrl + '/de/gcc/hospital/ean/7601002002592',
                            ),
      AddressCorrections.new('pharmacy',
                            OddbUrl + '/de/gcc/pharmacy/ean/7601001380028',
                            ),
    ]
  to_check[0..0].each {
    |correction|
    it "should be possible to correct an address for a #{correction.name}" do
      login(ViewerUser,  ViewerPassword)
      @browser.goto correction.url_display
      sleep(1) unless @browser.button(:name, "correct").exist?
      unless @browser.button(:name, "correct").exist?
        skip "Login failed. Please check your setup"
      end
      @browser.button(:name, "correct").click
      expect(@browser.url).to match /\/suggest_address\/.*\/address\//
      @browser.text_field(:name, "email").set("ngiger@ywesee.com")
      @browser.textarea(:name, "message").set("Testbemerkung")
      @browser.textarea(:name, "additional_lines").set("Neue Addresszeile")
      @browser.button(:value,"Vorschlag senden").click
      expect(@browser.text).not_to match /Die von Ihnen gewünschte Information ist leider nicht mehr vorhanden./
      expect(@browser.text).to match /Vielen Dank, Ihr Vorschlag wurde versendet./
      ean13 = /\d{13}/.match(@browser.url)
      skip "Could not find Oddb_log_file #{Oddb_log_file}" unless File.exists?(Oddb_log_file)
      expect(File.exist?(Oddb_log_file)).to eql true
      cmd = "tail -1 #{Oddb_log_file}"
      log_line =  `#{cmd}`.split
      url_from_received_mail = /http:[^\s]+/.match(log_line.last).to_s
      puts "oddb_log_file #{Oddb_log_file} url_from_received_mail #{url_from_received_mail}"

      # As a normal user I must not be view the change
      expect(login(ViewerUser,  ViewerPassword)).to eq true
      @browser.goto url_from_received_mail
      sleep 0.1
      text = @browser.text.to_s.clone
      # puts "URL #{@browser.url} with :#{text}"
      expect(text).not_to match /Momentan Aktive Adresse/

      # As a admin user I must not be view the change
      logout
      expect(login(AdminUser, AdminPassword)).to eq true
      @browser.goto url_from_received_mail
      expect(@browser.url).to eq(url_from_received_mail)
      sleep 1
      text = @browser.text.clone
      expect(@browser.text).not_to match /Die von Ihnen gewünschte Information ist leider nicht mehr vorhanden./
      expect(@browser.button(:name => 'accept').exist?).to eq(true)
      expect(@browser.text).to match /Momentan Aktive Adresse/
      expect(@browser.text).to match /E-Mail für Rückfragen/
      expect(@browser.url).to eq(url_from_received_mail)
    end
  }  unless ['just-medical'].index(Flavor)


  after :each do
    logout
  end

  after :all do
    @browser.close
  end
end