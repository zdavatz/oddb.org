#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::User::TestMailingList -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../../../src', File.dirname(__FILE__))


gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/user/mailinglist'
require 'sbsm/validator'
$: << File.expand_path("../..", File.dirname(__FILE__))

module ODDB
  module State
    module User

class TestMailingList <Minitest::Test
  include FlexMock::TestCase
  def setup
		Util.configure_mail :test
		Util.clear_sent_mails
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @state   = ODDB::State::User::MailingList.new(@session, @model)
  end
  def test_send_email
    assert(@state.send_email('subscriber', 'recipient', 'info_message'))
		assert_equal(1, Util.sent_mails.size)
		assert_equal('info_message', Util.sent_mails.first.body.to_s)
  end
  def test_send_email__error
		skip "Don't know how to generate a SBSM::ProcessingError. But this should better be part of the paypal unit test"
    assert_kind_of(SBSM::ProcessingError, @state.send_email('subscriber', 'recipient', 'info_message'))
  end
  def test_update__subscribe
    flexmock(@session) do |s|
      s.should_receive(:user_input).with(:subscribe).once.and_return('subscribe')
      s.should_receive(:user_input).with(:email).once.and_return('email')
    end
    assert_equal(@state, @state.update)
  end
  def test_update__unsubscribe
    flexmock(@session) do |s|
      s.should_receive(:user_input).with(:subscribe).once.and_return(nil)
      s.should_receive(:user_input).with(:unsubscribe).once.and_return('unsubscribe')
      s.should_receive(:user_input).with(:email).once.and_return('email')
    end
    assert_equal(@state, @state.update)
  end
  def test_update__error
    flexmock(@session) do |s|
      s.should_receive(:user_input).with(:subscribe).once.and_return(nil)
      s.should_receive(:user_input).with(:unsubscribe).once.and_return('unsubscribe')
      s.should_receive(:user_input).with(:email).once.and_return(SBSM::InvalidDataError.new('message', 'key', 'value'))
    end

    assert_equal(@state, @state.update)
  end

end

    end # User
  end # State
end # ODDB
