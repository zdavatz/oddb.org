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
				'2347618'	=>	'32.00',
				'2347624' =>  '58.00',
				'0912103' =>	'9.85',
				'1987273' =>	'114.65',
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
			package.mock_handle(:pointer) { 'package-pointer' }
			package.mock_handle(:name) { 'Der Name' }
			package.mock_handle(:price_public) { 250 }
			package.mock_handle(:pharmacode) { '1234567' }
			package.mock_handle(:sl_entry) {  }
			@app.mock_handle(:update, 1) { |pointer, hash|
				assert_equal('package-pointer', pointer)
				expected = { :price_public	=>	"9.90", }
				assert_equal(expected, hash)
			}
			@plugin.update_package(package, data)
			update = @plugin.updated_packages.first
			assert_instance_of(LppvPlugin::PriceUpdate, update)
			assert(update.up?)
			@app.mock_verify
		end
		def test_update_package__price_down
			data = {
					'1234567' => '9.90',
					'7654321' => '5.55',
			}
			package = FlexMock.new
			package.mock_handle(:pointer){ 'package-pointer' }
			package.mock_handle(:iksnr) { }
			package.mock_handle(:name) { 'Neuer Name' }
			package.mock_handle(:price_public) { 1000 }
			package.mock_handle(:pharmacode) { '1234567' }
			package.mock_handle(:sl_entry) { }
			@app.mock_handle(:update, 1) { |pointer, hash|
			assert_equal('package-pointer', pointer)
			expected = { :price_public => "9.90", }
			assert_equal(expected, hash)
			}
			@plugin.update_package(package, data)
			update = @plugin.updated_packages.first
			assert_instance_of(LppvPlugin::PriceUpdate, update)
			assert(update.down?)
			@app.mock_verify
			puts @plugin.report
		end		
		def test_update_package__price_same
			data = {
				'1234567' => '9.90',
			}	
			package = FlexMock.new
			package.mock_handle(:pointer) { 'package-pointer' }
			package.mock_handle(:name) { 'Noch a Name' }
			package.mock_handle(:iksnr) { }
			package.mock_handle(:price_public) { 990 }
			package.mock_handle(:pharmacode) { '1234567' }
			package.mock_handle(:sl_entry) { }
			@app.mock_handle(:update, 0) { }
			@plugin.update_package(package, data)
			assert_equal([], @plugin.updated_packages)
			@app.mock_verify
		end
		def test_update_package__no_price
			data = {
				'1234567' => '9.90',
				'7654321' => '9.90'
			}
			package = FlexMock.new
			package2 = FlexMock.new
			package.mock_handle(:pointer) { 'package-pointer' }
			package.mock_handle(:name) { 'Namenda' }
			package.mock_handle(:price_public) { 1000 }
			package.mock_handle(:pharmacode) { '1234567' }
			package.mock_handle(:sl_entry) { }
			@app.mock_handle(:update, 1) { |pointer, hash|
				assert_equal('package-pointer', pointer)
				expected = { :price_public => "9.90",}
				assert_equal(expected, hash)
			}
			@plugin.update_package(package, data)
			package2.mock_handle(:pointer) { 'package-pointer' }
			package2.mock_handle(:name) { 'Bla' }
			package2.mock_handle(:price_public) {900 }
			package2.mock_handle(:pharmacode) { '7654321' }
			package2.mock_handle(:sl_entry) { }
			@app.mock_handle(:update, 2) { |pointer, hash|
				assert_equal('package-pointer', pointer)
				expected = { :price_public => "9.90",}
				assert_equal(expected, hash)
			}
			@plugin.update_package(package2, data)
			update = @plugin.updated_packages.first
			assert_instance_of(LppvPlugin::PriceUpdate, update)
			@app.mock_verify
		end
	end
end
