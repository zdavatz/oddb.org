#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Atc_lessPluginTest -- oddb.org -- 12.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'plugin/atc_less'

module ODDB
  class TestAtc_lessPlugin <Minitest::Test
    include FlexMock::TestCase
    def setup
      @latest_xlsx = File.join(ODDB::Plugin::ARCHIVE_PATH, 'xls', 'Packungen-latest.xlsx')
      @latest_xml  = File.join(ODDB::Plugin::ARCHIVE_PATH, 'xml', 'XMLSwissindexPharma-DE-latest.xml')
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
Total number of sequences with ATC-codes from swissindex: 0
Total Sequences without ATC-Class: 0
Swissmedic: All registrations present
Swissmedic: All sequences present
No empty ATC-codes found
All found ATC-codes were correct
All ATC codes present in database
All ATC codes from swissmedic are as long as those from swissindex
No obsolete sequence '00' found"
      assert_equal(expected, @plugin.report)
    end

    def test_missing_packungen_latest
      expected = "Could not find Packungen-latest.xlsx"
      assert_equal(expected, @plugin.update_atc_codes)
    end

    def test_update_atc_codes

      atc_J06AA = flexmock(atc_J06AA, :code => 'J06AA')
      atc_V07 = flexmock(atc_V07, :code => 'V07')
      atc_V07AB = flexmock(atc_V07, :code => 'V07AB')
      atc_D0XXXXX = flexmock(atc_D0XXXXX, :code => 'D0XXXXX')
      atc_G03FA   = flexmock(atc_G03FA,   :code => 'G03FA')
      atc_G03FA01 = flexmock(atc_G03FA01, :code => 'G03FA01')

      seq_00274_00 = flexmock('seq_00274_00', :atc_class => nil,       :iksnr => '00274', :seqnr => '00')
      seq_00274_1 = flexmock('seq_00274_1', :atc_class => atc_J06AA)
      reg_00274 = flexmock('reg_00274')
      reg_00274.should_receive(:sequence).with('01').and_return(seq_00274_1)

      seq_00277_1 = flexmock('seq_00277_1', :atc_class => atc_D0XXXXX)
      seq_00277_1.should_receive(:atc_class=).once
      seq_00277_1.should_receive(:odba_isolated_store).once
      reg_00277 = flexmock('reg_00277')
      reg_00277.should_receive(:sequence).with('01').and_return(seq_00277_1)

      seq_00278_1 = flexmock('seq_00278_1', :atc_class => atc_J06AA)
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
      reg_00279.should_receive(:delete_sequence).with('00').once

      seq_56504_1 = flexmock('seq_56504_1', :atc_class => atc_V07, :odba_isolated_store => nil)
      reg_56504 = flexmock('reg_56504')
      reg_56504.should_receive(:sequence).with('01').and_return(seq_56504_1)

      seq_54708_2 = flexmock('seq_54708_2', :atc_class => atc_G03FA01, :odba_isolated_store => nil)
      seq_54708_1 = flexmock('seq_54708_1', :atc_class => atc_G03FA,   :odba_isolated_store => nil)
      seq_54708_2.should_receive(:atc_class=).never
      seq_54708_1.should_receive(:atc_class=).once
      reg_54708 = flexmock('reg_54708')
      reg_54708.should_receive(:sequence).with('01').and_return(seq_54708_1)
      reg_54708.should_receive(:sequence).with('02').and_return(seq_54708_2)


      @app = flexmock('app_xx', :sequences => [])
      @app.should_receive(:registration).with('00274').and_return(nil)
      @app.should_receive(:registration).with('00277').and_return(reg_00277)
      @app.should_receive(:registration).with('00278').and_return(reg_00278)
      @app.should_receive(:registration).with('00279').and_return(reg_00279)
      @app.should_receive(:registration).with('56504').and_return(reg_56504)
      @app.should_receive(:registration).with('54708').and_return(reg_54708)

      @app.should_receive(:atc_class).with('G03FA01').and_return(atc_G03FA01)
      @app.should_receive(:atc_class).with('G03FA').and_return(atc_G03FA)
      @app.should_receive(:atc_class).with('J06AA').and_return(atc_J06AA)
      @app.should_receive(:atc_class).with('V07AB').and_return(atc_V07AB)
      @app.should_receive(:atc_class).with('V07').and_return(nil)
      @app.should_receive(:rebuild_indices).once.with('atcless')
      @app.should_receive(:registrations).and_return(
        {'00279' =>  reg_00279, }
      )
      @app.should_receive(:atcless_sequences).and_return [seq_00274_00]
      @plugin = ODDB::Atc_lessPlugin.new(@app)

      tst_xlsx = File.expand_path(File.join(File.dirname(__FILE__), '../data/xlsx/Packungen_2014_small.xlsx'))
      FileUtils.cp(tst_xlsx, @latest_xlsx, :verbose => false)
      tst_xml  = File.expand_path(File.join(File.dirname(__FILE__), '../data/xml/XMLSwissindexPharma-DE.xml'))
      FileUtils.cp(tst_xml,  @latest_xml, :verbose => false)
      assert_equal(true, @plugin.update_atc_codes)
      expected = "ODDB::Atc_lessPlugin - Report 15.01.2015
Total time to update: 0.00 [m]
Total number of sequences with ATC-codes from swissmedic: 1
Total number of sequences with ATC-codes from swissindex: 1
Total Sequences without ATC-Class: 1
00274 00
Skipped 1 registrations
  00274
Skipped 1 sequences
  00279/01
No empty ATC-codes found
Corrected 1 ATC-code in sequences
  00277/01 D0XXXXX -> J06AA
1 ATC codes absent in database
  56504/01 ATC V07
1 ATC code taken from swissindex where they are longer
  54708/01 G03FA -> G03FA01
Deleted 1 sequences '00' in registrations
  00279"

      assert_equal(expected, @plugin.report)
    end
    # test/data/xlsx/Packungen_2014_small.xlsx
  end
end
