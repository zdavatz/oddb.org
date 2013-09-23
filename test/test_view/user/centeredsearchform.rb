#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::User::TestCenteredSearchForm -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/user/centeredsearchform'


module ODDB
  module View
    module User

class TestCenteredSearchComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @app       = flexmock('app',:package_count => 0)
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url => '_event_url',
                          :enabled?   => nil,
                          :zones      => 'zones',
                          :base_url   => 'base_url',
                          :zone_navigation => 'zone_navigation',
                          :direct_event    => 'direct_event'
                         )
    @session   = flexmock('session', 
                          :app => @app,
                          :lookandfeel => @lnf
                         )
    @model     = flexmock('model')
    @composite = ODDB::View::User::CenteredSearchComposite.new(@model, @session)
  end
  def test_new_registration
    assert_kind_of(HtmlGrid::Link, @composite.new_registration(@model, @session))
  end
  def test_substance_count
    flexmock(@app, :substance_count => 0)
    assert_equal(0, @composite.substance_count(@model, @session))
  end
end

    end # User
  end # View
end # ODB

