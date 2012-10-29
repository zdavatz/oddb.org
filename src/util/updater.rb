#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Updater-- oddb.org -- 29.10.2012 -- yasaka@ywesee.com
# ODDB::Updater-- oddb.org -- 10.02.2012 -- mhatakeyama@ywesee.com
# ODDB::Updater-- oddb.org -- 12.01.2012 -- zdavatz@ywesee.com
# ODDB::Updater-- oddb.org -- 19.02.2003 -- hwyss@ywesee.com

require 'plugin/analysis'
require 'plugin/bsv_xml'
require 'plugin/comarketing'
require 'plugin/doctors'
require 'plugin/dosing'
require 'plugin/drugbank'
require 'plugin/divisibility'
require 'plugin/hospitals'
require 'plugin/interaction'
require 'plugin/lppv'
require 'plugin/medwin'
require 'plugin/narcotic'
require 'plugin/ouwerkerk'
require 'plugin/rss'
require 'plugin/swissmedic'
require 'plugin/swissmedicjournal'
require 'plugin/swissreg'
require 'plugin/text_info'
require 'plugin/vaccines'
require 'plugin/who'
require 'util/log'
require 'util/persistence'
require 'util/exporter'
require 'ext/meddata/src/ean_factory'
require 'util/schedule'
require 'plugin/swissindex'
require 'plugin/mail_order_price'
require 'util/oddbconfig'

