#!/usr/bin/env ruby
# encoding: utf-8
# TestOddbDatExport -- oddb -- 07.02.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/oddbdat_export'
require 'test/unit'
require 'flexmock'
require 'date'


module ODDB
  module OdbaExporter
    class StubDRbObject
      def export_oddbdat(*args)
        ['export_oddbdat']
      end
      def compress_many(*args)
      end
    end
    class OddbDatExport
      remove_const :EXPORT_SERVER
      EXPORT_SERVER = StubDRbObject.new
      @@today = Date.new(2011,2,3)
    end
    class TestOddbDatExport < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @app = flexmock('app') do |ap|
         ap.should_receive(:atc_classes).and_return(flexmock('atc_classes') do |atc|
            atc.should_receive(:values).and_return([])
          end)
          ap.should_receive(:each_galenic_form).and_yield(flexmock('galform') do |gal|
            gal.should_receive(:odba_id).and_return('gal.odba_id')
          end)
          ap.should_receive(:substances).and_return([])
          ap.should_receive(:companies).and_return([])
        end
        @oddbdatexport = OddbDatExport.new(@app)

     end
      def test_export
        flexstub(@app) do |ap|
          ap.should_receive(:each_package).and_yield(flexmock('pac') do |pac|
            pac.should_receive(:odba_id).and_return('pac.odba_id')
            pac.should_receive(:parts).and_return('not empty')
          end)
        end

        # white box test: check 'files' value
        flexstub(OddbDatExport::EXPORT_SERVER) do |drb|
          expected = ["export_oddbdat"] * 5
          drb.should_receive(:compress_many).with(String, String, expected)
        end

        # black box test
        assert_equal([], @oddbdatexport.export)
      end
      def test_export__dose_missing
        flexstub(@app) do |ap|
          ap.should_receive(:each_package).and_yield(flexmock('pac') do |pac|
            pac.should_receive(:odba_id).and_return('pac.odba_id')
            pac.should_receive(:parts).and_return('')
            pac.should_receive(:basename).and_return('pac.basename')
            pac.should_receive(:iksnr).and_return('pac.iksnr')
            pac.should_receive(:"sequence.seqnr").and_return('pac.sequence.seqnr')
            pac.should_receive(:ikscd).and_return('pac.iksce')
          end)
        end
 
        expected = [["pac.basename", "pac.iksnr", "pac.sequence.seqnr", "pac.iksce"]]
        assert_equal(expected, @oddbdatexport.export)
      end
      def test_export_fachinfos
        flexstub(@app) do |ap|
          ap.should_receive(:fachinfos).and_return([])
        end

        # white box test: check 'files' value
        flexstub(OddbDatExport::EXPORT_SERVER) do |drb|
          expected = "export_oddbdat"
          drb.should_receive(:compress).with(String, expected)
        end
 
        # black box test
        assert_equal(nil, @oddbdatexport.export_fachinfos)
      end
    end
  end
end

