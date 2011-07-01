#!/usr/bin/env ruby
# ODDB::State::Admin::TestMergeCommercialForm -- oddb.rg -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/admin/merge_commercial_form'
require 'model/commercial_form'
require 'view/admin/registration'
require 'view/descriptionform'
require 'state/admin/commercial_form'

module ODDB
  module State
    module Admin

class TestMergeCommercialForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app', :merge_commercial_forms => 'merge_commercial_forms')
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :user_input  => 'user_input'
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Admin::MergeCommercialForm.new(@session, @model)
  end
  def test_merge
    flexmock(ODBA.cache, :retrieve_from_index => ['retrieve_from_index'])
    assert_kind_of(ODDB::State::Admin::CommercialForm, @state.merge)
  end
  def test_merge__target_nil
    flexmock(ODBA.cache, :retrieve_from_index => [nil])
    assert_equal(@state, @state.merge)
  end
  def test_merge__target_model
    flexmock(ODBA.cache, :retrieve_from_index => [@model])
    assert_equal(@state, @state.merge)
  end
end

    end # Admin
  end # State
end # ODDB
