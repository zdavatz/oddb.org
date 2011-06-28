#!/usr/bin/env ruby
# ODDB::State::User::TestMailingList -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../../../src', File.dirname(__FILE__))


require 'test/unit'
require 'flexmock'
require 'state/user/mailinglist'
require 'sbsm/validator'


module ODDB
  module State
    module User

class TestMailingList < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @smtp    = flexmock('smtp', :sendmail => 'sendmail')
    flexmock(Net::SMTP).should_receive(:start).and_yield(@smtp)
    config   = flexmock('config', 
                        :smtp_server => 'smtp_server',
                        :smtp_port   => 'smtp_port',
                        :smtp_domain => 'smtp_domain',
                        :smtp_user   => 'smtp_user',
                        :smtp_pass   => 'smtp_pass',
                        :smtp_authtype => 'smtp_authtype'
                       )
    flexmock(ODDB, :config => config)
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @state   = ODDB::State::User::MailingList.new(@session, @model)
  end
  def test_send_email
    assert_equal(['info_message'], @state.send_email('subscriber', 'recipient', 'info_message'))
  end
  def test_send_email__error
    flexmock(@smtp).should_receive(:sendmail).and_raise(StandardError)
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
