#!/usr/bin/env ruby
# ODDB::State::Drugs::TestNarcotics -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/drugs/narcotics'

module ODDB
  module State
    module Drugs

class TestNarcotics < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :language    => 'language'
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Drugs::Narcotics.new(@session, @model)
  end
  def test_index_name
    assert_equal('narcotics_language', @state.index_name)
  end
  def test_index_name_en
    flexmock(@session, :language => 'en')
    assert_equal('narcotics_de', @state.index_name)
  end
end

    end # Drugs
  end # State
end # ODDB
