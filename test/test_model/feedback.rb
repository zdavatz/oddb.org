#!/usr/bin/env ruby
# TestFeedback -- oddb -- 02.11.2004 -- jlang@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'model/feedback'
require 'mock'

module ODDB
	class TestFeedback < Test::Unit::TestCase
		def setup
			@feedback = Feedback.new
		end
		def test_init
			ptr = Mock.new('Pointer')
			@feedback.pointer = ptr
			ptr.__next(:append) { |id|
				assert_equal(@feedback.oid, id)
			}
			@feedback.init
			ptr.__verify
		end
	end
end
