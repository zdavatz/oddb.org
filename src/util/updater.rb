#!/usr/bin/env ruby
# Updater-- oddb -- 19.02.2003 -- hwyss@ywesee.com 

require 'plugin/swissmedicjournal'
require 'plugin/doctors'
require 'plugin/fachinfo'
require 'plugin/fxcrossrate'
require 'plugin/interaction'
require 'plugin/patinfo'
require 'plugin/hospitals'
require 'plugin/bsv'
require 'plugin/ouwerkerk'
require 'plugin/limitation'
require 'plugin/medwin'
require 'plugin/migel'
require 'plugin/narcotic'
require 'plugin/vaccines'
require 'plugin/who'
require 'util/log'
require 'util/persistence'
require 'ext/meddata/src/ean_factory'

module ODDB
	class Updater
		# Recipients for all Update-Logs go here...
		RECIPIENTS = [
			'admin@ywesee.com',
		]
		LOG_RECIPIENTS = {
			:powerlink	=>	['matthijs.ouwerkerk@just-medical.com'],
			:passthru		=>	[],	
			:sponsor		=>	['christina.kobi@helvepharm.ch'],	
		}
		LOG_FILES = {
			:powerlink		=>	'Powerlink-Statistics',
			#:passthru		=>	'Banner-Clicks',
			:sponsor			=>	'Exklusiv-Sponsoring'
		}
		def initialize(app)
			@app = app
			@smj_updated = false
		end
		def export_ouwerkerk(date = Date.today)
			subj = 'Med-Drugs' 
			wrap_update(OuwerkerkPlugin, subj) {
				plug = OuwerkerkPlugin.new(@app)
				plug.export_xls
				log = Log.new(date)
				log.update_values(log_info(plug))
				log.notify(subj)
			}
		end
		def log_info(plugin)
			hash = plugin.log_info
			hash[:recipients] = if(rcp = hash[:recipients])
				rcp + recipients
			else
				recipients
			end
			hash
		end
		def mail_logfile(name, date, subj)
			log = Log.new(date)
			log.report = LogFile.read(name, date)
			log.recipients = recipients + self::class::LOG_RECIPIENTS[name]
			log.notify(subj)
		end
		def logfile_stats
			date = Date.today << 1
			if(date.day == 1)
				_logfile_stats(date)
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
		def reconsider_bsv
			logs_pointer = Persistence::Pointer.new([:log_group, :bsv_sl])
			logs = @app.create(logs_pointer)
			if(latest = logs.newest_date)
				klass = BsvPlugin2
				plug = klass.new(@app)
				subj = 'SL-Update Reconsidered'
				wrap_update(klass, subj) {
					if(plug.update(latest))
						log = logs.latest
						change_flags = plug.change_flags.update(log.change_flags.odba_instance) 
						@app.update(log.pointer, {:change_flags, change_flags})
						partlog = Log.new(latest)
						partlog.update_values(log_info(plug))
						partlog.notify(subj)
					end
				}
			end
		end
		def run
			logfile_stats
			update_swissmedicjournal
			update_fxcrossrate
			update_fachinfo
			if(update_bsv)
				update_limitation_text
			#elsif(@smj_updated)
				#reconsider_bsv
			end
			if(@smj_updated)
				update_medwin_companies
			end
		end
		def update_bsv
			logs_pointer = Persistence::Pointer.new([:log_group, :bsv_sl])
			logs = @app.create(logs_pointer)
			today = Date.today
			this_month = Date.new(today.year, today.month)
			latest = logs.newest_date || (this_month << 1)
			months = [this_month, this_month >> 1].select { |month| month > latest }
			klass = BsvPlugin2
			plug = klass.new(@app)
			subj = 'SL-Update'
			wrap_update(klass, subj) { 
				if(months.any? { |month| plug.update(month) } )
					log_notify_bsv(plug, plug.month, subj)
				end
			}
		end
		def update_doctors
			update_simple(Doctors::DoctorPlugin, 'Doctors')
		end
		def update_fachinfo
			klass = FachinfoPlugin
			subj = 'Fachinfo'
			wrap_update(klass, subj) {
				plug = klass.new(@app)
				if(plug.update)
					log = Log.new(Date.today)
					log.update_values(log_info(plug))
					log.notify(subj)
				end
			}
		end
		def update_fachinfo_news
			update_simple(FachinfoPlugin, 'Fachinfo', :update_news)
		end
		def update_fxcrossrate
			klass = FXCrossratePlugin
			wrap_update(klass, 'Currency Rates') {
				plug = klass.new(@app)
				plug.update
			}
		end
		def update_hospitals
			update_simple(HospitalPlugin, 'Hospitals')
		end
		def update_all_fachinfo
			update_simple(FachinfoPlugin, "Complete Fachinfo", :update_all)
		end
		def update_interactions
			update_simple(Interaction::InteractionPlugin, 'Interaktionen')
		end
		def update_limitation_text
			update_simple(LimitationPlugin, 'LimitationText')
		end
		def update_medwin_companies
			update_simple(MedwinCompanyPlugin, 'Medwin-Companies')
		end
		def update_medwin_packages
			update_simple(MedwinPackagePlugin, 'Medwin-Packages')
		end
		def update_migel
			klass = MiGeLPlugin
			subj = 'MiGeL'
			status_report = "MiGeL is now up to date"
			wrap_update(klass, subj) {
				plug = klass.new(@app)
				[:de, :fr, :it].each { |lang|
					path = File.expand_path("../../data/csv/migel_#{lang}.csv", 
						File.dirname(__FILE__))
					plug.update(path, lang)
				}
				status_report
			}
		end
		def update_narcotics
			klass = NarcoticPlugin
			subj = 'Narcotic'
			status_report = "Narcotics are now up to date"
			wrap_update(klass, subj) {
				plug = klass.new(@app)
				[:de].each { |lang|
					path = File.expand_path("../../data/csv/betaeubungsmittel_a_#{lang}.csv",
						File.dirname(__FILE__))
					plug.update(path, lang)
				}
				status_report
			}
		end
		def update_patinfo
			update_simple(PatinfoPlugin, 'Patinfo')		
		end
		def update_patinfo_news
			update_simple(PatinfoPlugin, 'Patinfo', :update_news)
		end
		def update_swissmedicjournal
			logs_pointer = Persistence::Pointer.new([:log_group, :swissmedic_journal])
			logs = @app.create(logs_pointer)
			# The first issue of SwissmedicJournal is 2002,1
			latest = logs.newest_date || Date.new(2002,4) 
			success = true
			while((latest < Date.today) && success)
				latest = latest >> 1
				klass = SwissmedicJournalPlugin
				plug = klass.new(@app)
				wrap_update(klass, "swissmedic-journal") { 
					success = false
					success = plug.update(latest)
				}
				if(success)
					pointer = logs.pointer + [:log, latest.dup]
					log = @app.update(pointer.creator, log_info(plug))
					log.notify('Swissmedic-Journal')
					@smj_updated = latest
				end
			end
		end
		def update_vaccines
			wrap_update(VaccinePlugin, 'blutprodukte') { 
				plugin = VaccinePlugin.new(@app)
				# registrations, indications, sequences
				plugin.parse_from_smj('vaccines.txt')
				# sequences, substances, active_agents
				plugin.parse_from_xls('vaccines.xls')
				# packages
				plugin.parse_from_xls('vaccines_ean.xls')
			}
		end
		private
		def log_notify_bsv(plug, date, subj='SL-Update')
			pointer = Persistence::Pointer.new([:log_group, :bsv_sl], [:log, date])
			values = log_info(plug)
			log = @app.update(pointer.creator, values)
			log.notify(subj)
		end
		def wrap_update(klass, subj, &block)
			begin
				ODBA.transaction {
					block.call
				}
			rescue Exception => e #RuntimeError, StandardError => e
				log = Log.new(Date.today)
				log.report = [
					"Plugin: #{klass}",
					"Error: #{e.class}",
					"Message: #{e.message}",
					"Backtrace:",
					e.backtrace.join("\n"),
				].join("\n")
				log.recipients = RECIPIENTS.dup
				log.notify("Error: #{subj}")
				nil
			end
		end
		def update_simple(klass, subj, update_method=:update)
			wrap_update(klass, subj) {
				plug = klass.new(@app)
				plug.send(update_method)
				log = Log.new(Date.today)
				log.update_values(log_info(plug))
				log.notify(subj)
			}
		end
	end
end
