# encoding: utf-8
migelDir= File.join(File.dirname(File.dirname(__FILE__)), '..', 'migel')
require 'spec_helper'

describe "MigelSpec" do
  require 'drb'
  DRB_TEST_URI = 'druby://127.0.0.1:33000'
  MIGEL_SERVER = DRb::DRbObject.new(nil, DRB_TEST_URI)

  it "Finde Krücke" do
    skip("MIGEL_SERVER search does not work at the moment")
    expect(MIGEL_SERVER.migelid.search_by_migel_code('10.01.01.00.1').first.code).to eq '01.00.1'
    expect(MIGEL_SERVER.migelid.search_by_migel_code('10.01.01.00.1').first.name).to match /Höhenausgleich für Gips und Orthese/
    expect(MIGEL_SERVER.migelid.search_by_migel_code('10.02.01.00.1').first.name).to match /2-stufige Höhenausgleichssohle für Gips/
  end

  before :all do
    @idx = 0
    waitForOddbToBeReady(@browser, ODDB_URL)
    login
  end

  it "should correct result for Migel product 100101011" do
    url = ODDB_URL + '/de/gcc/migel_search/migel_product/100101011'
    @browser.goto(url)
    inhalt = @browser.text.dup
    expect(inhalt).not_to match LeeresResult
    expect(inhalt).to match /MiGeL-Code.*10.01.01.01.1/
    expect(inhalt).to match /GEHHILFEN/
    expect(inhalt).to match /Beschreibung Krücken für Erwachsene, anatomischer- \/ orthopädischer Griff, Kauf/
    expect(inhalt).to match /Limitationstext.*Limitation :.*Nécessité d'une décharge de durée prolongée\(au moins 1 mois\)/m
  end

  it "should correct result for Migel search_query/10.01.01.00.1" do
    @browser.link(name: 'migel').click
    @browser.text_field(name: "search_query").wait_until(&:present?)
    @browser.text_field(name: "search_query").value = "10.01.01.00.1"
    @browser.button(name: 'search').click
    @browser.text_field.wait_until(&:present?)
    inhalt = @browser.text.dup
    expect(inhalt).not_to match LeeresResult
    expect(inhalt).to match /GEHHILFEN/
    expect(inhalt).to match /Höhenausgleich für Gips und Orthesen/
    expect(inhalt).to match /2-stufige Höhenausgleichssohle für Gips/
  end

  it "should be possible to find Krücke via MiGeL" do
    @browser.link(name: 'migel').click
    @browser.text_field(name: "search_query").wait_until(&:present?)
    @browser.text_field(name: "search_query").value = "Krücke"
    @browser.button(name: 'search').click
    @browser.text_field.wait_until(&:present?)
    expect(@browser.text).not_to match LeeresResult
    expect(@browser.text).to match /Beschreibung/
    expect(@browser.text).to match /Krücken/
  end

  it "should correct result for Migel migel_code 100101" do
    url = ODDB_URL + '/de/gcc/migel_search/migel_code/100101'
    @browser.goto(url)
    inhalt = @browser.text.dup
    expect(inhalt).not_to match LeeresResult
    expect(inhalt).to match /Es wurden keine Einträge gefunden./
  end
end
