#!/usr/bin/env ruby
# encoding: utf-8
# TestAnalysisPlugin -- ydpm -- 22.03.2005 -- hwyss@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))
$: << File.expand_path('..', File.dirname(__FILE__))


require 'minitest/autorun'
require 'minitest/unit'
require 'flexmock/minitest'
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
  class Plugin
    @@today = Today
    ARCHIVE_PATH = File.expand_path('../../test_run', File.dirname(__FILE__))
  end
  def ODDB.init_analysis_test_variables(object= self)
    object.today = Today
    object.datadir = File.expand_path '../data', File.dirname(__FILE__)
    object.data_file = File.join(object.datadir, 'xlsx/analysenliste_2017_01_01.xlsx')
    object.index_html  = File.join(object.datadir, 'html/bag_analysen.html')
    object.download_file = File.join(ODDB::Plugin::ARCHIVE_PATH, 'xls/analysis_latest.xlsx')
  end
  class BagDelegator
    def method_missing key, *args, &block
      @mock.send key, *args, &block
    end
    def setobj mock
      @mock = mock
    end
  end
  class TestAnalysisPluginDownload <Minitest::Test
    attr_accessor :today, :datadir, :download_file, :data_file, :index_html
    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
    end
    def setup
      ODDB.init_analysis_test_variables(self)
      FileUtils.rm_rf(ODDB::Plugin::ARCHIVE_PATH, :verbose => true)
      FileUtils.makedirs(ODDB::Plugin::ARCHIVE_PATH)
      FileUtils.cp(@data_file,  ODDB::Plugin::ARCHIVE_PATH, {verbose: false, preserve: true})
      @app = ODDB::App.new
      @plugin = AnalysisPlugin.new(@app)
      @agent = flexmock('mechanize_mock', Mechanize.new)
      @agent.should_receive(:get).with(AnalysisPlugin::INDEX_URL).and_return do
        Mechanize.new.get('file://'+ @index_html)
      end
      @agent.should_receive(:get).and_return do |args|
        if /excelformat/i.match(args)
          Mechanize.new.get('file://'+@data_file)
        else
          nil
        end
      end
    end
    def test_update
      result = @plugin.update(@agent)
      assert(File.exists?(@download_file))
      assert_match(/update_group_position de/, @plugin.log_info.to_s)
      assert_match(/update_group_position fr/, @plugin.log_info.to_s)
      assert_match(/update_group_position it/, @plugin.log_info.to_s)
      assert_equal(24, @app.analysis_groups.size)
      assert_equal( "17-cétostéroïdes, fractionnés", @app.analysis_group('1003').position('00').description('fr'))
      assert_equal( "17-chetosteroidi, frazionati", @app.analysis_group('1003').position('00').description('it'))
      assert_equal( "17-Ketosteroide, fraktioniert", @app.analysis_group('1003').position('00').description('de'))
    end
  end

end
