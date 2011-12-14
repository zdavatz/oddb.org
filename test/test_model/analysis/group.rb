#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Analysis::TestGroup -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'model/analysis/group'

module ODDB
  module Analysis

class TestGroup < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @group = ODDB::Analysis::Group.new('groupcd')
  end
  def test_create_position
    assert_kind_of(ODDB::Analysis::Position, @group.create_position('poscd'))
  end
  def test_position
    @group.create_position('poscd')
    assert_kind_of(ODDB::Analysis::Position, @group.position('poscd'))
  end
end

  end # Analysis
end # ODDB
