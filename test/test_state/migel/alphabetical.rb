#!/usr/bin/env ruby
# ODDB::State::Migel::TestAlphabetical -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'util/interval'
require 'view/resulttemplate'
require 'state/migel/alphabetical'

module ODDB
  module State
    module Migel

class TestAlphabetical < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :language => 'language'
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Migel::Alphabetical.new(@session, @model)
  end
  def test_index_name
    assert_equal('migel_index_language', @state.index_name)
  end
  def test_index_name__en
    flexmock(@session, :language => 'en')
    assert_equal('migel_index_de', @state.index_name)
  end
end

    end # Migel
  end # State
end # ODDB
