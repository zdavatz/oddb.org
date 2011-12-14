#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Doctors::TestDoctor -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/welcomehead'
require 'state/global'
require 'state/doctors/doctor'

module ODDB
  module State
    module Doctors

class TestRootDoctor < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app', :update => 'update')
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :user_input  => {:name => 'name', :name_first => 'name_first', :title => 'title'}
                       )
    @model   = flexmock('model', :pointer => 'pointer')
    @state   = ODDB::State::Doctors::RootDoctor.new(@session, @model)
  end
  def test_update
    assert_equal(@state, @state.update)
  end
end

    end # Doctors
  end # State
end # ODDB
