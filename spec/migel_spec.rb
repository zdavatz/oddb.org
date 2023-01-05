# encoding: utf-8
migelDir= File.join(File.dirname(File.dirname(__FILE__)), '..', 'migel')
DRB_TEST_URI = 'druby://127.0.0.1:33000'
require 'spec_helper'

if !File.exist?(migelDir)
  puts "Cannot run spec tests for migel as #{migelDir} #{File.exist?(migelDir)} not found"
  else
  $LOAD_PATH << File.join(File.dirname(File.dirname(__FILE__)), 'src')
  $LOAD_PATH << File.join(migelDir, 'lib')
  require File.join(migelDir, 'lib', 'migel')
  require File.join(migelDir, 'lib', 'migel', 'version')
  require File.join(migelDir, 'lib', 'migel', 'model')
  require File.join(migelDir, 'lib', 'migel', 'persistence')
  require File.join(migelDir, 'lib', 'migel', 'util', 'server')
  # Adapted from ../migel/bin/migeld

  module Migel
    def Migel::server
      @@server
    end
    def Migel::stop_service
      puts "stop_service #{ @@server.class}"
      DRb.stop_service if @@server
    end
    begin

      server = Migel::Util::Server.new
      server.extend(DRbUndumped)
      @@server = server

      url = @config.server_url
      begin
        DRb.start_service(DRB_TEST_URI, server)
        rescue => error
      end
      logger.info('start') { sprintf("starting migel-server on %s", url) }
    end
  end
  describe "MigelSpec" do
    MIGEL_SERVER = DRb::DRbObject.new(nil, DRB_TEST_URI)

    it "Finde Krücke" do
      expect(MIGEL_SERVER.migelid.search_by_migel_code('10.01.01.00.1').first.code).to eq '01.00.1'
      expect(MIGEL_SERVER.migelid.search_by_migel_code('10.01.01.00.1').first.name.de).to eq 'Krücken für Erwachsene, ergonomischer Griff, Kauf'
      expect(MIGEL_SERVER.migelid.search_by_migel_code('10.02.01.00.1').first.name.de).to eq "2-stufige Höhenausgleichssohle für Gips und Orthesen"
    end

    before :all do
      @idx = 0
      waitForOddbToBeReady(@browser, OddbUrl)
      login
    end

    it "should correct result for Migel product 100101011" do
      url = OddbUrl + '/de/gcc/migel_search/migel_product/100101011'
      @browser.goto(url)
      inhalt = @browser.text.dup
      expect(inhalt).not_to match LeeresResult
      expect(inhalt).to match /MiGeL-Code.*10.01.01.01.1/
      expect(inhalt).to match /Untergruppe.*Hand-\/Gehstöcke/
      expect(inhalt).to match /Beschreibung.*Krücken für Erwachsene, anatomischer- \/ orthopädischer Griff, Kauf/
      expect(inhalt).to match /Limitationstext.*Limitation :.*Nécessité d'une décharge de durée prolongée\(au moins 1 mois\)/m
    end

    it "should correct result for Migel search_query/10.01.01.00.1" do
      @browser.link(name: 'migel').click;  small_delay
      @browser.text_field(name: "search_query").value = "10.01.01.00.1"
      @browser.button(name: 'search').click;  small_delay
      inhalt = @browser.text.dup
      expect(inhalt).not_to match LeeresResult
      expect(inhalt).to match /GEHHILFEN/
      expect(inhalt).to match /Hand-\/Gehstöcke/
      expect(inhalt).to match /Krücken für Erwachsene/
    end

    it "should be possible to find Krücke via MiGeL" do
      @browser.link(name: 'migel').click;  small_delay
      @browser.text_field(name: "search_query").value = "Krücke"
      @browser.button(name: 'search').click;  small_delay
      expect(@browser.text).not_to match LeeresResult
      expect(@browser.text).to match /Beschreibung/
      expect(@browser.text).to match /Krücken/
    end

    it "should correct result for Migel product 100101011" do
      url = OddbUrl + '/de/gcc/migel_search/migel_code/100101001'
      @browser.goto(url)
      inhalt = @browser.text.dup
      expect(inhalt).not_to match LeeresResult
      expect(inhalt).to match /Höchstvergütungsbetrag:.*Paar.+MiGel Code: 10.01.01.00.1/
      expect(inhalt).to match /Krücke/
    end
  end
end
