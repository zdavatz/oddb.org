#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Analysis::TestCenteredSearchForm -- oddb.org -- 29.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/analysis/centeredsearchform'

module ODDB
  module View
    module Analysis

class TestCenteredSearchComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :enabled?   => nil,
                          :attributes => {},
                          :_event_url => '_event_url',
                          :disabled?  => nil,
                          :zones      => 'zones',
                          :base_url   => 'base_url',
                          :zone_navigation => 'zone_navigation',
                          :direct_event    => 'direct_event'
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :analysis_count => 0,
                          :zone => 'zone'
                         )
    @model     = flexmock('model')
    @composite = ODDB::View::Analysis::CenteredSearchComposite.new(@model, @session)
  end
  def test_download_analysis
    assert_kind_of(HtmlGrid::Link, @composite.download_analysis(@model, @session))
  end
end


    end # Analysis
  end # View
end # ODDB
