#!/usr/bin/env ruby
# TestFeedback -- oddb -- 02.11.2004 -- jlang@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'model/feedback'
require 'mock'
require 'odba'

module ODDB
	class TestFeedback < Test::Unit::TestCase
		def setup
			ODBA.storage = Mock.new
			ODBA.storage.__next(:next_id) {
				1
			}
			@feedback = Feedback.new
		end
		def teardown
			ODBA.storage = nil
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
