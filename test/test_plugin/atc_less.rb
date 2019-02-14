#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Atc_lessPluginTest -- oddb.org -- 12.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'plugin/atc_less'

module ODDB
  class TestAtc_lessPlugin <Minitest::Test
    def setup
      @latest_xlsx = File.join(ODDB::Plugin::ARCHIVE_PATH, 'xls', 'Packungen-latest.xlsx')
      @latest_xml  = File.join(ODDB::Plugin::ARCHIVE_PATH, 'xml', 'XMLRefdataPharma-latest.xml')
      [@latest_xlsx, @latest_xml].each {
        |file|
          FileUtils.rm(file, :verbose => false) if File.exists?(file)
      }
      @app    = flexmock('setup_app', :sequences => [],:registrations => {},:atcless_sequences => [], :registration => nil )
      @@today = Date.new(2015,1,15)
      @plugin = ODDB::Atc_lessPlugin.new(@app)
    end

    def test_report
      expected = "ODDB::Atc_lessPlugin - Report 15.01.2015
Total time to update: 0.00 [m]
Total number of sequences with ATC-codes from swissmedic: 0
Total number of sequences with ATC-codes from refdata: 0
Total Sequences without ATC-Class: 0
Swissmedic: All sequences present
No empty ATC-codes found
All found ATC-codes were correct
All ATC codes present in database
Checked against 0 ATC-codes from RefData
All ATC codes from swissmedic are as long as those from refdata
No obsolete sequence '00' found
Swissmedic: All registrations present"
      assert_equal(expected, @plugin.report)
    end

    def test_missing_packungen_latest
      expected = "Could not find Packungen-latest.xlsx"
      assert_equal(expected, @plugin.update_atc_codes)
    end

    def test_update_atc_codes

      atc_J06A  = flexmock(atc_J06A, :code => 'J06A')
      atc_J06AA = flexmock(atc_J06AA, :code => 'J06AA')
      atc_V07 = flexmock(atc_V07, :code => 'V07')
      atc_V07AB = flexmock(atc_V07, :code => 'V07AB')
      atc_D0XXXXX = flexmock(atc_D0XXXXX, :code => 'D0XXXXX')
      atc_G03FA   = flexmock(atc_G03FA,   :code => 'G03FA')
      atc_G03FA01 = flexmock(atc_G03FA01, :code => 'G03FA01')
      atc_C08CA01 = flexmock(atc_C08CA01, :code => 'C08CA01')

      seq_00274_00 = flexmock('seq_00274_00', :atc_class => nil,       :iksnr => '00274', :seqnr => '00')
      seq_00274_1 = flexmock('seq_00274_1', :atc_class => atc_J06AA)
      reg_00274 = flexmock('reg_00274')
      reg_00274.should_receive(:sequence).with('01').and_return(seq_00274_1)

      seq_00277_1 = flexmock('seq_00277_1', :atc_class => atc_D0XXXXX)
      seq_00277_1.should_receive(:atc_class=)
      seq_00277_1.should_receive(:odba_isolated_store)
      reg_00277 = flexmock('reg_00277')
      reg_00277.should_receive(:sequence).with('01').and_return(seq_00277_1)

      seq_00278_1 = flexmock('seq_00278_1', :atc_class => atc_J06AA, :atc_class= => nil, :odba_isolated_store => nil)
      reg_00278 = flexmock('reg_00278')
      reg_00278.should_receive(:sequence).with('01').and_return(seq_00278_1)

      reg_00279 = flexmock('reg_00279')
      reg_00279.should_receive(:sequence).with('01').and_return(nil)
      seq_00279_01 = flexmock('seq_00279_01', :atc_class => atc_J06AA, :iksnr => '00279', :seqnr => '01')
      seq_00279_00 = flexmock('seq_00279_00', :atc_class => nil,       :iksnr => '00279', :seqnr => '00')
      reg_00279.should_receive(:sequence).with('01').and_return(seq_00279_01)
      reg_00279.should_receive(:sequence).with('00').and_return(seq_00279_00)
      reg_00279.should_receive(:iksnr).and_return('00279')
      reg_00279.should_receive(:sequences).and_return([seq_00279_00, seq_00279_01])
      reg_00279.should_receive(:delete_sequence).with('00')

      seq_56504_1 = flexmock('seq_56504_1', :atc_class => atc_V07, :odba_isolated_store => nil)
      reg_56504 = flexmock('reg_56504')
      reg_56504.should_receive(:sequence).with('01').and_return(seq_56504_1)

      seq_57678_3 = flexmock('seq_57678_3', :atc_class => atc_C08CA01, :odba_isolated_store => nil)
      seq_57678_1 = flexmock('seq_57678_1', :atc_class => atc_G03FA,   :odba_isolated_store => nil)
      seq_57678_3.should_receive(:atc_class=)
      seq_57678_1.should_receive(:atc_class=)
      reg_57678 = flexmock('reg_57678')
      reg_57678.should_receive(:sequence).with('01').and_return(seq_57678_1)
      reg_57678.should_receive(:sequence).with('03').and_return(seq_57678_3)


      @app = flexmock('app_xx', :sequences => [])
      @app.should_receive(:registration).with('00274').and_return(nil)
      @app.should_receive(:registration).with('47066').and_return(nil)
      @app.should_receive(:registration).with('48624').and_return(nil)
      @app.should_receive(:registration).with('62069').and_return(nil)
      @app.should_receive(:registration).with('16105').and_return(nil)
      @app.should_receive(:registration).with('57678').and_return(nil)
      @app.should_receive(:registration).with('00488').and_return(nil)
      @app.should_receive(:registration).with('15219').and_return(nil)
      @app.should_receive(:registration).with('16598').and_return(nil)
      @app.should_receive(:registration).with('28486').and_return(nil)
      @app.should_receive(:registration).with('30015').and_return(nil)
      @app.should_receive(:registration).with('31644').and_return(nil)
      @app.should_receive(:registration).with('32475').and_return(nil)
      @app.should_receive(:registration).with('35366').and_return(nil)
      @app.should_receive(:registration).with('39252').and_return(nil)
      @app.should_receive(:registration).with('39252').and_return(nil)
      @app.should_receive(:registration).with('43454').and_return(nil)
      @app.should_receive(:registration).with('43454').and_return(nil)
      @app.should_receive(:registration).with('44447').and_return(nil)
      @app.should_receive(:registration).with('44625').and_return(nil)
      @app.should_receive(:registration).with('45882').and_return(nil)
      @app.should_receive(:registration).with('53290').and_return(nil)
      @app.should_receive(:registration).with('53662').and_return(nil)
      @app.should_receive(:registration).with('54015').and_return(nil)
      @app.should_receive(:registration).with('54534').and_return(nil)
      @app.should_receive(:registration).with('55558').and_return(nil)
      @app.should_receive(:registration).with('55561').and_return(nil)
      @app.should_receive(:registration).with('55594').and_return(nil)
      @app.should_receive(:registration).with('55674').and_return(nil)
      @app.should_receive(:registration).with('55674').and_return(nil)
      @app.should_receive(:registration).with('56352').and_return(nil)
      @app.should_receive(:registration).with('58158').and_return(nil)
      @app.should_receive(:registration).with('58734').and_return(nil)
      @app.should_receive(:registration).with('58943').and_return(nil)
      @app.should_receive(:registration).with('59267').and_return(nil)
      @app.should_receive(:registration).with('61186').and_return(nil)
      @app.should_receive(:registration).with('61186').and_return(nil)
      @app.should_receive(:registration).with('62069').and_return(nil)
      @app.should_receive(:registration).with('62132').and_return(nil)
      @app.should_receive(:registration).with('65160').and_return(nil)
      @app.should_receive(:registration).with('65856').and_return(nil)
      @app.should_receive(:registration).with('65857').and_return(nil)
      @app.should_receive(:registration).with('65857').and_return(nil)
      @app.should_receive(:registration).with('66297').and_return(nil)

      @app.should_receive(:registration).with('00277').and_return(reg_00277)
      @app.should_receive(:registration).with('00278').and_return(reg_00278)
      @app.should_receive(:registration).with('00279').and_return(reg_00279)
      @app.should_receive(:registration).with('56504').and_return(reg_56504)
      @app.should_receive(:registration).with('57678').and_return(reg_57678)

      @app.should_receive(:atc_class).with('G03FA01').and_return(atc_G03FA01)
      @app.should_receive(:atc_class).with('C08CA01').and_return(atc_C08CA01)
      @app.should_receive(:atc_class).with('G03FA').and_return(atc_G03FA)
      @app.should_receive(:atc_class).with('J06A').and_return(atc_J06A)
      @app.should_receive(:atc_class).with('J06AA').and_return(atc_J06AA)
      @app.should_receive(:atc_class).with('V07AB').and_return(atc_V07AB)
      @app.should_receive(:atc_class).with('V07').and_return(nil)
      @app.should_receive(:rebuild_indices).with('atcless')
      @app.should_receive(:registrations).and_return(
        {'00279' =>  reg_00279, }
      )
      @app.should_receive(:atcless_sequences).and_return [seq_00274_00]
      @plugin = ODDB::Atc_lessPlugin.new(@app)
      FileUtils.makedirs(File.dirname(@latest_xlsx))
      FileUtils.makedirs(File.dirname(@latest_xml))
      tst_xlsx = File.expand_path(File.join(File.dirname(__FILE__), '../data/xlsx/Packungen-2019.01.31.xlsx'))
      tst_xml  = File.expand_path(File.join(File.dirname(__FILE__), '../data/xml/XMLRefdataPharma-2015.07.01.xml'))
      FileUtils.cp(tst_xlsx, @latest_xlsx, :verbose => true)
      FileUtils.cp(tst_xml,  @latest_xml, :verbose => true)

      result = @plugin.update_atc_codes
      assert_equal(true, result)
      expected = "ODDB::Atc_lessPlugin - Report 15.01.2015
Total time to update: 0.00 [m]
Total number of sequences with ATC-codes from swissmedic: 0
Total number of sequences with ATC-codes from refdata: 0
Total Sequences without ATC-Class: 1
00274 00
Swissmedic: All sequences present
No empty ATC-codes found
Corrected 1 ATC-code in sequences
  00277/01 D0XXXXX -> J06AA
All ATC codes present in database
Checked against 0 ATC-codes from RefData
All ATC codes from swissmedic are as long as those from refdata
Deleted 1 sequences '00' in registrations
  00279
Skipped 36 registrations
  15219 16105 16598 28486 30015 31644 32475 35366 43454 44625 45882 53290 53662 54015 54534 55558 66297 55594 55674 56352 59267 61186 62069 62132 65856 65857 55674 43454 61186 58734 55561 65160 58158 44447 15219 39252"

      assert_equal(expected, @plugin.report)
    end
    # test/data/xlsx/Packungen_2014_small.xlsx
  end
end
