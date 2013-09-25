#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestNarcoticPlugin -- oddb.org -- 19.01.2012 -- mhatakeyama@ywesee.com
# ODDB::TestNarcoticPlugin -- oddb.org -- 03.11.2005 -- ffricker@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))
$: << File.expand_path('..', File.dirname(__FILE__))


gem 'minitest'
require 'minitest/autorun'
require 'plugin/narcotic'
require 'flexmock'


module ODDB
	class TestNarcoticPlugin <Minitest::Test
    include FlexMock::TestCase
		def setup
			@app = flexmock('app')
			@plugin = NarcoticPlugin.new(@app)
		end
    def test_report
      @plugin.instance_variable_set('@update_bm_flag', 12)
      @plugin.instance_variable_set('@update_ikscat', 34)
      expected = "Updated packages Narcotic flag(true): 12\nUpdated packages Category(A+): 34"
      assert_equal(expected, @plugin.report)
    end
    def test_update_from_xls
      # TODO
    end
	end
end
