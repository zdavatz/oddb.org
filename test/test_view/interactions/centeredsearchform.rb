#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Interactions::TestCenteredSearchForm -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'view/interactions/centeredsearchform'

module ODDB
  module View
    class Session
      DEFAULT_FLAVOR = 'gcc' unless defined?(DEFAULT_FLAVOR)
    end
    module Interactions

class TestCenteredSearchComposite <Minitest::Test
  def setup
    @app       = flexmock('app', 
                          :package_count   => 0,
                          :substance_count => 0,
		                      :registrations   => [],
                         )
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :enabled?   => nil,
                          :_event_url => '_event_url',
                          :disabled?  => nil,
                          :zones      => ['zones'],
                          :base_url   => 'base_url',
                          :direct_event    => 'direct_event',
                          :zone_navigation => ['zone_navigation'],
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :app  => @app,
                          :zone => 'zone',
                          :search_form => 'search_form',
                          :flavor => 'flavor',
                          :event => 'event',
		                      :persistent_user_input => [],
                         )
    @model     = flexmock('model')
    @composite = ODDB::View::Interactions::CenteredSearchComposite.new(@model, @session)
  end
  def test_substance_count
    assert_equal('0&nbsp;', @composite.substance_count(@model, @session))
  end
end

    end # Interactions
  end # View
end # ODDB
