#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestLppvPlugin -- oddb.org -- 13.04.2011 -- mhatakeyama@ywesee.com
# ODDB::TestLppvPlugin -- oddb.org -- 18.01.2006 -- sfrischknecht@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src/", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require "plugin/lppv"
require "net/http"
require 'flexmock'

module ODDB
	class TestLppvWriter <Minitest::Test
		def setup
			@writer = LppvWriter.new
			@formatter = HtmlFormatter.new(@writer)
			@parser = HtmlParser.new(@formatter)
      f = File.new(File.expand_path('../data/html/lppv/A.html', File.dirname(__FILE__)))
      f.set_encoding(Encoding::ISO_8859_1, Encoding::UTF_8)
			@source = f.read
		end
		def test_integrate
			@parser.feed(@source)
			expected = {
				'2347618'	=>	Util::Money.new(32.00),
				'2347624' =>  Util::Money.new(58.00),
				'912103' =>	Util::Money.new(9.85),
				'1987273' =>	Util::Money.new(114.65),
			}
      skip("lppv does not have get_prices anymore. How to replace test in #{__FILE__}:#{__LINE__}?")
			assert_equal(expected, @writer.prices)
		end
	end
	class TestLppvPlugin <Minitest::Test
    include FlexMock::TestCase
		def setup
			@app = FlexMock.new('app')
			@plugin = LppvPlugin.new(@app)
		end
		def test_update_package__price_up
			data = {
				'1234567'	=>	'9.90',		
			}
			package = FlexMock.new
			package.should_receive(:pointer).and_return { 'package-pointer' }
      package.should_receive(:barcode).and_return { 'barcode' }
      package.should_receive(:data_origin).and_return { 'data_origin' }
      package.should_receive(:lppv).and_return { 'lppv' }
      package.should_receive(:name).and_return { 'Der Name' }
			package.should_receive(:price_public).and_return { Util::Money.new(2.50) }
			package.should_receive(:pharmacode).and_return { '1234567' }
			package.should_receive(:sl_entry).and_return {  }
			@app.should_receive(:update, 1).and_return { |pointer, hash|
				assert_equal('package-pointer', pointer)
				expected = { :price_public	=>	"9.90", :lppv => true}
				assert_equal(expected, hash)
			}
			@plugin.update_package(package, data)
			update = @plugin.updated_packages.first
      skip("lppv does not have get_prices anymore. How to replace test in #{__FILE__}:#{__LINE__}?")
			assert_instance_of(LppvPlugin::PriceUpdate, update)
			assert(update.up?)
			@app.flexmock_verify
		end
		def test_update_package__price_down
			data = {
					'1234567' => '9.90',
					'7654321' => '5.55',
			}
			package = FlexMock.new
			package.should_receive(:pointer).and_return{ 'package-pointer' }
      package.should_receive(:barcode).and_return { 'barcode' }
      package.should_receive(:data_origin).and_return { 'data_origin' }
      package.should_receive(:lppv).and_return { 'lppv' }
			package.should_receive(:iksnr).and_return { }
			package.should_receive(:name).and_return { 'Neuer Name' }
			package.should_receive(:price_public).and_return { Util::Money.new(1000) }
			package.should_receive(:pharmacode).and_return { '1234567' }
			package.should_receive(:sl_entry).and_return { }
			@app.should_receive(:update, 1).and_return { |pointer, hash|
			assert_equal('package-pointer', pointer)
			expected = { :price_public => "9.90", :lppv => true}
			assert_equal(expected, hash)
			}
			@plugin.update_package(package, data)
			update = @plugin.updated_packages.first
      assert_instance_of(nil.class, update)
      @app.flexmock_verify
      skip("lppv does not have get_prices anymore. How to replace test in #{__FILE__}:#{__LINE__}?")
      assert_instance_of(LppvPlugin::PriceUpdate, update)
		end		
		def test_update_package__price_same__no_lppv
			data = {
				'1234567'	=>	'9.90',		
			}
			package = FlexMock.new
			package.should_receive(:pointer).and_return { 'package-pointer' }
      package.should_receive(:barcode).and_return { 'barcode' }
      package.should_receive(:data_origin).and_return { 'data_origin' }
      package.should_receive(:lppv).and_return { 'lppv' }
			package.should_receive(:name).and_return { 'Der Name' }
			package.should_receive(:price_public).and_return { Util::Money.new(9.90) }
			package.should_receive(:pharmacode).and_return { '1234567' }
			package.should_receive(:sl_entry).and_return {  }
			package.should_receive(:lppv).and_return {  }
			@app.should_receive(:update, 1).and_return { |pointer, hash|
				assert_equal('package-pointer', pointer)
				expected = { :price_public	=>	"9.90", :lppv => true}
				assert_equal(expected, hash)
			}
			@plugin.update_package(package, data)
			update = @plugin.updated_packages.first
      skip("lppv does not have get_prices anymore. How to replace test in #{__FILE__}:#{__LINE__}?")
			assert_instance_of(LppvPlugin::PriceUpdate, update)
			@app.flexmock_verify
		end
		def test_update_package__price_same__lppv
			data = {
				'1234567' => '9.90',
			}	
			package = FlexMock.new
			package.should_receive(:pointer).and_return { 'package-pointer' }
      package.should_receive(:barcode).and_return { 'barcode' }
      package.should_receive(:data_origin).and_return { 'data_origin' }
      package.should_receive(:lppv).and_return { 'lppv' }
			package.should_receive(:name).and_return { 'Noch a Name' }
			package.should_receive(:iksnr).and_return { }
			package.should_receive(:price_public).and_return { Util::Money.new(9.90) }
			package.should_receive(:pharmacode).and_return { '1234567' }
			package.should_receive(:sl_entry).and_return { }
			package.should_receive(:lppv).and_return { true }
			@app.should_receive(:update, 0).and_return { }
			@plugin.update_package(package, data)
			assert_equal([], @plugin.updated_packages)
			@app.flexmock_verify
		end	
		def test_update_package__no_price
			data = {
				'1234567' => '9.90',
				'7654321' => '9.90'
			}
			package = FlexMock.new
			package2 = FlexMock.new
			package.should_receive(:pointer).and_return { 'package-pointer' }
      package.should_receive(:barcode).and_return { 'barcode' }
      package.should_receive(:data_origin).and_return { 'data_origin' }
      package.should_receive(:lppv).and_return { 'lppv' }
			package.should_receive(:name).and_return { 'Namenda' }
			package.should_receive(:price_public).and_return { Util::Money.new(1000) }
			package.should_receive(:pharmacode).and_return { '1234567' }
			package.should_receive(:sl_entry).and_return { }
			@app.should_receive(:update, 1).and_return { |pointer, hash|
				assert_equal('package-pointer', pointer)
				expected = { :price_public => "9.90", :lppv => true}
				assert_equal(expected, hash)
			}
			@plugin.update_package(package, data)
      package2.should_receive(:barcode).and_return { 'barcode' }
      package2.should_receive(:data_origin).and_return { 'data_origin' }
      package2.should_receive(:lppv).and_return { 'lppv' }
			package2.should_receive(:pointer).and_return { 'package-pointer' }
			package2.should_receive(:name).and_return { 'Bla' }
			package2.should_receive(:price_public).and_return {900 }
			package2.should_receive(:pharmacode).and_return { '7654321' }
			package2.should_receive(:sl_entry).and_return { }
			@app.should_receive(:update, 2).and_return { |pointer, hash|
				assert_equal('package-pointer', pointer)
				expected = { :price_public => "9.90",:lppv => true}
				assert_equal(expected, hash)
			}
			@plugin.update_package(package2, data)
			update = @plugin.updated_packages.first
      skip("lppv does not have get_prices anymore. How to replace test in #{__FILE__}:#{__LINE__}?")
			assert_instance_of(LppvPlugin::PriceUpdate, update)
			@app.flexmock_verify
		end
    def test_update_package
      data    = {}
      flexmock(@app, :update => 'update')
      package = flexmock('package',
                         :barcode      => 'barcode',
                         :data_origin  => 'data_origin',
                         :lppv         => 'lppv',
                         :pharmacode   => 'pharmacode',
                         :price_public => 'price_public',
                         :sl_entry     => 'sl_entry',
                        )
      @plugin.update_package(package, data)
    end
    def test_update_package__sl_entry
      data    = {'pharmacode' => 'price_dat'}
      package = flexmock('package',
                         :barcode      => 'barcode',
                         :data_origin  => 'data_origin',
                         :lppv         => 'lppv',
                         :pharmacode   => 'pharmacode',
                         :price_public => 'price_public',
                         :sl_entry     => 'sl_entry',
                        )
      @plugin.update_package(package, data)
    end
    def test_update_packages
      package = flexmock('package', 
                         :barcode      => 'barcode',
                         :data_origin  => 'data_origin',
                         :lppv         => 'lppv',
                         :pharmacode   => 'pharmacode',
                         :price_public => 'price_public',
                         :sl_entry     => 'sl_entry',
                        )
      flexmock(@app) do |a|
        a.should_receive(:each_package).and_yield(package)
      end
      data = {'pharmacode' => 'price_dat'}
      @plugin.update_packages(data)
    end
    def test_get_prices
      char = 'A'
      body = File.read(File.expand_path('../data/html/lppv/A.html', File.dirname(__FILE__)))
      response = flexmock('response', :body => body)
      http = flexmock('http', :get => response)
      skip("lppv does not have get_prices anymore. How to replace test in #{__FILE__}:#{__LINE__}?")
      assert_kind_of(Hash, @plugin.get_prices(char, http))
    end
    def test_get_prices__price_empty
      char = 'A'
      body = File.read(File.expand_path('../data/html/lppv/A_empty.html', File.dirname(__FILE__)))
      response = flexmock('response', :body => body)
      http = flexmock('http', :get => response)
      skip("lppv does not have get_prices anymore. How to replace test in #{__FILE__}:#{__LINE__}?")
      assert_kind_of(Hash, @plugin.get_prices(char, http))
    end
    def test_update
      package = flexmock('package', 
                         :barcode      => 'barcode',
                         :data_origin  => 'data_origin',
                         :pharmacode  => 'pharmacode',
                         :lppv        => 'lppv',
                         :data_origin => :lppv,
                         :pointer     => 'pointer'
                        )
      flexmock(@app) do |a|
        a.should_receive(:each_package).and_yield(package)
        a.should_receive(:update).and_return('update')
      end

      body = File.read(File.expand_path('../data/html/lppv/A_empty.html', File.dirname(__FILE__)))
      response = flexmock('response', :body => body)
      http = flexmock('http', :get => response)
      flexmock(Net::HTTP).new_instances do |net|
        net.should_receive(:start).and_yield(http)
      end
      assert_equal('update', @plugin.update())
    end
    def test_report
      price1 = flexmock('price1', 
                        :"package.name" => 'price1',
                        :up?            => true,
                        :report_lines   => ['report1']
                       )
      price2 = flexmock('price2', 
                        :"package.name" => 'price2',
                        :up?            => false,
                        :report_lines   => ['report2']
                       )
      @plugin.instance_eval('@updated_packages = [price1, price2]')
      @plugin.instance_eval('@prices = []')
      expected = "Updated Packages (lppv flag true): 2\n\nPackages with SL-Entry: 0\n\nNot updated were: "
      assert_equal(expected, @plugin.report)
    end
	end

end
