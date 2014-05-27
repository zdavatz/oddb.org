#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::TestSuggestAddress -- oddb.org -- 09.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'state/global'

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/suggest_address'
require 'util/mail'

module ODDB 
	module State

class TestSuggestAddress <Minitest::Test
  include FlexMock::TestCase
  def setup
    Util.configure_mail :test
    Util.clear_sent_mails
    @update  = flexmock('update', 
                        :email_suggestion => 'email_suggestion',
                        :fullname => 'fullname',
                        :pointer  => 'pointer'
                       )
    @app     = flexmock('app', :update => @update)
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :_event_url => '_event_url'
                       )
    doctor   = flexmock('doctor', :fullname => 'fullname')
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :user_input  => {},
                        :persistent_user_input => 'persistent_user_input',
                        :set_cookie_input => 'set_cookie_input',
                        :search_doctor => doctor
                       ).by_default
    parent   = flexmock('parent', :fullname => 'fullname')
    @model   = flexmock('model', 
                        :pointer => 'pointer',
                        :parent  => parent
                       )
    @state   = ODDB::State::SuggestAddress.new(@session, @model)
    flexmock(@state, :unique_email => 'unique_email')
  end
  def test_address_send
    flexmock(@session, :user_input => {:name => 'name', :email => 'email'})
    assert_kind_of(ODDB::State::AddressConfirm, @state.address_send)
      mails_sent = Util.sent_mails
      assert_equal(1, mails_sent.size)
      assert_equal('lookup fullname', mails_sent.first.subject)
      assert_equal('_event_url', mails_sent.first.body.to_s)
      assert_equal(['email_suggestion'], mails_sent.first.from)
      assert_equal(["zdavatz@ywesee.com", "mhatakeyama@ywesee.com"], mails_sent.first.to)
  end
  def test_save_suggestion
    flexmock(@session, :user_input => {:message => 'message', :name => 'name', :email => 'email'})
    assert_equal(@update, @state.save_suggestion)
  end
end


	end # State
end # ODDB
