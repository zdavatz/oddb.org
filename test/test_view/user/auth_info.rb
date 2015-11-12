#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::User::TestAuthInfo -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/user/auth_info'


module ODDB
  module View
    module User

class TestAuthInfoComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url => '_event_url'
                         )
    @session   = flexmock('session', :lookandfeel => @lnf)
    @model     = flexmock('model', :email => 'email')
    @composite = ODDB::View::User::AuthInfoComposite.new(@model, @session)
  end
  def test_auth_info
    assert_equal('lookup', @composite.auth_info(@model))
  end
end

    end # User
  end # View
end # ODB

