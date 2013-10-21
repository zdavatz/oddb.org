#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Migel::TestAlphabetical -- oddb.org -- 09.09.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'util/interval'
require 'view/resulttemplate'
require 'state/migel/alphabetical'

module ODDB
  module State
    module Migel

class TestAlphabetical <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :language => 'language'
                       ).by_default
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
  def test_index_lookup
    flexmock(@session, :"app.search_migel_alphabetical" => 'search_migel_alphabetical')
    assert_equal('search_migel_alphabetical', @state.index_lookup('query'))
  end
  def test_index_lookup__en
    flexmock(@session, 
             :"app.search_migel_alphabetical" => 'search_migel_alphabetical',
             :language => 'en'
            )
    assert_equal('search_migel_alphabetical', @state.index_lookup('query'))
  end

end

    end # Migel
  end # State
end # ODDB
