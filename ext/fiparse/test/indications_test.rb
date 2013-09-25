#!/usr/bin/env ruby
# FiParse::TestMiniFi -- oddb.org -- 23.04.2007 -- hwyss@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'indications'

module ODDB
  module FiParse
    class TestIndicationsHandler <Minitest::Test
      def setup
        @writer = Indications::Handler.new
      end
      def test_smj_07_2007
        eval(File.read(File.expand_path('data/smj_07_2007.rb',
                                        File.dirname(__FILE__))))
        assert_equal 8, @writer.flags.size
        assert_equal 140, @writer.indications.size
      end
    end
  end
end
