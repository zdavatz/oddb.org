#!/usr/bin/env ruby
# ODDB::Analysis::TestDetailInfo -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'model/analysis/detail_info'

module ODDB
  module Analysis

class TestDetailInfo < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @model = ODDB::Analysis::DetailInfo.new('lab_key')
  end
  def test_to_s
    assert_equal('', @model.to_s)
  end
end

  end # Analysis
end # ODDB
