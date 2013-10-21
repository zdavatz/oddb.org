#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Migel::TestFeedbacks -- oddb.org -- 20.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'view/resulttemplate'
require 'view/migel/feedbacks'


module ODDB
  module View
    module Migel

class TestFeedbacksComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :base_url   => 'base_url',
                          :_event_url => '_event_url',
                          :disabled?  => nil
                         )
    state      = flexmock('state', :passed_turing_test => 'passed_turing_test')
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :state       => state,
                          :error       => 'error',
                          :user_input  => 'user_input',
                          :warning?    => nil,
                          :error?      => nil,
                          :info?       => nil,
                          :zone        => 'zone',
                          :event       => 'event',
                         )
    current_feedback = flexmock('current_feedback', 
                                :show_email => 'show_email',
                                :experience => 'experience',
                                :recommend  => 'recommend',
                                :impression => 'impression',
                                :helps      => 'helps',
                                :time       => Time.local(2011,2,3),
                                :email      => 'email'
                               )
    @model     = flexmock('model', 
                          :name => 'name',
                          :current_feedback => current_feedback,
                          :feedback_count   => 0,
                          :feedback_list    => [current_feedback]
                         ).by_default
    @composite = ODDB::View::Migel::FeedbacksComposite.new(@model, @session)
  end
  def test_current_feedback
    assert_kind_of(ODDB::View::Migel::FeedbackForm, @composite.current_feedback(@model))
  end
  def test_feedback_pager
    flexmock(@model, 
             :feedback_count => 1,
             :has_prev?      => nil,
             :index          => 1,
             :has_next?      => nil
            )
    @model.class.instance_eval('FlexMock::INDEX_STEP = 1')
    assert_kind_of(ODDB::View::FeedbackPager, @composite.feedback_pager(@model))
  end
end
    end # Migel
  end # View
end # ODDB
