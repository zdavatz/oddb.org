#!/usr/bin/env ruby
# encoding: utf-8
# kate: space-indent on; indent-width 2; mixedindent off; indent-mode ruby;
require 'spec_helper'
require 'pp'
require 'tmpdir'

describe "ch.oddb.org" do

  def enter_search_to_field_by_name(search_text, field_name)
    idx = -2
    chooser = @browser.text_field(name: field_name)
    0.upto(2).each{
      |idx|
      break if chooser and chooser.present?
      sleep 1
      chooser = @browser.text_field(name: field_name)
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
    $searchbar_test_id = 1
    waitForOddbToBeReady(@browser, OddbUrl)
    login
  end

  before :each do
    @timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    # puts "before #{$searchbar_test_id} with #{@browser.windows.size} windows"
    while @browser.windows.size > 1
      @browser.windows.first.use
      @browser.windows.last.close if @browser.windows.last
    end
    @browser.goto OddbUrl
  end

  after :each do
    createScreenshot(@browser, '_'+$searchbar_test_id.to_s) if @browser
    $searchbar_test_id += 1
  end

  it "should work with the privatetemplate searchbar" do
    field_name = 'search_query'
    @browser.links.find{ |item| item.href.match(/fachinfo\/reg/) != nil}.click;  small_delay
    expect(@browser.text_field(name: field_name).text).to eq("")
    expect(@browser.text_field(name: field_name).value).to eq("HIER Suchbegriff eingeben")
    @browser.text_field(name: field_name).value = 'Aspirin'
    @browser.text_field(name: field_name).send_keys :enter
    expect(@browser.url).to match /search_query/
    expect(@browser.url).to match /Aspirin/
    expect(@browser.text.scan(/aspirin/i).count).to be > 10 # was 17 in august 2014
  end unless ['just-medical'].index(Flavor)

  it "should be possible to find Dr. Peter Schönbucher via doctors " do
    @browser.link(name: "doctors").click;  small_delay

    @browser.text_field(name: "search_query").value = "Schönbucher"
    @browser.button(name: 'search').click;  small_delay

    expect(@browser.text).to match /Schönbucher Peter/
  end unless ['just-medical'].index(Flavor)

  it "should be possible to find Abacavir via Wirkstoffe" do
    if  @browser.link(name: 'substances').exists?
      @browser.link(name: 'substances').click;  small_delay
    end
    # @browser.text.should_not match /substance_search_explain/
    @browser.text_field(name: "search_query").value = "Abacavirum"
    @browser.select_list(name: "search_type").select("Inhaltsstoff")

    expect(@browser.text).not_to match LeeresResult
    expect(@browser.text).to match /Deutsche Bezeichnung|Präparat/
    expect(@browser.text).to match /Abacavir/
  end unless ['just-medical'].index(Flavor)

  it "should return an empty list when entering a non existing name in the drugs-result search button" do
    invalid = "THIS_NAME_SHOULD_NOT_BE_FOUND"
    name = "Keppra"
    @browser.text_field(name: "search_query").value = name
    @browser.select_list(name: "search_type").select("Preisvergleich")
    @browser.text_field(name: "search_query").send_keys :return
    expect(@browser.url).to match /#{name}/i
    expect(@browser.text_field(visible_text: /#{name}/i).exist?).to eql true
    expect(@browser.text).not_to match LeeresResult

    expect(@browser.text).not_to match LeeresResult
    @browser.text_field(name: "search_query").value = invalid
    @browser.text_field(name: "search_query").send_keys :return
    expect(@browser.url).to match(invalid)
    expect(@browser.url).not_to match /#{name}/i
    expect(@browser.text_field(visible_text: /#{name}/i).exist?).to eql false
  end unless ['just-medical'].index(Flavor)

  it "should be possible to find the Kantonsspital Glarus via Spital" do
    @browser.link(name: 'hospitals').click;  small_delay

    # @browser.text.should_not match /substance_search_explain/
    @browser.text_field(name: "search_query").value = "Glarus"
    @browser.button(name: 'search').click;  small_delay

    expect(@browser.text).not_to match LeeresResult
    expect(@browser.text).to match /Abteilung/
    expect(@browser.text).to match /Kantonsspital Glarus/
  end unless ['just-medical'].index(Flavor)

  it "should be possible to find Krücke via MiGeL" do
    @browser.link(name: 'migel').click;  small_delay

    # @browser.text.should_not match /substance_search_explain/
    @browser.text_field(name: "search_query").value = "Krücke"
    @browser.button(name: 'search').click;  small_delay

    expect(@browser.text).not_to match LeeresResult
    expect(@browser.text).to match /Beschreibung/
    expect(@browser.text).to match /Krücken/
  end unless ['just-medical'].index(Flavor)

  it "should be possible to find Novartis via Zulassungsinhaber" do
    @browser.link(name: 'companies').click;  small_delay

    # @browser.text.should_not match /substance_search_explain/
    @browser.text_field(name: "search_query").value = "Novartis"
    @browser.button(name: 'search').click;  small_delay

    expect(@browser.text).not_to match LeeresResult
    text = @browser.text.clone
    # Aktuell Einträge come only when we are logged in as admin user
    expect(text).to match /Zulassungs­inhaber Geschäftsfeld/
    expect(text).to match /Novartis Pharma Schweiz AG/
  end unless ['just-medical'].index(Flavor)

  pending "should work with the notify searchbar" do
    expect(false).to eq(true)
  end

  pending "should work with the notify_confirm searchbar" do
    expect(false).to eq(true)
  end

  pending "should work with the drugs/vaccines searchbar" do
    expect(false).to eq(true)
  end

  pending "should work with the drugs/limitationtexts searchbar" do
    expect(false).to eq(true)
  end

  pending "should work with the drugs/feedbacks searchbar" do
    expect(false).to eq(true)
  end

  pending "should work with the drugs/patinfos searchbar" do
    expect(false).to eq(true)
  end

  pending "should work with the  drugs/sequences searchbar" do
    expect(false).to eq(true)
  end

  pending "should work with the drugs/resultlimit searchbar" do
    expect(false).to eq(true)
  end

  pending "should work with the substances/result searchbar" do
    expect(false).to eq(true)
  end

  # Other ATC code for Adenosin like Andere Diagnostika (V04CX) and
  # Lösungs- und Verdünnungsmittel, inkl. Spüllösungen (V07AB) come from no longer active
  it "should show only ATC-Code for C01EB10 for Adenosin" do
    @browser.link(name: 'drugs').click;  small_delay

    @browser.select_list(name: "search_type").select("Preisvergleich und Inhaltsstoff")
    @browser.text_field(name: "search_query").value = "Adenosin"
    @browser.button(name: 'search').click;  small_delay
    text = @browser.text.clone
    expect(text).not_to match LeeresResult
    expect(text).to match('C01EB10')
    expect(text).not_to match('V04CX')
    expect(text).not_to match('V07AB')
  end unless ['just-medical'].index(Flavor)


  it "should show no drugs for Gentamycin in combined search" do
    @browser.link(name: 'drugs').click;  small_delay

    @browser.select_list(name: "search_type").select("Preisvergleich und Inhaltsstoff")
    @browser.text_field(name: "search_query").value = "Gentamycin"
    @browser.button(name: 'search').click;  small_delay
    text = @browser.text.clone
    expect(text).to match LeeresResult
  end unless ['just-medical'].index(Flavor)

  it "should show no drugs for Gentamycin in price search" do
    @browser.link(name: 'drugs').click;

    @browser.select_list(name: "search_type").select("Preisvergleich")
    @browser.text_field(name: "search_query").value = "Gentamycin"
    @browser.button(name: 'search').click;  small_delay
    text = @browser.text.clone
    expect(text).to match LeeresResult
  end unless ['just-medical'].index(Flavor)

  it "should show no drugs for Iscover" do
    @browser.link(name: 'drugs').click;  small_delay

    @browser.select_list(name: "search_type").select("Preisvergleich und Inhaltsstoff")
    @browser.text_field(name: "search_query").value = "Iscover"
    @browser.button(name: 'search').click;  small_delay
    text = @browser.text.clone
    expect(text).to match LeeresResult
  end unless ['just-medical'].index(Flavor)

  it "should show no drugs for Fortex in combined search" do
    @browser.link(name: 'drugs').click;  small_delay

    @browser.select_list(name: "search_type").select("Preisvergleich und Inhaltsstoff")
    @browser.text_field(name: "search_query").value = "Fortex"
    @browser.button(name: 'search').click;  small_delay
    text = @browser.text.clone
    expect(text).to match LeeresResult
  end unless ['just-medical'].index(Flavor)

  it "should show no drugs for Fortex via unwanted effects search" do
    # Fortext should not show up, as it was never registered in Switzerland
    # However we have not yet had the time to fix this problem
    @browser.link(name: 'drugs').click;  small_delay

    @browser.select_list(name: "search_type").select("Unerwünschte Wirkung")
    @browser.text_field(name: "search_query").value = "Fortex"
    @browser.button(name: 'search').click;  small_delay
    text = @browser.text.clone
    expect(text).to match LeeresResult
  end unless ['just-medical'].index(Flavor)

  it "should be possible to find Budenofalk and Budesonid Sandoz via combined search" do
    @browser.link(name: 'drugs').click;  small_delay

    @browser.select_list(name: "search_type").select("Preisvergleich und Inhaltsstoff")
    @browser.text_field(name: "search_query").value = "Budesonid"
    @browser.button(name: 'search').click;  small_delay

    text = @browser.text.clone
    expect(text).not_to match LeeresResult
    expect(text).to match('Budesonid Sandoz') # by price
    expect(text).to match('Budenofalk')       # by component
  end unless ['just-medical'].index(Flavor)

  ['Interaktion',
   'Markenname',
   'Preisvergleich',
   'Inhaltsstoff',
   'Preisvergleich und Inhaltsstoff'][0..0].each do |search_type|
    it "#{search_type} should display not found for Warfarin which is not registered in Switzerland " do
        # @browser.goto OddbUrl
        @browser.select_list(name: "search_type").select(search_type)
        @browser.text_field(name: "search_query").value = "Warfarin"
        @browser.button(name: 'search').click;  small_delay
        puts "Warfarin: URL ist #{@browser.url}"
        text = @browser.text.clone
        skip("Warfarin behaves differently on oddb-ci2 and ch.oddb.org")
        expect(text).to match LeeresResult
      end
  end

  it "should search via pharmacode 6430210 without problem" do
    @browser.link(name: 'drugs').click;  small_delay

    @browser.select_list(name: "search_type").select("Pharmacode")
    @browser.text_field(name: "search_query").value = "6430210"
    @browser.button(name: 'search').click;  small_delay

    text = @browser.text.clone
    expect(text).not_to match LeeresResult
    expect(text).to match('Oxycodon')
  end unless ['just-medical'].index(Flavor)

  it "should set best_result when searching Rivoleve via search_type Preisvergleich und Inhaltsstof" do
    @browser.link(name: 'drugs').click;  small_delay
    @browser.text_field(name: "search_query").value = "Rivoleve"
    @browser.select_list(name: "search_type").select("Preisvergleich und Inhaltsstoff")
    text = @browser.text.clone
    expect(text).not_to match LeeresResult
    expect(text).to match('Rivoleve')
    expect(@browser.url).to match /#best_result$/
  end unless ['just-medical'].index(Flavor)

  it "should set best_result when searching Rivoleve via search_type Preisvergleich" do
    @browser.link(name: 'drugs').click;  small_delay
    @browser.text_field(name: "search_query").value = "Rivoleve"
    @browser.select_list(name: "search_type").select("Preisvergleich")
    text = @browser.text.clone
    expect(text).not_to match LeeresResult
    expect(text).to match('Rivoleve')
    skip("22.01.2021: This is no longer the case. But does this matter?")
    expect(@browser.url).to match /#best_result$/
  end unless ['just-medical'].index(Flavor)

  it "should link to the correct ATC-code for Deponit" do
    @browser.link(name: 'drugs').click;  small_delay
    @browser.text_field(name: "search_query").value = "Deponit"
    @browser.select_list(name: "search_type").select("Markenname")
    text = @browser.text.clone
    expect(@browser.link(visible_text: 'WHO-DDD').exist?).to eq true
    expect(@browser.link(visible_text: 'WHO-DDD').href).to match(/atc_code\/\w{7}/)
    expect(text).not_to match LeeresResult
    expect(text).to match('Deponit')
    expect(@browser.url).not_to match /#best_result$/
  end unless ['just-medical'].index(Flavor)

  after :all do
    @browser.close if @browser
  end
end
