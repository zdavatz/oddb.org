#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestPatent -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'model/patent'

module ODDB
  class TestPatent <Minitest::Test
    include FlexMock::TestCase
    def setup
      flexmock(ODBA.cache, :next_id => 123)
      @model = ODDB::Patent.new
    end
    def test_pointer_descr
      assert_equal(:patent, @model.pointer_descr)
    end
    def test_protected
      assert_nil(@model.protected?)
    end
  end
end
