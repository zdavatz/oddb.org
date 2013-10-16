#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::TestPatinfoAssign -- oddb.org -- 20.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'htmlgrid/labeltext'
require 'view/admin/orphaned_patinfo_assign'


module ODDB
  module View
    module Admin

class TestOrphanedPatinfoSequences <Minitest::Test
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
                        :state       => 'state',
                        :language    => 'language',
                        :warning?    => nil,
                        :error?      => nil
                       )
    substance    = flexmock('substance', :language => 'language')
    active_agent = flexmock('active_agent', 
                            :substance => substance,
                            :dose      => 'dose'
                           )
    galenic_form = flexmock('galenic_form', :language => 'language')
    composition  = flexmock('composition', 
                            :galenic_form  => galenic_form,
                            :active_agents => [active_agent]
                           )
    pointer    = flexmock('pointer', :to_csv => 'pointer.to_csv')
    @model   = flexmock('model', 
                        :pointer => pointer,
                        :seqnr   => 'seqnr',
                        :compositions => [composition],
                        :has_patinfo? => nil,
                        :name_base    => 'name_base'
                       )
    @list    = ODDB::View::Admin::OrphanedPatinfoSequences.new([@model], @session)
  end
  def test_init
    assert_nil(@list.init)
  end
end

class TestOrphanedPatinfoAssignComposite <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf       = flexmock('lookandfeel', 
                          :lookup     => 'lookup',
                          :attributes => {},
                          :_event_url => '_event_url',
                          :disabled?  => nil,
                          :base_url   => 'base_url',
                          :event_url  => 'event_url'
                         )
    @session   = flexmock('session', 
                          :lookandfeel => @lnf,
                          :zone        => 'zone',
                          :event       => 'event',
                          :allowed?    => nil,
                          :state       => 'state',
                          :language    => 'language',
                          :warning?    => nil,
                          :error?      => nil
                         )
    substance    = flexmock('substance', :language => 'language')
    active_agent = flexmock('active_agent', 
                            :substance => substance,
                            :dose      => 'dose'
                           )
    galenic_form = flexmock('galenic_form', :language => 'language')
    composition  = flexmock('composition', 
                            :galenic_form => galenic_form,
                            :active_agents => [active_agent]
                           )
    pointer    = flexmock('pointer', :to_csv => 'pointer.to_csv')
    sequence   = flexmock('sequence', 
                          :pointer => pointer,
                          :seqnr   => 'seqnr',
                          :compositions => [composition],
                          :has_patinfo? => nil,
                          :name_base    => 'name_base'
                         )
    @model     = flexmock('model', :sequences => [sequence])
    @composite = ODDB::View::Admin::OrphanedPatinfoAssignComposite.new(@model, @session)
  end
  def test_sequences
    assert_kind_of(ODDB::View::Admin::OrphanedPatinfoSequences, @composite.sequences(@model, @session))
  end
end
    end # Admin
  end    # View
end     # ODDB
