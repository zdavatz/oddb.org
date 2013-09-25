#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::TestFachinfos -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))


gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/resultfoot'
require 'state/drugs/fachinfos'

module ODDB
  module State
    module Drugs

class TestFachinfos <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @fachinfo = flexmock('fachinfo', :registrations => ['registration'])
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :language    => 'language',
                        :fachinfos_by_name => [@fachinfo]
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Drugs::Fachinfos.new(@session, @model)
  end
  def test_index_lookup
    assert_equal([@fachinfo], @state.index_lookup('range'))
  end
  def test_symbol
    assert_equal([:localized_name, "language"], @state.symbol)
  end
  def test_index_name
    assert_equal('fachinfo_name_language', @state.index_name)
  end
  def test_index_name__de
    flexmock(@session, :language => 'en')
    assert_equal('fachinfo_name_de', @state.index_name)
  end
end

    end # Drugs
  end # State
end # ODDB
