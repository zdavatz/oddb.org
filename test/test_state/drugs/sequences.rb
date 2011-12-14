#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::TestSequences -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'state/global'
module ODDB
  module State
    module Drugs
      class Fachinfo < Global; end
      class RootFachinfo < Fachinfo; end
    end
  end
end

require 'test/unit'
require 'flexmock'
require 'state/drugs/fachinfo'

module ODDB
  module State
    module Drugs

class TestSequences < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup => 'lookup',
                        :has_result_filter? => true,
                        :result_filter => true
                       )
    sequence = flexmock('sequence', :has_public_packages? => nil)
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :search_sequences => [sequence]
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Drugs::Sequences.new(@session, @model)
  end
  def test_index_lookup
    assert_equal([], @state.index_lookup('range'))
  end
  def test_index_name
    assert_equal('sequence_index_exact', @state.index_name)
  end
  def test_sequences
    flexmock(@state, :user_range => 'user_range')
    assert_kind_of(ODDB::State::Drugs::Sequences, @state.sequences)
  end
  def test_sequences__range
    flexmock(@state, :user_range => nil)
    assert_equal(@state, @state.sequences)
  end

end

    end # Drugs
  end # State
end # ODDB
