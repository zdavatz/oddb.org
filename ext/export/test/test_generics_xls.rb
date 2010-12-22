#!/usr/bin/env ruby
# Odba::Exporter::TestGenericsXls -- oddb -- 22.12.2010 -- mhatakeyama@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))
$: << File.expand_path('../../..', File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'spreadsheet'
require 'generics_xls'
require 'date'

module ODDB
  module OdbaExporter
    class TestGenericXls < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        loggroup_swiss = LogGroup.new(:swissmedic_journal)
        loggroup_swiss.create_log(Date.today)
        loggroup_swiss.latest.change_flags = {123 => [:new]}
        loggroup_bsv = LogGroup.new(:bsv_sl)
        loggroup_bsv.create_log(Date.today)
        loggroup_bsv.latest.change_flags = {123 => [:price_cut]}

        flexstub(ODBA.cache) do |cacheobj|
           cacheobj.should_receive(:fetch_named).and_return do
             flexmock do |appobj|
               appobj.should_receive(:log_group).with(:swissmedic_journal).and_return(loggroup_swiss)
               appobj.should_receive(:log_group).with(:bsv_sl).and_return(loggroup_bsv)
             end
           end
        end

        @generics_xls = GenericXls.new(".")
      end
      def test__remarks1
        pac = flexstub(Package) do |pacobj|
          pacobj.should_receive(:"registration.pointer").and_return(999)
          pacobj.should_receive(:pointer).and_return(999)
        end
        assert_nil(@generics_xls._remarks(pac, 'Generikum'))
      end
      def test__remarks2
        pac = flexstub(Package) do |pacobj|
          pacobj.should_receive(:"registration.pointer").and_return(123)
          pacobj.should_receive(:pointer).and_return(123)
        end
        expect = "Generikum: neue Registration, Preissenkung"
        assert_equal(expect, @generics_xls._remarks(pac, 'Generikum'))
      end
      def test_remarks
        pac = flexstub(Package) do |pacobj|
          pacobj.should_receive(:"registration.pointer").and_return(123)
          pacobj.should_receive(:pointer).and_return(123)
        end
        expect = "Original: neue Registration, Preissenkung Generikum: neue Registration, Preissenkung"
        assert_equal(expect, @generics_xls.remarks(pac, pac))
      end
      def test_format_price
        price = nil
        assert_nil(@generics_xls.format_price(price))
        price = 12.349
        assert_equal("12.35", @generics_xls.format_price(price))
      end
      def test_preprocess_fields
        fields = [1,2,3,Date.new(2010, 12, 31)]
        assert_equal(["1","2","3","31.12.2010"], @generics_xls.preprocess_fields(fields))
      end
      def test_format_original
        pac = flexstub(Package) do |pacobj|
          pacobj.should_receive(:basename).and_return("basename")
          pacobj.should_receive(:dose).and_return("dose")
          pacobj.should_receive(:comparable_size).and_return(111)
          pacobj.should_receive(:barcode).and_return(222)
          pacobj.should_receive(:pharmacode).and_return(333)
          pacobj.should_receive(:name).and_return("name")
          pacobj.should_receive(:price_exfactory).and_return(444.444)
          pacobj.should_receive(:price_public).and_return(555.555)
          pacobj.should_receive(:company_name).and_return("company_name")
          pacobj.should_receive(:ikscat).and_return(666)
          pacobj.should_receive(:sl_entry).and_return(777)
          pacobj.should_receive(:registration_date).and_return(Date.new(2010,12,31))
        end
        expect = ["basename", "basename dose/111", "222", "333", "name", "dose", "111", 
                  "444.44", "555.55", "company_name", "666", "SL", "31.12.2010"]
        assert_equal(expect,  @generics_xls.format_original(pac))
      end
      def test_format_generic
        pac = flexstub(Package) do |pacobj|
          pacobj.should_receive(:basename).and_return("basename")
          pacobj.should_receive(:dose).and_return("dose")
          pacobj.should_receive(:comparable_size).and_return(111)
          pacobj.should_receive(:barcode).and_return(222)
          pacobj.should_receive(:pharmacode).and_return(333)
          pacobj.should_receive(:name).and_return("name")
          pacobj.should_receive(:price_exfactory).and_return(444.444)
          pacobj.should_receive(:price_public).and_return(555.555)
          pacobj.should_receive(:company_name).and_return("company_name")
          pacobj.should_receive(:ikscat).and_return(666)
          pacobj.should_receive(:sl_entry).and_return(nil)
          pacobj.should_receive(:registration_date).and_return(Date.new(2010,12,31))
        end
        expect = ["222", "333", "name", "dose", "111", "444.44", "555.55", "company_name",
                  "666", "", "31.12.2010"]
        assert_equal(expect,  @generics_xls.format_generic(pac))
      end
      def test_format_row
        pac = flexstub(Package) do |pacobj|
          pacobj.should_receive(:basename).and_return("basename")
          pacobj.should_receive(:dose).and_return("dose")
          pacobj.should_receive(:comparable_size).and_return(111)
          pacobj.should_receive(:barcode).and_return(222)
          pacobj.should_receive(:pharmacode).and_return(333)
          pacobj.should_receive(:name).and_return("name")
          pacobj.should_receive(:price_exfactory).and_return(444.444)
          pacobj.should_receive(:price_public).and_return(555.555)
          pacobj.should_receive(:company_name).and_return("company_name")
          pacobj.should_receive(:ikscat).and_return(666)
          pacobj.should_receive(:sl_entry).and_return('SL')
          pacobj.should_receive(:registration_date).and_return(Date.new(2010,12,31))
          pacobj.should_receive(:"registration.pointer").and_return(123)
          pacobj.should_receive(:pointer).and_return(123)
        end
        expect = ["basename", "basename dose/111", "222", "333", "name", "dose", "111",
                  "444.44", "555.55", "company_name", "666", "SL", "31.12.2010", "222",
                  "333", "name", "dose", "111", "444.44", "555.55", "company_name",
                  "666", "SL", "31.12.2010", 
                  "Original: neue Registration, Preissenkung Generikum: neue Registration, Preissenkung"]
        assert_equal(expect,  @generics_xls.format_row(pac, pac))
      end
=begin
      def test_export_generic
      end
      def test_export_comparable
      end
      def test_export_comparables
      end
      def test_export_generics
      end
=end
   end
  end
end
