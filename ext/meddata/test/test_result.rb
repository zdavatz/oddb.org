#!/usr/bin/env ruby
# ResultTest -- oddb -- 21.12.2004 -- jlang@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))

require 'result'
gem 'minitest'
require 'minitest/autorun'

module ODDB
	module MedData
		class ResultTest <Minitest::Test
			def test_initialize
				result = Result.new('bar', 'baz')
				assert_equal('bar', result.values)
				assert_equal('baz', result.ctl)
				result = Result.new(nil, nil)
				assert_nil(result.values)
				assert_nil(result.ctl)
			end
		end
	end
end
