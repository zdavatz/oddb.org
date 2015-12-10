#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'

@workThread = nil

describe "ch.oddb.org" do

  before :all do
    @idx = 0
    waitForOddbToBeReady(@browser, OddbUrl)
  end

  before :each do
    @browser.goto OddbUrl
    @browser.link(:text=>'Deutsch').click unless /Vergleichen Sie einfach und schnell Medikamentenpreise./.match(@browser.text)
  end

  after :each do
    @idx += 1
#    createScreenshot(@browser, '_'+@idx.to_s)
    # sleep
#    @browser.goto OddbUrl
  end

    def enter_search_to_field_by_name(search_text, field_name)
      idx = 1
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
      chooser.set(search_text)
      sleep idx*0.1
      chooser.send_keys(:down)
      sleep idx*0.1
      chooser.send_keys(:enter)
      sleep idx*0.1
    end

ArztDefinition = Struct.new(:name, :street, :fields)
AerzteDefinitions = [
  ArztDefinition.new('Züst',    'Bahnhofstr. 3',  { 'Facharzttitel:' => 'Allgemeine Innere Medizin, 2003, Schweiz',
                                                    'Fertigkeitsausweise:' => 'Sportmedizin, 2004, Schweiz',
                                                    'Korrespondenzsprache:' => 'deutsch',
                                                    'Staatsexamenjahr:' => '1992',
                                                    'EAN:' => '7601000254207',
                                                    'E-Mail:' => 'peter-zuest@bluewin.ch',
                                                    'Bewilligung Selbstdispensation' => 'Ja',
                                                    'BTM Berechtigung' => 'Ja',
                                                    'Telefon' => '055 6122353',
                                                    }),
  ArztDefinition.new('Pfister', 'Bahnhofstr. 16', { 'Facharzttitel:' => 'Allgemeine Innere Medizin, 1992, Schweiz'}),
]
  # We don't repeat here the tests that are in the smoketest!
  it "check doctors" do
    @browser.link(:name, 'doctors').click
    enter_search_to_field_by_name('Mollis', 'search_query');
    AerzteDefinitions.each {
                         |arzt|
                              expect(@browser.text).to match arzt.name
                              @browser.link(:text =>arzt.name).click
                              # don't know why we need to wait here, but it works!
                              sleep 0.5 unless @browser.link(:text => /vCard/).exists?
                              nrFiles = check_download(@browser.link(:text => /vCard/))
                              expect(nrFiles.size).to eq(1)
                              expect(File.size(nrFiles.first)).to be >= 100

                              inhalt = @browser.text
                              expect(inhalt).to match arzt.street
      arzt.fields.each{ |key, value| # puts "key #{key} val #{value}";
                   expect(inhalt).to match /#{key}.#{value}/m
                 }
                           # Check map link
                              @browser.link(:text => /map.search/).click
                              expect(@browser.url).to match /bahnhofstr/i
                              expect(@browser.url).to match /mollis/i
                              @browser.back
                           # go back to search result
                              @browser.back
                           }
  end unless ['just-medical'].index(Flavor)

  after :all do
    @browser.close
  end

end
