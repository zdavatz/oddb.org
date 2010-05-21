#!/usr/bin/env ruby
# TestLppvPlugin -- oddb.org -- 18.01.2006 -- sfrischknecht@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src/", File.dirname(__FILE__))

require "test/unit"
require "plugin/lppv"
require "net/http"
require 'flexmock'

module ODDB
	class TestLppvWriter < Test::Unit::TestCase
		def setup
			@writer = LppvWriter.new
			@formatter = HtmlFormatter.new(@writer)
			@parser = HtmlParser.new(@formatter)
			@source = File.read(File.expand_path('../data/html/lppv/A.html', 
																					 File.dirname(__FILE__)))
		end
		def test_integrate
			@parser.feed(@source)
			expected = {
				'2347618'	=>	Util::Money.new(32.00),
				'2347624' =>  Util::Money.new(58.00),
				'912103' =>	Util::Money.new(9.85),
				'1987273' =>	Util::Money.new(114.65),
			}
			assert_equal(expected, @writer.prices)
		end
	end
	class TestLppvPlugin < Test::Unit::TestCase
		def setup
			@app = FlexMock.new
			@plugin = LppvPlugin.new(@app)
		end
		def test_update_package__price_up
			data = {
				'1234567'	=>	'9.90',		
			}
			package = FlexMock.new
			package.should_receive(:pointer).and_return { 'package-pointer' }
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
			assert_instance_of(LppvPlugin::PriceUpdate, update)
			assert(update.down?)
			@app.flexmock_verify
		end		
		def test_update_package__price_same__no_lppv
			data = {
				'1234567'	=>	'9.90',		
			}
			package = FlexMock.new
			package.should_receive(:pointer).and_return { 'package-pointer' }
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
			assert_instance_of(LppvPlugin::PriceUpdate, update)
			@app.flexmock_verify
		end
		def test_update_package__price_same__lppv
			data = {
				'1234567' => '9.90',
			}	
			package = FlexMock.new
			package.should_receive(:pointer).and_return { 'package-pointer' }
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
			assert_instance_of(LppvPlugin::PriceUpdate, update)
			@app.flexmock_verify
		end
	end
end
