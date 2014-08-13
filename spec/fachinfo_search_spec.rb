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
    0.upto(5).each{ 
      |idx|
      break if chooser and chooser.present?
      sleep 1
      chooser = @browser.text_field(:name,field_name)
    }
    unless chooser and chooser.present?
      msg = "idx #{idx} could not find textfield prescription_searchbar in #{@browser.url}"
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
    puts "chooser set to #{chooser.value}"
    createScreenshot(@browser, "_#{search_text}_#{__LINE__}")
  end
  
  before :all do
    $prescription_test_id = 1
    waitForOddbToBeReady(@browser, OddbUrl)
    login
  end

  before :each do
    @timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    # puts "before #{$prescription_test_id} with #{@browser.windows.size} windows"
    while @browser.windows.size > 1
      @browser.windows.first.use
      @browser.windows.last.close if @browser.windows.last
    end
    @browser.goto OddbUrl
    if @browser.link(:name=>'fachinfo_search').exists?
      puts "Going to search FI erweitert"
      @browser.link(:name=>'fachinfo_search').click
    end
  end

  after :each do
    createScreenshot(@browser, '_'+$prescription_test_id.to_s) if @browser
    $prescription_test_id += 1
  end


  it "should show the chapter unwanted effects for Schwindel and show 61374 Quetiapin Sandoz:" do
    @browser.select_list(:name, "fachinfo_search_type").select(/Unerw.Wirk/i)
    # require 'pry'; binding.pry
    @browser.checkbox(:name,'fachinfo_search_full_text').set
    @browser.text_field(:name,'fachinfo_search_term').set('Gewichtszunahme')
    enter_search_to_field_by_name('Quetiapin Sandoz', 'searchbar');
    @browser.button(:name, "search").click
    @browser.text.should match /Sehr häufig: Gewichtszunahme/
  end

end