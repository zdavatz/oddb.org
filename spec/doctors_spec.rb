#!/usr/bin/env ruby
# encoding: utf-8
require 'spec_helper'

@workThread = nil

describe "ch.oddb.org" do

  before :all do
    @idx = 0
    waitForOddbToBeReady(@browser, ODDB_URL)
  end

  before :each do
    @browser.goto ODDB_URL
    @browser.link(visible_text: 'Deutsch').click unless /Vergleichen Sie einfach und schnell Medikamentenpreise./.match(@browser.text)
  end

  after :each do
    @idx += 1
#    createScreenshot(@browser, '_'+@idx.to_s)
    # sleep
#    @browser.goto ODDB_URL
  end
ArztDefinition = Struct.new(:name, :street, :fields)
AerzteDefinitions = [
  ArztDefinition.new('Albert',    /Stephan Albert\n8400 Winterthur/,
                     { 'Facharzttitel:' => 'Allgemeine Innere Medizin, 1998, Schweiz',
                                                    'Fertigkeitsausweise:' => 'Praxislabor, 2002, Schweiz',
                                                    'Korrespondenzsprache:' => 'deutsch',
                                                    'Staatsexamenjahr:' => '',
                                                    'EAN:' => '',
                                                    'E-Mail:' => '',
                                                    'Bewilligung Selbstdispensation' => 'Ja',
                                                    'BTM Berechtigung' => 'Ja',
                                                    'Telefon' => '052 213.21.00',
                                                    }),
  ArztDefinition.new('Andreae', /Postfach 144.*8408 Winterthur/mi,
                      { 'Facharzttitel:' => 'Psychiatrie und Psychotherapie, 1987, Schweiz',
                                                  'EAN:' => '7601000239983'}),
]

  ['Winterthur', 'Näfels', 'Mollis'].each do |village|
    it "should find at least one doctor for #{village}" do
      waitForOddbToBeReady(@browser, ODDB_URL)
      @browser.link(name: 'doctors').click
      enter_search_to_field_by_name(village, 'search_query');
    end
  end

  # We don't repeat here the tests that are in the smoketest!
  it "check doctors" do
    waitForOddbToBeReady(@browser, ODDB_URL)
    @browser.link(name: 'doctors').click
    enter_search_to_field_by_name('Winterthur', 'search_query');
    AerzteDefinitions.each {
                         |arzt|
                              @browser.link(name: 'name').wait_until(&:present?)
                              expect(@browser.text).to match arzt.name
                              @browser.link(visible_text: arzt.name).click
                              # don't know why we need to wait here, but it works!
                              @browser.link(visible_text: /vCard/).wait_until(&:present?)
                              expect(is_link_valid?(@browser.link(visible_text: /vCard/).href)).to eql true

                              inhalt = @browser.text
                              expect(inhalt).to match arzt.street
      arzt.fields.each{ |key, value| # puts "key #{key} val #{value}";
                   expect(inhalt).to match /#{key}.#{value}/m
                 }
                           # Check map link
                              @browser.link(visible_text: /map.search/).click
                              expect(@browser.url).to match /840\d/
                              @browser.back
                           # go back to search result
                              @browser.back
                           }
  end unless ['just-medical'].index(Flavor)

  after :all do
    @browser.close if @browser
  end

end
