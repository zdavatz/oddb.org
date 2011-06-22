#!/usr/bin/env ruby
# ODDB::View::Admin::TestEntities -- oddb.org -- 22.06.2011 -- mhatakeyama@ywesee.com

#$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/admin/entities'

module ODDB
  module View
    Copyright::ODDB_VERSION = 'version'
    module Admin

class TestEntities < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :enabled?   => nil,
                        :attributes => {},
                        :resource   => 'resource',
                        :zones      => 'zones',
                        :disabled?  => nil,
                        :direct_event => 'direct_event',
                        :_event_url   => '_event_url',
                        :event_url    => 'event_url',
                        :base_url     => 'base_url',
                        :navigation   => 'navigation',
                        :zone_navigation => 'zone_navigation'
                       )
    user     = flexmock('user', :valid? => nil)
    sponsor  = flexmock('sponsor', :valid? => nil)
    name     = flexmock('name', :name => 'name')
    affiliation = flexmock('affiliation', :name => name)
    @model   = flexmock('model', 
                        :pointer => 'pointer',
                        :name    => 'name',
                        :affiliations => [affiliation],
                        :get_preference => 'get_preference'
                       )
    state    = flexmock('state', 
                        :direct_event   => 'direct_event',
                        :snapback_model => @model
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :user     => user,
                        :sponsor  => sponsor,
                        :state    => state,
                        :allowed? => nil,
                        :event    => 'event',
                        :zone     => 'zone'
                       )
    flexmock(ODDB::View::Admin::Entities::Wrapper).new_instances do |wrapper|
      wrapper.should_receive(:get_preference).and_return('get_preference')
    end
    @view    = ODDB::View::Admin::Entities.new([@model], @session)
  end
  def test_init
    assert_equal({}, @view.init)
  end
end

    end # Admin
  end # View
end # ODDB

