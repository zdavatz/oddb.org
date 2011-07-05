#!/usr/bin/env ruby
# ODDB::State::Hospitals::TestVCard -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))


require 'test/unit'
require 'flexmock'
require 'view/welcomehead'
require 'state/hospitals/global'
require 'state/hospitals/vcard'

module ODDB
  module State
    module Hospitals

class TestVCard < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @model   = flexmock('model')
    pointer  = flexmock('pointer', :resolve => @model)
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :user_input  => pointer
                       )
    @state   = ODDB::State::Hospitals::VCard.new(@session, @model)
  end
  def test_init
    assert_nil(@state.init)
  end
end


    end # Hospitals
  end # State
end # ODDB

