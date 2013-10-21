#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::TestFeedbacks -- oddb.org -- 06.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'view/resulttemplate'
require 'view/drugs/feedbacks'


module ODDB
  module View
    module Drugs

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
                                :helps      => 'helps'
                               )
    @model     = flexmock('model', 
                          :name => 'name',
                          :size => 'size',
                          :current_feedback => current_feedback,
                          :feedback_count   => 1,
                          :feedback_list    => [],
                          :has_prev?        => nil,
                          :index            => 1,
                          :has_next?        => nil
                         )
    @composite = ODDB::View::Drugs::FeedbacksComposite.new(@model, @session)
  end
  FlexMock::INDEX_STEP = 1
  def test_current_feedback
    assert_kind_of(ODDB::View::Drugs::FeedbackForm, @composite.current_feedback(@model))
  end
end

    end # Drugs
  end # View
end # ODDB
