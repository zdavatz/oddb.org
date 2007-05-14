#!/usr/bin/env ruby
# OddbApp -- oddb -- hwyss@ywesee.com

require 'odba'
require 'odba/index_definition'
require 'odba/drbwrapper'
require 'custom/lookandfeelbase'
require 'util/failsafe'
require 'util/oddbconfig'
require 'util/searchterms'
require 'util/session'
require 'util/updater'
require 'util/exporter'
require 'util/validator'
require 'util/loggroup'
require 'util/soundex'
require 'util/iso-latin1'
require 'util/notification_logger'
require 'remote/package'
require 'admin/subsystem'
require 'models'
require 'commands'
require 'sbsm/drbserver'
require 'sbsm/index'
require 'util/drb'
require 'util/config'
require 'fileutils'
require 'yaml'
require 'yus/session'
require 'model/migel/group'
require 'model/analysis/group'

class Object
	unless(defined?(@@date_arithmetic_optimization))
		@@date_arithmetic_optimization = Thread.new {
			loop {
				@@today = Date.today
				@@one_year_ago = @@today << 12
				@@two_years_ago = @@today << 24
				tomorrow = Time.local(@@today.year, @@today.month, @@today.day)
				sleep([tomorrow - Time.now, 3600].max)
			}	
		}
		def today
			@@today
		end
	end
end

