#!/usr/bin/env ruby
# OddbApp -- oddb -- hwyss@ywesee.com

require 'odba'
require 'odba/index_definition'
require 'custom/lookandfeelbase'
require 'util/failsafe'
require 'util/oddbconfig'
require 'util/session'
require 'util/updater'
require 'util/exporter'
require 'util/validator'
require 'util/loggroup'
require 'util/soundex'
require 'admin/subsystem'
require 'models'
require 'commands'
require 'sbsm/drbserver'
require 'sbsm/index'
require 'util/drb'
require 'util/config'
require 'fileutils'
require 'yaml'

class OddbPrevalence
	include ODDB::Failsafe
	include ODBA::Persistable
	ODBA_EXCLUDE_VARS = [
		"@bean_counter",
	]
	attr_reader :galenic_groups, :companies, :doctors
	attr_reader	:atc_classes, :last_update
	attr_reader :atc_chooser, :registrations
	attr_reader :last_medication_update
	attr_reader :orphaned_patinfos, :orphaned_fachinfos
	attr_reader :fachinfos
	attr_reader :patinfos_deprived_sequences, :patinfos
	attr_reader :invoices
	def initialize		
		super
		@atc_classes ||= {}
		@companies ||= {}
		@doctors ||= {}
		@cyp450s ||= {}
		@fachinfos ||= {}
		@galenic_forms ||= []
		@galenic_groups ||= []
		@generic_groups ||= {}
		@orphaned_fachinfos ||= {}
		@orphaned_patinfos ||= {}
		@patinfos ||= {}
		@incomplete_registrations ||= {}
		@indications ||= {}
		@last_medication_update ||= Time.now()
		@log_groups ||= {}
		@registrations ||= {}
		@substances ||= {}
		create_unknown_galenic_group()
		create_root_user()
	end
	def init
		create_unknown_galenic_group()
		create_root_user()
		@atc_classes ||= {}
		@patinfos_deprived_sequences ||= []
		@companies ||= {}
		@cyp450s ||= {}
		@fachinfos ||= {}
		@doctors ||= {}
		@galenic_forms ||= []
		@galenic_groups ||= []
		@generic_groups ||= {}
		@incomplete_registrations ||= {}
		@indications ||= {}
		@last_medication_update ||= Time.now()
		@log_groups ||= {}
		@patinfos ||= {}
		@registrations ||= {}
		@substances ||= {}
		@orphaned_patinfos ||= {}
		@orphaned_fachinfos ||= {}
		rebuild_atc_chooser()
		atc_ddd_count()
		limitation_text_count()
		package_count()
		patinfo_count()
		doctor_count()
	end
	# prevalence-methods ################################
	def create(pointer)
		#puts [__FILE__,__LINE__,"create(#{pointer})"].join(':')
		@last_update = Time.now()
		failsafe {
			if(item = pointer.issue_create(self))
				#puts item
				updated(item)
				item
			end
		}
	end
	def delete(pointer)
		@last_update = Time.now()
		failsafe(ODDB::Persistence::UninitializedPathError) {
			if(item = pointer.resolve(self))
				updated(item)
			end
			pointer.issue_delete(self)
		}
	end
	def update(pointer, values)
		#puts [__FILE__,__LINE__,"update(#{pointer}, #{values})"].join(':')
		@last_update = Time.now()
		item = failsafe(ODDB::Persistence::UninitializedPathError, nil) {
			pointer.resolve(self)
		}
		unless item.nil? 
			updated(item)
			pointer.issue_update(self, values)
		end
		item
	end
	#####################################################
	def accepted_orphans
		@accepted_orphans ||= {}
	end
	def admin(oid)
		@users[oid.to_i]
	end
	def admin_subsystem
		ODBA.cache_server.fetch_named('admin', self) {
			ODDB::Admin::Subsystem.new
		}
	end
	def atcless_sequences
		@registrations.values.collect { |reg|
			reg.atcless_sequences
		}.flatten
	end
	def atc_class(code)
		@atc_classes[code]
	end
	def atc_ddd_count
		@atc_ddd_count ||= count_atc_ddd()
	end
	def company(oid)
		@companies[oid.to_i]
	end
	def company_by_name(name)
		namedown = name.to_s.downcase
		@companies.each_value { |company|
			if company.name.to_s.downcase == namedown
				return company
			end
		}
		nil
	end
	def company_count
		@companies.length
	end
	def config(*args)
		if(@config.nil?)
			@config = ODDB::Config.new
			@config.pointer = ODDB::Persistence::Pointer.new(:config)
			self.odba_store
		end
		hook = @config
		args.each { |arg|
			conf = hook.send(arg)
			if(conf.nil?)
				conf = hook.send("create_#{arg}")
				conf.pointer = hook.pointer + arg
				hook.odba_store
			end
			hook = conf
		}
		hook
	end
	def count_atc_ddd
		@atc_classes.values.inject(0) { |inj, atc|
			inj += 1 if(atc.has_ddd?)
			inj
		}
	end
	def count_limitation_texts
		@registrations.values.inject(0) { |inj,reg|			
			inj += reg.limitation_text_count
		}
	end
	def count_packages
		@registrations.values.inject(0) { |inj, reg|
			inj += reg.package_count
		}
	end
	def count_patinfos
		patinfo_count = @patinfos.size 
		@registrations.each_value { |reg| 
			reg.sequences.each_value { |seq|
				unless(seq.pdf_patinfo.nil?)
					patinfo_count += 1
				end
			}
		}
		patinfo_count
	end
	def cyp450(id)
		@cyp450s[id]
	end
	def cyp450s
		@cyp450s.values
	end
	def create_admin
		user = ODDB::AdminUser.new
		@users.store(user.oid, user)
	end
	def create_atc_class(atc_class)
		atc = ODDB::AtcClass.new(atc_class)
		@atc_chooser.add_offspring(ODDB::AtcNode.new(atc))
		@atc_classes.store(atc_class, atc)
	end
	def create_company
		company = ODDB::Company.new
		@companies.store(company.oid, company)
	end
	def create_doctor
		doctor = ODDB::Doctor.new
		@doctors ||= {}
		@doctors.store(doctor.oid, doctor)
	end
	def create_cyp450(cyp_id)
		@cyp450s ||= {}
		cyp450 = ODDB::CyP450.new(cyp_id)
		@cyp450s.store(cyp_id, cyp450)
	end
	def create_fachinfo
		@fachinfos ||= {}
		fachinfo = ODDB::Fachinfo.new
		@fachinfos.store(fachinfo.oid, fachinfo)
	end
	def create_galenic_group
		galenic_group = ODDB::GalenicGroup.new
		@galenic_groups.store(galenic_group.oid, galenic_group)
	end
	def create_generic_group(package_pointer)
		@generic_groups.store(package_pointer, ODDB::GenericGroup.new)
	end
	def create_incomplete_registration
		incomplete = ODDB::IncompleteRegistration.new
		@incomplete_registrations.store(incomplete.oid, incomplete)
	end
	def create_indication
		indication = ODDB::Indication.new
		@indications.store(indication.oid, indication)
	end
	def create_invoice(invoice_name)
		@invoices.store(invoice_name, ODDB::Invoice.new(invoice_name))
	end
	def create_log_group(key)
		@log_groups[key] ||= ODDB::LogGroup.new(key)
	end
	def create_orphaned_fachinfo
		@orphaned_fachinfos ||= {}
		orphan = ODDB::OrphanedFachinfo.new
	  @orphaned_fachinfos.store(orphan.oid, orphan)
	end
	def create_orphaned_patinfo
		@orphaned_patinfos ||= {}
		orphan = ODDB::OrphanedPatinfo.new
	  @orphaned_patinfos.store(orphan.oid, orphan)
	end
	def create_patinfo
		@patinfos ||= {}
		patinfo = ODDB::Patinfo.new
		@patinfos.store(patinfo.oid, patinfo)
	end
	def create_patinfo_deprived_sequences
		@patinfos_deprived_sequences ||= []
		pat = ODDB::PatinfoDeprivedSequences.new
	  @patinfos_deprived_sequences.store(pat.oid, pat)
	end
	def create_registration(iksnr)
		unless @registrations.include?(iksnr)
			reg = ODDB::Registration.new(iksnr)
			#reg.odba_store
			@registrations.store(iksnr, reg)
			#@registrations.odba_store
			reg
		end
	end
	def create_substance(key=nil)
		if(!key.nil? && (subs = substance(key)))
			subs
		else
			subs = ODDB::Substance.new
			unless(key.nil?)
				values = {
					'lt'	=>	key,
				}
				diff = subs.diff(values, self)
				subs.update_values(diff)
			end
			@substances.store(subs.oid, subs)
		end
	end
	def create_user
		@users ||= {}
		user = ODDB::CompanyUser.new
		@users.store(user.oid, user)
	end
	def delete_atc_class(atccode)
		atc = @atc_classes[atccode]
		#delete_from_index(@atc_index, atc.name, atc)
		@atc_chooser.delete(atccode)
		@atc_classes.delete(atccode)
	end
	def delete_cyp450(cyp_id)
		@cyp450s.delete(cyp_id)
	end
	def delete_company(oid)
		#comp = @companies[oid]
		#@company_index.delete(comp.name.downcase, comp)
		@companies.delete(oid)
	end
	def delete_doctor(oid)
		@doctors.delete(oid.to_i)
	end
	def delete_fachinfo(oid)
		@fachinfos.delete(oid)
	end
	def delete_galenic_group(oid)
		group = galenic_group(oid)
		unless (group.nil? || group.empty?)
			raise 'e_nonempty_galenic_group'
		end
		@galenic_groups.delete(oid.to_i)
	end
	def delete_incomplete_registration(oid)
		@incomplete_registrations.delete(oid)
	end
	def delete_indication(oid)
		@indications.delete(oid)
	end
	def delete_orphaned_fachinfo(oid)
		@orphaned_fachinfos.delete(oid.to_i)
	end
	def delete_orphaned_patinfo(oid)
		@orphaned_patinfos.delete(oid.to_i)
	end
	def delete_patinfo_deprived_sequences(oid)
		@patinfos_deprived_sequences.delete(oid.to_i)
	end
	def delete_registration(iksnr)
		@registrations.delete(iksnr)
	end
	def delete_substance(key)
		substance = nil
		if(key.to_i.to_s == key.to_s)
			substance = @substances.delete(key.to_i)
		else
			substance = @substances.delete(key.to_s.downcase)
		end
	end
	def doctor(oid)
		@doctors[oid.to_i]
	end
	def doctor_count
		@doctors.size
	end
	def doctor_by_origin(origin_db, origin_id)
		# values.each instead of each_value for testing
		@doctors.values.each { |doctor|
			if(doctor.record_match?(origin_db, origin_id))
				return doctor
			end
		}
		nil
	end
	def each_atc_class(&block)
		@atc_classes.each_value(&block)
	end
	def each_galenic_form(&block)
		@galenic_groups.each_value { |galgroup|
			galgroup.each_galenic_form(&block)
		}
	end
	def each_package(&block)
		@registrations.each_value { |reg|
			reg.each_package(&block)
		}
	end
	def execute_command(command)
		command.execute(self)
	end
	def fachinfo(oid)
		@fachinfos[oid.to_i]
	end
	def fachinfo_count
		@fachinfos.size
	end
	def galenic_form(name)
		@galenic_groups.values.collect { |galenic_group|
			galenic_group.get_galenic_form(name)
		}.compact.first
	end
	def galenic_group(oid)
		@galenic_groups[oid.to_i]
	end
	def generic_group(package_pointer)
		@generic_groups[package_pointer]
	end
	def incomplete_registration(oid)
		@incomplete_registrations[oid.to_i]
	end
	def incomplete_registrations
		@incomplete_registrations.values
	end
	def indication(oid)
		@indications[oid.to_i]
	end
	def indication_by_text(text)
		@indications.values.select { |indication|
			indication.has_description?(text)
		}.first
	end
	def indications
		@indications.values
	end
	def invoice(invoice_name)
		@invoices ||= {}
		@invoices[invoice_name]
