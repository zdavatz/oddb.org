# encoding: utf-8
currencyDir= File.join(File.dirname(File.dirname(__FILE__)), '..', 'currency')
if !File.exists?(currencyDir)
  puts "Cannot run spec tests for currency as #{currencyDir} #{File.exists?(currencyDir)} not found"
  else
  $LOAD_PATH << File.join(File.dirname(File.dirname(__FILE__)), 'src')
  require File.join(currencyDir, 'lib', 'currency')
  require File.join(currencyDir, 'lib', 'currency', 'version')
  # Adapted from ../currency/bin/currencyd
  DRB_TEST_URI = 'druby://127.0.0.1:10999'

  module Currency
    require 'drb'
  #  require 'rclconf'
  # require File.join(File.expand_path(File.dirname(File.dirname(__FILE__))), 'lib', 'currency')
    run_updater
    puts "Starting #{File.basename(__FILE__)} #{VERSION} on #{DRB_TEST_URI}"
    @@server = DRb.start_service(DRB_TEST_URI, self)
    pp @@server
    # DRb.thread.join
    def Currency::server
      @@server
    end
    def Currency::stop_service
      puts "stop_service #{ @@server.class}"
      DRb.stop_service if @@server
    end
  end
  require 'util/currency'

  describe "CurrencySpec" do
    before :each do
      ODDB::Currency = DRbObject.new(nil, ODDB::CURRENCY_URI)
    end
    after :all do
      puts "After"
      system('sudo netstat -tulpen | grep 10999')
      puts "After_all #{Currency.class} #{::Currency.class} #{ODDB::Currency}"
      Currency.stop_service
      puts "After_all done"
    end

    it "return 1.0 for same CHF -> CHF" do
      expect(ODDB::Currency.rate('CHF', "CHF")).to be 1.0
    end

    it "return 1.0 for same USD -> USD" do
      expect(ODDB::Currency.rate('USD', "USD")).to be 1.0
    end

    it 'should convert correctly from CHF to EUR' do
      rate =  ODDB::Currency.rate('CHF', 'EUR')
      expect(rate.class).to eq Float
      expect(rate).to be < 1.0
      expect(rate).to be > 0.5
    end
  end
end