module ODDB
	class Updater
    include Util::Schedule
		# Recipients for all Update-Logs go here...
		RECIPIENTS = []
		LOG_RECIPIENTS = {
			# :powerlink					=>	[], ## Disabled 2.3.2009, there are no Powerlink-Users at the current time
			:passthru						=>	[],
		}
		LOG_FILES = {
			:powerlink				=>	'Powerlink-Statistics',
			#:passthru				=>	'Banner-Clicks',
    }
    SPONSORS = {
      :generika	=>	'Exklusiv-Sponsoring Generika.cc',
      :gcc			=>	'Exklusiv-Sponsoring ODDB.org',
    }
		def initialize(app)
			@app = app
			@smj_updated = false
		end
		def export_competition_xls(company, db_path=nil)
			subj = "Generika-Preisvergleich #{company.name}"
			wrap_update(XlsExportPlugin, subj) {
				plug = Exporter.new(@app).export_competition_xls(company, db_path)
				log = Log.new(@@today)
				log.update_values(log_info(plug))
				log.notify(subj)
			}
			plug = XlsExportPlugin.new(@app)
			path = plug.export_competition(company)
		end
		def export_competition_xlss(db_path=nil)
			@app.companies.each_value { |comp|
				if(comp.competition_email)
					export_competition_xls(comp, db_path)
				end
			}
		end
    def export_index_therapeuticus_csv(date = @@today)
      subj = 'index_therapeuticus.csv'
      wrap_update(CsvExportPlugin, subj) {
        plug = CsvExportPlugin.new(@app)
        plug.export_index_therapeuticus
        log = Log.new(date)
        log.update_values(log_info(plug))
        log.notify(subj)
      }
    end
    def export_oddb_csv(date = @@today)
      subj = 'oddb.csv'
      wrap_update(CsvExportPlugin, subj) {
        plug = CsvExportPlugin.new(@app)
        plug.export_drugs
        log = Log.new(date)
        log.update_values(log_info(plug))
        log.notify(subj)
      }
    end
    def export_oddb2_csv(date = @@today)
      subj = 'oddb2.csv'
      wrap_update(CsvExportPlugin, subj) {
        plug = CsvExportPlugin.new(@app)
        plug.export_drugs_extended
        log = Log.new(date)
        log.update_values(log_info(plug))
        log.notify(subj)
      }
    end
    def export_oddb2tdat
      Exporter.new(@app).export_oddb2tdat
    end
    def export_oddb2tdat_with_migel
      # use csv in migel/data/csv
      Exporter.new(@app).export_oddb2tdat_with_migel
    end
		def export_generics_xls(date = @@today)
			subj = 'Generikaliste'
			wrap_update(XlsExportPlugin, subj) {
        plug = XlsExportPlugin.new(@app)
        plug.export_generics
				log = Log.new(date)
				log.update_values(log_info(plug))
				log.notify(subj)
			}
		end
		def export_patents_xls(date = @@today)
			subj = 'Export patents.xls'
			wrap_update(XlsExportPlugin, subj) {
        plug = XlsExportPlugin.new(@app)
        plug.export_patents
				log = Log.new(date)
				log.update_values(log_info(plug))
				log.notify(subj)
			}
		end
		def export_ouwerkerk(date = @@today)
			subj = 'Med-Drugs'
			wrap_update(OuwerkerkPlugin, subj) {
				plug = Exporter.new(@app).export_swissdrug_xls date,
                                                       :remove_newlines => true
				log = Log.new(date)
				log.update_values(log_info(plug))
				log.notify(subj)
			}
		end
		def log_info(plugin, method=:log_info)
			hash = plugin.send(method)
			hash[:recipients] = if(rcp = hash[:recipients])
				rcp + recipients
			else
				recipients
			end
			hash
		end
		def mail_logfile(name, date, subj, emails=nil)
      report = LogFile.read(name, date)
      unless report.empty?
        log = Log.new(date)
        log.report = report
        mails = (emails || self::class::LOG_RECIPIENTS[name] || [])
        log.recipients = recipients + mails
        log.notify(subj)
      end
		end
    def mail_sponsor_logs(date=@@today)
      self::class::SPONSORS.each { |name, subj|
        if sponsor = @app.sponsor(name)
				  mail_logfile("sponsor_#{name}", date, subj, sponsor.emails)
        end
      }
    end
		def logfile_stats
			date = @@today << 1
			if(date.day == 1)
				_logfile_stats(date)
        mail_sponsor_logs(date)
			end
		end
		def _logfile_stats(date)
			self::class::LOG_FILES.each { |name, subj|
				mail_logfile(name, date, subj)
			}
		end
		def recipients
			self.class::RECIPIENTS
		end
		def run
			logfile_stats
      update_recall_feeds
      update_textinfo_news
			if(update_swissmedic)
        update_swissmedic_followers
      end
      return_value_update_bsv = update_bsv
      LogFile.append('oddb/debug', " return_value_update_bsv=" + return_value_update_bsv.inspect.to_s, Time.now)
			#if(update_bsv)
			if(return_value_update_bsv)
        update_bsv_followers
			end
      run_on_monthday(1) {
        update_interactions
      }
		end
    def run_random
      # no task
    end
		def update_analysis
			klass = AnalysisPlugin
			subj = 'Analysis'
			wrap_update(klass, subj) {
				plug = klass.new(@app)
				plug.update
			}
		end
    def update_atc_dosing_link
      update_notify_simple(DosingPlugin, 'ATC Class (dosing.de)', :update_ni_id)
    end
    def update_atc_drugbank_link
      update_notify_simple(DrugbankPlugin, 'ATC Class (drugbank.ca)', :update_db_id)
    end
		def update_bsv

      LogFile.append('oddb/debug', " getin update_bsv", Time.now)

      sl_errors_dir = File.expand_path("doc/sl_errors/#{@@today.year}/#{"%02d" % @@today.month.to_i}", ODDB::PROJECT_ROOT)
      sl_error_file = File.join(sl_errors_dir, 'bag_xml_swissindex_pharmacode_error.log')
      if File.exist?(sl_error_file)
        FileUtils.rm sl_error_file
      end
			logs_pointer = Persistence::Pointer.new([:log_group, :bsv_sl])
			logs = @app.create(logs_pointer)
			this_month = Date.new(@@today.year, @@today.month)
      if (latest = logs.newest_date) && latest > this_month
        this_month = latest
      end
			klass = BsvXmlPlugin
			plug = klass.new(@app)
			subj = 'SL-Update (XML)'
            return_value_plug_update = nil
			wrap_update(klass, subj) {

        return_value_plug_update = plug.update
        LogFile.append('oddb/debug', " return_value_BsvXmlPlugin.update = " + return_value_plug_update.inspect.to_s, Time.now)

				#if plug.update
				if return_value_plug_update
					log_notify_bsv(plug, this_month, subj)
				end
			}
            return return_value_plug_update
		end
    def update_bsv_followers

      LogFile.append('oddb/debug', " getin update_bsv_followers", Time.now)

      update_package_trade_status_by_swissindex
      update_lppv
      update_price_feeds
      export_oddb_csv
      export_oddb2_csv
      export_oddb2tdat
      export_oddb2tdat_with_migel
      export_ouwerkerk
      export_generics_xls
      export_competition_xlss
    end
    def update_comarketing
      update_immediate(CoMarketingPlugin, 'Co-Marketing')
    end
    def update_company_textinfos *companies
      update_notify_simple TextInfoPlugin,
                           "Fach- und Patienteninfo '#{companies.join(', ')}'",
                           :import_company, [companies]
    end
    def update_company_textinfos2 *companies
      update_notify_simple TextInfoPlugin,
                           "Fach- und Patienteninfo2 '#{companies.join(', ')}'",
                           :import_company2, [companies]
    end
    def update_teilbarkeit(path)
      update_notify_simple DivisibilityPlugin,
                           "Teilbarkeit (CSV)",
                           :update_from_csv, [path]
    end
    def update_textinfo_news
      update_notify_simple TextInfoPlugin,
                           "Fach- und Patienteninfo News",
                           :import_news
    end
		def update_doctors
			update_simple(Doctors::DoctorPlugin, 'Doctors')
		end
    def update_fachinfo(*iksnrs)
      update_textinfos *iksnrs
    end
    def update_patinfo_only *companies
      update_notify_simple TextInfoPlugin,
                           "Patienteninfo '#{companies.join(', ')}'",
                           :import_company, [companies, nil, :pi]
    end
		def update_hospitals
			update_simple(HospitalPlugin, 'Hospitals')
		end
		def update_interactions
			update_simple(Interaction::InteractionPlugin, 'Interaktionen')
		end
		def update_lppv
			update_immediate(LppvPlugin, 'Lppv prices')
		end
		def update_medwin_companies
			update_simple(MedwinCompanyPlugin, 'Medwin-Companies')
		end
    def update_price_feeds(month = @@today)
      RssPlugin.new(@app).update_price_feeds(month)
    end
    def update_recall_feeds(month = @@today)
      subj = 'recall.rss'
      wrap_update(RssPlugin, subj) {
        plug = RssPlugin.new(@app)
        plug.update_recall_feeds(month)
        log = Log.new(@@today)
        log.update_values(log_info(plug))
        log.notify(subj)
      }
    end
		def update_trade_status
			update_immediate(MedwinPackagePlugin, 'Trade-Status', :update_trade_status)
		end
    def update_btm(path)
      update_notify_simple(NarcoticPlugin, 'Narcotics (XLS)', :update_from_xls, [path])
    end
    def update_swissmedic(*args)
      logs_pointer = Persistence::Pointer.new([:log_group, :swissmedic])
      logs = @app.create(logs_pointer)
      klass = SwissmedicPlugin
      plug = klass.new(@app)
      return_value_plug_update = nil
      wrap_update(klass, "swissmedic") {
        #if(plug.update(*args))
        if(return_value_plug_update = plug.update(*args))
          month = @@today << 1
          pointer = logs.pointer + [:log, Date.new(month.year, month.month)]
          log = @app.update(pointer.creator, log_info(plug))
          log.notify('Swissmedic XLS')
        end
      }
      return return_value_plug_update
    end
    def update_swissmedic_followers
			# update_trade_status # replaced by swissINDEX
      update_package_trade_status_by_swissindex
      update_comarketing
			update_swissreg_news
      update_lppv
      update_medwin_companies
			exporter = Exporter.new(@app)
			exporter.export_generics_xls
      export_patents_xls
      exporter.mail_swissmedic_notifications
    end
		def update_swissreg
			update_immediate(SwissregPlugin, 'Patents')
		end
		def update_swissreg_news
			update_immediate(SwissregPlugin, 'Patents', :update_news)
		end
    def update_textinfos *iksnrs
      update_notify_simple TextInfoPlugin,
                           "Fach- und Patienteninfo '#{iksnrs.join(', ')}'",
                           :import_fulltext, [iksnrs]
    end
    def update_whocc
      update_notify_simple WhoPlugin, "WHO-Update", :import
    end
    def update_package_trade_status_by_swissindex(logging = false)
			update_notify_simple(SwissindexPharmaPlugin, 'Swissindex Pharma', :update_package_trade_status, [logging])
    end
    def migel_nonpharma(pharmacode_file, logging = false)
      update_notify_simple(SwissindexNonpharmaPlugin, 'Swissindex Migel Nonpharma', :migel_nonpharma, [pharmacode_file, logging])
    end
    def update_mail_order_prices(csv_file_path)
      update_notify_simple(MailOrderPricePlugin, 'Update Mail Order Prices', :update, [csv_file_path])
    end

		private
		def log_notify_bsv(plug, date, subj='SL-Update')

      LogFile.append('oddb/debug', " getin log_notify_bsv", Time.now)
      LogFile.append('oddb/debug', " date=" + date.inspect.to_s, Time.now)

			pointer = Persistence::Pointer.new([:log_group, :bsv_sl], [:log, date])
      LogFile.append('oddb/debug', " after pointer creating", Time.now)
			values = log_info(plug)
      LogFile.append('oddb/debug', " after log_info(plug)", Time.now)
      if log = pointer.resolve(@app)
        change_flags = values[:change_flags]
        if previous = log.change_flags
          previous.each do |ptr, flgs|
            if flags = change_flags[ptr]
              flags.concat flgs
              flags.uniq!
            else
              change_flags[ptr] = flgs
            end
          end
        end
      end
      LogFile.append('oddb/debug', " before @app.update", Time.now)
			log = @app.update(pointer.creator, values)

      LogFile.append('oddb/debug', " after @app.update", Time.now)
			#log.notify(subj)
      return_value_log_notify = log.notify(subj)
      LogFile.append('oddb/debug', " the first log.notify end", Time.now)
      LogFile.append('oddb/debug', " return_value_log_notify = " + return_value_log_notify.inspect.to_s, Time.now)

      log2 = Log.new(date)
      log2.update_values log_info(plug, :log_info_bsv)

      LogFile.append('oddb/debug', " before the second mail process", Time.now)
      return_value_log2_notify = log2.notify(subj)
      LogFile.append('oddb/debug', " the second log.notify end", Time.now)
      LogFile.append('oddb/debug', " return_value_log2_notify = " + return_value_log2_notify.inspect.to_s, Time.now)
      #log2.notify(subj)
      return_value_log2_notify
		end
		def notify_error(klass, subj, error)
			log = Log.new(@@today)
			log.report = [
				"Plugin: #{klass}",
				"Error: #{error.class}",
				"Message: #{error.message}",
				"Backtrace:",
				error.backtrace.join("\n"),
			].join("\n")
			log.recipients = RECIPIENTS.dup
			log.notify("Error: #{subj}")
		end
		def wrap_update(klass, subj, &block)
      begin
        block.call
      rescue Exception => e #RuntimeError, StandardError => e
        notify_error(klass, subj, e)
        raise
      end
		rescue StandardError
			nil
		end
		def update_immediate(klass, subj, update_method=:update)
			plug = klass.new(@app)
			plug.send(update_method)
			log = Log.new(@@today)
			log.update_values(log_info(plug))
			log.notify(subj)
		rescue StandardError => e #RuntimeError, StandardError => e
			notify_error(klass, subj, e)
		end
		def update_notify_simple(klass, subj, update_method=:update, args=[])
			wrap_update(klass, subj) {
				plug = klass.new(@app)
				if(plug.send(update_method, *args))
					log = Log.new(@@today)
					log.update_values(log_info(plug))
					log.notify(subj)
				end
			}
		end
		def update_simple(klass, subj, *update_method)
      if(update_method.empty?)
        update_method.push(:update)
      end
			wrap_update(klass, subj) {
				plug = klass.new(@app)
				plug.send(*update_method)
				log = Log.new(@@today)
				log.update_values(log_info(plug))
				log.notify(subj)
			}
		end
	end
end
