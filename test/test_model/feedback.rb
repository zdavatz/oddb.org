#!/usr/bin/env ruby
# encoding: utf-8
# TestFeedback -- oddb -- 02.11.2004 -- jlang@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'stub/odba'
require 'test/unit'
require 'flexmock'
require 'model/feedback'

module ODDB
	class TestFeedback < Test::Unit::TestCase
    include FlexMock::TestCase
		def setup
			@feedback = Feedback.new
		end
		def test_init
      ptr = Persistence::Pointer.new :feedback
			@feedback.pointer = ptr
			@feedback.init
      assert_equal Persistence::Pointer.new([:feedback, @feedback.oid]), ptr
      assert_equal ptr, @feedback.pointer
		end
    def test_item_writer
      item = flexmock 'item2'
      item.should_receive(:add_feedback).with(@feedback).times(1).and_return do
        assert true
      end
      res = @feedback.item = item
      assert_equal item, res
      assert_equal item, @feedback.item
      item.should_receive(:remove_feedback).with(@feedback).times(1).and_return do
        assert true
      end
      other = flexmock 'item2'
      other.should_receive(:add_feedback).with(@feedback).times(1).and_return do
        assert true
      end
      res = @feedback.item = other
      assert_equal other, res
      assert_equal other, @feedback.item
    end
	end
end
