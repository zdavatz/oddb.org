#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::TestVaccines -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/global'
require 'state/drugs/vaccines'

module ODDB
  module State
    module Drugs

class TestVaccines < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :persistent_user_input => 'persistent_user_input'
                       )
    @model   = flexmock('model')
    flexmock(ODBA.cache, :index_keys => [])
    @state   = ODDB::State::Drugs::Vaccines.new(@session, @model)
  end
  def test_vaccines
    assert_equal(@state, @state.vaccines)
  end
  def test_vaccines__else
    @state.instance_eval('@range = "range"')
    assert_kind_of(ODDB::State::Drugs::Vaccines, @state.vaccines)
  end

end

    end # Drugs
  end # State
end # ODDB
