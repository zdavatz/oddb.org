#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::TestFeedbacks -- oddb.org -- 29.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'view/resulttemplate'
require 'view/latin1'
require 'state/feedbacks'
require 'state/global'

module ODDB 
	module State
    module Feedbacks

      class TestItemWrapper < Test::Unit::TestCase
        include FlexMock::TestCase
        def setup
          @item    = flexmock('item')
          @wrapper = ODDB::State::Feedbacks::ItemWrapper.new(@item)
        end
        def test_current_feedback
          assert_kind_of(ODDB::Persistence::CreateItem, @wrapper.current_feedback)
        end
        def test_feedback_list
          flexmock(@item, :feedbacks => 'feedbacks')
          assert_equal('feedbacks', @wrapper.feedback_list)
        end
        def test_feedback_count
          flexmock(@item, :feedbacks => [1,2,3])
          assert_equal(3, @wrapper.feedback_count)
        end
        def test_next_index
          assert_equal(10, @wrapper.next_index)
        end
        def test_has_next
          flexmock(@item, :feedbacks => [1,2,3,4,5,6,7,8,9,10,11])
          assert_equal(true, @wrapper.has_next?)
        end
        def test_has_prev
          assert_equal(false, @wrapper.has_prev?)
          @wrapper.index = 1
          assert_equal(true, @wrapper.has_prev?)
        end
        def test_prev_index
          assert_equal(-10, @wrapper.prev_index)
        end
      end

    end # Feedbacks

    class StubFeedbacks < ODDB::State::Global
      include ODDB::State::Feedbacks
      def initialize(session, model)
        @session = session
        @app     = session.app
        @lookandfeel = session.lookandfeel
        @model   = model
        @errors  = {}
      end
    end
    
    class TestFeedbacks < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @lnf     = flexmock('lookandfeel')
        @app     = flexmock('app')
        @session = flexmock('session', 
                            :app         => @app,
                            :lookandfeel => @lnf
                           )
        @model   = flexmock('model')
        @state = ODDB::State::StubFeedbacks.new(@session, @model)
      end
      def test_init
        assert_equal(nil, @state.init)
      end
      def test_init__filter
        flexmock(@session, :user_input => 'index')
        @state.init
        assert_kind_of(ODDB::State::Feedbacks::ItemWrapper, @state.instance_eval('@filter.call(@model)'))
      end
      def test_update__error
        flexmock(@state, :user_input => {})
        assert_equal(@state, @state.update)
        assert_equal(true, @state.error?)
        assert_kind_of(SBSM::ProcessingError, @state.errors[:captcha])
      end
      def test_update
        flexmock(@session, :update_feedback_rss_feed => 'update_feedback_rss_feed')
        flexmock(@app, :update => 'update')
        current_feedback = flexmock('current_feedback', :pointer => 'pointer')
        flexmock(@model, 
                 :current_feedback  => current_feedback,
                 :current_feedback= => nil
                )
        flexmock(@state, :user_input => {})
        @state.instance_eval('@passed_turing_test = "passed_turing_test"')
        assert_equal(@state, @state.update)
      end
      def test_update__feedback_saved
        flexmock(@lnf, :_event_url => '_event_url')
        flexmock(@session, :update_feedback_rss_feed => 'update_feedback_rss_feed')
        flexmock(@app, :update => 'update')
        item = flexmock('item', :pointer => 'pointer')
        flexmock(@model, 
                 :current_feedback  => ODDB::Persistence::CreateItem.new,
                 :current_feedback= => nil,
                 :item => item
                )
        flexmock(@state, :user_input => {:message => 'message'})
        @state.instance_eval('@passed_turing_test = "passed_turing_test"')
        assert_equal(@state, @state.update)
      end
      def test_upadte__candidates
        flexmock(@session, :update_feedback_rss_feed => 'update_feedback_rss_feed')
        flexmock(@app, :update => 'update')
        current_feedback = flexmock('current_feedback', :pointer => 'pointer')
        flexmock(@model, 
                 :current_feedback  => current_feedback,
                 :current_feedback= => nil
                )
        flexmock(@lnf, :"captcha.valid_answer?" => true)
        flexmock(@state, :user_input => {:captcha => {'key' => 'word'}})
        assert_equal(@state, @state.update)
      end
    end


	end # State
end # ODDB
