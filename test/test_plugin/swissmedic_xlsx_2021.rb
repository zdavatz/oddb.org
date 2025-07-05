#!/usr/bin/env ruby
# encoding: utf-8

# We ignore registration 00277, 47066, 57678 which
# we used for testing the atc_less

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'minitest/unit'
require 'flexmock/minitest'
require 'test_helpers' # for VCR setup
require 'stub/odba'
require 'util/persistence'
require 'plugin/swissmedic'
require 'model/registration'
require 'model/sequence'
require 'model/package'
require 'model/galenicgroup'
require 'model/composition'
require 'ostruct'
require 'tempfile'
require 'util/log'
require 'util/util'
require 'util/oddbconfig'
require 'stub/oddbapp'

begin  require 'debug'; rescue LoadError; end # ignore error when debug cannot be loaded (for Jenkins-CI)

class FlexMock::TestUnitFrameworkAdapter
    attr_accessor :assertions
end

module ODDB

  class SwissmedicPluginTestXLSX2021 < Minitest::Test

    def setup
      ODDB::GalenicGroup.reset_oids
      ODBA.storage.reset_id
      ODDB::TestHelpers.vcr_setup
      mock_downloads
      @app = flexmock(ODDB::App.new)
      @archive = ODDB::WORK_DIR
      FileUtils.rm_rf(@archive)
      FileUtils.mkdir_p(@archive)
      @latest = File.join ODDB::TEST_DATA_DIR, 'xls', 'Packungen-latest.xlsx'
      @older  = File.join(ODDB::TEST_DATA_DIR, 'xls/Packungen-2019.01.31.xlsx')
      @plugin = flexmock('plugin', SwissmedicPlugin.new(@app, @archive))
      @bag_listen  = File.join(ODDB::TEST_DATA_DIR, 'html/listen_neu.html')
      @current  = File.join(ODDB::TEST_DATA_DIR, 'xlsx/Packungen-2021.04.01.xlsx')
      @target   = File.join @archive, 'xls',  @@today.strftime('Packungen-%Y.%m.%d.xlsx')
      @plugin.should_receive(:fetch_with_http).with('https://www.swissmedic.ch/swissmedic/de/home/services/listen_neu.html').and_return(File.open(@bag_listen).read).by_default
      @plugin.should_receive(:open).with( ODDB::SwissmedicPlugin.get_packages_url).and_return(File.open(@current).read).by_default
      @prep_from = File.join(ODDB::TEST_DATA_DIR, 'xlsx/Erweiterte_Arzneimittelliste_HAM_31012019.xlsx')
      FileUtils.cp(@prep_from, File.join(@archive, 'xls',  @@today.strftime('Erweiterte_Arzneimittelliste_HAM_31012019.xlsx')),
                   :verbose => true, :preserve => true)
      @plugin.should_receive(:fetch_with_http).with( ODDB::SwissmedicPlugin.get_preparations_url).and_return(File.open(@prep_from).read).by_default
      FileUtils.makedirs(File.dirname(@latest)) unless File.exist?(File.dirname(@latest))
      FileUtils.cp(@latest, File.join(ODDB::WORK_DIR, 'xls'), :verbose => true)
      FileUtils.cp(@older, File.join(ODDB::WORK_DIR, 'xls'), :verbose => true)

      puts File.join(ODDB::WORK_DIR, 'xlsx')
      puts @latest
      assert(true, File.exist?('/opt/src/oddb.org-3.4/data4tests/xls/Packungen-latest.xlsx'))
      require 'debug'; binding.break

    end
    def teardown
      ODBA.storage = nil
      super # to clean up FlexMock
    end
    def test_april_2021
      # Use first the last month and compare it to a non existing lates
      FileUtils.rm(Dir.glob("#{File.dirname(@latest)}/*"), :verbose => true)
      FileUtils.cp(@older, @latest, :verbose => true, :preserve => true)
      FileUtils.cp(@current, @target, :verbose => true, :preserve => true)
      assert_equal(0, @app.registrations.size)
      reg = @app.create_registration('00278')
      reg.pointer = Persistence::Pointer.new([:registration, '00278'])
      seq = reg.create_sequence('01')
      seq.composition_text = 'composition_text'
      seq.pointer = Persistence::Pointer.new([:registration, '00278', :sequence, '01'])
      seq.name_base = 'Colon Sérocytol, suppositoire'
      seq.name_descr = 'name_descr'
      seq.dose = nil
      seq.pointer = Persistence::Pointer.new([:registration, '00278', :sequence, '01'])
      seq.sequence_date = Date.new(2017,5,9)
      seq.export_flag = false
      seq.atc_class = ODDB::AtcClass.new('AB0')
      seq.indication = 'indication'
      seq.create_package('001')
      seq.create_package('002')
      reg = @app.create_registration('57678')
      seq = reg.create_sequence('01')
      seq.create_package('001')
      seq2 = reg.create_sequence('03')
      seq2.create_package('002')

      reg = @app.create_registration('00277')
      seq = reg.create_sequence('01')
      seq.create_package('001')
      seq.create_package('002')

      reg = @app.create_registration('00279')
      seq = reg.create_sequence('01')
      seq.create_package('001')
      seq.create_package('002')

      seq.create_package('022')
      reg = @app.create_registration('48624')
      seq = reg.create_sequence('02')
      seq.create_package('022')

      reg = @app.create_registration('62069')
      seq = reg.create_sequence('02')
      seq.create_package('009')
      @plugin.should_receive(:fetch_with_http).with(  ODDB::SwissmedicPlugin.get_packages_url).
        and_return(File.open(@current).read)
      @plugin.should_receive(:fetch_with_http).with(ODDB::SwissmedicPlugin.get_preparations_url).
        and_return(File.open(@prep_from).read)
      result = @plugin.update()
      puts @plugin.report
      assert_nil(@app.registration('66097').expiration_date) # unbegrenzt
    end
  end
end
