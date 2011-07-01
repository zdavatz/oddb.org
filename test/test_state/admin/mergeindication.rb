#!/usr/bin/env ruby
# ODDB::State::Admin::TestMergeIndication -- oddb.rg -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/admin/mergeindication'
require 'state/admin/indication'

module ODDB
  module State
    module Admin

class TestMergeIndication < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app', 
                        :indication_by_text => 'target',
                        :merge_indications  => 'merge_indications'
                       )
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :user_input  => 'user_input'
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Admin::MergeIndication.new(@session, @model)
  end
  def test_merge
    assert_kind_of(ODDB::State::Admin::Indication, @state.merge)
  end
  def test_merge__taret_nil
    flexmock(@app, :indication_by_text => nil)
    assert_equal(@state, @state.merge)
  end
  def test_merge__taret_model
    flexmock(@app, :indication_by_text => @model)
    assert_equal(@state, @state.merge)
  end
end

    end # Admin
  end # State
end # ODDB
