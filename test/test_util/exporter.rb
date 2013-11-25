#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestExporter -- oddb.org -- 19.01.2012 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
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
  class TestExporter <Minitest::Test
    include FlexMock::TestCase
    def test_test
      assert(true)
    end
    def setup
      now = Time.now
      @download_time = Date.new(2013,9,2)
      @jetzt = Time.new(now.year, now.month, now.day, now.hour, now.min, now.sec)  
      @today = Date.new(now.year, now.month, now.day)
      @app = flexmock('app') 
      @exporter = ODDB::Exporter.new(@app)
      flexmock(@exporter).should_receive(:sleep).and_return('sleep')
      @log = flexmock('log') do |log|
        log.should_receive(:report)
        log.should_receive(:notify)
        log.should_receive(:report=)
        log.should_receive(:date_str=)
      end

      # plugins
      # @plugins will be modifed depending on a test-case in each test method
      @plugin = flexmock('plugin')
      flexmock(OdbaExporter::OddbDatExport).should_receive(:new).and_return(@plugin)
      flexmock(SwissmedicPlugin).should_receive(:new).and_return(@plugin)
      flexmock(XlsExportPlugin).should_receive(:new).and_return(@plugin)
      flexmock(CsvExportPlugin).should_receive(:new).and_return(@plugin)
      flexmock(FiPDFExporter).should_receive(:new).and_return(@plugin)
      flexmock(OuwerkerkPlugin).should_receive(:new).and_return(@plugin)
      flexmock(YamlExporter).should_receive(:new).and_return(@plugin)
      flexmock(DownloadInvoicer).should_receive(:new).and_return(@plugin)
      flexmock(FachinfoInvoicer).should_receive(:new).and_return(@plugin)
      flexmock(PatinfoInvoicer).should_receive(:new).and_return(@plugin)
      flexmock(LogFile) do |logclass| logclass.should_receive(:filename).with(@jetzt, 'oddb/debug',).and_return('/tmp/logfile')  end
    end
    def test_export_oddbdat__on_sunday
      flexmock(@exporter, :today => Date.new(2011,1,2)) # Sunday
      flexmock(Log) do |logclass|
        # white box test: Log.new is never called
        # if dose_missing_list is not empty or an error raises,
        # Log.new will be called
        logclass.should_receive(:new).times(0).and_return(@log)
      end
      flexmock(@plugin) do |exporter|
        exporter.should_receive(:export_fachinfos).once.with_no_args
        exporter.should_receive(:export).and_return([]) # this is the key point
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')

      # the 'nil' means 'if' condition runs, otherwise it may indicate an error
      assert_equal(nil, @exporter.export_oddbdat)
    end
    def test_export_oddbdat__on_monday
      flexmock(@exporter, :today => Date.new(2011,1,3)) # Monday
      flexmock(Log) do |logclass|
        logclass.should_receive(:new).times(0).and_return(@log)
      end
      flexmock(@plugin) do |exporter|
          exporter.should_receive(:export).and_return([]) # this is the key point
          exporter.should_receive(:export_fachinfos).once.with_no_args
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')

      assert_equal(nil, @exporter.export_oddbdat)
    end
    def test_export_oddbdat__dose_missing
      flexmock(@exporter, :today => Date.new(2011,1,2)) # Sunday
      flexmock(Log) do |logclass|
        # white box test: Log.new is once called because of dose data missing
        logclass.should_receive(:new).times(1).and_return(@log)
      end      
      flexmock(@plugin) do |exporter|
        exporter.should_receive(:export).and_return(['dose_missing']) # this is the key point
        exporter.should_receive(:export_fachinfos).once.with_no_args
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')

      assert_equal(nil, @exporter.export_oddbdat)
    end
    def test_run__on_1st_day
      # totally whilte box test
      flexmock(@exporter) do  |exp|
        exp.should_receive(:today).and_return(Date.new(2011,1,1)) # Saturday
        exp.should_receive(:mail_patinfo_invoices).once.with_no_args
        exp.should_receive(:mail_fachinfo_log).once.with_no_args
        exp.should_receive(:mail_download_invoices).once.with_no_args
        exp.should_receive(:mail_download_stats).times(0).with_no_args
        exp.should_receive(:mail_feedback_stats).times(0).with_no_args
        exp.should_receive(:export_sl_pcodes).once.with_no_args
