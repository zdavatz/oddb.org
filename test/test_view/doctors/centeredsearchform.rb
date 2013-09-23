#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Doctors::TestCenteredSearchForm -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/doctors/centeredsearchform'

module ODDB
  module View
    module Doctors

class TestCenteredSearchComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @app       = flexmock('app')
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url => '_event_url',
                          :enabled?   => nil,
                          :disabled?  => nil,
                          :zones      => 'zones',
                          :base_url   => 'base_url',
                          :zone_navigation => 'zone_navigation',
                          :direct_event    => 'direct_event'
                         )
    @session   = flexmock('session', 
                          :app => @app,
                          :lookandfeel  => @lnf,
                          :doctor_count => 0,
                          :zone => 'zone'
                         )
    @model     = flexmock('model')
    @composite = ODDB::View::Doctors::CenteredSearchComposite.new(@model, @session)
  end
  def test_doctor_count
    assert_equal('0&nbsp;', @composite.doctor_count(@model, @session))
  end
end

    end # Doctors
  end # View
end # ODDB
