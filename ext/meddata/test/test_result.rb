#!/usr/bin/env ruby
# ResultTest -- oddb -- 21.12.2004 -- jlang@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))

require 'result'
require 'test/unit'

module ODDB
	module MedData
		class ResultTest < Test::Unit::TestCase
			def test_initialize
				result = Result.new('foo', 'bar', 'baz')
				assert_equal('foo', result.session)
				assert_equal('bar', result.values)
				assert_equal('baz', result.ctl)
				result = Result.new(nil, nil, nil)
				assert_nil(result.session)
				assert_nil(result.values)
				assert_nil(result.ctl)
			end
		end
	end
end
