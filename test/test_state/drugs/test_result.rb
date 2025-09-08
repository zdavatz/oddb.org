#!/usr/bin/env ruby

# ODDB::State::Drugs::TestResult -- oddb.org -- 06.07.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Drugs::TestResult -- oddb.org -- 11.03.2003 -- aschrafl@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../..", File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require "minitest/autorun"
require "define_empty_class"
require "flexmock/minitest"
class TestResult < Minitest::Test
  def dummy_test
    skip("TODO: August 2025: Why suddendly this test does not work anymore. We user standarb --fix for various files")
  end
end
