#!/usr/bin/env ruby
# ODDB::TestNarcoticPlugin -- oddb -- 03.11.2005 -- ffricker@ywesee.com

$: << File.expand_path('../../src', 
File.dirname(__FILE__))
$: << File.expand_path('..', File.dirname(__FILE__))


require 'test/unit'
require 'plugin/narcotic'
require 'flexmock'

module ODDB
	class TestNarcoticPlugin < Test::Unit::TestCase
		def setup
			@app = FlexMock.new
			@plugin = NarcoticPlugin.new(@app)
		end
		def test_casrn
			row = ['NAME', nil, 'pcode', 'smcd']
			assert_nil(@plugin.casrn(row))
			row = ['NAME', '', 'pcode', 'smcd']
			assert_nil(@plugin.casrn(row))
			row = ['NAME', 'nil', 'pcode', 'smcd']
			assert_nil(@plugin.casrn(row))
			row = ['NAME', '345-768', 'pcode', 'smcd']
			assert_equal('345-768', @plugin.casrn(row))
		end
		def test_smcd
			row = ['NAME', 'casrn', 'pcode', '7680543210079']
			assert_equal('54321007', @plugin.smcd(row))
			row = ['NAME', 'casrn', 'pcode', nil]
			assert_nil(@plugin.smcd(row))
			row = ['NAME', 'casrn', 'pcode', ''] 
			assert_nil(@plugin.smcd(row))
			row = ['NAME', 'casrn', 'pcode', 'nil'] 
			assert_nil(@plugin.smcd(row))
		end
	end
end
