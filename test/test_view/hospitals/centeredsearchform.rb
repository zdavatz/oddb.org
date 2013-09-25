#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Hospitals::TestCenteredSearchForm -- oddb.org -- 30.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/hospitals/centeredsearchform'

module ODDB
  module View
    module Hospitals

class TestCenteredSearchComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @app       = flexmock('app')
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :enabled?   => nil,
                          :_event_url => '_event_url',
                          :disabled?  => nil,
                          :zones      => 'zones',
                          :base_url   => 'base_url',
                          :zone_navigation => 'zone_navigation',
                          :direct_event => 'direct_event'
                         )
    @session   = flexmock('session', 
                          :app => @app,
                          :lookandfeel => @lnf,
                          :hospital_count => 0,
                          :zone => 'zone'
                         )
    @model     = flexmock('model')
    @composite = ODDB::View::Hospitals::CenteredSearchComposite.new(@model, @session)
  end
  def test_hospitals_count
    assert_equal('0&nbsp;', @composite.hospitals_count(@modle, @session))
  end
end

    end # Hospitals
  end # View
end # ODDB
