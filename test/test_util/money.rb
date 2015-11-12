#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Util::TestMoney -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'util/money'

module ODDB
  module Util

class TestMoney <Minitest::Test
  include FlexMock::TestCase
  def setup
    @money = ODDB::Util::Money.new(123.0, 'type', 'country')
  end
  def test_amount
    assert_in_delta(123.0, @money.amount, 0.01)
    @money.amount = nil
    assert_in_delta(0.0, @money.amount, 0.01)
  end
  def test_is_for
    assert(@money.is_for?('type', 'country'))
  end
  def test_to_i
    assert_equal(12300, @money.to_i)
  end
end

  end # Util
end # ODDB
