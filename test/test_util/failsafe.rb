#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestFailsafe -- oddb -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'util/failsafe'

module ODDB
  class StubFailsafe
    include Failsafe
  end
  class TestFailsafe < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @util = ODDB::StubFailsafe.new
    end
    def stdout_null
      require 'tempfile'
      $stdout = Tempfile.open('stdout')
      yield
      $stdout.close
      $stdout = STDOUT
    end
    def test_failsafe
      result = nil
      stdout_null do 
        result = @util.failsafe do 
          raise
        end
      end
      assert_kind_of(RuntimeError, result)
    end
  end

end

