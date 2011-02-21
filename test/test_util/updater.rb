#!/usr/bin/env ruby
# TestUpdater -- oddb -- 23.05.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'util/updater'
require 'stub/odba'
require 'flexmock'
require 'date'

module ODDB
	class StubUpdaterPlugin
		attr_reader :month
		def initialize(app)
			@app = app
		end
		def log_info
			{
				:report =>	@last_date,
			}
		end
		def update(date)
			@last_date = @month = @app.last_date = date
			date < Date.new(2002,12)
		end
		def report
			@last_date
		end
		def incomplete_pointers
			[]
		end
		alias :recipients :incomplete_pointers
	end
	class TestUpdater < Test::Unit::TestCase
    include FlexMock::TestCase
		class StubLog
			include ODDB::Persistence
			attr_accessor :report, :pointers, :recipients, :hash
			def notify(arg=nil)
			end
		end
		class StubApp
			attr_writer :log_group
			attr_reader :pointer, :values, :model
			attr_accessor :last_date
			def initialize
				@model = StubLog.new
			end
			def update(pointer, values)
				@pointer = pointer
				@values = values
				@model
			end
			def log_group(key)
				@log_group
			end
			def create(pointer)
				@log_group
			end
		end
		class StubLogGroup
			attr_accessor :newest_date
			def pointer
				ODDB::Persistence::Pointer.new([:log_group, :foo])
			end
		end

		def setup
			@app = StubApp.new
			@updater = ODDB::Updater.new(@app)
			@group = @app.log_group = StubLogGroup.new

      flexstub(Log) do |klass|
        klass.should_receive(:new).and_return(flexmock('log') do |obj|
          obj.should_receive(:report=)
          obj.should_receive(:recipients=)
          obj.should_receive(:update_values)
          obj.should_receive(:notify).and_return('notify')
        end)
      end
      @error = flexmock('error') do |err|
        err.should_receive(:class)
        err.should_receive(:message)
        err.should_receive(:backtrace).and_return(['backtrace'])
      end
      @recipients = {:recipients => ['recipient']}
		end
		def test_update_bsv_no_repeats
			today = Date.today()
			this_month = Date.new(today.year, today.month)
			@group.newest_date = this_month >> 1
			@updater.update_bsv
			assert_nil(@app.last_date)
		end

    def test_recipients
      assert_equal([], @updater.recipients)
    end
    def test_log_info
      plugin = flexmock('plugin') do |plg|
        plg.should_receive(:log_info).and_return({})
      end
      assert_equal({:recipients => []}, @updater.log_info(plugin))
    end
    def test_log_info__else
      plugin = flexmock('plugin') do |plg|
        plg.should_receive(:log_info).and_return(@recipients)
      end
      assert_equal(@recipients, @updater.log_info(plugin))
    end
    def test_notify_error # test private method
      error = @error
      assert_equal('notify', @updater.instance_eval('notify_error("klass", "subject", error)'))
    end
    def test_wrap_update  # test private method
      assert_equal('block', @updater.instance_eval("wrap_update('klass', 'subject'){'block'}"))
    end
    def test_wrap_update__error
      assert_equal(nil, @updater.instance_eval("wrap_update('klass', 'subject'){raise}"))
    end
    def setup_exporter
      plugin = flexmock('plugin') do |plg|
        plg.should_receive(:log_info).and_return(@recipients)
      end
      flexstub(Exporter) do |klass|
        klass.should_receive(:new).and_return(flexmock('exp') do |obj|
          obj.should_receive(:export_competition_xls).and_return(plugin)
          obj.should_receive(:export_swissdrug_xls).and_return(plugin)
        end)
      end
    end
    def setup_export_competition_xls
      setup_exporter
      flexstub(XlsExportPlugin) do |klass|
        klass.should_receive(:new).and_return(flexmock('xls') do |obj|
          obj.should_receive(:export_competition).and_return('path')
        end)
      end
      @company = flexmock('company') do |comp|
        comp.should_receive(:name).and_return('name')
        comp.should_receive(:competition_email).and_return('competition_email')
      end
    end
    def test_export_competition_xls
      setup_export_competition_xls
      assert_equal('path', @updater.export_competition_xls(@company))
    end
    def test_export_competition_xlss
      setup_export_competition_xls
      flexstub(@app) do |app|
        app.should_receive(:companies).and_return({'key' => @company})
      end
      expected = {'key' => @company}
      assert_equal(expected, @updater.export_competition_xlss)
    end
    def setup_csv_export_plugin
      flexstub(CsvExportPlugin) do |klass|
        klass.should_receive(:new).and_return(flexmock('csv') do |obj|
          obj.should_receive(:export_index_therapeuticus)
          obj.should_receive(:export_drugs)
          obj.should_receive(:export_drugs_extended)
          obj.should_receive(:log_info).and_return(@recipients)
        end)
      end
    end
    def test_export_index_therapeuticus_csv
      setup_csv_export_plugin
      assert_equal('notify', @updater.export_index_therapeuticus_csv)
    end
    def test_export_oddb_csv
      setup_csv_export_plugin
      assert_equal('notify', @updater.export_oddb_csv)
    end
    def test_export_oddb2_csv
      setup_csv_export_plugin
      assert_equal('notify', @updater.export_oddb2_csv)
    end
    def setup_xls_export_plugin
      flexstub(XlsExportPlugin) do |klass|
        klass.should_receive(:new).and_return(flexmock('xls') do |obj|
          obj.should_receive(:export_generics)
          obj.should_receive(:export_patents)
          obj.should_receive(:log_info).and_return(@recipients)
        end)
      end
    end
    def test_export_generics_xls
      setup_xls_export_plugin
      assert_equal('notify', @updater.export_generics_xls)
    end
    def test_export_patents_xls
      setup_xls_export_plugin
      assert_equal('notify', @updater.export_patents_xls) 
    end
    def test_export_ouwerkerk
      setup_exporter
      assert_equal('notify', @updater.export_ouwerkerk)
    end
    def setup_logfile
      flexstub(LogFile) do |log|
        log.should_receive(:read).and_return('report')
      end
    end
    def test_mail_logfile
      setup_logfile
      assert_equal('notify', @updater.mail_logfile('name', 'date', 'subject', ['emails']))
    end
    def test_mail_sponsor_logs
      setup_logfile
      sponsor = flexmock('sponsor') do |spr|
        spr.should_receive(:emails).and_return(['emails'])
      end
      flexstub(@app) do |app|
        app.should_receive(:sponsor).and_return(sponsor)
      end
      expected = {:generika=>"Exklusiv-Sponsoring Generika.cc", :gcc=>"Exklusiv-Sponsoring ODDB.org"}
      assert_equal(expected, @updater.mail_sponsor_logs)
    end
    def test__logfile_stats
      setup_logfile
      assert_equal({:powerlink=>"Powerlink-Statistics"}, @updater._logfile_stats('date'))
    end
    def test_logfile_stats
      setup_logfile
      @updater.instance_eval('@@today = Date.new(2011,1,1)')
      sponsor = flexmock('sponsor') do |spr|
        spr.should_receive(:emails).and_return(['emails'])
      end
      flexstub(@app) do |app|
        app.should_receive(:sponsor).and_return(sponsor)
      end
      expected = {:generika=>"Exklusiv-Sponsoring Generika.cc", :gcc=>"Exklusiv-Sponsoring ODDB.org"}
      assert_equal(expected, @updater.logfile_stats)
    end
    def setup_log_notify_bsv
      log = flexmock('log') do |log|
        log.should_receive(:change_flags).and_return({'ptr' => ['flgs']})
      end
      @plugin = flexmock('plugin') do |plg|
        plg.should_receive(:log_info).and_return(@recipients)
        plg.should_receive(:log_info_bsv).and_return(@recipients)
      end
      flexstub(Persistence::Pointer) do |klass|
        klass.should_receive(:new).and_return(flexmock('ptr') do |obj|
          obj.should_receive(:resolve).and_return(log)
          obj.should_receive(:creator)
          obj.should_receive(:+)
        end)
      end
    end
    def test_log_notify_bsv # test private method
      setup_log_notify_bsv
      @recipients[:change_flags] = {'ptr' => []}
      plugin = @plugin
      assert_equal('notify', @updater.instance_eval('log_notify_bsv(plugin, "date")'))
    end
    def test_log_notify_bsv__else_change_flags
      setup_log_notify_bsv
      @recipients[:change_flags] = {}
      plugin = @plugin
      assert_equal('notify', @updater.instance_eval('log_notify_bsv(plugin, "date")'))
    end
    def setup_bsv_xml_plugin
   #   @change_flags = {}
      flexstub(BsvXmlPlugin) do |klass|
        klass.should_receive(:new).and_return(flexmock('bsv') do |bsv|
          bsv.should_receive(:update).and_return('update')
          bsv.should_receive(:_update).and_return('_update')
          #bsv.should_receive(:change_flags).and_return(@change_flags)
          bsv.should_receive(:change_flags).and_return({})
          bsv.should_receive(:log_info).and_return(@recipients)
        end)
      end
    end
    def test_update_bsv
      setup_bsv_xml_plugin
      assert_equal('update', @updater.update_bsv)
    end
    def test_reconsider_bsv
      setup_log_notify_bsv
      setup_bsv_xml_plugin
      log = flexmock('log') do |log|
        log.should_receive(:change_flags).and_return({'ptr' => ['flgs']})
        log.should_receive(:pointer)
      end
      logs = flexmock('logs') do |logs|
        logs.should_receive(:newest_date).and_return(Date.new(2011,1,1))
        logs.should_receive(:latest).and_return(log)
      end
      flexstub(@app) do |app|
        app.should_receive(:create).and_return(logs)
        app.should_receive(:update)
      end
      assert_equal(logs, @updater.reconsider_bsv({:new_log => 'new_log'}))
    end
    def test_update_analysis
      flexstub(AnalysisPlugin) do |klass|
        klass.should_receive(:new).and_return(flexmock('ana') do |obj|
          obj.should_receive(:update).and_return('update')
        end)
      end
      assert_equal('update', @updater.update_analysis('path', 'lang'))
    end
	end
end
