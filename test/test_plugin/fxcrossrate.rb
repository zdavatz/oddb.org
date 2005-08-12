#!/usr/bin/env ruby
# TestFXCrossratePlugin -- oddb -- 23.06.2005 -- jlang@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'plugin/fxcrossrate'
require 'test/unit'
require 'mock'

module ODDB
	class TestFXCrossratePlugin < Test::Unit::TestCase
		def setup
			path = File.expand_path('../data/html/fxcrossrate/fxcrossrate.shtml',
				File.dirname(__FILE__))
			@html = File.read(path)
			@app = Mock.new("app")
			@plugin = ODDB::FXCrossratePlugin.new(@app)
		end
		def test_parse
			result = @plugin.parse(@html)
			expected = {
				'EUR'	=> 0.6484,
				'USD'	=> 0.7862,
			}
			assert_equal(expected, result)
		end
	end
end
