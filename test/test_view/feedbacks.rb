#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestFeedBacks -- oddb.org -- 05.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'view/feedbacks'

module ODDB
	module View

class TestFeedbackForm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :attributes => {},
                          :lookup     => 'lookup',
                          :base_url   => 'base_url'
                         )
    component  = flexmock('component', :update => 'update')
    components = {[0,0] => component}
    unless defined?(ODDB::View::FeedbackForm::COMPONENTS)
      self.instance_eval('ODDB::View::FeedbackForm::COMPONENTS = components')
    end
    @state     = flexmock('state', :passed_turing_test => 'passed_turing_test')
    @session   = flexmock('session', 
                          :state       => @state,
                          :lookandfeel => @lnf,
                          :error       => 'error',
                          :warning?    => nil,
                          :error?      => nil,
                          :info?       => nil
                         )
    @model     = flexmock('model')
    @form      = ODDB::View::FeedbackForm.new(@model, @session)
  end
  def test_init
    assert_equal(nil, @form.init)
  end
  def test_init__else
    flexmock(@state, :passed_turing_test => false)
    generate_challenge = flexmock('generage_challenge', :file => 'file')
    flexmock(@lnf, 
             :generate_challenge => generate_challenge,
             :resource           => 'resource'
            )
    assert_equal(nil, @form.init)
  end
  def test_radio_good
    flexmock(@model, :good_key => 'good_key')
    assert_kind_of(HtmlGrid::InputRadio, @form.radio_good('good_key'))
  end
  def test_experience
    flexmock(@model, :experience => 'experience')
    assert_kind_of(HtmlGrid::InputRadio, @form.experience(@model))
  end
  def test_radio_bad
    flexmock(@model, :bad_key => false)
    assert_kind_of(HtmlGrid::InputRadio, @form.radio_bad('bad_key'))
  end
  def test_experience_bad
    flexmock(@model, :experience => false)
    assert_kind_of(HtmlGrid::InputRadio, @form.experience_bad(@model))
  end
  def test_helps
    flexmock(@model, :helps => 'helps')
    assert_kind_of(HtmlGrid::InputRadio, @form.helps(@model))
  end
  def test_helps_bad
    flexmock(@model, :helps => false)
    assert_kind_of(HtmlGrid::InputRadio, @form.helps_bad(@model))
  end
  def test_impression
    flexmock(@model, :impression => 'impression')
    assert_kind_of(HtmlGrid::InputRadio, @form.impression(@model))
  end
  def test_impression_bad
    flexmock(@model, :impression => false)
    assert_kind_of(HtmlGrid::InputRadio, @form.impression_bad(@model))
  end
  def test_recommend
    flexmock(@model, :recommend => 'recommend')
    assert_kind_of(HtmlGrid::InputRadio, @form.recommend(@model))
  end
  def test_recommend_bad
    flexmock(@model, :recommend => false)
    assert_kind_of(HtmlGrid::InputRadio, @form.recommend_bad(@model))
  end
  def test_show_email
    flexmock(@model, :show_email => 'show_email')
    assert_kind_of(HtmlGrid::InputRadio, @form.show_email(@model))
  end
  def test_show_email_bad
    flexmock(@model, :show_email => false)
    assert_kind_of(HtmlGrid::InputRadio, @form.show_email_bad(@model))
  end
  def test_feedback_text_e
    assert_kind_of(HtmlGrid::Textarea, @form.feedback_text_e(@model))
  end
end

class TestFeedbackList <Minitest::Test
  include FlexMock::TestCase
  def setup
    component  = flexmock('component', :update => 'update')
    components = {[0,0] => component}
    unless defined?(ODDB::View::FeedbackList::COMPONENTS)
      self.instance_eval('ODDB::View::FeedbackList::COMPONENTS = components')
    end
    @lnf       = flexmock('lookandfeel')
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model')
    @list      = ODDB::View::FeedbackList.new([@model], @session)
  end
  def test_result__true
    assert_kind_of(HtmlGrid::Div, @list.result(true))
  end
  def test_result__false
    assert_kind_of(HtmlGrid::Div, @list.result(false))
  end
  def test_experience
    flexmock(@model, :experience => true)
    assert_kind_of(HtmlGrid::Div, @list.experience(@model, @session))
  end
  def test_show_email
    flexmock(@model, 
             :show_email => true,
             :email      => 'email'
            )
    assert_equal('email', @list.show_email(@model, @session))
  end
  def test_show_email__else
    flexmock(@model, :show_email => false)
    flexmock(@lnf, :lookup => 'lookup')
    assert_equal('lookup', @list.show_email(@model, @session))
  end
  def test_recommend
    flexmock(@model, :recommend => true)
    assert_kind_of(HtmlGrid::Div, @list.recommend(@model, @session))
  end
  def test_impression
    flexmock(@model, :impression => true)
    assert_kind_of(HtmlGrid::Div, @list.impression(@model, @session))
  end
  def test_helps
    flexmock(@model, :helps => true)
    assert_kind_of(HtmlGrid::Div, @list.helps(@model, @session))
  end
  def test_time
    flexmock(@model, :"time.strftime" => 'strftime')
    flexmock(@lnf, :lookup => 'lookup')
    assert_equal('strftime', @list.time(@model, @session))
  end
end

class TestFeedbackPager <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {}
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model', 
                          :has_prev? => nil,
                          :index     => 123,
                          :feedback_count => 'feedback_count',
                          :has_next? => nil
                         )
    unless defined?(FlexMock::INDEX_STEP)
      @model.instance_eval('FlexMock::INDEX_STEP = 1')
    end
    @composite = ODDB::View::FeedbackPager.new(@model, @session)
  end
  def test_create_link
    assert_kind_of(HtmlGrid::Link, @composite.create_link('text_key', 'href'))
  end
  def test_fb_navigation_prev
    flexmock(@lnf, :event_url => 'event_url')
    flexmock(@model, 
             :has_prev?  => true,
             :prev_index => 'prev_index'
            )
    assert_kind_of(HtmlGrid::Link, @composite.fb_navigation_prev(@model))
  end
  def test_fb_navigation_next
    flexmock(@lnf, :event_url => 'event_url')
    flexmock(@model, 
             :has_next?  => true,
             :next_index => 'next_index'
            )
    assert_kind_of(HtmlGrid::Link, @composite.fb_navigation_next(@model))
  end
end

	end # View
end # ODDB