class OddbPrevalence
	include ODDB::Failsafe
	include ODBA::Persistable
	ODBA_EXCLUDE_VARS = [
		"@atc_chooser", "@bean_counter",
	]
	ODBA_SERIALIZABLE = [ '@currency_rates' ]
	ODBA_PREFETCH = true
	attr_reader :address_suggestions, :atc_chooser, :atc_classes, :analysis_groups,
		:companies, :doctors, :fachinfos, :galenic_groups, :migel_groups,
		:hospitals, :invoices, :last_medication_update, :last_update,
    :minifis, :notification_logger, :orphaned_fachinfos,
    :orphaned_patinfos, :patinfos, :patinfos_deprived_sequences,
    :registrations, :slates, :users, :narcotics, :accepted_orphans,
    :commercial_forms
	def initialize
		init
		@last_medication_update ||= Time.now()
	end
	def init
		create_unknown_galenic_group()
		create_root_user()
		@accepted_orphans ||= {}
		@analysis_groups ||= {}
		@atc_classes ||= {}
		@address_suggestions ||= {}
		@patinfos_deprived_sequences ||= []
		@commercial_forms ||= {}
		@companies ||= {}
		@currency_rates ||= {}
		@cyp450s ||= {}
		@fachinfos ||= {}
		@doctors ||= {}
		@galenic_forms ||= []
		@galenic_groups ||= []
		@generic_groups ||= {}
		@migel_groups ||= {}
    @minifis ||= {}
		@hospitals ||= {}
		@incomplete_registrations ||= {}
		@indications ||= {}
		@invoices ||= {}
		@log_groups ||= {}
		@narcotics ||= {}
		@notification_logger ||= ODDB::NotificationLogger.new
		@patinfos ||= {}
		@registrations ||= {}
		@sponsors ||= {}
		@substances ||= {}
		@orphaned_patinfos ||= {}
		@orphaned_fachinfos ||= {}
		@slates ||= {}
		#recount()
		rebuild_atc_chooser()
	end
	# prevalence-methods ################################
	def create(pointer)
		@last_update = Time.now()
		failsafe {
			if(item = pointer.issue_create(self))
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
	def update(pointer, values, origin=nil)
		#puts [__FILE__,__LINE__,"update(#{pointer}, #{values})"].join(':')
		@last_update = Time.now()
		item = nil
		failsafe(ODDB::Persistence::UninitializedPathError, nil) {
			item = pointer.issue_update(self, values, origin)
			updated(item) unless(item.nil?)
		}
		item
	end
	def clean_odba_stubs
		_clean_odba_stubs_hash(@substances)
		@substances.each_value { |sub| _clean_odba_stubs_array(sub.sequences) }
		_clean_odba_stubs_hash(@atc_classes)
		@atc_classes.each_value { |atc| _clean_odba_stubs_array(atc.sequences) }
		_clean_odba_stubs_hash(@registrations)
		@registrations.each_value { |reg|
			_clean_odba_stubs_hash(reg.sequences)
			reg.sequences.each_value { |seq|
				_clean_odba_stubs_hash(seq.packages)
				_clean_odba_stubs_array(seq.active_agents)
			}
		}
	end
	def _clean_odba_stubs_hash(hash)
		if(hash.values.any? { |val| val.odba_instance.nil? })
			hash.delete_if { |key, val| val.odba_instance.nil? }
			hash.odba_store
		end
	end
	def _clean_odba_stubs_array(array)
		if(array.any? { |val| val.odba_instance.nil? })
			array.delete_if { |val| val.odba_instance.nil? }
			array.odba_store
		end
	end
	#####################################################
	def admin(oid)
		@users[oid.to_i]
	end
	def admin_subsystem
		ODBA.cache.fetch_named('admin', self) {
			ODDB::Admin::Subsystem.new
		}
	end
	def active_pdf_patinfos
		active = {}
		each_sequence { |seq|
			if(seq.active? && (str = seq.pdf_patinfo))
				active.store(str, 1)
			end
		}
		active
	end
	def address_suggestion(oid)
		@address_suggestions[oid.to_i]
	end
	def analysis_group(grpcd)
		@analysis_groups[grpcd]
	end
	def analysis_positions
		@analysis_groups.values.inject([]) { |memo, group| 
			memo.concat(group.positions.values)
		}
	end
	def atcless_sequences
		ODBA.cache.retrieve_from_index('atcless', 'true')
	end
	def atc_class(code)
		@atc_classes[code]
	end
	def atc_ddd_count
		@atc_ddd_count ||= count_atc_ddd()
	end
	def clean_invoices
		@invoices.delete_if { |oid, invoice| invoice.odba_instance.nil? }
		deletables = @invoices.values.select { |invoice|
			invoice.deletable?
		}
		unless(deletables.empty?)
			deletables.each { |invoice|
=begin # replaced by Yus
				if((ptr = invoice.user_pointer) \
					&& (user = ptr.resolve(self)) \
					&& user.respond_to?(:remove_invoice))
					user.remove_invoice(invoice)	
				end
=end
				delete(invoice.pointer)
			}
			@invoices.odba_isolated_store
		end
	end
  def commercial_form(oid)
    @commercial_forms[oid.to_i]
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
		@company_count ||= @companies.size
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
			inj + reg.limitation_text_count
		}
	end
	def count_packages
		@registrations.values.inject(0) { |inj, reg|
			inj + reg.active_package_count
		}
	end
	def count_patinfos
		@patinfos.size + active_pdf_patinfos.size
	end
	def count_recent_registrations
		if((grp = log_group(:swissmedic_journal)) \
			 && (log = grp.latest))
			log.change_flags.select { |ptr, flags|
				flags.include?(:new)
			}.size
		else 
			0
		end
	end
	def count_vaccines
		@registrations.values.inject(0) { |inj, reg|
			if(reg.vaccine)
				inj += reg.active_package_count
			end
			inj
		}
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
	def create_analysis_group(groupcd)
		group = ODDB::Analysis::Group.new(groupcd)
		@analysis_groups.store(groupcd, group)
	end
	def create_atc_class(atc_class)
		atc = ODDB::AtcClass.new(atc_class)
		@atc_chooser.add_offspring(ODDB::AtcNode.new(atc))
		@atc_classes.store(atc_class, atc)
	end
	def create_commercial_form
		form = ODDB::CommercialForm.new
		@commercial_forms.store(form.oid, form)
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
	def create_hospital(ean13)
		hospital = ODDB::Hospital.new(ean13)
		@hospitals.store(ean13, hospital)
	end
	def create_cyp450(cyp_id)
		cyp450 = ODDB::CyP450.new(cyp_id)
		@cyp450s.store(cyp_id, cyp450)
	end
	def create_fachinfo
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
	def create_invoice
		invoice = ODDB::Invoice.new
		@invoices.store(invoice.oid, invoice)
	end
	def create_address_suggestion
		address = ODDB::AddressSuggestion.new
		@address_suggestions.store(address.oid, address) 
	end
	def create_log_group(key)
		@log_groups[key] ||= ODDB::LogGroup.new(key)
	end
  def create_minifi
    minifi = ODDB::MiniFi.new
    @minifis.store(minifi.oid, minifi)
  end
	def create_narcotic
		narc = ODDB::Narcotic.new
		@narcotics.store(narc.oid, narc)
	end
	def create_orphaned_fachinfo
		@orphaned_fachinfos ||= {}
		orphan = ODDB::OrphanedFachinfo.new
	  @orphaned_fachinfos.store(orphan.oid, orphan)
	end
	def create_orphaned_patinfo
		orphan = ODDB::OrphanedPatinfo.new
	  @orphaned_patinfos.store(orphan.oid, orphan)
	end
	def create_patinfo
		patinfo = ODDB::Patinfo.new
		@patinfos.store(patinfo.oid, patinfo)
	end
	def create_poweruser
		user = ODDB::PowerUser.new
		@users.store(user.oid, user)
	end
	def create_registration(iksnr)
		unless @registrations.include?(iksnr)
			reg = ODDB::Registration.new(iksnr)
			@registrations.store(iksnr, reg)
			reg
		end
	end
	def create_slate(name)
		slate = ODDB::Slate.new(name)
		@slates.store(name, slate)
	end
	def create_sponsor(flavor)
		sponsor = ODDB::Sponsor.new
		@sponsors.store(flavor, sponsor)
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
	def currencies
		@currency_rates.keys.sort
	end
	def create_migel_group(groupcd)
		migel = ODDB::Migel::Group.new(groupcd)
		@migel_groups.store(groupcd, migel)
	end
	def analysis_count
		@analysis_count ||= analysis_positions.size
	end
	def delete_address_suggestion(oid)
		if(sug = @address_suggestions.delete(oid))
			@address_suggestions.odba_isolated_store
			sug
		end
	end
	def delete_atc_class(atccode)
		atc = @atc_classes[atccode]
		@atc_chooser.delete(atccode)
		if(@atc_classes.delete(atccode))
			@atc_classes.odba_isolated_store
		end
		atc
	end
	def delete_cyp450(cyp_id)
		if(cyp = @cyp450s.delete(cyp_id))
			@cyp450s.odba_isolated_store
			cyp
		end
	end
	def delete_commercial_form(oid)
		if(form = @commercial_forms.delete(oid))
			@commercial_forms.odba_isolated_store
			form
		end
	end
	def delete_company(oid)
		if(comp = @companies.delete(oid))
			@companies.odba_isolated_store
			comp
		end
	end
	def delete_doctor(oid)
		if(doc = @doctors.delete(oid.to_i))
			@doctors.odba_isolated_store
			doc
		end
	end
	def delete_fachinfo(oid)
		if(fi = @fachinfos.delete(oid))
			@fachinfos.odba_isolated_store
			fi
		end
	end
	def delete_galenic_group(oid)
		group = galenic_group(oid)
		unless (group.nil? || group.empty?)
			raise 'e_nonempty_galenic_group'
		end
		if(grp = @galenic_groups.delete(oid.to_i))
			@galenic_groups.odba_isolated_store
			grp
		end
	end
	def delete_incomplete_registration(oid)
		if(reg = @incomplete_registrations.delete(oid))
			@incomplete_registrations.odba_isolated_store
			reg
		end
	end
	def delete_indication(oid)
		if(ind = @indications.delete(oid))
			@indications.odba_isolated_store
			ind
		end
	end
	def delete_invoice(oid)
		if(inv = @invoices.delete(oid))
			@invoices.odba_isolated_store
			inv
		end
	end
	def delete_migel_group(code)
		if(grp = @migel_groups[code])
			@migel_groups.odba_isolated_store
			grp
		end
	end
  def delete_minifi(oid)
    if(minifi = @minifis.delete(oid.to_i))
      @minifis.odba_isolated_store
      minifi
    end
  end
	def delete_orphaned_fachinfo(oid)
		if(fi = @orphaned_fachinfos.delete(oid.to_i))
			@orphaned_fachinfos.odba_isolated_store
			fi
		end
	end
	def delete_orphaned_patinfo(oid)
		if(pi = @orphaned_patinfos.delete(oid.to_i))
			@orphaned_patinfos.odba_isolated_store
			pi
		end
	end
	def delete_patinfo(oid)
		if(fi = @patinfos.delete(oid))
			@patinfos.odba_isolated_store
			fi
		end
	end
	def delete_registration(iksnr)
		if(reg = @registrations.delete(iksnr))
			@registrations.odba_isolated_store
			reg
		end
	end
	def delete_substance(key)
		substance = nil
		if(key.to_i.to_s == key.to_s)
			substance = @substances.delete(key.to_i)
		else
			substance = @substances.delete(key.to_s.downcase)
		end
		if(substance)
			@substances.odba_isolated_store
			substance
		end
	end
	def doctor(oid)
		@doctors[oid.to_i]
	end
	def hospital(ean13)
		@hospitals[ean13]
	end
	def hospital_count
		@hospitals.size
	end
	def doctor_count
		@doctor_count ||= @doctors.size
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
	def each_sequence(&block)
		@registrations.each_value { |reg|
			reg.each_sequence(&block)
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
	def fachinfos_by_name(name, lang)
		if(lang.to_s != "fr") 
			lang = "de"
		end
		ODBA.cache.retrieve_from_index("fachinfo_name_#{lang}", 
			name)
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
	def get_currency_rate(symbol)
    ODDB::Currency.rate('CHF', symbol)
	end
	def incomplete_registration(oid)
		@incomplete_registrations[oid.to_i]
	end
	def incomplete_registration_by_iksnr(iksnr)
		@incomplete_registrations.values.select { |reg|
			reg.iksnr == iksnr
		}.first
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
	def invoice(oid)
		@invoices ||= {}
		@invoices[oid.to_i]
	end
	def limitation_text_count
		@limitation_text_count ||= count_limitation_texts()
	end
	def log_group(key)
		@log_groups[key]
	end
	def migel_count
		@migel_count ||= migel_products.size	
	end
	def migel_group(groupcd)
		@migel_groups[groupcd]
	end
	def migel_product(code)
		parts = code.split('.', 3)
		migel_group(parts[0]).subgroup(parts[1]).product(parts[2])
	rescue NoMethodError
		# invalid migel_code
		nil
	end
	def migel_products
		products = []
		@migel_groups.each_value { |group| 
			group.subgroups.each_value { |subgr|
				products.concat(subgr.products.values)
			}
		}
		products
	end
  def minifi(oid)
    @minifis[oid.to_i]
  end
	def narcotic(odba_id)
		@narcotics[odba_id.to_i]
	end
	def narcotic_by_casrn(casrn)
		unless(casrn.nil?)
			@narcotics.values.each { |narc| 
				if(narc.casrn == casrn)
					return narc
				end
			}
		end
		nil
	end
	def narcotic_by_smcd(smcd)
		unless(smcd.nil?)
			@narcotics.values.each { |narc| 
				if(narc.swissmedic_code == smcd)
					return narc
				end
			}
		end
		nil
	end
	def narcotics_count
		@narcotics.size
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
	def poweruser(oid)
		@users[oid.to_i]
	end
	def rebuild_atc_chooser
		chooser = ODDB::AtcNode.new(nil)
		@atc_classes.sort.each { |key, atc| 
			chooser.add_offspring(ODDB::AtcNode.new(atc))
		}
		@atc_chooser = chooser
	end
	def recent_registration_count
		@recent_registration_count ||= count_recent_registrations()
	end
	def recount
		if(@bean_counter.is_a?(Thread) && @bean_counter.status)
			@bean_counter.kill
		end
		@bean_counter = Thread.new {
			#Thread.current.priority = -5
			@analysis_count = analysis_positions.size
			@atc_ddd_count = count_atc_ddd()
			@doctor_count = @doctors.size
			@company_count = @companies.size
			@substance_count = @substances.size
			@limitation_text_count = count_limitation_texts()
			@migel_count = migel_products.size
			@package_count = count_packages()
			@patinfo_count = count_patinfos()
			@recent_registration_count = count_recent_registrations()
			@vaccine_count = count_vaccines()
			self.odba_isolated_store
		}
	end
	def registration(registration_id)
		@registrations[registration_id]
	end
  def remote_comparables(package)
    package = ODDB::Remote::Package.new(package)
    sequence = package.sequence
    comparables = []
    if(atc = atc_class(sequence.atc_code))
      atc.sequences.each { |seq|
        if(sequence.comparable?(seq))
          comparables.concat seq.packages.values.select { |pac|
            package.comparable?(pac)
          }
        end
      }
    end
    ODBA::DRbWrapper.new comparables
  end
  def remote_each_package(&block)
    each_package { |pac|
      if(pac.public? && !pac.narcotic?)
        block.call ODBA::DRbWrapper.new(pac)
      end
    }
    nil # don't try to pass all registrations across DRb-Land
  end
  def remote_packages(query)
    seqs = search_sequences(query, false)
    if(seqs.empty?)
      seqs = ODBA.cache.\
        retrieve_from_index('substance_index_sequence', query)
    end
    ODBA::DRbWrapper.new seqs.collect { |seq|
      seq.public_packages
    }.flatten
  end
	def resolve(pointer)
		pointer.resolve(self)
	end
	def refactor_addresses
		# 3 Iterationen 
		puts "refactoring doctors"
		$stdout.flush
	  @doctors.each_value { |doc| 
			doc.refactor_addresses 
			doc.odba_store
		}
		puts "refactoring hospitals"
		$stdout.flush
	  @hospitals.each_value { |spi| 
			spi.refactor_addresses 
			spi.odba_store
		}
		puts "refactoring companies"
		$stdout.flush
	  @companies.each_value { |comp| 
			comp.refactor_addresses 
			comp.odba_store
		}
		puts "finished refactoring addresses"
		$stdout.flush
	end
	def search_analysis(key, lang)
		if(lang == 'en')
			lang = 'de'
		end
		ODBA.cache.retrieve_from_index("analysis_index_#{lang}", key)
	end
	def search_analysis_alphabetical(query, lang)
		if(lang == 'en')
			lang = 'de'
		end
		index_name = "analysis_alphabetical_index_#{lang}"
		ODBA.cache.retrieve_from_index(index_name, query)
	end
	def search_oddb(query, lang)
		# current search_order:
		# 1. atcless
		# 2. iksnr or ean13
		# 3. atc-code
		# 4. exact word in sequence name
		# 5. company-name
		# 6. substance
		# 7. indication
		# 8. sequence
		result = ODDB::SearchResult.new
		result.exact = true
		result.search_query = query
		# atcless
		if(query == 'atcless')
			atc = ODDB::AtcClass.new('n.n.')
			atc.sequences = atcless_sequences
			atc.instance_eval {
				alias :active_packages :packages
			}
			result.atc_classes = [atc]
			result.search_type = :atcless
			return result
		# iksnr or ean13
		elsif(match = /(?:\d{4})?(\d{5})(?:\d{4})?/.match(query))
			iksnr = match[1]
			if(reg = registration(iksnr))
				atc = ODDB::AtcClass.new('n.n.')
				atc.sequences = reg.sequences.values
				result.atc_classes = [atc]
				result.search_type = :iksnr
				return result
			end
		end
		key = query.to_s.downcase
		# atc-code
		atcs = search_by_atc(key)
		result.search_type = :atc
		# exact word in sequence name
		if(atcs.empty?)
			atcs = search_by_sequence(key, result)
			result.search_type = :sequence
		end
		# company-name
		if(atcs.empty?)
			atcs = search_by_company(key)
			result.search_type = :company
		end
		# substance
		if(atcs.empty?)
			atcs = search_by_substance(key)
			result.search_type = :substance
		end
		# indication
		if(atcs.empty?)
			atcs = search_by_indication(key, lang, result)
			result.search_type = :indication
		end
		# sequence
		if(atcs.empty?)
			atcs = search_by_sequence(key)
			result.search_type = :sequence
		end
		result.atc_classes = atcs
		# interaction
		if(atcs.empty?)
			result = search_by_interaction(key, lang)
		end
		# unwanted effects
		if(result.atc_classes.empty?)
			result = search_by_unwanted_effect(key, lang)
		end
		result
	end
	def search_by_atc(key)
		ODBA.cache.retrieve_from_index('atc_index', key.dup)
	end
	def search_by_company(key)
		atcs = ODBA.cache.retrieve_from_index('atc_index_company', key.dup)
		filtered = atcs.collect { |atc|
			atc.company_filter_search(key.dup)
		}
		filtered.flatten.compact.uniq
	end
	def search_by_indication(key, lang, result)
		if(lang.to_s != "fr") 
			lang = "de"
		end
		atcs = ODBA.cache.\
			retrieve_from_index("fachinfo_index_#{lang}", key.dup, result)
		atcs += ODBA.cache.\
			retrieve_from_index("indication_index_atc_#{lang}",
			key.dup, result)
		atcs.uniq
	end
	def search_by_sequence(key, result=nil)
		ODBA.cache.retrieve_from_index('sequence_index_atc', key.dup, result)
	end
	def search_by_interaction(key, lang)
		result = ODDB::SearchResult.new
		if(lang.to_s != "fr") 
			lang = "de"
		end
		sequences = ODBA.cache.retrieve_from_index("interactions_index_#{lang}", 
                                               key, result)
    sequences.reject! { |seq| 
      ODDB.search_term(seq.name).include?(key) || seq.substances.any? { |sub|
        sub.search_keys.any? { |skey| skey.include?(key) }
      }
    }
		_search_exact_classified_result(sequences, :interaction, result)
	end
	def search_by_substance(key)
		ODBA.cache.retrieve_from_index('substance_index_atc', key.dup)
	end
	def search_by_unwanted_effect(key, lang)
		result = ODDB::SearchResult.new
		if(lang.to_s != "fr") 
			lang = "de"
		end
		sequences = ODBA.cache.retrieve_from_index("unwanted_effects_index_#{lang}", 
                                               key, result)
		_search_exact_classified_result(sequences, :unwanted_effect, result)
	end
	def search_doctors(key)
		ODBA.cache.retrieve_from_index("doctor_index", key)
	end
	def search_companies(key)
		ODBA.cache.retrieve_from_index("company_index", key)
	end
	def search_exact_company(query)
		result = ODDB::SearchResult.new
		result.search_type = :company
		result.atc_classes = search_by_company(query)
		result
	end
	def search_exact_indication(query, lang)
		result = ODDB::SearchResult.new
		result.exact = true
		result.search_type = :indication
		result.atc_classes = search_by_indication(query, lang, result)
		result
	end
	def search_migel_alphabetical(query, lang)
		if(lang.to_s != "fr") 
			lang = "de"
		end
		index_name = "migel_index_#{lang}"
		ODBA.cache.retrieve_from_index(index_name, query)
	end
	def search_migel_products(query, lang)
		if(lang.to_s != "fr") 
			lang = "de"
		end
		index_name = "migel_fulltext_index_#{lang}"
		ODBA.cache.retrieve_from_index(index_name, query)
	end
	def search_narcotics(query, lang)
		if(lang.to_s != "fr") 
			lang = "de"
		end
		index_name = "narcotics_#{lang}"
		ODBA.cache.retrieve_from_index(index_name, query)
	end
	def search_patinfos(query)
		ODBA.cache.retrieve_from_index('sequence_patinfos', query)
	end
	def search_vaccines(query)
		ODBA.cache.retrieve_from_index('sequence_vaccine', query)
	end
	def search_exact_sequence(query)
		sequences = search_sequences(query)
		_search_exact_classified_result(sequences, :sequence)
	end
	def search_exact_substance(query)
		sequences = ODBA.cache.\
			retrieve_from_index('substance_index_sequence', query)
		_search_exact_classified_result(sequences, :substance)
	end
	def _search_exact_classified_result(sequences, type=:unknown, result=nil)
		atc_classes = {}
		sequences.each { |seq|
			code = (atc = seq.atc_class) ? atc.code : 'n.n'
			new_atc = atc_classes.fetch(code) { 
				atc_class = ODDB::AtcClass.new(code)
				atc_class.descriptions = atc.descriptions unless(atc.nil?)
				atc_classes.store(code, atc_class)
			}
			new_atc.sequences.push(seq)
		}
		result ||= ODDB::SearchResult.new
		result.search_type = type
		result.atc_classes = atc_classes.values
		result
	end
	def search_hospitals(key)
		ODBA.cache.retrieve_from_index("hospital_index", key)
	end
	def search_indications(query)
		ODBA.cache.retrieve_from_index("indication_index", query)
	end
	def search_interactions(query)
		result = ODBA.cache.retrieve_from_index("sequence_index_substance", query)
		if(subs = substance(query))
			result.unshift(subs)
		end
		if(result.empty?)
			result = soundex_substances(query)
		end
		result
	end
	def search_sequences(query, chk_all_words=true)
		index = (chk_all_words) ? 'sequence_index' : 'sequence_index_exact'
		ODBA.cache.retrieve_from_index(index, query)
	end
	def search_single_substance(key)
		result = ODDB::SearchResult.new
		result.exact = true
		ODBA.cache.retrieve_from_index("substance_index", key, result).first
	end
	def search_substances(query)
		if(subs = substance(query))
			[subs]
		else
			soundex_substances(query)
		end
	end
	def sequences
		@registrations.values.inject([]) { |seq, reg| 
			seq.concat(reg.sequences.values)
		}
	end
	def set_currency_rate(symbol, value)
		@currency_rates.store(symbol, value)
	end
	def slate(name)
		@slates[name]
	end
	def soundex_substances(name)
		parts = ODDB::Text::Soundex.prepare(name).split(/\s+/)
		soundex = ODDB::Text::Soundex.soundex(parts)
		key = soundex.join(' ')
		ODBA.cache.retrieve_from_index("substance_soundex_index", key)
	end
  def sorted_minifis
    @minifis.values.sort_by { |minifi| 
      [ -minifi.publication_date.year, 
        -minifi.publication_date.month, minifi.name] }
  end
	def sponsor(flavor)
		@sponsors[flavor]
	end
	def substance(key)
		if(key.to_i.to_s == key.to_s)
			@substances[key.to_i]
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
	def substance_by_smcd(smcd)
		@substances.values.select { |sub|
			sub.swissmedic_code == smcd
		}.first
	end
	def substances
		@substances.values
	end
	def substance_count
		@substance_count ||= @substances.size
	end
	def updated(item)
		case item
		when ODDB::Registration, ODDB::Sequence, ODDB::Package, ODDB::AtcClass
			@last_medication_update = @@today
			odba_isolated_store
		when ODDB::LimitationText, ODDB::AtcClass::DDD
		when ODDB::Substance
			@substances.each_value { |subs|
				if(!subs.is_effective_form? && subs.effective_form == item)
					subs.odba_isolated_store
				end
			}
		end
	end
	def user(oid)
		@users[oid]
	end
	def user_by_email(email)
		@users.values.find { |user| user.unique_email == email }
	end
	def unique_atc_class(substance)
	 atc_array = search_by_substance(substance)
=begin ## this is much too unstable, completely wrong assignment is 
       ## probable!
	 if(atc_array.size > 1)
		 atc_array = atc_array.select { |atc|
			 atc.substances.size == 1
		 }
	 end
=end
	 if(atc_array.size == 1)
		 atc_array.first
	 end
  end
	def vaccine_count
		@vaccine_count ||= count_vaccines()
	end

	## indices
	def rebuild_indices(name=nil, &block)
		ODBA.cache.indices.size
		begin
			start = Time.now
			path = File.expand_path("../../etc/index_definitions.yaml", 
				File.dirname(__FILE__))
			FileUtils.mkdir_p(File.dirname(path))
			file = File.open(path)
			YAML.load_documents(file) { |index_definition|
        doit = if(name)
                 name.match(index_definition.index_name)
               elsif(block)
                 block.call(index_definition)
               else
                 true
               end
				if(doit)
					index_start = Time.now
					begin
						puts "dropping: #{index_definition.index_name}"
						ODBA.cache.drop_index(index_definition.index_name)
					rescue Exception => e
						puts e.message
					end
					puts "creating: #{index_definition.index_name}"
					ODBA.cache.create_index(index_definition, ODDB)
					begin 
						puts "filling: #{index_definition.index_name}"
						puts index_definition.init_source
						source = instance_eval(index_definition.init_source)
						puts "source.size: #{source.size}"
						ODBA.cache.fill_index(index_definition.index_name, 
							source)
					rescue Exception => e
						puts e.class
						puts e.message
						puts e.backtrace
					end
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
		ODBA.storage.remove_dictionary(language)
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
		RUN_EXPORTER_NOTIFY = true
		RUN_UPDATER = true
		SESSION = Session
		UNKNOWN_USER = UnknownUser
		UPDATE_INTERVAL = 24*60*60
		VALIDATOR = Validator
    YUS_SERVER = DRb::DRbObject.new(nil, YUS_URI)
		attr_reader :cleaner, :updater
		def initialize
			@admin_threads = ThreadGroup.new
			@system = ODBA.cache.fetch_named('oddbapp', self){
				OddbPrevalence.new
			}
			puts "init system"
			@system.init
			@system.odba_store
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
		def accept_orphaned(orphan, pointer, symbol, origin=nil)
			command = AcceptOrphan.new(orphan, pointer,symbol, origin)
			@system.execute_command(command)
		end
		def clean
			super
			@system.clean_invoices
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
    def create_commercial_forms
      @system.each_package { |pac| 
        if(comform = pac.comform)
          possibilities = [
            comform.strip,
            comform.gsub(/\([^\)]+\)/, '').strip,
            comform.gsub(/[()]/, '').strip,
          ].uniq.delete_if { |possibility| possibility.empty? }
          cform = nil
          possibilities.each { |possibility|
            if(cform = CommercialForm.find_by_name(possibility))
              break
            end
          }
          if(cform.nil?)
            args = { :de => possibilities.first, 
              :synonyms => possibilities[1..-1] }
            possibilities.each { |possibility|
              if(form = @system.galenic_form(possibility))
                args = form.descriptions
                args.store(:synonyms, form.synonyms)
                break
              end
            }
            pointer = Persistence::Pointer.new(:commercial_form)
            cform = @system.update(pointer.creator, args)
          end
          pac.commercial_form = cform
          pac.odba_store
        end
      }
    end
		def delete(pointer)
			@system.execute_command(DeleteCommand.new(pointer))
		end
    def inject_poweruser(email, pass, days)
      user_pointer = Persistence::Pointer.new(:poweruser)
      user_data = {
        :unique_email => email,
        :pass_hash    => Digest::MD5.hexdigest(pass),
      }
      invoice_pointer = Persistence::Pointer.new(:invoice)
      time = Time.now
      expiry = InvoiceItem.expiry_time(days, time)
      invoice_data = { :currency => State::PayPal::Checkout::CURRENCY }
      item_data = {
        :duration     => days,
        :expiry_time  => expiry,
        :total_netto  => State::Limit.price(days.to_i),
        :quantity     => days,
        :text         => 'unlimited access',
        :time         => time,
        :type         => :poweruser,
        :vat_rate     => VAT_RATE,
      }
      ODBA.transaction {
        user = @system.update(user_pointer.creator, user_data, :admin)
        invoice = @system.update(invoice_pointer.creator, invoice_data, :admin)
        item_pointer = invoice.pointer + [:item]
        @system.update(item_pointer.creator, item_data, :admin)
        user.add_invoice(invoice)
        invoice.payment_received!
        invoice.odba_isolated_store
      }
    end
		def merge_commercial_forms(source, target)
			command = MergeCommand.new(source.pointer, target.pointer)
			@system.execute_command(command)
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
		def update(pointer, values, origin=nil)
			#@system.execute_command(UpdateCommand.new(pointer, values))
			@system.update(pointer, values, origin)
		end
		#####################################################
		def _admin(src, result, priority=0)
			t = Thread.new {
				Thread.current.abort_on_exception = false
				result << failsafe {
					response = instance_eval(src)
					str = response.to_s
					if(str.length > 200)
						response.class
					else
						str
					end
				}.to_s
			}
			t[:source] = src
			t.priority = priority
			@admin_threads.add(t)
			t
		end
		def login(email, pass)
      YusUser.new(YUS_SERVER.login(email, pass, YUS_DOMAIN))
		end
    def logout(session)
      YUS_SERVER.logout(session)
    rescue DRb::DRbError, RangeError
    end
		def reset
			@updater.kill if(@updater.is_a? Thread)
			@exporter.kill if(@exporter.is_a? Thread)
			@updater = run_updater if RUN_UPDATER
			@exporter = run_exporter if RUN_EXPORTER
			@exporter_notify = run_exporter_notify if RUN_EXPORTER_NOTIFY
			@mutex.synchronize {
				@sessions.clear
			}
		end
		def run_exporter
			Thread.new {
				#Thread.current.priority=-10
				Thread.current.abort_on_exception = true
				today = (EXPORT_HOUR > Time.now.hour) ? \
					@@today : @@today.next
				loop {
					next_run = Time.local(today.year, today.month, today.day, 
						EXPORT_HOUR)
					sleep(next_run - Time.now)
					Exporter.new(self).run
					GC.start
					today = @@today.next
				}
			}
		end
		def run_exporter_notify
			Thread.new {
				#Thread.current.priority=-10
				Thread.current.abort_on_exception = true
				today = (10 > Time.now.hour) ? @@today : @@today.next
				loop {
					next_run = Time.local(today.year, today.month, today.day, 10)
					sleep(next_run - Time.now)
					Exporter.new(self).mail_notification_stats
					GC.start
					today = @@today.next
				}
			}
		end
		def run_updater
			update_hour = rand(24)
			update_min = rand(60)
			Thread.new {
				#Thread.current.priority=-5
				Thread.current.abort_on_exception = true
				today = (update_hour > Time.now.hour) ? \
					Date.today : @@today.next
				loop {
					next_run = Time.local(today.year, today.month, today.day, 
						update_hour, update_min)
					puts "next update will take place at #{next_run}"
					$stdout.flush
					sleep(next_run - Time.now)
					Updater.new(self).run
					@system.recount
					GC.start
					today = @@today.next
					update_hour = rand(24)
					update_min = rand(60)
				}
			}
		end
		def assign_effective_forms(arg=nil)
			ODBA.transaction {
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
							seq.active_agents.odba_isolated_store
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

    def yus_allowed?(email, action, key=nil)
      YUS_SERVER.autosession(YUS_DOMAIN) { |session|
        session.entity_allowed?(email, action, key)
      }
    end
    def yus_create_user(email, pass=nil)
      YUS_SERVER.autosession(YUS_DOMAIN) { |session|
        session.create_entity(email, pass)
      }
      # if there is a password, we can log in
      login(email, pass) if(pass)
    end
    def yus_grant(name, key, item, expires=nil)
      YUS_SERVER.autosession(YUS_DOMAIN) { |session|
        session.grant(name, key, item, expires)
      }
    end
    def yus_get_preference(name, key)
      YUS_SERVER.autosession(YUS_DOMAIN) { |session|
        session.get_entity_preference(name, key)
      }
    rescue Yus::YusError
      # user not found
    end
    def yus_get_preferences(name, keys)
      YUS_SERVER.autosession(YUS_DOMAIN) { |session|
        session.get_entity_preferences(name, keys)
      }
    rescue Yus::YusError
      {} # return an empty hash
    end
    def yus_model(name)
      if(odba_id = yus_get_preference(name, 'association'))
        ODBA.cache.fetch(odba_id, nil)
      end
    rescue Yus::YusError, ODBA::OdbaError
      # association not found
    end
    def yus_reset_password(name, token, password)
      YUS_SERVER.autosession(YUS_DOMAIN) { |session|
        session.reset_entity_password(name, token, password)
      }
    end
    def yus_set_preference(name, key, value, domain=YUS_DOMAIN)
      YUS_SERVER.autosession(YUS_DOMAIN) { |session|
        session.set_entity_preference(name, key, value, domain)
      }
    end

    def migrate_to_yus(email, pass)
      session = YUS_SERVER.login(email, pass, YUS_DOMAIN)
      @system.users.each_value { |userobj|
        klass = userobj.class.to_s.split('::').last
        group, user = nil
        unless(group = session.find_entity(klass))
          group = session.create_entity(klass)
        end
        privileges = [
          "login|org.oddb.#{klass}", 
        ]
        case klass 
        when 'RootUser' 
          #'view|org.oddb',
          privileges.concat [ 'grant|create', 'grant|edit', 'grant|credit',
            'edit|yus.entities', 'edit|org.oddb.drugs', 'set_password',
            'edit|org.oddb.model.!company.*', 
            'create|org.oddb.registration',
            'edit|org.oddb.model.!sponsor.*', 
            'edit|org.oddb.model.!indication.*', 
            'edit|org.oddb.model.!galenic_group.*', 
            'edit|org.oddb.model.!incomplete_registration.*', 
            'edit|org.oddb.model.!address.*', 
            'edit|org.oddb.model.!atc_class.*',
            'view|org.oddb.patinfo_stats', 
            'invoice|org.oddb.processing', 
          ]
        when 'AdminUser'
          privileges.concat [ 'edit|org.oddb.drugs', #'view|org.oddb',
            'create|org.oddb.registration', 
            'edit|org.oddb.model.!incomplete_registration.*', 
            'edit|org.oddb.model.!indication', 
            'edit|org.oddb.model.!galenic_group.*', 
          ]
        when 'CompanyUser'
          privileges.concat [ 'edit|org.oddb.drugs', #'view|org.oddb',
            'create|org.oddb.registration', 
            'edit|org.oddb.model.!galenic_group.*', 
            'view|org.oddb.patinfo_stats.associated', 
          ]
        when 'PowerLinkUser'
          privileges.concat [ 'edit|org.oddb.powerlinks', #'view|org.oddb',
            'edit|org.oddb.drugs', 
          ]
        #when 'PowerUser'
        else
          [] # no further privileges
        end
        privileges.each { |priv|
          session.grant(klass, *priv.split('|'))
        }
				empty = if(userobj.respond_to?(:invoices))
									userobj.invoices.delete_if { |inv| inv.odba_instance.nil? }
									userobj.invoices.empty?
								else
									false 
								end
        if(!empty && (email = userobj.unique_email) && !email.empty?)
          unless(user = session.find_entity(email))
            user = session.create_entity(email)
          end
          session.affiliate(email, klass)
          if(hash = userobj.pass_hash)
            session.set_password(email, hash)
          end
          if(model = userobj.model.odba_instance)
            session.grant(email, "edit", model.pointer.to_yus_privilege)
            if(contact = model.contact)
              contact.slice!(/^(Herr|Frau)\s+/)
              name_first, name_last = contact.split(' ', 2)
              session.set_entity_preference(email, 'name_first', name_first)
              session.set_entity_preference(email, 'name_last', name_last)
            end
            session.set_entity_preference(email, 'association', model.odba_id)
          end
          if(userobj.respond_to?(:paid_invoices))
            userobj.invoices.delete_if { |inv| inv.odba_instance.nil? }
            pair = userobj.paid_invoices.inject([]) { |memo, invoice|
              invoice.items.each_value { |item|
                if(item.type == :poweruser && time = item.expiry_time)
                  memo.push([time, item.duration])
                end
              }
              memo
            }.max || [Time.now, 1]
            session.grant(email, 'view', 'org.oddb', pair.first)
            session.set_entity_preference(email, 'poweruser_duration', pair.last)
            userobj.invoices.each { |inv|
              inv.yus_name = email
              inv.odba_store
            }
          end
          if(userobj.creditable?('download'))
            session.grant(email, 'credit', 'org.oddb.download')
          end
          YusUser::PREFERENCE_KEYS.each { |key|
            if(userobj.respond_to?(key) && (val = userobj.send(key)))
              session.set_entity_preference(email, key, val, YUS_DOMAIN)
            end
          }
        end
      }
      session.grant('hwyss@ywesee.com', 'grant', 'grant')
      session.grant('hwyss@ywesee.com', 'grant', 'login')
      klass = 'DownloadUser'
      unless(group = session.find_entity(klass))
        group = session.create_entity(klass)
        session.grant(klass, 'login', 'org.oddb.DownloadUser')
      end
      @system.admin_subsystem.download_users.each { |email, userobj|
				userobj.invoices.delete_if { |inv| inv.odba_instance.nil? }
				unless(userobj.invoices.empty?)
					unless(user = session.find_entity(email))
						user = session.create_entity(email)
					end
					session.affiliate(email, klass)
					userobj.invoices.delete_if { |inv| inv.odba_instance.nil? }
					userobj.invoices.each { |invoice|
						invoice.items.each_value { |item|
							if(item.type == :download && item.expiry_time > Time.now)
								session.grant(email, 'download', item.text, item.expiry_time)
							end
						}
					}
					YusUser::PREFERENCE_KEYS.each { |key|
						if(userobj.respond_to?(key) && (val = userobj.send(key)))
							session.set_entity_preference(email, key, val, YUS_DOMAIN)
						end
					}
					userobj.invoices.each { |inv|
						inv.yus_name = email
						inv.odba_store
					}
				end
      }

      # Fix all Invoices and InvoiceItems - user_pointer -> yus_name
      ptr_replace = Proc.new { |item|
        if((ptr = item.user_pointer) && user = ptr.resolve(@system))
          item.yus_name = user.unique_email
          item.odba_store
        end
      }
      @system.invoices.each_value { |inv|
        ptr_replace.call(inv)
        inv.items.each_value { |item|
          ptr_replace.call(item)
        }
      }
      @system.slates.each_value { |slate|
        slate.items.each_value { |item|
          ptr_replace.call(item)
        }
      }
		rescue StandardError => e
			puts e.class, e.message	
			puts e.backtrace
		ensure
      YUS_SERVER.logout(session)
    end
		def multilinguify_analysis
			@system.analysis_positions.each { |pos|
				if(descr = pos.description)
					pos.instance_variable_set('@description', nil)
					@system.update(pos.pointer, {:de => descr})
				end
				if(fn = pos.footnote)
					pos.instance_variable_set('@footnote', nil)
					ptr = pos.pointer + :footnote
					@system.update(ptr.creator, {:de => fn})
				end
				if(lt = pos.list_title)
					pos.instance_variable_set('@list_title', nil)
					ptr = pos.pointer + :list_title
					@system.update(ptr.creator, {:de => lt})
				end
				if(tn = pos.taxnote)
					pos.instance_variable_set('@taxnote', nil)
					ptr = pos.pointer + :taxnote
					@system.update(ptr.creator, {:de => tn})
				end
				if(perm = pos.permissions)
					pos.instance_variable_set('@permissions', nil)
					ptr = pos.pointer + :permissions
					@system.update(ptr.creator, {:de => perm})
				end
				if(lim = pos.instance_variable_get('@limitation'))
					pos.instance_variable_set('@limitation', nil)
					ptr = pos.pointer + :limitation_text
					@system.update(ptr.creator, {:de => lim})
				end
				pos.odba_store
			}
		end
	end
end

begin 
	require 'testenvironment'
rescue LoadError
end
