
#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Updater-- oddb.org -- 16.04.2013 -- yasaka@ywesee.com
# ODDB::Updater-- oddb.org -- 10.02.2012 -- mhatakeyama@ywesee.com
# ODDB::Updater-- oddb.org -- 12.01.2012 -- zdavatz@ywesee.com
# ODDB::Updater-- oddb.org -- 19.02.2003 -- hwyss@ywesee.com

require 'plugin/atc_less'
require 'plugin/bsv_xml'
require 'plugin/comarketing'
require 'plugin/doctors'
require 'plugin/refdata_jur'
require 'plugin/refdata_nat'
require 'plugin/dosing'
require 'plugin/drugbank'
require 'plugin/divisibility'
require 'plugin/epha_interactions'
require 'plugin/lppv'
require 'plugin/medical_products'
require 'plugin/ouwerkerk'
require 'plugin/rss'
require 'plugin/swissmedic'
require 'plugin/swissmedicjournal'
require 'plugin/swissreg'
require 'plugin/shortage'
require 'plugin/text_info'
require 'plugin/who'
require 'util/log'
require 'util/persistence'
require 'util/exporter'
require 'ext/meddata/src/ean_factory'
require 'util/schedule'
require 'plugin/refdata'
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
    }
    SPONSORS = {
      :generika	=>	'Exklusiv-Sponsoring Generika.cc',
      :gcc			=>	'Exklusiv-Sponsoring ODDB.org',
    }
    def initialize(app)
      ENV['LANG'] ||= "de_CH.UTF-8"
      ENV['LANGUAGE'] ||= "de_CH.UTF-8"
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
    def export_ddd_csv(date = @@today)
      subj = 'ddd.csv'
      wrap_update(CsvExportPlugin, subj) {
        plug = CsvExportPlugin.new(@app)
        plug.export_ddd_csv
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
    def run(opts)
      unless opts[:patinfo_only]
        logfile_stats
        update_epha_interactions

        # drugshortage
        update_drugshortage

        # recall, hpc
        update_swissmedic_feeds

        # textinfo
        update_textinfo_swissmedicinfo({:target => :fi, :newest => true})
        GC.start
        sleep(10) unless defined?(Minitest)
      end
      update_textinfo_swissmedicinfo({:target => :pi, :newest => true})
    end
    def run_random
      # no task
    end
    def update_atc_dosing_link
      update_notify_simple(DosingPlugin, 'ATC Class (dosing.de)', :update_ni_id)
    end
    def update_atc_drugbank_link
      update_notify_simple(DrugbankPlugin, 'ATC Class (drugbank.ca)', :update_db_id)
    end
    def update_refdata_jur(opts = nil)
      LogFile.append('oddb/debug', " update refdata jur opts #{opts.inspect}", Time.now)
      klass = ODDB::Companies::RefdataJurPlugin
      subj = 'companies (Refdata)'
      wrap_update(klass, subj) {
        plug = klass.new(@app, opts)
        plug.update
        return if plug.report.empty?
        log = Log.new(@@today)
        log.update_values(log_info(plug))
        log.notify(subj)
      }
    end
    def update_refdata_nat(opts = nil)
      LogFile.append('oddb/debug', " update refdata nat opts #{opts.inspect}", Time.now)
      klass = ODDB::Doctors::RefdataNatPlugin
      subj = 'doctors (Refdata)'
      wrap_update(klass, subj) {
        plug = klass.new(@app, opts)
        plug.update
        return if plug.report.empty?
        log = Log.new(@@today)
        log.update_values(log_info(plug))
        log.notify(subj)
      }
    end
    def update_bsv
      logs_pointer = Persistence::Pointer.new([:log_group, :bsv_sl])

      LogFile.append('oddb/debug', " getting update_bsv #{logs_pointer.class}", Time.now)

      sl_errors_dir = File.expand_path("doc/sl_errors/#{@@today.year}/#{"%02d" % @@today.month.to_i}", ODDB::PROJECT_ROOT)
      sl_error_file = File.join(sl_errors_dir, 'bag_xml_swissindex_pharmacode_error.log')
      if File.exist?(sl_error_file)
        FileUtils.rm sl_error_file
      end
      logs = @app.create(logs_pointer)
      this_month = Date.new(@@today.year, @@today.month)
      if (latest = logs.newest_date) && latest > this_month
        this_month = latest
      end
      date_pointer = Persistence::Pointer.new([:log_group, :bsv_sl], [:log, this_month])
      LogFile.append('oddb/debug', " getting update_bsv date_pointer #{date_pointer.class}", Time.now)
      klass = BsvXmlPlugin
      plug = klass.new(@app)
      subj = 'SL-Update (XML)'
      return_value_plug_update = nil
      wrap_update(klass, subj) {

        return_value_plug_update = plug.update
        LogFile.append('oddb/debug', " return_value_BsvXmlPlugin.update = " + return_value_plug_update.inspect.to_s, Time.now)

        #if plug.update
        if return_value_plug_update
          log_notify_bsv(plug, this_month, subj, date_pointer)
        end
      }
      return return_value_plug_update
    end
    def update_bsv_followers

      LogFile.append('oddb/debug', " getting update_bsv_followers", Time.now)

      update_package_trade_status_by_refdata
      # update_lppv
      update_price_feeds
      #export_oddb_csv
      #export_oddb2_csv
      # oddb2tdat no more needed as defined by Zeno on May 19, 2014
      # export_oddb2tdat
      # export_oddb2tdat_with_migel
      export_ouwerkerk
      #export_competition_xlss
      #export_generics_xls
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
      saved_options = @options
      @options = {:reparse => true}
      update_notify_simple TextInfoPlugin,
                            "Fach- und Patienteninfo2 '#{companies.join(', ')}'",
                            :import_company2, [companies]
      @options = saved_options
    end
    def update_teilbarkeit(path)
      update_notify_simple DivisibilityPlugin,
                            "Teilbarkeit (CSV)",
                            :update_from_csv, [path]
    end
    def update_textinfo_swissmedicinfo(opts=nil)
      @options = opts
      update_notify_simple TextInfoPlugin,
                            "Fach- und Patienteninfo Updates (swissmedicinfo.ch)",
                            :import_swissmedicinfo
    end
    def update_drugshortage(opts=nil)
      @options = opts
      subj = 'drugshortage.ch'
      # update_immediate_with_error_report(ShortagePlugin, )
      wrap_update(ShortagePlugin, subj) {
        plug = ShortagePlugin.new(@app, @options)
        plug.update
        return if plug.report.empty?
        log = Log.new(plug.date)
        log.update_values(log_info(plug))
        log.notify(subj)
      }
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
    def update_medical_products(opts)
      @options = opts
      update_notify_simple(MedicalProductPlugin, 'Medical Products', :update)
    end
    def update_epha_interactions
      update_immediate_with_error_report(EphaInteractionPlugin, 'EPHA interactions')
    end
    def update_lppv
      update_immediate(LppvPlugin, 'Lppv')
    end
    def update_price_feeds(month = @@today)
      RssPlugin.new(@app).update_price_feeds(month)
    end
    def update_swissmedic_feeds(month = @@today)
      update_recall_feed(month)
      update_hpc_feed(month)
    end
    def update_recall_feed(month = @@today)
      update_immediate_with_error_report(RssPlugin, 'recall.rss', :update_recall_feed)
    end
    def update_hpc_feed(month = @@today)
      update_immediate_with_error_report(RssPlugin, 'hpc.rss', :update_hpc_feed)
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
    def update_atc_less
      update_immediate(Atc_lessPlugin, 'ATC-less', :update_atc_codes)
    end
    def update_swissmedic_followers
      update_atc_less
      update_package_trade_status_by_refdata
      update_comarketing
      update_swissreg_news
      # update_lppv # as per May 2019 LPPV.ch does not provide an XLSX file anymore.
      update_refdata_jur
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
      @options = {}
      update_notify_simple TextInfoPlugin,
                            "Fach- und Patienteninfo '#{iksnrs.join(', ')}'",
                            :import_fulltext, [iksnrs]
    end
    def update_whocc
      update_notify_simple WhoPlugin, "WHO-Update", :import
    end
    def update_package_trade_status_by_refdata(logging = false)
      update_notify_simple(RefdataPlugin, 'Refdata', :update_package_trade_status, [logging])
    end
    def update_mail_order_prices(csv_file_path)
      update_notify_simple(MailOrderPricePlugin, 'Update Mail Order Prices', :update, [csv_file_path])
    end

    private
    def log_notify_bsv(plug, date, subj, pointer)
      LogFile.append('oddb/debug', " getting log_notify_bsv", Time.now)
      LogFile.append('oddb/debug', " date=" + date.inspect.to_s, Time.now)
      values = log_info(plug)
      LogFile.append('oddb/debug', " after log_info(plug)", Time.now)
      if !@prevalence && !defined?(Minitest)
        @prevalence = ODBA.cache.fetch_named('oddbapp', self) {OddbPrevalence.new}
      end
      if log = @prevalence ? pointer.resolve(@prevalence) :  OpenStruct.new
        change_flags = values[:change_flags]
        if previous = log.change_flags
          previous.each do |ptr, flgs|
            # It seems like a bug caused nil key to be saved, it's fixed but we have to remove the existing nil key from the database
            # https://github.com/zdavatz/oddb.org/issues/175
            if !ptr.nil?
              if flags = change_flags[ptr]
                flags.concat flgs
                flags.uniq!
              else
                change_flags[ptr] = flgs
              end
            end
          end
        end
      end
      LogFile.append('oddb/debug', " before @app.update @prevalence #{@prevalence.class}", Time.now)
      log = @app.update(pointer.creator, values)

      LogFile.append('oddb/debug', " after @app.update", Time.now)
      return_value_log_notify = log.notify(subj)
      LogFile.append('oddb/debug', " the first log.notify end", Time.now)
      LogFile.append('oddb/debug', " return_value_log_notify = " + return_value_log_notify.inspect.to_s, Time.now)

      log2 = Log.new(date)
      log2.update_values log_info(plug, :log_info_bsv)

      LogFile.append('oddb/debug', " before the second mail process", Time.now)
      return_value_log2_notify = log2.notify(subj)
      LogFile.append('oddb/debug', " the second log.notify end", Time.now)
      LogFile.append('oddb/debug', " return_value_log2_notify = " + return_value_log2_notify.inspect.to_s, Time.now)
      return_value_log2_notify
    end
    def notify_error(klass, subj, error)
      log = Log.new(@@today)
      mem_error = klass.get_memory_error if klass.respond_to?(:get_memory_error)
      msg ||= ' '
      log.report = [
        "Plugin: #{klass}",
        msg,
        "Error: #{error.class}",
        "Message: #{error.message}",
        "Backtrace:",
        error.backtrace.join("\n"),
      ].compact.join("\n")
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
      LogFile.append('oddb/debug', "update_immediate #{subj}", Time.now)
      plug = klass.new(@app)
      plug.send(update_method)
      log = Log.new(@@today)
      log.update_values(log_info(plug))
      log.notify(subj)
    rescue StandardError => e #RuntimeError, StandardError => e
      notify_error(klass, subj, e)
    end
    def update_immediate_with_error_report(klass, subj, update_method=:update)
      LogFile.append('oddb/debug', "update_immediate_with_error_report #{subj}", Time.now)
      if @options
        plug = klass.new(@app, @options)
      else
        plug = klass.new(@app)
      end
      plug.send(update_method)
      log = Log.new(@@today)
      log.update_values(log_info(plug))
        unless plug.report.empty?
        log = Log.new(@@today)
        log.update_values(log_info(plug))
        log.notify(subj)
      end
   rescue StandardError => e #RuntimeError, StandardError => e
      notify_error(klass, subj, e)
    end
    def update_notify_simple(klass, subj, update_method=:update, args=[])
      LogFile.append('oddb/debug', "update_notify_simple #{subj}", Time.now)
      wrap_update(klass, subj) {
        if @options
          plug = klass.new(@app, @options)
        else
          plug = klass.new(@app)
        end
        if (plug.send(update_method, *args))
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
