#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Analysis::TestAlphabetical -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

#require 'state/global'
require 'test/unit'
require 'flexmock'
require 'util/interval'
require 'view/resulttemplate'
require 'state/analysis/alphabetical'

module ODDB
  module State
    module Analysis

class TestAlphabetical < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :language => 'language'
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Analysis::Alphabetical.new(@session, @model)
  end
  def test_index_name
    assert_equal('analysis_alphabetical_index_language', @state.index_name)
  end
  def test_index_name__en
    flexmock(@session, :language => 'en')
    assert_equal('analysis_alphabetical_index_de', @state.index_name)
  end
end

    end # Admin
  end # State
end # ODDB
