#!/usr/bin/env ruby
# encoding: utf-8

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'util/zsr'

module ODDB
  class TestZsr <Minitest::Test
    def checkAnswer(info)
      assert_equal("7601000159199", info[:gln_id])
      assert_equal("Dr. med.", info[:title])
      assert_equal("Davatz", info[:last_name])
    end
    def test_zsr
      checkAnswer (ZSR.info('J039019'))
      checkAnswer (ZSR.info('J 0390.19'))
    end
  end
end # ODDB
