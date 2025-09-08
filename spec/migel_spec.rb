File.join(File.dirname(__FILE__, 2), "..", "migel")
require "spec_helper"

describe "MigelSpec" do
  require "drb"
  DRB_TEST_URI = "druby://127.0.0.1:33000"
  MIGEL_SERVER = DRb::DRbObject.new(nil, DRB_TEST_URI)
  MIGEL_NOT_FOUND = "Such-Stichwort hat zu keinem Suchergebnis geführt"

  it "Finde Krücke" do
    skip("MIGEL_SERVER search does not work at the moment")
    expect(MIGEL_SERVER.migelid.search_by_migel_code("10.01.01.00.1").first.code).to eq "01.00.1"
    expect(MIGEL_SERVER.migelid.search_by_migel_code("10.01.01.00.1").first.name).to match(/Höhenausgleich für Gips und Orthese/)
    expect(MIGEL_SERVER.migelid.search_by_migel_code("10.02.01.00.1").first.name).to match(/2-stufige Höhenausgleichssohle für Gips/)
  end

  def select_migel(name)
    @browser.goto ODDB_URL
    @browser.link(name: "de").wait_until(&:present?).click
    @browser.link(name: "migel").wait_until(&:present?).click
    @browser.text_field(name: "search_query").set(name)
    @browser.button(name: "search").wait_until(&:present?).click
    expect(@browser.text).to match(/#{MIGEL_NOT_FOUND}|Suchresultat/o)
  end

  before :all do
    @idx = 0
    waitForOddbToBeReady(@browser, ODDB_URL)
    login
  end

  it "should correct result for Migel product 100101001" do
    select_migel("100101001")
    inhalt = @browser.text.dup
    expect(inhalt).not_to match MIGEL_NOT_FOUND
    expect(inhalt).to match(/GEHHILFEN/)
    expect(inhalt).to match(/Hand-\/Gehstöcke/)
    expect(inhalt).to match(/Krücken für Erwachsene, ergonomischer Griff, Kauf:/)
    #    expect(inhalt).to match(/Limitationstext.*Limitation :.*Nécessité d'une décharge de durée prolongée\(au moins 1 mois\)/m)
  end

  it "should correct result for Migel search_query/10.01.01.00.1" do
    select_migel("10.01.01.00.1")
    inhalt = @browser.text.dup
    expect(inhalt).not_to match MIGEL_NOT_FOUND
    expect(inhalt).to match(/GEHHILFEN/)
    expect(inhalt).to match(/Hand-\/Gehstöcke/)
    expect(inhalt).to match(/Krücken für Erwachsene, ergonomischer Griff, Kauf:/)
  end

  it "should be possible to find Krücke via MiGeL" do
    select_migel("Krücke")
    expect(@browser.text).not_to match MIGEL_NOT_FOUND
    expect(@browser.text).to match(/Beschreibung/)
    expect(@browser.text).to match(/Krücken/)
  end

  it "should correct result for Migel migel_code 100101" do
    select_migel("100101")
    inhalt = @browser.text.dup
    expect(inhalt).to match MIGEL_NOT_FOUND
    expect(inhalt).to match(/zu\s+vergütenden Mittel und Gegenstände./)
  end
end
