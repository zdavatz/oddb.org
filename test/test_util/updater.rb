#!/usr/bin/env ruby
# TestUpdater -- oddb.org -- 22.02.2011 -- mhatakeyama@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'util/updater'
require 'stub/odba'
require 'flexmock'
require 'date'

module ODDB
  module Doctors
    class DoctorPlugin; end
  end
  module Interaction
    class InteractionPlugin; end
  end
  class MiGelPlugin; end
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
      expected = @updater.class::RECIPIENTS
      assert_equal(expected, @updater.recipients)
    end
    def test_log_info
      plugin = flexmock('plugin') do |plg|
        plg.should_receive(:log_info).and_return({})
      end
      expected = {:recipients => [] + @updater.class::RECIPIENTS}
      assert_equal(expected, @updater.log_info(plugin))
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
          obj.should_receive(:export_generics_xls)
          obj.should_receive(:mail_swissmedic_notifications)\
            .and_return('mail_swissmedic_notifications')
        end)
      end
    end
    def setup_xls_export_plugin
      flexstub(XlsExportPlugin) do |klass|
        klass.should_receive(:new).and_return(flexmock('xls') do |obj|
          obj.should_receive(:export_generics)
          obj.should_receive(:export_patents)
          obj.should_receive(:log_info).and_return(@recipients)
          obj.should_receive(:export_competition).and_return('path')
        end)
      end
    end
    def setup_export_competition_xls
      setup_exporter
      setup_xls_export_plugin
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
    def setup_logfile_stats
      setup_logfile
      @updater.instance_eval('@@today = Date.new(2011,1,1)')
      sponsor = flexmock('sponsor') do |spr|
        spr.should_receive(:emails).and_return(['emails'])
      end
      flexstub(@app) do |app|
        app.should_receive(:sponsor).and_return(sponsor)
      end
      expected = {:generika=>"Exklusiv-Sponsoring Generika.cc", :gcc=>"Exklusiv-Sponsoring ODDB.org"}
      yield
      @updater.instance_eval('@@today = Date.today')    # reset the @@today to the default value for the other test-cases
    end
    def test_logfile_stats
      setup_logfile_stats do
        expected = {:generika=>"Exklusiv-Sponsoring Generika.cc", :gcc=>"Exklusiv-Sponsoring ODDB.org"}
        assert_equal(expected, @updater.logfile_stats)
      end
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
      bsv = flexmock('bsv') do |bsv|
          bsv.should_receive(:update).and_return('update')
          bsv.should_receive(:_update).and_return('_update')
          bsv.should_receive(:change_flags).and_return({})
          bsv.should_receive(:log_info).and_return(@recipients)
      end
      flexstub(BsvXmlPlugin) do |klass|
        klass.should_receive(:new).and_return(bsv)
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
    def test_reconsider_bsv__change_flags
      setup_log_notify_bsv
      bsv = flexmock('bsv') do |bsv|
          bsv.should_receive(:update).and_return('update')
          bsv.should_receive(:_update).and_return('_update')
          bsv.should_receive(:change_flags).and_return({'ptr' => ['flgs']})
          bsv.should_receive(:log_info).and_return(@recipients)
      end
      flexstub(BsvXmlPlugin) do |klass|
        klass.should_receive(:new).and_return(bsv)
      end

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
    def test_update_immediate   # update_immediate is a private method
      plugin = flexmock('plugin') do |plg|
        plg.should_receive(:update)
        plg.should_receive(:log_info).and_return({})
      end
      klass = flexmock('klass') do |klass|
        klass.should_receive(:new).and_return(plugin)
      end
      assert_equal('notify', @updater.instance_eval("update_immediate(klass, 'subject')"))
    end
    def test_update_immediate__error
      klass = flexmock('klass') do |klass|
        klass.should_receive(:new).and_raise(StandardError)
      end
      assert_equal('notify', @updater.instance_eval("update_immediate(klass, 'subject')"))
    end
    def setup_update_immediate(klass, method=:update)
      plugin = flexmock('plugin') do |plg|
        plg.should_receive(method)
        plg.should_receive(:log_info).and_return({})
      end
      flexmock(klass) do |klass|
        klass.should_receive(:new).and_return(plugin)
      end
    end
    def test_update_notify_simple # update_notify_simple is a private method
      plugin = flexmock('plugin') do |plg|
        plg.should_receive(:update).and_return(true)
        plg.should_receive(:log_info).and_return({})
      end
      klass = flexmock('klass') do |klass|
        klass.should_receive(:new).and_return(plugin)
      end
      assert_equal('notify', @updater.instance_eval("update_notify_simple(klass, 'subject')"))
    end
    def setup_update_notify_simple(klass, *methods)
      plugin = flexmock('plugin') do |plg|
        plg.should_receive(:update).and_return(true)
        methods.each do |method|
          plg.should_receive(method).and_return(true)
        end
        plg.should_receive(:log_info).and_return({})
      end
      flexmock(klass) do |klass|
        klass.should_receive(:new).and_return(plugin)
      end
    end
    def test_update_simple  # update_simple is a private method
      plugin = flexmock('plugin') do |plg|
        plg.should_receive(:update)
        plg.should_receive(:log_info).and_return({})
      end
      klass = flexmock('klass') do |klass|
        klass.should_receive(:new).and_return(plugin)
      end
      assert_equal('notify', @updater.instance_eval("update_simple(klass, 'subject')"))
    end
    def setup_update_simple(klass)
      plugin = flexmock('plugin') do |plg|
        plg.should_receive(:update)
        plg.should_receive(:log_info).and_return({})
      end
      flexmock(klass) do |klass|
        klass.should_receive(:new).and_return(plugin)
      end
    end
    def test_update_comarketing
      setup_update_simple(CoMarketingPlugin)
      assert_equal('notify', @updater.update_comarketing)
    end
    def test_update_company_textinfos
      setup_update_notify_simple(TextInfoPlugin, :import_company)
      assert_equal('notify', @updater.update_company_textinfos)
    end
    def test_update_textinfo_news
      setup_update_notify_simple(TextInfoPlugin, :import_news)
      assert_equal('notify', @updater.update_textinfo_news)
    end
    def test_update_textinfos
      setup_update_notify_simple(TextInfoPlugin, :import_fulltext)
      assert_equal('notify', @updater.update_textinfos)
    end
    def test_update_fachinfo
      setup_update_notify_simple(TextInfoPlugin, :import_news)
      assert_equal('notify', @updater.update_fachinfo)
    end
    def test_update_fachinfo__iksnrs
      setup_update_notify_simple(TextInfoPlugin, :import_fulltext)
      assert_equal('notify', @updater.update_fachinfo(123))
    end
    def test_run_random
      setup_update_notify_simple(TextInfoPlugin, :import_news)
      assert_equal('notify', @updater.run_random)
    end
    def test_update_doctors
      setup_update_simple(ODDB::Doctors::DoctorPlugin)
      assert_equal('notify', @updater.update_doctors)
    end
    def test_update_hospitals
      setup_update_simple(HospitalPlugin)
      assert_equal('notify', @updater.update_hospitals)
    end
    def test_update_interactions
      setup_update_simple(ODDB::Interaction::InteractionPlugin)
      assert_equal('notify', @updater.update_interactions)
    end
    def test_update_lppv
      setup_update_immediate(LppvPlugin)
      assert_equal('notify', @updater.update_lppv)
    end
    def test_update_medwin_companies
      setup_update_simple(MedwinCompanyPlugin)
      assert_equal('notify', @updater.update_medwin_companies)
    end
    def test_update_medwin_packages
      setup_update_simple(MedwinPackagePlugin)
      assert_equal('notify', @updater.update_medwin_packages)
    end
    def test_update_price_feeds
      flexstub(RssPlugin) do |klass|
        klass.should_receive(:new).and_return(flexmock('rss') do |obj|
          obj.should_receive(:update_price_feeds).and_return('update_price_feeds')
        end)
      end
      assert_equal('update_price_feeds', @updater.update_price_feeds)
    end
    def test_update_trade_status
      setup_update_immediate(MedwinPackagePlugin)
      assert_equal('notify', @updater.update_trade_status)
    end
    def test_update_migel
      flexstub(MiGeLPlugin) do |klass|
        klass.should_receive(:new).and_return(flexmock('mig') do |obj|
          obj.should_receive(:update)
          obj.should_receive(:prune_old_revisions)
        end)
      end
      expected = "MiGeL is now up to date"
      assert_equal(expected, @updater.update_migel)
    end
    def test_update_narcotics
      setup_update_notify_simple(NarcoticPlugin)
      assert_equal('notify', @updater.update_narcotics)
    end
    def setup_update_swissmedic
      flexstub(SwissmedicPlugin) do |klass|
        klass.should_receive(:new).and_return(flexmock('swm') do |obj|
          obj.should_receive(:update).and_return('update')
          obj.should_receive(:log_info).and_return({})
        end)
      end
      pointer = flexmock('pointer') do |ptr|
        ptr.should_receive(:creator)
      end
      flexstub(pointer) do |ptr|
        ptr.should_receive(:+).and_return(pointer)
      end
      logs = flexmock('logs') do |logs|
        logs.should_receive(:pointer).and_return(pointer)
      end
      log = flexmock('log') do |log|
        log.should_receive(:notify)
      end
      flexstub(@app) do |app|
        app.should_receive(:create).and_return(logs)
        app.should_receive(:update).and_return(log)
      end
    end
    def test_update_swissmedic
      setup_update_swissmedic
      assert_equal('update', @updater.update_swissmedic)
    end
    def setup_update_swissmedicjournal
      pointer = flexmock('pointer') do |ptr|
        ptr.should_receive(:creator)
      end
      flexstub(pointer) do |ptr|
        ptr.should_receive(:+).and_return(pointer)
      end
      logs = flexmock('logs') do |logs|
        logs.should_receive(:newest_date).and_return(Date.today << 1)
        logs.should_receive(:pointer).and_return(pointer)
      end
      log = flexmock('log') do |log|
        log.should_receive(:notify)
      end
      flexstub(@app) do |app|
        app.should_receive(:create).and_return(logs)
        app.should_receive(:log_group).and_return(logs)
        app.should_receive(:update).and_return(log)
      end
      flexstub(SwissmedicJournalPlugin) do |klass|
        klass.should_receive(:new).and_return(flexmock('sjp') do |obj|
          obj.should_receive(:update).and_return('update')
          obj.should_receive(:log_info).and_return({})
        end)
      end
    end
    def test_update_swissmedicjournal
      setup_update_swissmedicjournal
      expected = Date.today
      assert_equal(expected, @updater.update_swissmedicjournal)
    end
    def test_update_swissreg
      setup_update_immediate(SwissregPlugin)
      assert_equal('notify', @updater.update_swissreg)
    end
    def test_update_swissreg_news
      setup_update_immediate(SwissregPlugin, :update_news)
      assert_equal('notify', @updater.update_swissreg_news)
    end
    def test_update_vaccines
      setup_update_notify_simple(VaccinePlugin)
      assert_equal('notify', @updater.update_vaccines)
    end
    def test_update_whocc
      setup_update_notify_simple(WhoPlugin, :import)
      assert_equal('notify', @updater.update_whocc)
    end
    def setup_update_bsv_followers
      setup_update_immediate(MedwinPackagePlugin) # for update_trade_status
      setup_update_simple(MedwinPackagePlugin)    # for update_medwin_packages
      setup_update_immediate(LppvPlugin)          # for update_lppv
      flexstub(RssPlugin) do |klass|              # for update_price_feeds
        klass.should_receive(:new).and_return(flexmock('rss') do |obj|
          obj.should_receive(:update_price_feeds).and_return('update_price_feeds')
        end)
      end
      setup_csv_export_plugin                     # for export_oddb_csv
      setup_exporter                              # for export_ouwerkerk
      setup_xls_export_plugin                     # for export_generics_xls
      setup_export_competition_xls                # for export_competition_xlss
      flexstub(@app) do |app|
        app.should_receive(:companies).and_return({'key' => @company})
      end
    end
    def test_update_bsv_followers
      setup_update_bsv_followers
      expected = {'key' => @company}  # the return value of export_competition_xlss
      assert_equal(expected, @updater.update_bsv_followers)
    end
    def setup_update_swissmedic_followers
      setup_update_immediate(MedwinPackagePlugin) # for update_trade_status
      setup_update_simple(MedwinPackagePlugin)    # for update_medwin_packages
      setup_log_notify_bsv                        # for reconsider_bsv
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
      setup_update_simple(CoMarketingPlugin)      # for update_comarketing
      setup_update_immediate(SwissregPlugin, :update_news) # for update_swissreg_news
      setup_update_immediate(LppvPlugin)          # for update_lppv
      setup_update_simple(MedwinCompanyPlugin)
      setup_exporter                              # for Exporter
      setup_xls_export_plugin                     # for export_patents_xls
    end
    def test_update_swissmedic_followers
      setup_update_swissmedic_followers
      expected = 'mail_swissmedic_notifications'  # the return value of 
                                                  # Exporter#mail_swissmedic_notifications
      assert_equal(expected, @updater.update_swissmedic_followers)
    end
    def test_run
      logs = flexmock('logs') do |logs|
        logs.should_receive(:newest_date).and_return(Date.new(2011,1,1))
      end
      flexstub(@app) do |app|
        app.should_receive(:create).and_return(logs)
      end
      setup_logfile_stats do                      # for logfile_stats
        setup_update_swissmedic                   # for update_swissmedic
        setup_update_swissmedic_followers         # for update_swissmedic_followers
        setup_update_swissmedicjournal            # for update_swissmedicjournals
        setup_update_notify_simple(VaccinePlugin) # for update_vaccines
        setup_bsv_xml_plugin                      # for update_bsv
        setup_update_bsv_followers                # for update_bsv_followers
        setup_update_notify_simple(NarcoticPlugin)# for update_narcotics
        setup_update_simple(ODDB::Interaction::InteractionPlugin) # for update_interactions

        assert_equal('notify', @updater.run)
      end
    end
  end
end
