#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Util::TestIsoLatin1 -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'util/iso-latin1'

module ODDB
  module Util

class TestIsoLatin1 < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @str = 'TESTFÄLLE'
  end
  def test_downcase
    assert_equal('testfälle', @str.downcase)
  end
  def test_downcase!
    @str.downcase!
    assert_equal('testfälle', @str)
  end
end

  end # Util
end # ODDB
