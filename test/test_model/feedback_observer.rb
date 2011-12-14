#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestFeedbackObserver -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'model/feedback_observer'

module ODDB
  class StubFeedbackObserver
    include FeedbackObserver
    def initialize(feedbacks)
      @feedbacks = feedbacks
    end
  end
  class TestFeedbackObserver < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @feedback  = flexmock('feedback', :oid => 123)
      @feedbacks = [@feedback]
      flexmock(@feedbacks, :odba_isolated_store => 'odba_isolated_store')
      @model = ODDB::StubFeedbackObserver.new(@feedbacks)
    end
    def test_feedback
      assert_equal(@feedback, @model.feedback('123'))
    end
    def test_add_feedback
      feedback = flexmock('feedback2')
      assert_equal(feedback, @model.add_feedback(feedback))
    end
    def test_remove_feedback
      assert_equal(@feedback, @model.remove_feedback(@feedback))
    end
  end
end
