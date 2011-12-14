#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::TestPackage -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

#require 'state/global'

require 'test/unit'
require 'flexmock'
require 'state/drugs/package'

module ODDB
  module State
    module Drugs

class TestPackage < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model', :pointer => 'pointer')
    @state   = ODDB::State::Drugs::Package.new(@session, @model)
  end
  def test_augment_self
    resolve_state = flexmock('resolve_state', :new => 'new')
    flexmock(@state, :resolve_state => resolve_state)
    assert_equal('new', @state.augment_self)
  end
  def test_augment_self__nil
    flexmock(@state, :resolve_state => nil)
    assert_equal(@state, @state.augment_self)
  end
end

    end # Drugs
  end # State
end # ODDB
