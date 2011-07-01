#!/usr/bin/env ruby
# ODDB::State::Drugs::TestInit -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/drugs/init'

module ODDB
  module State
    module Drugs

class TestInit < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    revision = flexmock('revision', 
                        :year  => 2011,
                        :month => 2,
                        :day   => 3
                       )
    fachinfo = flexmock('fachinfo', :revision => revision)
    @app     = flexmock('app', 
                        :sorted_fachinfos => [fachinfo],
                        :sorted_feedbacks => 'sorted_feedbacks'
                       )
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :app => @app
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Drugs::Init.new(@session, @model)
  end
  def test_init
    assert_equal('sorte', @state.init)
  end
end

    end # Drugs
  end # State
end # ODDB
