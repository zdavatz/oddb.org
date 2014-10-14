#!/usr/bin/env ruby
# encoding: utf-8
# TestAnalysisPlugin -- ydpm -- 22.03.2005 -- hwyss@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))
$: << File.expand_path('..', File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'minitest/unit'
require 'flexmock'
require 'stub/odba'
require 'stub/oddbapp'
require 'mechanize'
require 'plugin/analysis'

module ODBA
  def ODBA.transaction(&block)
    block.call
  end
end
module ODDB
  Today = Date.new(2014,5,1)
  class BagDelegator
    def method_missing key, *args, &block
      @mock.send key, *args, &block
    end
    def setobj mock
      @mock = mock
    end
  end
  class AnalysisPlugin
    @@today = Today
  end
  class TestAnalysisPluginDownload <Minitest::Test
    @@today = Today
    include FlexMock::TestCase
    def setup
      @pointer = FlexMock.new 'pointer'
      @pointer.should_receive(:+).and_return @pointer
      @pointer.should_receive(:creator).and_return 'creator'

      @position = FlexMock.new 'position'
      @position.should_receive(:pointer).and_return @pointer

      @analysis_group = FlexMock.new 'analysis_group'
      @analysis_group.should_receive(:oid).and_return 'oid'
      @analysis_group.should_receive(:position).and_return @position
      @analysis_group.should_receive(:update_position).and_return 'update_position'
      
      @app = FlexMock.new 'app'
      @app.should_receive(:delete_all_analysis_group).and_return true
      @app.should_receive(:analysis_group).and_return(@analysis_group)
      @app.should_receive(:analysis_groups).and_return([@analysis_group])
      @app.should_receive(:create)
      @app.should_receive(:update)
      @app.should_receive(:recount).and_return('recount')
      @plugin = AnalysisPlugin.new(@app)
      @download_file = File.expand_path(File.join(__FILE__, "../../../data/xls/analysis_fr_#{Today.strftime('%Y.%m.%d')}.xlsx")) 
      @latest_file = File.expand_path(File.join(__FILE__, "../../../data/xls/analysis_fr_latest.xlsx")) 
      FileUtils.rm(@download_file, :verbose => false) if File.exists?(@download_file)
      FileUtils.rm(@latest_file, :verbose => false)   if File.exists?(@latest_file)
    end
    def test_update
      assert_equal('recount', @plugin.update)
      assert(File.exists?(@download_file))
    end
  end

  class TestAnalysisPluginWithoutDownload <Minitest::Test
    @@today = Today
    Download_file = File.expand_path(File.join(__FILE__, '../../data/xlsx/analysis_de_2014.10.14_small.xlsx')) 
    include FlexMock::TestCase
    def setup
      ODDB::GalenicGroup.reset_oids
      ODBA.storage.reset_id
      @app = ODDB::App.new
      @plugin = AnalysisPlugin.new(@app)
      def @plugin.get_latest_file(lang = 'de')
        return true, Download_file
      end
      @latest_file = File.expand_path(File.join(__FILE__, "../../../data/xls/analysis_fr_latest.xlsx")) 
      FileUtils.rm(@latest_file, :verbose => false)   if File.exists?(@latest_file)
    end
    def test_update
      @plugin.update
      assert(File.exists?(Download_file))
      assert_equal(4, @app.analysis_groups.size)
      assert_equal('1000', @app.analysis_groups.first[1].groupcd)
      assert_equal('1,25-Dihydroxycholecalciferol', @app.analysis_groups.first[1].positions.first[1].description)
      assert_equal('C', @app.analysis_groups.first[1].positions.first[1].lab_areas)
      assert_equal(85, @app.analysis_groups.first[1].positions.first[1].taxpoints)
      assert_equal('Alkalische Phosphatase-Isoenzyme mittels elektrophoretischer Differenzierung', @app.analysis_groups['1030'].positions.first[1].description)
      assert_equal('Alpha-1-Antitrypsin',  @app.analysis_groups['1032'].positions.first[1].description)
      assert_equal('in Stoffwechsellaboratorien der Universitätskliniken',
                   @app.analysis_groups['1007'].positions.first[1].limitation_text.to_s)
      
    end
  end
end
