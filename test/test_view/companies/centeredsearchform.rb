#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Companies::TestCenteredSearchForm -- oddb.org -- 29.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/companies/centeredsearchform'


module ODDB
  module View
    module Companies

class TestCenteredSearchComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app       = flexmock('app', :company_count => 0)
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :enabled?   => nil,
                          :_event_url => '_event_url',
                          :disabled?  => nil,
                          :zones      => 'zones',
                          :base_url   => 'base_url',
                          :zone_navigation => 'zone_navigation',
                          :direct_event    => 'direct_event'
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :app  => @app,
                          :zone => 'zone'
                         )
    @model     = flexmock('model')
    @composite = ODDB::View::Companies::CenteredSearchComposite.new(@model, @session)
  end
  def test_company_count
    assert_equal('0&nbsp;', @composite.company_count(@model, @session))
  end
end

    end # Companies
  end # View
end # ODDB
