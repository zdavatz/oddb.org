#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::TestSuggestAddress -- oddb.org -- 09.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'state/global'

require 'test/unit'
require 'flexmock'
require 'state/suggest_address'

module ODDB 
	module State

class TestSuggestAddress < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    smtp = flexmock('smtp', :sendmail => 'sendmail')
    flexmock(Net::SMTP) do |net|
      net.should_receive(:start).and_yield(smtp)
    end
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
                       )
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
  end
  def test_save_suggestion
    flexmock(@session, :user_input => {:message => 'message', :name => 'name', :email => 'email'})
    assert_equal(@update, @state.save_suggestion)
  end
end


	end # State
end # ODDB
