#!/usr/bin/env ruby
# TestExporter -- oddb -- 07.02.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'util/exporter'
require 'util/log'
require 'date'

module ODDB
  include FlexMock::TestCase
  class StubDRbObject
    def clear
    end
  end
  class Exporter
    remove_const :EXPORT_SERVER
    EXPORT_SERVER = StubDRbObject.new
  end
  class TestExporter < Test::Unit::TestCase
    include FlexMock::TestCase
    def test_test
      assert(true)
    end
    def setup
      @app = flexmock('app') 
      @exporter = ODDB::Exporter.new(@app)
      flexstub(@exporter).should_receive(:sleep).and_return('sleep')
      @log = flexmock('log') do |log|
        log.should_receive(:report)
        log.should_receive(:notify)
        log.should_receive(:report=)
        log.should_receive(:date_str=)
      end

      # plugins
      # @plugins will be modifed depending on a test-case in each test method
      @plugin = flexmock('plugin')
      flexstub(OdbaExporter::OddbDatExport).should_receive(:new).and_return(@plugin)
      flexstub(SwissmedicPlugin).should_receive(:new).and_return(@plugin)
      flexstub(XlsExportPlugin).should_receive(:new).and_return(@plugin)
      flexstub(CsvExportPlugin).should_receive(:new).and_return(@plugin)
      flexstub(FiPDFExporter).should_receive(:new).and_return(@plugin)
      flexstub(OuwerkerkPlugin).should_receive(:new).and_return(@plugin)
      flexstub(YamlExporter).should_receive(:new).and_return(@plugin)
      flexstub(DownloadInvoicer).should_receive(:new).and_return(@plugin)
      flexstub(FachinfoInvoicer).should_receive(:new).and_return(@plugin)
      flexstub(PatinfoInvoicer).should_receive(:new).and_return(@plugin)
    end
    def test_export_oddbdat__on_sunday
      flexstub(@exporter, :today => Date.new(2011,1,2))
      flexstub(Log) do |logclass|
        # white box test: Log.new is never called
        # if dose_missing_list is not empty or an error raises,
        # Log.new will be called
        logclass.should_receive(:new).times(0).and_return(@log)
      end
      flexstub(@plugin) do |exporter|
          exporter.should_receive(:export).and_return([]) # this is the key point
      end

      # the 'nil' means 'if' condition runs, otherwise it may indicate an error
      assert_equal(nil, @exporter.export_oddbdat)
    end
    def test_export_oddbdat__on_monday
      flexstub(@exporter, :today => Date.new(2011,1,3)) # Monday
      flexstub(Log) do |logclass|
        logclass.should_receive(:new).times(0).and_return(@log)
      end
      flexstub(@plugin) do |exporter|
          exporter.should_receive(:export).and_return([]) # this is the key point
          exporter.should_receive(:export_fachinfos).once.with_no_args
      end

      assert_equal(nil, @exporter.export_oddbdat)
    end
    def test_export_oddbdat__dose_missing
      flexstub(@exporter, :today => Date.new(2011,1,4)) # Tuesday
      flexstub(Log) do |logclass|
        # white box test: Log.new is once called because of dose data missing
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      flexstub(@plugin) do |exporter|
          exporter.should_receive(:export).and_return(['dose_missing']) # this is the key point
      end

      assert_equal(nil, @exporter.export_oddbdat)
    end
    def test_run__on_1st_day
      # totally whilte box test
      flexstub(@exporter) do  |exp|
        exp.should_receive(:today).and_return(Date.new(2011,1,1)) # Saturday
        exp.should_receive(:mail_patinfo_invoices).once.with_no_args
        exp.should_receive(:mail_fachinfo_log).once.with_no_args
        exp.should_receive(:mail_download_invoices).once.with_no_args
        exp.should_receive(:mail_download_stats).times(0).with_no_args
        exp.should_receive(:mail_feedback_stats).times(0).with_no_args
        exp.should_receive(:export_sl_pcodes).once.with_no_args
        exp.should_receive(:export_yaml).once.with_no_args
        exp.should_receive(:export_oddbdat).once.with_no_args
        exp.should_receive(:export_csv).once.with_no_args
        exp.should_receive(:export_doc_csv).once.with_no_args
        exp.should_receive(:export_index_therapeuticus_csv).once.with_no_args
        exp.should_receive(:export_price_history_csv).once.with_no_args
      end
      assert_equal(nil, @exporter.run)
    end
    def test_run__on_15th_day
      flexstub(@exporter) do  |exp|
        exp.should_receive(:today).and_return(Date.new(2011,1,15)) # Saturday
        exp.should_receive(:mail_patinfo_invoices).once.with_no_args
        exp.should_receive(:mail_fachinfo_log).once.with_no_args
        exp.should_receive(:mail_download_invoices).once.with_no_args
        exp.should_receive(:mail_download_stats).times(0).with_no_args
        exp.should_receive(:mail_feedback_stats).times(0).with_no_args
        exp.should_receive(:export_sl_pcodes).once.with_no_args
        exp.should_receive(:export_yaml).once.with_no_args
        exp.should_receive(:export_oddbdat).once.with_no_args
        exp.should_receive(:export_csv).once.with_no_args
        exp.should_receive(:export_doc_csv).once.with_no_args
        exp.should_receive(:export_index_therapeuticus_csv).once.with_no_args
        exp.should_receive(:export_price_history_csv).once.with_no_args
      end
      assert_equal(nil, @exporter.run)
    end
    def test_run__on_sunday
      flexstub(@exporter) do  |exp|
        exp.should_receive(:today).and_return(Date.new(2011,1,2)) # Sunday
        exp.should_receive(:mail_patinfo_invoices).once.with_no_args
        exp.should_receive(:mail_fachinfo_log).once.with_no_args
        exp.should_receive(:mail_download_invoices).times(0).with_no_args
        exp.should_receive(:mail_download_stats).once.with_no_args
        exp.should_receive(:mail_feedback_stats).once.with_no_args
        exp.should_receive(:export_sl_pcodes).once.with_no_args
        exp.should_receive(:export_yaml).once.with_no_args
        exp.should_receive(:export_oddbdat).once.with_no_args
        exp.should_receive(:export_csv).once.with_no_args
        exp.should_receive(:export_doc_csv).once.with_no_args
        exp.should_receive(:export_index_therapeuticus_csv).once.with_no_args
        exp.should_receive(:export_price_history_csv).once.with_no_args
      end
      assert_equal(nil, @exporter.run)
    end
    def test_export_helper
      flexstub(Exporter::EXPORT_SERVER) do |exp|
        exp.should_receive(:remote_safe_export).and_yield('path')
      end
      @exporter.export_helper('name') do |path|
        assert_equal('path', path)
      end
    end
    def test_export_all_csv
      # totally white box test
      flexstub(@exporter) do |exp|
        exp.should_receive(:export_csv).once.with_no_args
        exp.should_receive(:export_doc_csv).once.with_no_args
        exp.should_receive(:export_index_therapeuticus_csv).once.with_no_args
        exp.should_receive(:export_price_history_csv).once.with_no_args.and_return('export_price_history_csv')
      end
      assert_equal('export_price_history_csv', @exporter.export_all_csv)
    end
    def test_export_competition_xls
      flexstub(@plugin) do |plug|
        plug.should_receive(:export_competition)
      end
      assert_equal(@plugin, @exporter.export_competition_xls('company'))
    end
    def test_export_csv
      flexstub(@plugin) do |plug|
        plug.should_receive(:export_drugs)
        plug.should_receive(:export_drugs_extended)
      end
      assert_equal('sleep', @exporter.export_csv)
    end
    def test_export_csv__errorcase1
      flexstub(@plugin) do |plug|
        plug.should_receive(:export_drugs).and_raise(StandardError)
        plug.should_receive(:export_drugs_extended)
      end
      flexstub(Log) do |logclass|
        # white box test: Log.new is once called because of error
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      assert_equal('sleep', @exporter.export_csv)
    end
    def test_export_csv__errorcase2
      flexstub(@plugin) do |plug|
        plug.should_receive(:export_drugs)
        plug.should_receive(:export_drugs_extended).and_raise(StandardError)
      end
      flexstub(Log) do |logclass|
        # white box test: Log.new is once called because of error
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      assert_equal('sleep', @exporter.export_csv)
    end
    def test_export_analysis_csv
      flexstub(@plugin) do |plug|
        plug.should_receive(:export_analysis)
      end
      assert_equal('sleep', @exporter.export_analysis_csv)
    end
    def test_export_doc_csv
      flexstub(@plugin) do |plug|
        plug.should_receive(:export_doctors)
      end
      assert_equal('sleep', @exporter.export_doc_csv)
    end
    def test_export_doc_csv__error
      flexstub(@plugin) do |plug|
        plug.should_receive(:export_doctors).and_raise(StandardError)
      end
      flexstub(Log) do |logclass|
        # white box test: Log.new is once called because of error
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      assert_equal('sleep', @exporter.export_doc_csv)
    end
    def test_export_fachinfo_pdf
      # this method will be removed
    end
    def test_export_generics_xls
      flexstub(@plugin) do |plug|
        plug.should_receive(:export_generics)
      end
      assert_equal(@plugin, @exporter.export_generics_xls)
    end
    def test_export_swissdrug_xls
      flexstub(@plugin) do |plug|
        plug.should_receive(:export_xls)
        plug.should_receive(:file_path)
      end
      flexstub(FileUtils).should_receive(:cp)
      flexstub(Exporter::EXPORT_SERVER).should_receive(:compress)
      assert_equal(@plugin, @exporter.export_swissdrug_xls)
    end
    def test_export_index_therapeuticus_csv
      flexstub(@plugin) do |plug|
        plug.should_receive(:export_index_therapeuticus)
      end
      assert_equal('sleep', @exporter.export_index_therapeuticus_csv)
    end
    def test_export_index_therapeuticus_csv__error
      flexstub(@plugin) do |plug|
        plug.should_receive(:export_index_therapeuticus).and_raise(StandardError)
      end
      flexstub(Log) do |logclass|
        # white box test: Log.new is once called because of error
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      assert_equal('sleep', @exporter.export_index_therapeuticus_csv) 
    end
    def test_export_migel_csv
      flexstub(@plugin) do |plug|
        plug.should_receive(:export_migel)
      end
      assert_equal('sleep', @exporter.export_migel_csv)
    end
    def test_export_narcotics_csv
      flexstub(@plugin) do |plug|
        plug.should_receive(:export_narcotics)
      end
      assert_equal('sleep', @exporter.export_narcotics_csv)
    end
    def test_export_pdf
      flexstub(@plugin) do |plug|
        plug.should_receive(:run).and_return('run')
      end
      assert_equal('run', @exporter.export_pdf)
    end
    def test_export_sl_pcodes
      flexstub(@app) do |app|
        app.should_receive(:each_package).and_yield(flexmock('pac') do |pac|
          pac.should_receive(:sl_entry).and_return(true)
          pac.should_receive(:pharmacode).and_return('pharmacode')
        end)
      end
 
      # test
      expected = 'pharmacode'
      fh = flexmock('file_pointer') do |file_pointer|
        file_pointer.should_receive(:puts).with(expected)
      end
      flexstub(File) do |file|
        file.should_receive(:open).and_yield(fh)
      end
      assert_equal(nil, @exporter.export_sl_pcodes)
    end
    def test_export_sl_pcodes__error
      flexstub(File) do |file|
        file.should_receive(:open).and_raise(StandardError)
      end
      flexstub(Log) do |logclass|
        # white box test: Log.new is once called because of error
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      assert_equal('sleep', @exporter.export_sl_pcodes)
    end
    def test_export_patents_xls
      flexstub(@plugin) do |plug|
        plug.should_receive(:export_patents)
      end
      assert_equal(@plugin, @exporter.export_patents_xls)
    end
    def test_export_yaml__on_monday
      flexstub(@exporter, :today => Date.new(2011,1,3)) # Monday
      # totally white box test
      flexstub(@plugin) do |plug|
        plug.should_receive(:export).once.with_no_args
        plug.should_receive(:export_atc_classes).once.with_no_args
        plug.should_receive(:export_interactions).once.with_no_args
        plug.should_receive(:export_narcotics).once.with_no_args
        plug.should_receive(:export_prices).once.with_no_args
        plug.should_receive(:export_fachinfos).times(0).with_no_args
        plug.should_receive(:export_patinfos).times(0).with_no_args
        plug.should_receive(:export_doctors).times(0).with_no_args
      end
      assert_equal('sleep', @exporter.export_yaml)
    end
    def test_export_yaml__on_tuesday
      flexstub(@exporter, :today => Date.new(2011,1,4)) # Tuesday
      # totally white box test
      flexstub(@plugin) do |plug|
        plug.should_receive(:export).once.with_no_args
        plug.should_receive(:export_atc_classes).once.with_no_args
        plug.should_receive(:export_interactions).once.with_no_args
        plug.should_receive(:export_narcotics).once.with_no_args
        plug.should_receive(:export_prices).once.with_no_args
        plug.should_receive(:export_fachinfos).once.with_no_args
        plug.should_receive(:export_patinfos).times(0).with_no_args
        plug.should_receive(:export_doctors).times(0).with_no_args
      end
      assert_equal('sleep', @exporter.export_yaml)
    end
    def test_export_yaml__on_wednesday
      flexstub(@exporter, :today => Date.new(2011,1,5)) # Wednesday
      # totally white box test
      flexstub(@plugin) do |plug|
        plug.should_receive(:export).once.with_no_args
        plug.should_receive(:export_atc_classes).once.with_no_args
        plug.should_receive(:export_interactions).once.with_no_args
        plug.should_receive(:export_narcotics).once.with_no_args
        plug.should_receive(:export_prices).once.with_no_args
        plug.should_receive(:export_fachinfos).times(0).with_no_args
        plug.should_receive(:export_patinfos).once.with_no_args
        plug.should_receive(:export_doctors).times(0).with_no_args
      end
      assert_equal('sleep', @exporter.export_yaml)
    end
    def test_export_yaml__on_thursday
      flexstub(@exporter, :today => Date.new(2011,1,6)) # Tursday
      # totally white box test
      flexstub(@plugin) do |plug|
        plug.should_receive(:export).once.with_no_args
        plug.should_receive(:export_atc_classes).once.with_no_args
        plug.should_receive(:export_interactions).once.with_no_args
        plug.should_receive(:export_narcotics).once.with_no_args
        plug.should_receive(:export_prices).once.with_no_args
        plug.should_receive(:export_fachinfos).times(0).with_no_args
        plug.should_receive(:export_patinfos).times(0).with_no_args
        plug.should_receive(:export_doctors).once.with_no_args
      end
      assert_equal('sleep', @exporter.export_yaml)
    end
    def test_mail_download_stats
      flexstub(Log) do |logclass|
        # white box test: Log.new is once called in any case
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      flexstub(File).should_receive(:read)
      flexstub(LogFile).should_receive(:filename).times(1).with('download', Date)
      assert_equal(nil, @exporter.mail_download_stats)
    end
    def test_mail_download_invoices
      flexstub(@plugin) do |plug|
        plug.should_receive(:run).and_return('run')
      end
      assert_equal('run', @exporter.mail_download_invoices)
    end
    def test_mail_fachinfo_log__noreport
      flexstub(@plugin) do |plug|
        plug.should_receive(:run)
        plug.should_receive(:report).and_return(nil)
      end
      assert_equal(nil, @exporter.mail_fachinfo_log)
    end
    def test_mail_fachinfo_log__report
      flexstub(@plugin) do |plug|
        plug.should_receive(:run)
        plug.should_receive(:report).and_return('report')
      end
      flexstub(Log) do |logclass|
        # white box test: Log.new is once called if there is a report
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      assert_equal(nil, @exporter.mail_fachinfo_log)
    end

    def test_mail_feedback_stats
      flexstub(Log) do |logclass|
        # white box test: Log.new is once called in any case
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      flexstub(File).should_receive(:read)
      flexstub(LogFile).should_receive(:filename).times(1).with('feedback', Date)
      assert_equal(nil, @exporter.mail_feedback_stats)
    end
    def test_mail_notification_stats
      flexstub(@app) do |app|
        app.should_receive(:"notification_logger.create_csv").and_return('file')
      end
      flexstub(@log) do |log|
        log.should_receive(:notify_attachment).with('file', Hash).and_return('notify_attachment')
      end
      flexstub(Log) do |logclass|
        # white box test: Log.new is once called
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      assert_equal('notify_attachment', @exporter.mail_notification_stats)
    end
    def test_mail_patinfo_invoice
      flexstub(@plugin) do |plug|
        plug.should_receive(:run).and_return('run')
      end
      assert_equal('run', @exporter.mail_patinfo_invoices)
    end
    def test_export_price_history_csv
      flexstub(@plugin) do |plug|
        plug.should_receive(:export_price_history)
      end
      flexstub(Log) do |logclass|
        # white box test: Log.new is never called
        logclass.should_receive(:new).times(0).and_return(@log)
      end
      assert_equal('sleep', @exporter.export_price_history_csv) 
    end
    def test_export_price_history_csv
      flexstub(@plugin) do |plug|
        plug.should_receive(:export_price_history).and_raise(StandardError)
      end
      flexstub(Log) do |logclass|
        # white box test: Log.new is once called if there is an error
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      assert_equal('sleep', @exporter.export_price_history_csv) 
    end
    def test_mail_stats__before_8th
      flexstub(@exporter, :today => Date.new(2011,1,5))
      flexstub(Log) do |logclass|
        # white box test: Log.new is once called in any case
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      flexstub(File).should_receive(:read)

      # test
      expected_date = Date.new(2010,12,5)
      flexstub(LogFile).should_receive(:filename).with('key', expected_date)
      assert_equal(nil, @exporter.mail_stats('key'))
    end
    def test_mail_stats__after_8th
      flexstub(@exporter, :today => Date.new(2011,1,10))
      flexstub(Log) do |logclass|
        # white box test: Log.new is once called in any case
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      flexstub(File).should_receive(:read)

      # test
      expected_date = Date.new(2011,1,10)
      flexstub(LogFile).should_receive(:filename).with('key', expected_date)
      assert_equal(nil, @exporter.mail_stats('key'))
    end
    def test_mail_swissmedic_notifications
      flexstub(@plugin) do |plug|
          plug.should_receive(:mail_notifications).and_return('mail_notifications')
      end
      assert_equal('mail_notifications', @exporter.mail_swissmedic_notifications)
    end
    def test_safe_export
      flexstub(Log) do |logclass|
        # white box test: Log.new is never called if there is no error
        logclass.should_receive(:new).times(0).and_return(@log)
      end
      @exporter.safe_export('test_safe_export') do
        'no error'
      end
    end
    def test_safe_export__error
      flexstub(Log) do |logclass|
        # white box test: Log.new is never called if there is no error
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      @exporter.safe_export('test_safe_export') do
        raise
      end
    end
  end
end

