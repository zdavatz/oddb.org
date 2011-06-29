#!/usr/bin/env ruby
# ODDB::View::Admin::TestCenteredSearchForm -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/admin/centeredsearchform'


module ODDB
  module View
    module Admin

class TestCenteredSearchComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app       = flexmock('app', 
                          :package_count   => 0,
                          :substance_count => 0
                         )
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :enabled?   => nil,
                          :zones      => 'zones',
                          :base_url   => 'base_url',
                          :_event_url => '_event_url',
                          :zone_navigation => 'zone_navigation',
                          :direct_event => 'direct_event'
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :app => @app
                         )
    @model     = flexmock('model')
    @composite = ODDB::View::Admin::CenteredSearchComposite.new(@model, @session)
  end
  def test_substance_count
    assert_equal(0, @composite.substance_count(@model, @session))
  end
end

    end # Admin
  end # View
end # ODDB
