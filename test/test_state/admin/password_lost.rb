#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestPasswordLost -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/admin/password_lost'
require 'state/admin/confirm'
require 'util/mail'

module ODDB
  module State
    module Admin

class TestPasswordLost <Minitest::Test
  include FlexMock::TestCase
  def setup
    Util.configure_mail :test
    Util.clear_sent_mails
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :_event_url => '_event_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :user_input  => { 'user_input' => 'x'}, 
                        :yus_grant   => 'yus_grant'
                       ).by_default
    @model   = flexmock('model')
    @state   = ODDB::State::Admin::PasswordLost.new(@session, @model)    
  end
  def test_notify_user
    time = flexmock('time', :strftime => 'strftime')
    assert_equal(["email", ODDB.config.mail_to].flatten, @state.notify_user('email', 'token', time))
  end
  def test_password_request
    flexmock(@session, :user_input => {:email => 'email'})
    assert_kind_of(ODDB::State::Admin::Confirm, @state.password_request)
  end
  def test_password_request__error
    flexmock(@session).should_receive(:yus_grant).and_raise(Yus::UnknownEntityError)    
    assert_equal(@state, @state.password_request)
  end
end

    end # Admin
  end # State
end # ODDB
