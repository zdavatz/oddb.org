#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Migel::TestCenteredSearchComposite -- oddb.org -- 21.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'view/migel/centeredsearchform'

module ODDB
  module View
    module Migel

class TestCenteredSearchComposite <Minitest::Test
  def setup
    @app       = flexmock('app')
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :enabled?   => nil,
                          :attributes => {},
                          :_event_url => '_event_url',
                          :disabled?  => nil,
                          :zones      => ['zones'],
                          :base_url   => 'base_url',
                          :zone_navigation => ['zone_navigation'],
                          :direct_event    => 'direct_event',
                          :languages  => ['languages'],
                          :currencies => ['currencies'],
                          :language   => 'language'
                         ).by_default
    @session   = flexmock('session', 
                          :app  => @app,
                          :zone => 'zone',
                          :lookandfeel  => @lnf,
                          :migel_count  => 0,
                          :request_path => 'request_path',
                          :currency     => 'currency',
                          :event        => 'event',
                         )
    @model     = flexmock('model')
    @composite = ODDB::View::Migel::CenteredSearchComposite.new(@model, @session)
  end
  def test_init
    assert_equal({}, @composite.init)
  end
  def test_init__just_medical_structure
    flexmock(@lnf, :enabled? => true)
    assert_equal({}, @composite.init)
  end
end

    end # Migel
  end # View
end # ODDB