#        exp.should_receive(:export_yaml).once.with_no_args # yaml only run on sunday
#        exp.should_receive(:export_oddbdat).once.with_no_args # yaml only run on sunday
        exp.should_receive(:export_csv).once.with_no_args
        exp.should_receive(:export_doc_csv).once.with_no_args
        exp.should_receive(:export_index_therapeuticus_csv).once.with_no_args
        exp.should_receive(:export_price_history_csv).once.with_no_args
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal(nil, @exporter.run)
    end
    def test_run__on_15th_day
      flexmock(@exporter) do  |exp|
        exp.should_receive(:today).and_return(Date.new(2011,1,15)) # Saturday
        exp.should_receive(:mail_patinfo_invoices).once.with_no_args
        exp.should_receive(:mail_fachinfo_log).once.with_no_args
        exp.should_receive(:mail_download_invoices).once.with_no_args
        exp.should_receive(:mail_download_stats).times(0).with_no_args
        exp.should_receive(:mail_feedback_stats).times(0).with_no_args
        exp.should_receive(:export_sl_pcodes).once.with_no_args
#        exp.should_receive(:export_yaml).once.with_no_args # yaml only run on sunday
#        exp.should_receive(:export_oddbdat).once.with_no_args # yaml only run on sunday
        exp.should_receive(:export_csv).once.with_no_args
        exp.should_receive(:export_doc_csv).once.with_no_args
        exp.should_receive(:export_index_therapeuticus_csv).once.with_no_args
        exp.should_receive(:export_price_history_csv).once.with_no_args
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal(nil, @exporter.run)
    end
    def test_run__on_sunday
      flexmock(@exporter) do  |exp|
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
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal(nil, @exporter.run)
    end
    def test_export_helper
      flexmock(Exporter::EXPORT_SERVER) do |exp|
        exp.should_receive(:remote_safe_export).and_yield('path')
      end
      @exporter.export_helper('name') do |path|
        assert_equal('path', path)
      end
    end
    def test_export_all_csv
      # totally white box test
      flexmock(@exporter) do |exp|
        exp.should_receive(:export_csv).once.with_no_args
        exp.should_receive(:export_doc_csv).once.with_no_args
        exp.should_receive(:export_index_therapeuticus_csv).once.with_no_args
        exp.should_receive(:export_price_history_csv).once.with_no_args.and_return('export_price_history_csv')
      end
      assert_equal('export_price_history_csv', @exporter.export_all_csv)
    end
    def test_export_competition_xls
      flexmock(@plugin) do |plug|
        plug.should_receive(:export_competition)
      end
      assert_equal(@plugin, @exporter.export_competition_xls('company'))
    end
    def test_export_csv
      flexmock(@plugin) do |plug|
        plug.should_receive(:export_drugs)
        plug.should_receive(:export_drugs_extended)
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal(nil, @exporter.export_csv)
    end
    def test_export_csv_errorcase1
      flexmock(@plugin) do |plug|
        plug.should_receive(:export_drugs).and_raise(StandardError)
        plug.should_receive(:export_drugs_extended)
      end
      flexmock(Log) do |logclass|
        # white box test: Log.new is once called because of error
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal(nil, @exporter.export_csv)
    end
    def test_export_csv_errorcase2
      flexmock(@plugin) do |plug|
        plug.should_receive(:export_drugs)
        plug.should_receive(:export_drugs_extended).and_raise(StandardError)
      end
      flexmock(Log) do |logclass|
        # white box test: Log.new is once called because of error
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal('sleep', @exporter.export_csv)
    end
    def test_export_analysis_csv
      flexmock(@plugin) do |plug|
        plug.should_receive(:export_analysis)
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal(nil, @exporter.export_analysis_csv)
    end
    def test_export_doc_csv
      flexmock(@plugin) do |plug|
        plug.should_receive(:export_doctors)
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal(nil, @exporter.export_doc_csv)
    end
    def test_export_doc_csv__error
      flexmock(@plugin) do |plug|
        plug.should_receive(:export_doctors).and_raise(StandardError)
      end
      flexmock(Log) do |logclass|
        # white box test: Log.new is once called because of error
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal('sleep', @exporter.export_doc_csv)
    end
    def test_export_fachinfo_pdf
      # this method will be removed
    end
    def test_export_generics_xls
      flexmock(@plugin) do |plug|
        plug.should_receive(:export_generics)
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal(@plugin, @exporter.export_generics_xls)
    end
    def test_export_swissdrug_xls
      flexmock(@plugin) do |plug|
        plug.should_receive(:export_xls)
        plug.should_receive(:file_path)
      end
      flexmock(FileUtils).should_receive(:cp)
      flexmock(Exporter::EXPORT_SERVER).should_receive(:compress)
      assert_equal(@plugin, @exporter.export_swissdrug_xls)
    end
    def test_export_index_therapeuticus_csv
      flexmock(@plugin) do |plug|
        plug.should_receive(:export_index_therapeuticus)
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal(nil, @exporter.export_index_therapeuticus_csv)
    end
    def test_export_index_therapeuticus_csv__error
      flexmock(@plugin) do |plug|
        plug.should_receive(:export_index_therapeuticus).and_raise(StandardError)
      end
      flexmock(Log) do |logclass|
        # white box test: Log.new is once called because of error
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal('sleep', @exporter.export_index_therapeuticus_csv) 
    end
    def test_export_migel_csv
      flexmock(@plugin) do |plug|
        plug.should_receive(:export_migel)
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal(nil, @exporter.export_migel_csv)
    end
    def test_export_pdf
      flexmock(@plugin) do |plug|
        plug.should_receive(:run).and_return('run')
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal('run', @exporter.export_pdf)
    end
    def test_export_sl_pcodes
      flexmock(@app) do |app|
        app.should_receive(:each_package).and_yield(flexmock('pac') do |pac|
          pac.should_receive(:sl_entry).and_return(true)
          pac.should_receive(:pharmacode).and_return('pharmacode')
        end)
      end
 
      # test
      expected = 'pharmacode'
      fh = flexmock('file_pointer') do |file_pointer|
        file_pointer.should_receive(:puts).once.with(expected)
        file_pointer.should_receive(:<<)
      end
      flexmock(File) do |file|
        file.should_receive(:open).and_yield(fh)
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal(nil, @exporter.export_sl_pcodes)
    end
    def test_export_sl_pcodes__error
      flexmock(File) do |file|
        file.should_receive(:open).and_raise(StandardError)
      end
      flexmock(Log) do |logclass|
        # white box test: Log.new is once called because of error
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      res = @exporter.export_sl_pcodes
      skip("Niklaus does not know why under minitest it returns sleep instead of raising an error")
      assert_raises(StandardError) { @exporter.export_sl_pcodes }
    end
    def test_export_patents_xls
      flexmock(@plugin) do |plug|
        plug.should_receive(:export_patents)
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal(@plugin, @exporter.export_patents_xls)
    end
    def test_export_csv_on_monday
      flexmock(@exporter, :today => Date.new(2011,1,3)) # Monday
      # totally white box test
      flexmock(@plugin) do |plug|
        plug.should_receive(:export_drugs).once.with_no_args
        plug.should_receive(:export_drugs_extended).once.with_no_args
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal(nil, @exporter.export_csv)
    end
    def test_export_csv_on_tuesday
      flexmock(@exporter, :today => Date.new(2011,1,4)) # Tuesday
      # totally white box test
      flexmock(@plugin) do |plug|
        plug.should_receive(:export_drugs).once.with_no_args
        plug.should_receive(:export_drugs_extended).once.with_no_args
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal(nil, @exporter.export_csv)
    end
    def test_export_csv_on_wednesday
      flexmock(@exporter, :today => Date.new(2011,1,5)) # Wednesday
      # totally white box test
      flexmock(@plugin) do |plug|
        plug.should_receive(:export_drugs).once.with_no_args
        plug.should_receive(:export_drugs_extended).once.with_no_args
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal(nil, @exporter.export_csv)
    end
    def test_export_csv_on_thursday
      flexmock(@exporter, :today => Date.new(2011,1,6)) # Tursday
      # totally white box test
      flexmock(@plugin) do |plug|
        plug.should_receive(:export_drugs).once.with_no_args
        plug.should_receive(:export_drugs_extended).once.with_no_args
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal(nil, @exporter.export_csv)
    end
    def test_mail_download_stats
      flexmock(Log) do |logclass|
        # white box test: Log.new is once called in any case
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      flexmock(File).should_receive(:read)
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal(nil, @exporter.mail_download_stats)
    end
    def test_mail_download_invoices
      flexmock(@plugin) do |plug|
        plug.should_receive(:run).and_return('run')
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal('run', @exporter.mail_download_invoices)
    end
    def test_mail_fachinfo_log__noreport
      flexmock(@plugin) do |plug|
        plug.should_receive(:run)
        plug.should_receive(:report).and_return(nil)
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal(nil, @exporter.mail_fachinfo_log)
    end
    def test_mail_fachinfo_log__report
      flexmock(@plugin) do |plug|
        plug.should_receive(:run)
        plug.should_receive(:report).and_return('report')
      end
      flexmock(Log) do |logclass|
        # white box test: Log.new is once called if there is a report
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal(nil, @exporter.mail_fachinfo_log)
    end

    def test_mail_feedback_stats
      flexmock(Log) do |logclass|
        # white box test: Log.new is once called in any case
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      flexmock(File).should_receive(:read)
      flexmock(LogFile).should_receive(:filename).times(1).with('feedback', Date)
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal(nil, @exporter.mail_feedback_stats)
    end
    def test_mail_notification_stats
      flexmock(@app) do |app|
        app.should_receive(:"notification_logger.create_csv").and_return('file')
      end
      flexmock(@log) do |log|
        log.should_receive(:notify_attachment).with('file', Hash).and_return('notify_attachment')
      end
      flexmock(Log) do |logclass|
        # white box test: Log.new is once called
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      assert_equal('notify_attachment', @exporter.mail_notification_stats)
    end
    def test_mail_patinfo_invoice
      flexmock(@plugin) do |plug|
        plug.should_receive(:run).and_return('run')
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal('run', @exporter.mail_patinfo_invoices)
    end
    def test_export_price_history_csv
      flexmock(@plugin) do |plug|
        plug.should_receive(:export_price_history)
      end
      flexmock(Log) do |logclass|
        # white box test: Log.new is never called
        logclass.should_receive(:new).times(0).and_return(@log)
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      assert_equal(nil, @exporter.export_price_history_csv) 
    end
    def test_mail_stats__before_8th
      flexmock(Log) do |logclass|
        # white box test: Log.new is once called in any case
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      flexmock(File).should_receive(:read)
      flexmock(LogFile).should_receive(:filename).once.with('key', @today)
      assert_equal(nil, @exporter.mail_stats('key'))
    end
    def test_mail_stats__after_8th
      flexmock(@exporter, :today => Date.new(2011,1,10))
      flexmock(Log) do |logclass|
        # white box test: Log.new is once called in any case
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      now = Time.now
      flexmock(File).should_receive(:read)
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      # test
      assert_equal(nil, @exporter.mail_stats('key'))
    end
    def test_mail_swissmedic_notifications
      flexmock(@plugin) do |plug|
          plug.should_receive(:mail_notifications).and_return('mail_notifications')
      end
      assert_equal('mail_notifications', @exporter.mail_swissmedic_notifications)
    end
    def test_safe_export
      flexmock(Log) do |logclass|
        # white box test: Log.new is never called if there is no error
        logclass.should_receive(:new).times(0).and_return(@log)
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      @exporter.safe_export('test_safe_export') do
        'no error'
      end
    end
    def test_safe_export__error
      flexmock(Log) do |logclass|
        # white box test: Log.new is never called if there is no error
        logclass.should_receive(:new).times(1).and_return(@log)
      end
      flexmock(LogFile).should_receive(:filename).and_return('/tmp/logfile')
      @exporter.safe_export('test_safe_export') do
        raise
      end
    end
  end
end

