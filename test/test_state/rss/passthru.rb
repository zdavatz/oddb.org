#!/usr/bin/env ruby
# ODDB::State::Rss::TestPassThru -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'util/oddbconfig'
require 'state/rss/passthru'

module ODDB
  module State
    module Rss

class TestPassThru < Test::Unit::TestCase
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
