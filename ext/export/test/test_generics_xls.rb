#!/usr/bin/env ruby
# Odba::Exporter::TestGenericsXls -- oddb -- 22.12.2010 -- mhatakeyama@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))
$: << File.expand_path('../../../src', File.dirname(__FILE__))
$: << File.expand_path('../../..', File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'spreadsheet'
require 'generics_xls'
require 'date'

module ODDB
  module OdbaExporter
    class TestGenericXls <Minitest::Test
      include FlexMock::TestCase
      def setup
        @loggroup_swiss = LogGroup.new(:swissmedic_journal)
        @loggroup_swiss.create_log(Date.today)
        @loggroup_swiss.latest.change_flags = {123 => [:new]}
        @loggroup_bsv = LogGroup.new(:bsv_sl)
        @loggroup_bsv.create_log(Date.today)
        @loggroup_bsv.latest.change_flags = {123 => [:price_cut]}

        flexstub(ODBA.cache) do |cacheobj|
           cacheobj.should_receive(:fetch_named).and_return do
             flexmock do |appobj|
               appobj.should_receive(:log_group).with(:swissmedic_journal).and_return(@loggroup_swiss)
               appobj.should_receive(:log_group).with(:bsv_sl).and_return(@loggroup_bsv)
             end
           end
        end

        @pac = flexmock('Package') do |pack|
          pack.should_receive(:basename).and_return("basename")
          pack.should_receive(:dose).and_return("dose")
          pack.should_receive(:comparable_size).and_return(111)
          pack.should_receive(:barcode).and_return("222")
          pack.should_receive(:pharmacode).and_return(333)
          pack.should_receive(:name).and_return("name")
          pack.should_receive(:price_exfactory).and_return(444.444)
          pack.should_receive(:price_public).and_return(555.555)
          pack.should_receive(:company_name).and_return("company_name")
          pack.should_receive(:ikscat).and_return(666)
          pack.should_receive(:sl_entry).and_return(777)
          pack.should_receive(:registration_date).and_return(Date.new(2010,12,31))
          pack.should_receive(:"registration.pointer").and_return(123)
          pack.should_receive(:pointer).and_return(123)
          pack.should_receive(:comparables).and_return([@pac])
          pack.should_receive(:"registration.generic?").and_return(true)
          pack.should_receive(:public?).and_return(true)
        end

        @generics_xls = GenericXls.new(".")
      end
      def test__remarks1
        pac = flexstub(Package) do |pack|
          pack.should_receive(:"registration.pointer").and_return(999)
          pack.should_receive(:pointer).and_return(999)
        end
        assert_nil(@generics_xls._remarks(pac, 'Generikum'))
      end
      def test__remarks2
        expect = "Generikum: neue Registration, Preissenkung"
        assert_equal(expect, @generics_xls._remarks(@pac, 'Generikum'))
      end
      def test_remarks
        expect = "Original: neue Registration, Preissenkung Generikum: neue Registration, Preissenkung"
        assert_equal(expect, @generics_xls.remarks(@pac, @pac))
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
        expect = ["basename", "basename dose/111", "222", "333", "name", "dose", "111", 
                  "444.44", "555.55", "company_name", "666", "SL", "31.12.2010"]
        assert_equal(expect,  @generics_xls.format_original(@pac))
      end
      def test_format_generic
        pac = flexstub(@pac) do |pack|
          pack.should_receive(:sl_entry).and_return(nil)
        end
        expect = ["222", "333", "name", "dose", "111", "444.44", "555.55", "company_name",
                  "666", "", "31.12.2010"]
        assert_equal(expect,  @generics_xls.format_generic(pac))
      end
      def test_format_row
        expect = ["basename", "basename dose/111", "222", "333", "name", "dose", "111",
                  "444.44", "555.55", "company_name", "666", "SL", "31.12.2010", "222",
                  "333", "name", "dose", "111", "444.44", "555.55", "company_name",
                  "666", "SL", "31.12.2010", 
                  "Original: neue Registration, Preissenkung Generikum: neue Registration, Preissenkung"]
        assert_equal(expect,  @generics_xls.format_row(@pac, @pac))
      end
      def assert_row(row)
        flexstub(Spreadsheet::Excel) do |klass|
          klass.should_receive(:new).and_return(flexmock{|book|
            book.should_receive(:add_worksheet).and_return(flexmock{|sheet|
              sheet.should_receive(:format_column)
              sheet.should_receive(:write).with(0,0,Array, Spreadsheet::Format)
              sheet.should_receive(:write).with(1,0,row) # This is the check point
            })
          })
        end
      end
      def test_export_generic
        expect_row = ["", "", "", "", "", "", "", "", "", "", "", "", "", 
                      "222", "333", "name", "dose", "111", "444.44", "555.55", 
                      "company_name", "666", "SL", "31.12.2010", 
                      "Generikum: neue Registration, Preissenkung"]
        assert_row(expect_row)
        generics_xls = GenericXls.new(".")
        assert_equal(2, generics_xls.export_generic(@pac))
      end
      def test_export_comparable
        expect_row =  ["basename", "basename dose/111", "222", "333", "name", 
                       "dose", "111", "444.44", "555.55", "company_name", "666", 
                       "SL", "31.12.2010", "222", "333", "name", "dose", "111", 
                       "444.44", "555.55", "company_name", "666", "SL", "31.12.2010", 
                       "Original: neue Registration, Preissenkung Generikum: neue Registration, Preissenkung"]
        assert_row(expect_row)
        generics_xls = GenericXls.new(".")
        assert_equal(2, generics_xls.export_comparable(@pac, @pac))
      end
      def test_export_comparables
        expect_row =  ["basename", "basename dose/111", "222", "333", "name", 
                       "dose", "111", "444.44", "555.55", "company_name", "666", 
                       "SL", "31.12.2010", "222", "333", "name", "dose", "111", 
                       "444.44", "555.55", "company_name", "666", "SL", "31.12.2010", 
                       "Original: neue Registration, Preissenkung Generikum: neue Registration, Preissenkung"]
        assert_row(expect_row)
        generics_xls = GenericXls.new(".")
        assert_equal(2, generics_xls.export_comparable(@pac, @pac))
 
      end
      def redefine_ODBA(package)
        # This is a trick code, a little bit different from the flexstub in setup method
        # That is why I can re-define the ODBA stub.
        flexstub(ODBA) do |odba|
          odba.should_receive(:cache).and_return(flexmock{|cache|
           cache.should_receive(:fetch_named).and_return(flexmock{|app|
             app.should_receive(:log_group).with(:swissmedic_journal).and_return(@loggroup_swiss)
             app.should_receive(:log_group).with(:bsv_sl).and_return(@loggroup_bsv)
             app.should_receive(:each_package).and_yield(package)
           })
          })
        end
      end
      def test_export_generics__case_no_output
        # Note:
        # if the return value of comparables is not empty (point.1), or
        # if the return value of registration.generics? is not false (ture) (point.2),
        # then you have to define the other method in the flexstub(Package),
        # since export_comparables or export_generic will be called.
        pac = flexstub(@pac) do |pack|
          pack.should_receive(:"registration.active?").and_return(true)
          pack.should_receive(:"registration.original?").and_return(true)
          pack.should_receive(:comparables).and_return([])                # point.1
          pack.should_receive(:"registration.generic?").and_return(false) # point.2
        end

        redefine_ODBA(pac)

        generics_xls = GenericXls.new(".")
        assert_equal(2, generics_xls.export_generics)
      end
      def test_export_generics__case_warning
        pac = flexstub(@pac) do |pack|
          pack.should_receive(:"registration.active?").and_return(true)
          pack.should_receive(:"registration.original?").and_return(true)
          pack.should_receive(:basename).and_return(nil)      # This is the point
        end

        redefine_ODBA(pac)

        # Note:
        # if the following flexstub is not defined,
        # an actual email will be sent.
        flexstub(Log) do |log|
          log.should_receive(:new)
        end

        generics_xls = GenericXls.new(".")
        assert_raise(NoMethodError) do    # This means the report process runs if this assert passes
          generics_xls.export_generics
        end
      end
      def test_export_generics__case_export
        pac = flexstub(@pac) do |pack|
          pack.should_receive(:"registration.active?").and_return(true)
          pack.should_receive(:"registration.original?").and_return(true)
          pack.should_receive(:comparables).and_return([]) 
          pack.should_receive(:basename).and_return("basename")          # This is the point
          pack.should_receive(:"registration.generic?").and_return(true) # This is the point
          pack.should_receive(:"registration.pointer").and_return(123)
        end

        redefine_ODBA(pac)

        # Note:
        # The actual row value (data) is not checked here,
        # since it is tested in test_export_generic.
        generics_xls = GenericXls.new(".")
        assert_equal(3, generics_xls.export_generics)
      end
   end
  end
end
