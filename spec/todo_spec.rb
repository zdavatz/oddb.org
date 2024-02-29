# encoding: utf-8
require 'spec_helper'

# From migel_spec.rb
migelDir= File.join(File.dirname(File.dirname(__FILE__)), '..', 'migel')
DRB_TEST_URI = 'druby://127.0.0.1:33000'
if !File.exist?(migelDir)
  puts "Cannot run spec tests for migel as #{migelDir} #{File.exist?(migelDir)} not found"
  else
    if false
  $LOAD_PATH << File.join(File.dirname(File.dirname(__FILE__)), 'src')
  $LOAD_PATH << File.join(migelDir, 'lib')
  require File.join(migelDir, 'lib', 'migel')
  require File.join(migelDir, 'lib', 'migel', 'version')
  require File.join(migelDir, 'lib', 'migel', 'model')
  require File.join(migelDir, 'lib', 'migel', 'persistence')
  require File.join(migelDir, 'lib', 'migel', 'util', 'server')
  # Adapted from ../migel/bin/migeld
    else
      puts "Migel not included"
    end
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
  end if false
  describe "MigelSpec" do
    require 'drb'
    MIGEL_SERVER = DRb::DRbObject.new(nil, DRB_TEST_URI)

    it "Finde Krücke via search_by_migel_code" do
      expect(MIGEL_SERVER.migelid.search_by_migel_code('10.01.01.00.1').first.code).to eq '01.00.1'
      expect(MIGEL_SERVER.migelid.search_by_migel_code('10.01.01.00.1').first.name).to match /Höhenausgleich für Gips und Orthese/
      expect(MIGEL_SERVER.migelid.search_by_migel_code('10.02.01.00.1').first.name).to match /2-stufige Höhenausgleichssohle für Gips/
    end

    before :all do
      @idx = 0
      waitForOddbToBeReady(@browser, ODDB_URL)
      login
    end
  end
end
# end of migel_spec.rb
