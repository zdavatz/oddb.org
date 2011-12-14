#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestAnalysisPlugin -- oddb.org -- 07.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'plugin/analysis'

module ODDB
  class TestAnalysisPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @app    = flexmock('app', :create => 'create')
      @plugin = ODDB::AnalysisPlugin.new(@app)
    end
    def test_update_group
      position = {:delete => 'groupcd'}
      assert_equal('create', @plugin.update_group(position))
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
      assert_equal('delete', @plugin.update_position(group, position, 'language'))
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
      group    = flexmock('group', :pointer => pointer)
      position = {:position => 'poscd', :permissions => ['permission']}
      assert_equal(update, @plugin.update_position(group, position, 'language'))
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
      group    = flexmock('group', :pointer => pointer)
      position = {:position => 'poscd', :limitation => limitation_text}
      assert_equal('delete', @plugin.update_position(group, position, 'language'))
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
      group    = flexmock('group', :pointer => pointer)
      position = {:position => 'poscd', :footnote => footnote}
      assert_equal('delete', @plugin.update_position(group, position, 'language'))
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
      group    = flexmock('group', :pointer => pointer)
      position = {:position => 'poscd', :list_title => list_title}
      assert_equal('delete', @plugin.update_position(group, position, 'language'))
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
      group    = flexmock('group', :pointer => pointer)
      position = {:position => 'poscd', :taxnote => taxnote}
      assert_equal('delete', @plugin.update_position(group, position, 'language'))
    end
    def stderr_null
      require 'tempfile'
      $stderr = Tempfile.open('stderr')
      yield
      $stderr.close
      $stderr = STDERR
    end
    def replace_constant(constant, temp)
      stderr_null do
        keep = eval constant
        eval "#{constant} = temp"
        yield
        eval "#{constant} = keep"
      end
    end
    def test_update_dacapo
      pointer  = flexmock('pointer', :creator => 'creator')
      flexmock(pointer, :+ => pointer)
      position = flexmock('position', :pointer => pointer)
      group    = flexmock('group', :position => position)
      flexmock(@app, 
               :analysis_group => group,
               :update => 'update'
              )
      server = flexmock('ANALYSIS_PARSER') do |serv|
        info = ['info']
        serv.should_receive(:dacapo).and_yield('code', info)
      end
      replace_constant('ODDB::AnalysisPlugin::ANALYSIS_PARSER', server) do
        assert_equal('update', @plugin.update_dacapo)
      end
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
      group    = flexmock('group', :pointer => pointer)
      flexmock(@app, 
               :create  => group,
               :update  => update,
               :delete  => 'delete',
               :recount => 'recount'
              )
      position = {:position => 'poscd', :delete => 'groupcd'}
      server = flexmock('ANALYSIS_PARSER') do |serv|
        serv.should_receive(:parse_pdf).and_return([position])
      end
      replace_constant('ODDB::AnalysisPlugin::ANALYSIS_PARSER', server) do
        assert_equal('recount', @plugin.update('path', 'language'))
      end
    end
    def test_position__analysis_revision
      pointer  = flexmock('pointer', :creator => 'creator' )
      flexmock(pointer, :+ => pointer)
      group    = flexmock('group', :pointer => pointer)
      flexmock(@app, 
               :create  => group,
               :recount => 'recount'
              )
      position = {:delete => 'groupcd', :analysis_revision => 'S'}
      server = flexmock('ANALYSIS_PARSER') do |serv|
        serv.should_receive(:parse_pdf).and_return([position])
      end
      replace_constant('ODDB::AnalysisPlugin::ANALYSIS_PARSER', server) do
        assert_equal('recount', @plugin.update('path', 'language'))
      end
    end
  end
end


