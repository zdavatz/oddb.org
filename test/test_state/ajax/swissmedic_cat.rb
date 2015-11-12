#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Ajax::TestSwissmedicCat -- oddb.org -- 14.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'sbsm/state'
require 'util/persistence'
require 'state/ajax/swissmedic_cat'

module ODDB
  module State
    module Ajax

class TestSwissmedicCat <Minitest::Test
  include FlexMock::TestCase
  def setup
    @package  = flexmock('package')
    sequence = flexmock('sequence', :package => @package)
    registration = flexmock('registration', :sequence => sequence)
    @app     = flexmock('app', :registration => registration)
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @model   = flexmock('model')
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :user_input  => @pointer
                       )
    @state   = ODDB::State::Ajax::SwissmedicCat.new(@session, @model)
  end
  def test_init
    assert_equal(@package, @state.init)
  end
  def test_init__nil
    flexmock(@pointer, :is_a? => false)
    assert_equal(@package, @state.init)
  end
end

    end # Ajax
  end # State
end # ODDB
