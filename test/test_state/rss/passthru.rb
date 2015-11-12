#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Rss::TestPassThru -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'util/oddbconfig'
require 'state/rss/passthru'

module ODDB
  module State
    module Rss

class TestPassThru <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :language    => 'language',
                        :passthru    => 'passthru'
                       )
    @state   = ODDB::State::Rss::PassThru.new(@session, 'model')
  end
  def test_init
    assert_equal('passthru', @state.init)
  end
end

    end # Rss
  end # State
end # ODDB