=begin
		if(@invoice_types.nil?)
			@invoice_types = {}
			pointer = ODDB::Persistence::Pointer.new([:invoice_types])
			invoice_types = create(pointer)
			update(invoice_types.pointer, {})
		end
		element = @invoice_types[invoice_name]
		if(element.nil?)
			invoice_type = ODDB::InvoiceType.new(invoice_name)
			@invoice_types.store(invoice_name, invoice_type)
		else
			element
		end
=end
	end
	def limitation_text_count
		@limitation_text_count ||= count_limitation_texts()
	end
	def login(email, pass)
		@users.values.select { |user| user.identified_by?(email, pass)}.first
	end
	def log_group(key)
		@log_groups[key]
	end
	def orphaned_fachinfo(oid)
		@orphaned_fachinfos[oid.to_i]
	end
	def orphaned_patinfo(oid)
		@orphaned_patinfos[oid.to_i]
	end
	def package_count
		@package_count ||= count_packages()
	end
	def patinfo(oid)
		@patinfos[oid.to_i]
	end
	def patinfo_count
		@patinfo_count ||= count_patinfos()
	end
	def patinfo_deprived_sequences(oid)
		@patinfos_deprived_sequences[oid.to_i]
	end
	def rebuild_atc_chooser
		chooser = ODDB::AtcNode.new(nil)
		@atc_classes.values.sort_by { |atc| 
			atc.code 
		}.each { |atc|
			chooser.add_offspring(ODDB::AtcNode.new(atc))
		}
		@atc_chooser = chooser
	end
	def rebuild_atc_chooser
		@atc_chooser = ODDB::AtcNode.new(nil)
		@atc_classes.values.sort_by { |atc| 
			atc.code 
		}.each { |atc|
			@atc_chooser.add_offspring(ODDB::AtcNode.new(atc))
		}
	end
	def recount
		if(@bean_counter.is_a?(Thread) && @bean_counter.status)
			@bean_counter.kill
		end
		@bean_counter = Thread.new {
			Thread.current.priority = -5
			@atc_ddd_count = count_atc_ddd()
			@limitation_text_count = count_limitation_texts()
			@package_count = count_packages()
			@patinfo_count = count_patinfos()
		}
	end
	def registration(registration_id)
		@registrations[registration_id]
	end
	def resolve(pointer)
		pointer.resolve(self)
	end
	def search(query, lang)
		# current search_order:
		# 1. atcless
		# 2. iksnr or ean13
		# 3. atc-code
		# 4. exact word in sequence name
		# 5. company-name
		# 6. indication
		# 7. substance
		# 8. sequence
		result = ODDB::SearchResult.new
		result.exact = true
		if(query == 'atcless')
			atc = ODDB::AtcClass.new('n.n.')
			sequences = []
			@registrations.each_value { |reg|
				reg.sequences.each_value { |seq|
					if(seq.atc_class.nil? && !seq.packages.empty?)
						sequences.push(seq)
					end	
				}	
			}
			atc.sequences = sequences
			result.atc_classes = [atc]
			return result
		elsif(match = /(?:\d{4})?(\d{5})(?:\d{4})?/.match(query))
			iksnr = match[1]
			if(reg = registration(iksnr))
				atc = ODDB::AtcClass.new('n.n.')
				atc.sequences = reg.sequences.values
				result.atc_classes = [atc]
				return result
			end
		end
		key = query.to_s.downcase
		atcs = search_by_atc(key)
		if(atcs.empty?)
			atcs = search_by_sequence(key, result)
		end
		if(atcs.empty?)
			atcs = search_by_company(key)
		end
		if(atcs.empty?)
			atcs = search_by_substance(key)
		end
		if(atcs.empty?)
			atcs = search_by_indication(key, lang, result)
		end
		if(atcs.empty?)
			atcs = search_by_sequence(key)
		end
		# cleanup. remove when all temporary-atcs are deleted from the db
		atcs.delete_if { |atc|
			delete = (atc.code == 'n.n.' || atc.code.empty?)
			if(delete)
				puts "atc: #{atc} - code: #{atc.code}"
				puts "deleting!"
				ODBA.batch { 
					atc.odba_delete 
				}
				true
			end
		}
		#
		#atcs.delete_if { |atc| atc.code.length == 0 }
		result.atc_classes = atcs
		result
	end
	def search_by_atc(key)
		ODBA.cache_server.retrieve_from_index('atc_index', key.dup)
	end
	def search_by_company(key)
		atcs = ODBA.cache_server.retrieve_from_index('atc_index_company', key.dup)
		filtered = atcs.collect { |atc|
			atc.company_filter_search(key.dup)
		}
		filtered.flatten.compact.uniq
	end
	def search_by_indication(key, lang, result)
		if(lang.to_s != "fr") 
			lang = "de"
		end
		atcs = ODBA.cache_server.retrieve_from_index("fachinfo_index_#{lang}",
			key.dup, result)
		atcs += ODBA.cache_server.retrieve_from_index("indication_index_atc",
			key.dup, result)
		atcs.uniq
	end
	def search_by_sequence(key, result=nil)
		ODBA.cache_server.retrieve_from_index('sequence_index_atc', key.dup, result)
	end
	def search_by_substance(key)
		ODBA.cache_server.retrieve_from_index('substance_index_atc', key.dup)
	end
	def search_doctors(key)
		ODBA.cache_server.retrieve_from_index("doctor_index", key)
	end
	def search_companies(key)
		ODBA.cache_server.retrieve_from_index("company_index", key)
	end
	def search_exact(query)
		result = ODDB::SearchResult.new
		atc = ODDB::AtcClass.new('n.n.')
		atc.sequences = ODBA.cache_server.\
			retrieve_from_index('sequence_index', query)
		result.atc_classes = [atc]
		result
	end
	def search_indications(query)
		ODBA.cache_server.retrieve_from_index("indication_index", query)
	end
	def search_interactions(query)
		result = ODBA.cache_server.retrieve_from_index("sequence_index_substance", query)
