#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Migel::TestResult -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

#require 'state/global'

require 'test/unit'
require 'flexmock'
require 'view/resulttemplate'
require 'state/migel/result'

module ODDB 
  module State
    module Migel

class TestSubgroupFacade < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @subgroup = flexmock('subgroup')
    @facade   = ODDB::State::Migel::Result::SubgroupFacade.new(@subgroup)
  end
  def test_add_product
    assert_equal('product', @facade.add_product('product'))
  end
end

class TestResult < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf      = flexmock('lookandfeel', :lookup => 'lookup')
    @session  = flexmock('session', :lookandfeel => @lnf)
    @subgroup = flexmock('subgroup', :migel_code => 'migel_code')
    @model    = flexmock('model', :subgroup => @subgroup)
    @state    = ODDB::State::Migel::Result.new(@session, [@model])
  end
  def test_init
    assert_kind_of(ODDB::State::Migel::Result::SubgroupFacade, @state.init[0])
  end
  def test_init__empty
    state = ODDB::State::Migel::Result.new(@session, [])
    assert_equal(ODDB::View::Migel::EmptyResult, state.init)
  end
  def test_sort
    product = flexmock('product')
    flexmock(@model, :products => [product])
    user_input = flexmock('user_input', :to_sym => :sym)
    flexmock(@session, :user_input => user_input)
    assert_equal(@state, @state.sort)
  end

end

    end # Migel
  end # State
end # ODDB
