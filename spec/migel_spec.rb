# encoding: utf-8
migelDir= File.join(File.dirname(File.dirname(__FILE__)), '..', 'migel')
if !File.exists?(migelDir)
  puts "Cannot run spec tests for migel as #{migelDir} #{File.exists?(migelDir)} not found"
  else
  $LOAD_PATH << File.join(File.dirname(File.dirname(__FILE__)), 'src')
  $LOAD_PATH << File.join(migelDir, 'lib')
  require File.join(migelDir, 'lib', 'migel')
  require File.join(migelDir, 'lib', 'migel', 'version')
  require File.join(migelDir, 'lib', 'migel', 'model')
  require File.join(migelDir, 'lib', 'migel', 'persistence')
  # Adapted from ../migel/bin/migeld
  DRB_TEST_URI = 'druby://127.0.0.1:20998'

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
      url.untaint
      pp DRB_TEST_URI
      pp DRB_TEST_URI.untaint
      DRb.start_service(DRB_TEST_URI, server)
      $SAFE = 1
      logger.info('start') { sprintf("starting migel-server on %s", url) }
      DRb.thread.join
      rescue => error
      logger.error('fatal') { error }
      raise
    end
  end
  require 'util/migel'
exit
  describe "MigelSpec" do
    before :each do
      ODDB::Migel = DRbObject.new(nil, ODDB::CURRENCY_URI)
    end
    after :all do
      puts "After_all #{Migel.class} #{::Migel.class} #{ODDB::Migel}"
      Migel.stop_service
      puts "After_all done"
    end

    it "return 1.0 for same CHF -> CHF" do
      expect(ODDB::Migel.rate('CHF', "CHF")).to be 1.0
    end

    it "return 1.0 for same USD -> USD" do
      expect(ODDB::Migel.rate('USD', "USD")).to be 1.0
    end

    it "runs Migel.rate" do
      xxx = ODDB::Migel.rate('CHF', "CHF")
    end

  end
end