=begin
		keys.each { |key|
			if(atc_codes = sequences_by_name(key))
				atc_codes.each { |atc_code|
					result += atc_code.substances
				} 
			end
			result += soundex_substances(key)
		}
=end
		if(subs = substance(query))
			result.unshift(subs)
		end
		if(result.empty?)
			result = soundex_substances(query)
		end
		result
	end
	def search_single_substance(key)
		result = ODDB::SearchResult.new
		result.exact = true
		ODBA.cache_server.retrieve_from_index("substance_index", key, result).first
	end
	def search_substances(query)
		if(subs = substance(query))
			[subs]
		else
			soundex_substances(query)
		end
	end
	def sequences_by_name(name)
		ODBA.cache_server.retrieve_from_index("sequence_index_atc", name)
	end
	def soundex_substances(name)
		parts = ODDB::Text::Soundex.prepare(name).split(/\s+/)
		soundex = ODDB::Text::Soundex.soundex(parts)
		key = soundex.join(' ')
		ODBA.cache_server.retrieve_from_index("substance_soundex_index", key)
	end
	def sponsor
		@sponsor ||= ODDB::Sponsor.new
	end
=begin
	def store_in_index(index, key, *values)
		key = key.to_s.gsub(/[^\sa-zA-Z0-9áéíóúàèìòùâêîôûäëïöüÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÄËÏÖÜ+-_="'.*ç%&\/()=!]/, '')
		parts = key.split(/\s+/)
		parts << key
		parts.uniq!
		parts.each { |part|
			index.store(part.downcase, *values) if part.length > 3
		}
	end
=end
	def substance(key)
		if(key.to_i.to_s == key.to_s)
			@substances[key.to_i]
		elsif(substance = @substances[key.to_s.downcase])
			substance
		elsif(substance = search_single_substance(key))
			substance
		else
			@substances.values.each { |subs|
				if(subs.same_as?(key))
					return subs
				end
			}
			nil
		end
	end
	def substance_by_connection_key(connection_key)
		@substances.values.select { |substance|
			substance.has_connection_key?(connection_key)
		}.first
	end
	def substances
		@substances.values
	end
	def substance_count
		@substances.length
	end
	def updated(item)
		case item
		when ODDB::Registration, ODDB::Sequence, ODDB::Package, ODDB::AtcClass
			@last_medication_update = Date.today
			recount
		when ODDB::LimitationText, ODDB::AtcClass::DDD
			recount
		end
	end
	def user(oid)
		@users[oid]
	end
	def user_by_email(email)
		@users.values.select { |user| user.unique_email == email }.first
	end
	def rebuild_odba_indices(name=nil)
		ODBA.scalar_cache.size
		ODBA.cache_server.indices.size
		begin
			start = Time.now
			path = File.expand_path("../../etc/index_definitions.yaml", 
				File.dirname(__FILE__))
			FileUtils.mkdir_p(File.dirname(path))
			file = File.open(path)
			YAML.load_documents(file) { |index_definition|
				if(name.nil? || name.match(index_definition.index_name))
					index_start = Time.now
					begin
						puts "dropping: #{index_definition.index_name}"
						ODBA.cache_server.drop_index(index_definition.index_name)
					rescue Exception => e
						puts e.message
					end
					puts "creating: #{index_definition.index_name}"
					ODBA.cache_server.create_index(index_definition, ODDB)
					puts "filling: #{index_definition.index_name}"
					puts index_definition.init_source
					ODBA.cache_server.fill_index(index_definition.index_name, 
					instance_eval(index_definition.init_source))
					puts "finished in #{(Time.now - index_start) / 60.0} min"
				end
			}
			puts "all Indices Created in total: #{(Time.now - start) / 3600.0} h"
		rescue StandardError => e
			puts "INDEX CREATION ERROR:"
			puts e.message
			puts e.backtrace
		ensure
			file.close
		end
	end
	def generate_dictionary(language, locale)
		base = File.expand_path("../../ext/fulltext/data/dicts/#{language}", 
			File.dirname(__FILE__))
		ODBA.storage.generate_dictionary(language, locale, base)
	end
	def generate_dictionaries
		generate_french_dictionary
		generate_german_dictionary
	end
	def generate_french_dictionary
		generate_dictionary('french', 'fr_FR@euro')
	end
	def generate_german_dictionary
		generate_dictionary('german', 'de_DE@euro')
	end
	private
	def create_unknown_galenic_group
		unless(@galenic_groups.is_a?(Hash) && @galenic_groups.size > 0)
			@galenic_groups = {}
			pointer = ODDB::Persistence::Pointer.new([:galenic_group])
			group = create(pointer)
			raise "Default GalenicGroup has illegal Object ID (#{group.oid})" unless group.oid == 1
			update(group.pointer, {'de'=>'Unbekannt'})
		end
	end
	def create_root_user
		@users ||= {}
		if(@users[0].nil?)
			@users.store(0, ODDB::RootUser.new)
		end
	end
end

module ODDB
	class App < SBSM::DRbServer
		include Failsafe
		AUTOSNAPSHOT = true
		CLEANING_INTERVAL = 5*60
		EXPORT_HOUR = 2
		RUN_CLEANER = true
		RUN_EXPORTER = true
		RUN_UPDATER = true
		SESSION = Session
		SNAPSHOT_INTERVAL = 4*60*60
		STORAGE_PATH = File.expand_path('log/prevalence', PROJECT_ROOT)
		UNKNOWN_USER = UnknownUser
		UPDATE_INTERVAL = 24*60*60
		VALIDATOR = Validator
		attr_reader :cleaner, :updater
		def initialize
			ODBA.cache_server.prefetch
			@system = ODBA.cache_server.fetch_named('oddbapp', self){
				OddbPrevalence.new
			}
			puts "init system"
			@system.init
			puts "setup drb-delegation"
			super(@system)
			puts "reset"
			reset()
			puts "system initialized"
		end
		# prevalence-methods ################################
		def accept_incomplete_registration(reg)
			command = AcceptIncompleteRegistration.new(reg.pointer)
			@system.execute_command(command)
			registration(reg.iksnr)
		end
		def accept_orphaned(orphan, pointer, symbol)
			command = AcceptOrphan.new(orphan, pointer,symbol)
			@system.execute_command(command)
		end
		def create(pointer)
			@system.execute_command(CreateCommand.new(pointer))
		end
		def create_admin_user(email, password)
			unless(@system.user_by_email(email))
				pass_hash = Digest::MD5.hexdigest(password)
				pointer = Persistence::Pointer.new([:admin])
				values = {
					:unique_email	=>	email,
					:pass_hash		=>	pass_hash,
				}
				update(pointer.creator, values)
			end
		end
		def delete(pointer)
			@system.execute_command(DeleteCommand.new(pointer))
		end
		def merge_companies(source_pointer, target_pointer)
			command = MergeCommand.new(source_pointer, target_pointer)
			@system.execute_command(command)
		end
		def merge_galenic_forms(source, target)
			command = MergeCommand.new(source.pointer, target.pointer)
			@system.execute_command(command)
		end
		def merge_substances(source_pointer, target_pointer)
			command = MergeCommand.new(source_pointer, target_pointer)
			@system.execute_command(command)
		end
		def replace_fachinfo(iksnr, pointer)
			@system.execute_command(ReplaceFachinfoCommand.new(iksnr, pointer))
		end
		def update(pointer, values)
			@system.execute_command(UpdateCommand.new(pointer, values))
		end
		#####################################################
		def admin(src, priority=-1)
			Thread.current.priority = priority
			Thread.current.abort_on_exception = false
			failsafe {
				response = begin
					instance_eval(src)
				rescue NameError => e
				#@system.instance_eval(src)
					e
				end
				str = response.to_s
				if(str.length > 200)
					response.class
				else
					str
				end
			}
		end
		def login(session)
			pair = session.user_input(:email, :pass)
			@system.login(pair[:email], pair[:pass])
		end
		def reset
			@updater.kill if(@updater.is_a? Thread)
			@exporter.kill if(@exporter.is_a? Thread)
			@updater = run_updater if RUN_UPDATER
			@exporter = run_exporter if RUN_EXPORTER
			@mutex.synchronize {
				@sessions.clear
			}
		end
		def run_exporter
			Thread.new {
				Thread.current.priority=-10
				Thread.current.abort_on_exception = true
				today = (EXPORT_HOUR > Time.now.hour) ? Date.today : Date.today.next
				loop {
					next_run = Time.local(today.year, today.month, today.day, EXPORT_HOUR)
					sleep(next_run - Time.now)
					Exporter.new(self).run
					GC.start
					today = Date.today.next
				}
			}
		end
		def run_updater
			Thread.new {
				Thread.current.priority=-5
				Thread.current.abort_on_exception = true
				loop {
					Updater.new(self).run
					GC.start
					sleep UPDATE_INTERVAL
				}
			}
		end
		def assign_effective_forms(arg=nil)
			ODBA.batch {
				_assign_effective_forms(arg)
			}
		end
		def _assign_effective_forms(arg=nil)
			result = nil
			last = nil
			@system.substances.select { |subs| 
				!subs.has_effective_form? && (arg.nil? || arg.to_s < subs.to_s)
			}.sort_by { |subs| subs.name }.each { |subs|
				puts "Looking for effective form of ->#{subs}<- (#{subs.sequences.size} Sequences)"
				name = subs.to_s
				parts = name.split(/\s/)
				suggest = if(parts.size == 1)
					subs
				elsif(![nil, '', 'Acidum'].include?(parts.first))
					@system.search_single_substance(parts.first) \
						|| @system.search_single_substance(parts.first.gsub(/i$/, 'um'))
				end
				last = result
				result = nil
				while(result.nil?)
					possibles = [
						"d(elete)", 
						"S(elf)", 
						"n(othing)", 
						"other_name",
					]
					if(suggest)
						puts "Suggestion:                   ->#{suggest}<-"
						possibles.unshift("s(uggestion)")
					end
					if(last)
						puts "Last:                         ->#{last}<-"
						possibles.unshift("l(ast)")
					end
					print possibles.join(", ")
					print " > "
					$stdout.flush
					answer = $stdin.readline.strip
					puts "you typed:                    ->#{answer}<-"
					case answer
					when ''
						# do nothing
					when 'l'
						result = last
					when 's'
						result = suggest
					when 'S'
						result = subs
					when 'd'
						subs.sequences.each { |seq| 
							seq.delete_active_agent(subs) 
							seq.active_agents.odba_store
						}
						subs.odba_delete
						break
					when 'n'
						break
					when 'q'
						return
					when /c .+/
						puts "creating:"
						pointer = Persistence::Pointer.new(:substance)
						puts "pointer: #{pointer}"
						args = { :lt => answer.split(/\s+/, 2).last.strip }
						argstr = args.collect { |*pair| pair.join(' => ') }.join(', ')
						puts "args: #{argstr}"
						result = @system.update(pointer.creator, args)
						result.effective_form = result
						result.odba_store
						puts "result: #{result}"
					else
						result = @system.substance(answer)
					end
				end
				if(result)
					subs.effective_form = result
					subs.odba_store
				end
			}
			nil
		end
	end
end

begin 
	require 'testenvironment'
rescue LoadError
end
