#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestAtcClass -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/admin/atcclass'

module ODDB
  module State
    module Admin

class TestAtcClass < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app', :update => 'update')
    @lnf     = flexmock('lookandfeel', 
                        :lookup => 'lookup',
                        :languages => ['language']
                       )
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :user_input  => 'user_input'
                       )
    @model   = flexmock('model', :pointer => 'pointer')
    @state   = ODDB::State::Admin::AtcClass.new(@session, @model)
    flexmock(@state, :unique_email => 'unique_email')
  end
  def test_init
    assert_equal(nil, @state.init)
  end
  def test_update
    assert_equal(@state, @state.update)
  end
end

    end # Admin
  end # State
end # ODDB
