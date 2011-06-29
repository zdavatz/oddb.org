#!/usr/bin/env ruby
# ODDB::State::Admin::TestPasswordReset -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/admin/password_reset'

module ODDB
  module State
    module Admin

class TestPasswordReset < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :user_input  => {:set_pass_1 => 'set_pass', :set_pass_2 => 'set_pass'},
                        :yus_reset_password => 'yus_reset_password',
                        :valid_input => {}
                       )
    @model   = flexmock('model', 
                        :email  => 'email',
                        :token  => 'token',
                        :valid? => nil,
                        :allowed? => nil
                       )
    flexmock(@session, :login => @model)
    @state   = ODDB::State::Admin::PasswordReset.new(@session, @model)
  end
  def test_password_reset
    assert_kind_of(ODDB::State::User::InvalidUser, @state.password_reset)
  end
  def test_password_reset__error
    flexmock(@session, :user_input  => {:set_pass_1 => 'set_pass_1', :set_pass_2 => 'set_pass_2'})
    assert_nil(@state.password_reset)
  end
end

    end # Admin
  end # State
end # ODDB
