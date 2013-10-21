#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestPasswordLost -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/admin/password_lost'
require 'state/admin/confirm'

module ODDB
  module State
    module Admin

class TestPasswordLost <Minitest::Test
  include FlexMock::TestCase
  def setup
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
    
    config = flexmock('config', 
                      :mail_from   => 'mail_from',
                      :mail_to     => ['mail_to'],
                      :smtp_server => 'smtp_server',
                      :smtp_port   => 'smtp_port',
                      :smtp_domain => 'smtp_domain',
                      :smtp_user   => 'smtp_user',
                      :smtp_pass   => 'smtp_pass',
                      :smtp_authtype => 'smtp_authtype'
                     )
    flexmock(ODDB, :config => config)
    smtp = flexmock('smtp', :sendmail => 'sendmail')
    flexmock(Net::SMTP).should_receive(:start).and_yield(smtp)
  end
  def test_notify_user
    time = flexmock('time', :strftime => 'strftime')
    assert_equal(["email", "mail_to"], @state.notify_user('email', 'token', time))
  end
  def test_password_request
    flexmock(@session, :user_input => {:email => 'email'})
    assert_kind_of(ODDB::State::Admin::Confirm, @state.password_request)
  end
  def test_password_request__error
    flexmock(@session).should_receive(:yus_grant).and_raise(Yus::UnknownEntityError)    
    skip("Niklaus does not know why this test passes when run via the suite") unless __FILE__.eql?($0)
    assert_equal(@state, @state.password_request)
  end
end

    end # Admin
  end # State
end # ODDB
