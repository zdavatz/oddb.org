#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Doctors::TestVCard -- oddb.org -- 05.07.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/welcomehead'
require 'state/doctors/global'
require 'state/doctors/vcard'

module ODDB
  module State
    module Doctors

class TestVCard <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @model   = flexmock('model')
    pointer  = flexmock('pointer', :resolve => @moel)
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :user_input  => pointer
                       )
    @state   = ODDB::State::Doctors::VCard.new(@session, @model)
  end
  def test_init
    assert_nil(@state.init)
  end
end

    end # Doctors
  end # State
end # ODDB
