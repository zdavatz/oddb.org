#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Doctors::TestGlobal -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/welcomehead'
#require 'state/global'
require 'state/doctors/global'

module ODDB
  module State
    module Doctors
      class LegalNote
        def initialize(session, model)
        end
      end

class TestGlobal < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', :lookandfeel => @lnf)
    @model   = flexmock('model')
    @state   = ODDB::State::Doctors::Global.new(@session, @model)
  end
  def test_legal_note
    assert_kind_of(ODDB::State::Doctors::LegalNote, @state.legal_note)
  end
  def test_limit_state
    assert_kind_of(ODDB::State::Doctors::Limit, @state.limit_state)
  end
end

    end # Doctors
  end # State
end # ODDB
