#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestFachinfoAssign -- oddb.org -- 20.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'view/admin/orphaned_fachinfo_assign'


module ODDB
  module View
    module Admin

class TestOrphanedFachinfoRegistrations < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :event_url  => 'event_url',
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :event       => 'event',
                        :allowed?    => nil,
                        :warning?    => nil,
                        :error?      => nil
                       )
    @model   = flexmock('model', 
                        :pointer          => 'pointer',
                        :fachinfo_active? => nil,
                        :has_fachinfo?    => nil,
                        :name_base        => 'name_base'
                       )
    @list    = ODDB::View::Admin::OrphanedFachinfoRegistrations.new([@model], @session)
  end
  def test_init
    assert_nil(@list.init)
  end
end

class TestOrphanedFachinfoAssignComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :base_url   => 'base_url',
                          :_event_url => '_event_url',
                          :disabled?  => nil,
                          :event_url  => 'event_url'
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :zone        => 'zone',
                          :event       => 'event',
                          :allowed?    => nil,
                          :warning?    => nil,
                          :error?      => nil
                         )
    registration = flexmock('registration', 
                            :pointer          => 'pointer',
                            :fachinfo_active? => nil,
                            :has_fachinfo?    => nil,
                            :name_base        => 'name_base'
                           )
    @model     = flexmock('model', :registrations => [registration])
    @composite = ODDB::View::Admin::OrphanedFachinfoAssignComposite.new(@model, @session)
  end
  def test_registrations
    assert_kind_of(ODDB::View::Admin::OrphanedFachinfoRegistrations, @composite.registrations(@model, @session))
  end
end

    end # Admin
  end    # View
end     # ODDB
