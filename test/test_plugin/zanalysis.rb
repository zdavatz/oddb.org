#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestAnalysisPlugin -- oddb.org -- 07.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))
$: << File.expand_path("..", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'stub/odba'
require 'stub/oddbapp'
require 'plugin/analysis'

module ODDB
  class TestAnalysisPlugin <Minitest::Test
    def setup
      @position = flexmock('position', :pointer => 'pointer')
      @analysis_group = flexmock('analysis_group', :position => @position)
      @app    = flexmock('app', 
                         :create => 'create',
                         :analysis_group => @analysis_group,
                        )
      @plugin = ODDB::AnalysisPlugin.new(@app)
    end
    def test_update_group
      @position.should_receive(:delete)
      assert_equal(@analysis_group, @plugin.update_group(@position))
    end
    def test_position
      pointer  = flexmock('pointer', :creator => 'creator' )
      flexmock(pointer, :+ => pointer)
      limitation_text = flexmock('limitation_text', :pointer => pointer)
      footnote   = flexmock('footnote', :pointer => pointer)
      list_title = flexmock('list_title', :pointer => pointer)
      taxnote    = flexmock('taxnote', :pointer => pointer)
      permissions = flexmock('permissions', :pointer => pointer)
      update     = flexmock('update', 
                            :limitation_text => limitation_text,
                            :footnote   => footnote,
                            :list_title => list_title,
                            :taxnote    => taxnote,
                            :pointer    => pointer,
                            :permissions => permissions
                           )
      flexmock(@app, 
               :update => update,
               :delete => 'delete'
              )
      group    = flexmock('group', :pointer => pointer)
      position = {:position => 'poscd'}
      skip('Niklaus does not think that this test is correct, analysis does not have any delete method')
      assert_equal('delete', @plugin.update_position(group, position, 'short', 'language'))
    end
    def test_position__delete_permissions
      pointer  = flexmock('pointer', :creator => 'creator' )
      flexmock(pointer, :+ => pointer)
      limitation_text = flexmock('limitation_text', :pointer => pointer)
      footnote   = flexmock('footnote', :pointer => pointer)
      list_title = flexmock('list_title', :pointer => pointer)
      taxnote    = flexmock('taxnote', :pointer => pointer)
      permissions = flexmock('permissions', :pointer => pointer)
      update     = flexmock('update', 
                            :limitation_text => limitation_text,
                            :footnote   => footnote,
                            :list_title => list_title,
                            :taxnote    => taxnote,
                            :permissions => permissions,
                            :pointer    => pointer
                           )
      flexmock(@app, 
               :update => update,
               :delete => 'delete'
              )
      group    = flexmock('group', :pointer => pointer, :oid => 'oid')
      position = {:position => 'poscd', :permissions => ['permission']}
      assert_equal(@position, @plugin.update_position(group, position, 'short', 'language'))
    end
    def test_position__delete_limitation
      pointer  = flexmock('pointer', :creator => 'creator' )
      flexmock(pointer, :+ => pointer)
      limitation_text = flexmock('limitation_text', :pointer => pointer)
      footnote   = flexmock('footnote', :pointer => pointer)
      list_title = flexmock('list_title', :pointer => pointer)
      taxnote    = flexmock('taxnote', :pointer => pointer)
      permissions = flexmock('permissions', :pointer => pointer)
      update     = flexmock('update', 
                            :limitation_text => limitation_text,
                            :footnote   => footnote,
                            :list_title => list_title,
                            :taxnote    => taxnote,
                            :permissions => permissions,
                            :pointer    => pointer
                           )
      flexmock(@app, 
               :update => update,
               :delete => 'delete'
              )
      group    = flexmock('group', :pointer => pointer, :oid => 'oid')
      position = {:position => 'poscd', :limitation => limitation_text}
      assert_equal(@position, @plugin.update_position(group, position, 'short', 'language'))
    end
    def test_position__delete_footnote
      pointer  = flexmock('pointer', :creator => 'creator' )
      flexmock(pointer, :+ => pointer)
      limitation_text = flexmock('limitation_text', :pointer => pointer)
      footnote   = flexmock('footnote', :pointer => pointer)
      list_title = flexmock('list_title', :pointer => pointer)
      taxnote    = flexmock('taxnote', :pointer => pointer)
      permissions = flexmock('permissions', :pointer => pointer)
      update     = flexmock('update', 
                            :limitation_text => limitation_text,
                            :footnote   => footnote,
                            :list_title => list_title,
                            :taxnote    => taxnote,
                            :pointer    => pointer,
                            :permissions => permissions
                           )
      flexmock(@app, 
               :update => update,
               :delete => 'delete'
              )
      group    = flexmock('group', :pointer => pointer, :oid => 'oid')
      position = {:position => 'poscd', :footnote => footnote}
      assert_equal(@position, @plugin.update_position(group, position, 'short', 'language'))
    end
    def test_position__delete_list_title
      pointer  = flexmock('pointer', :creator => 'creator' )
      flexmock(pointer, :+ => pointer)
      limitation_text = flexmock('limitation_text', :pointer => pointer)
      footnote   = flexmock('footnote', :pointer => pointer)
      list_title = flexmock('list_title', :pointer => pointer)
      taxnote    = flexmock('taxnote', :pointer => pointer)
      permissions = flexmock('permissions', :pointer => pointer)
      update     = flexmock('update', 
                            :limitation_text => limitation_text,
                            :footnote   => footnote,
                            :list_title => list_title,
                            :taxnote    => taxnote,
                            :pointer    => pointer,
                            :permissions => permissions
                           )
      flexmock(@app, 
               :update => update,
               :delete => 'delete'
              )
      group    = flexmock('group', :pointer => pointer, :oid => 'oid')
      position = {:position => 'poscd', :list_title => list_title}
      assert_equal(@position, @plugin.update_position(group, position, 'short', 'language'))
    end
    def test_position__delete_taxnote
      pointer  = flexmock('pointer', :creator => 'creator' )
      flexmock(pointer, :+ => pointer)
      limitation_text = flexmock('limitation_text', :pointer => pointer)
      footnote   = flexmock('footnote', :pointer => pointer)
      list_title = flexmock('list_title', :pointer => pointer)
      taxnote    = flexmock('taxnote', :pointer => pointer)
      permissions = flexmock('permissions', :pointer => pointer)
      update     = flexmock('update', 
                            :limitation_text => limitation_text,
                            :footnote   => footnote,
                            :list_title => list_title,
                            :taxnote    => taxnote,
                            :pointer    => pointer,
                            :permissions => permissions
                           )
      flexmock(@app, 
               :update => update,
               :delete => 'delete'
              )
      group    = flexmock('group', :pointer => pointer, :oid => 'oid')
      group = ODDB::Analysis::Group.new('0000')
      group.pointer = Persistence::Pointer.new(:group, '0000')
      position = group.create_position('00')
      position.create_taxnote # = 'taxnote'
      position.pointer = Persistence::Pointer.new(:position, '00')

      skip('Niklaus does not think that this test is correct, analysis does not have any delete method')
      assert_equal('delete', @plugin.update_position(group, position, 'short', 'language'))
    end
  end
end


