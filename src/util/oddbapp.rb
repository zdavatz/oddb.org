#!/usr/bin/env ruby
# encoding: utf-8
# OddbApp -- oddb.org -- 12.01.2012 -- mhatakeyama@ywesee.com
# OddbApp -- oddb.org -- 21.06.2010 -- hwyss@ywesee.com

require 'yaml'
YAML::ENGINE.yamler = "syck"
require 'odba'
require 'odba/index_definition'
require 'odba/drbwrapper'
require 'odba/18_19_loading_compatibility'
require 'custom/lookandfeelbase'
require 'util/currency'
require 'util/failsafe'
require 'util/ipn'
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
require 'util/ngram_similarity'
require 'util/today'
require 'models'
require 'commands'
require 'paypal'
require 'sbsm/drbserver'
require 'sbsm/index'
require 'util/config'
require 'fileutils'
require 'yus/session'
require 'model/migel/group'
require 'model/analysis/group'

require 'remote/migel/model'

class OddbPrevalence
	include ODDB::Failsafe
	include ODBA::Persistable
  RESULT_SIZE_LIMIT = 250
	ODBA_EXCLUDE_VARS = [
		"@atc_chooser", "@bean_counter", "@sorted_fachinfos", "@sorted_feedbacks",
    "@sorted_minifis",
	]
	ODBA_SERIALIZABLE = [ '@currency_rates', '@rss_updates' ]
	attr_reader :address_suggestions, :atc_chooser, :atc_classes, :analysis_groups,
		:companies, :doctors, :fachinfos, :galenic_groups, :migel_groups,
		:hospitals, :invoices, :last_medication_update, :last_update,
    :minifis, :notification_logger, :orphaned_fachinfos,
    :orphaned_patinfos, :patinfos, :patinfos_deprived_sequences,
    :registrations, :slates, :users, :narcotics, :accepted_orphans,
    :commercial_forms, :rss_updates, :feedbacks, :indices_therapeutici,
    :generic_groups
	def initialize
		init
		@last_medication_update ||= Time.now()
	end
	def init
		create_unknown_galenic_group()
		@accepted_orphans ||= {}
		@address_suggestions ||= {}
		@analysis_groups ||= {}
		@atc_classes ||= {}
		@commercial_forms ||= {}
		@companies ||= {}
		@currency_rates ||= {}
		@cyp450s ||= {}
		@doctors ||= {}
		@fachinfos ||= {}
    @feedbacks ||= {}
		@galenic_forms ||= []
		@galenic_groups ||= []
		@generic_groups ||= {}
		@hospitals ||= {}
		@indications ||= {}
    @indices_therapeutici ||= {}
		@invoices ||= {}
		@log_groups ||= {}
		@migel_groups ||= {}
    @minifis ||= {}
		@narcotics ||= {}
		@notification_logger ||= ODDB::NotificationLogger.new
		@orphaned_fachinfos ||= {}
		@orphaned_patinfos ||= {}
		@patinfos ||= {}
		@patinfos_deprived_sequences ||= []
		@registrations ||= {}
    @rss_updates ||= {}
		@slates ||= {}
		@sponsors ||= {}
		@substances ||= {}
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
  def active_fachinfos
    active = {}
    @registrations.each_value { |reg|
      if(reg.active? && reg.fachinfo)
        active.store(reg.pointer, 1)
      end
    }
    active
  end
	def active_pdf_patinfos
		active = {}
		each_sequence { |seq|
			if(str = seq.active_patinfo)
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
  def commercial_form_by_name(name)
    ODDB::CommercialForm.find_by_name(name)
  end
	def company(oid)
		@companies[oid.to_i]
	end
  def company_by_name(name, ngram_cutoff=nil)
    _company_by_name(name, ngram_cutoff) \
      || _company_by_name(name, ngram_cutoff, /\s*(ag|gmbh|sa)\b/i)
  end
  def _company_by_name(name, ngram_cutoff=nil, filter=nil)
    namedown = name.to_s.downcase
    if filter
      namedown.gsub! filter, ''
    end
    @companies.each_value { |company|
      name = company.name.to_s.downcase
      if filter
        name.gsub! filter, ''
      end
      if name == namedown \
        || (ngram_cutoff \
            && ODDB::Util::NGramSimilarity.compare(name, namedown) > ngram_cutoff)
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
		if((grp = log_group(:swissmedic) || log_group(:swissmedic_journal)) \
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
  def create_feedback
    feedback = ODDB::Feedback.new
    @feedbacks.store(feedback.oid, feedback) 
  end
	def create_galenic_group
		galenic_group = ODDB::GalenicGroup.new
		@galenic_groups.store(galenic_group.oid, galenic_group)
	end
	def create_generic_group(package_pointer)
		@generic_groups.store(package_pointer, ODDB::GenericGroup.new)
	end
  def create_index_therapeuticus(code)
    code = code.to_s
    it = ODDB::IndexTherapeuticus.new(code)
    @indices_therapeutici.store(code, it)
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
		orphan = ODDB::OrphanedTextInfo.new
	  @orphaned_fachinfos.store(orphan.oid, orphan)
	end
	def create_orphaned_patinfo
		orphan = ODDB::OrphanedTextInfo.new
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
  def delete_all_analysis_group
    analysis_positions.each do |pos|
      delete(pos.pointer)
    end
    analysis_groups.values.each do |grp|
      delete(grp.pointer)
    end
  end
  def delete_all_migel_group
    migel_products.each do |prd|
      delete(prd.pointer)
    end
    @migel_groups.each_value { |group| 
      group.subgroups.each_value { |subgrp|
        delete(subgrp.pointer)
      }
    }
    migel_groups.values.each do |group|
      delete(group.pointer)
    end
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
  def delete_index_therapeuticus(code)
    code = code.to_s
    if(it = @indices_therapeutici.delete(code))
      @indices_therapeutici.odba_isolated_store
      it
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
  def each_migel_product(&block)
    @migel_groups.each_value { |group| 
      group.subgroups.each_value { |subgr|
        subgr.products.each_value(&block)
      }
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
  def feedback(id)
    @feedbacks[id.to_i]
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
  def index_therapeuticus(code)
    @indices_therapeutici[code.to_s]
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
	def narcotic(oid)
		@narcotics[oid.to_i]
	end
	def narcotic_by_casrn(casrn)
    GC.start
		unless(casrn.nil?)
      @narcotics.values.find do |narc| narc.casrn == casrn end
    end
	end
	def narcotic_by_smcd(smcd)
    GC.start
		unless(smcd.nil?)
      @narcotics.values.find do |narc| narc.swissmedic_codes.include?(smcd) end
		end
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
  def package(pcode)
    ODDB::Package.find_by_pharmacode(pcode.to_s.gsub(/^0+/u, ''))
  end
  def package_by_ikskey(ikskey)
    ikskey = ikskey.to_s
    iksnr = "%05i" % ikskey[-8..-4].to_i
    ikscd = ikskey[-3..-1]
    if reg = registration(iksnr)
      reg.package ikscd
    end
  end
	def package_count
		@package_count ||= count_packages()
	end
  def packages
    @registrations.inject([]) { |pacs, (iksnr,reg)| 
      pacs.concat(reg.packages)
    }
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
    again = true
		if(@bean_counter.is_a?(Thread) && @bean_counter.status)
			return again = true
		end
		@bean_counter = Thread.new {
      while(again)
        again = false
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
      end
		}
	end
	def registration(registration_id)
		@registrations[registration_id]
	end
  def each_registration
		@registrations.values.each do |reg|
      yield reg
    end
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
  @@iks_or_ean = /(?:\d{4})?(\d{5})(?:\d{4})?/u
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
    end
		# iksnr or ean13
		if(match = @@iks_or_ean.match(query))
			iksnr = match[1]
			if(reg = registration(iksnr))
				atc = ODDB::AtcClass.new('n.n.')
				atc.sequences = reg.sequences.values
				result.atc_classes = [atc]
				result.search_type = :iksnr
				return result
			end
    end
		# pharmacode
    if(match = /^\d{6,}$/u.match(query))
      if(pac = package(query))
				atc = ODDB::AtcClass.new('n.n.')
        seq = ODDB::Sequence.new(pac.sequence.seqnr)
        seq.registration = pac.registration
        seq.packages.store pac.ikscd, pac
				atc.sequences = [seq]
				result.atc_classes = [atc]
				result.search_type = :pharmacode
				return result
      end
		end
		key = query.to_s.downcase
		# atc-code
		atcs = search_by_atc(key)
		result.search_type = :atc
    result.error_limit = RESULT_SIZE_LIMIT
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
		result = ODDB::SearchResult.new
    result.error_limit = RESULT_SIZE_LIMIT
		atcs = ODBA.cache.retrieve_from_index('atc_index_company', key.dup, result)
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
    result.error_limit = RESULT_SIZE_LIMIT
		if(lang.to_s != "fr") 
			lang = "de"
		end
		sequences = ODBA.cache.retrieve_from_index("interactions_index_#{lang}", 
                                               key, result)
    key = key.downcase
    sequences.reject! { |seq| 
      ODDB.search_terms(seq.search_terms, :downcase => true).include?(key) \
        || seq.substances.any? { |sub|
        sub.search_keys.any? { |skey| skey.downcase.include?(key) }
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
  def search_migel_group(migel_code)
    migel_group(migel_code)
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
		if(subs = substance(query, false))
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
    key = ODDB.search_term(key)
		ODBA.cache.retrieve_from_index("substance_index", key, result).find { |sub|
      sub.same_as? key
    }
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
  def rebuild_slates(name=:patinfo, type=:annual_fee) 
    case name
    when :patinfo
      slate(name).items.values.select{|i| i.type == type}.each do |item|
        rebuild_patinfo_slate_item(item, type)
      end
    when :fachinfo
      slate(name).items.values.select{|i| i.type == type}.each do |item|
        rebuild_fachinfo_slate_item(item, type)
      end
    end
  end
  def rebuild_patinfo_slate_item(item, type)
    #p "item.pointer = #{item.pointer}"
    sequence = item.sequence || resolve(item.item_pointer)
    if sequence and sequence.is_a?(ODDB::Sequence)
      values = {
        :data         =>  {:name => sequence.name},
        :duration     =>  ODDB::PI_UPLOAD_DURATION,
        :expiry_time  =>  item.expiry_time,
        :item_pointer =>  sequence.pointer,
        :price        =>  ODDB::PI_UPLOAD_PRICES[type],
        :text         =>  item.text,
        :time         =>  item.time,
        :type         =>  type,
        :unit         =>  item.unit,
        :yus_name     =>  item.yus_name,
        :vat_rate     =>  ODDB::VAT_RATE,
      }
      #puts "values = #{values.pretty_inspect}"
      begin
        item.data[:name]
        update(item.pointer, values, :admin)
      rescue
        delete(item.pointer)
        slate_pointer = ODDB::Persistence::Pointer.new([:slate, :patinfo])
        create(slate_pointer)
        item_pointer = slate_pointer + :item
        #p "item_pointer = #{item_pointer}"
        obj = update(item_pointer.creator, values, :admin)
        #p "obj.pointer = #{obj.pointer}"
      end
    end
  end
  def rebuild_fachinfo_slate_item(item, type)
    if registration = resolve(item.item_pointer) and registration.is_a?(ODDB::Registration)
      values = {
        :data         =>  {:name => registration.name_base},
        :duration     =>  ODDB::FI_UPLOAD_DURATION,
        :expiry_time  =>  item.expiry_time,
        :item_pointer =>  registration.pointer,
        :price        =>  ODDB::FI_UPLOAD_PRICES[type],
        :text         =>  registration.iksnr,
        :time         =>  item.time,
        :type         =>  type,
        :unit         =>  item.unit,
        :yus_name     =>  item.yus_name,
        :vat_rate     =>  ODDB::VAT_RATE,
      }
      #puts "values = #{values.pretty_inspect}"
      begin
        item.data[:name]
        update(item.pointer, values, :admin)
      rescue
        delete(item.pointer)
        slate_pointer = ODDB::Persistence::Pointer.new([:slate, :fachinfo])
        create(slate_pointer)
        item_pointer = slate_pointer + :item
        #p "item_pointer = #{item_pointer}"
        obj = update(item_pointer.creator, values, :admin)
        #p "obj.pointer = #{obj.pointer}"
      end
    end
  end
	def soundex_substances(name)
		parts = ODDB::Text::Soundex.prepare(name).split(/\s+/u)
		soundex = ODDB::Text::Soundex.soundex(parts)
		key = soundex.join(' ')
		ODBA.cache.retrieve_from_index("substance_soundex_index", key)
	end
  def sorted_fachinfos
    @sorted_fachinfos ||= @fachinfos.values.select { |fi| 
      fi.revision }.sort_by { |fi| fi.revision }.reverse
  end
  def sorted_feedbacks
    @sorted_feedbacks ||= @feedbacks.values.sort_by { |fb| fb.time }.reverse
  end
  def sorted_minifis
    @sorted_minifis ||= @minifis.values.sort_by { |minifi| 
      [ -minifi.publication_date.year, 
        -minifi.publication_date.month, minifi.name] }
  end
  def sorted_patented_registrations
    @registrations.values.select { |reg|
      (pat = reg.patent) && pat.expiry_date #_protected?
    }.sort_by { |reg| reg.patent.expiry_date }
  end
	def sponsor(flavor)
		@sponsors[flavor.to_s]
	end
	def substance(key, neurotic=false)
		if(key.to_i.to_s == key.to_s)
			@substances[key.to_i]
		elsif(substance = search_single_substance(key))
			substance
    elsif neurotic
			@substances.values.find { |subs|
				subs.same_as?(key)
			}
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
    when ODDB::Fachinfo, ODDB::FachinfoDocument
      @sorted_fachinfos = nil
    when ODDB::Feedback
      @sorted_feedbacks = nil
    when ODDB::MiniFi
      @sorted_minifis = nil
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
					rescue StandardError => e
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
					rescue StandardError => e
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
  def update_ibflag
    @registrations.values.select{|r| r.production_science =~ /Blutprodukte/ or r.production_science =~ /Impfstoffe/}.sort_by{|r| r.iksnr}.each do |reg|
      unless reg.vaccine
        ptr = reg.pointer
        args = {:vaccine => true}
        update ptr, args, :swissmedic
      end
    end
  end
  def set_inactive_date_nil(date)
    @registrations.values.each do |reg|
      if reg.inactive_date == date
        update reg.pointer, {:inactive_date => nil}, :admin
      end
    end
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
end

module ODDB
	class App < SBSM::DRbServer
		include Failsafe
		AUTOSNAPSHOT = true
		CLEANING_INTERVAL = 5*60
		EXPORT_HOUR = 2
		UPDATE_HOUR = 9
    MEMORY_LIMIT = 20480
		RUN_CLEANER = true
		RUN_UPDATER = true
		SESSION = Session
		UNKNOWN_USER = UnknownUser
		UPDATE_INTERVAL = 24*60*60
		VALIDATOR = Validator
    YUS_SERVER = DRb::DRbObject.new(nil, YUS_URI)
    MIGEL_SERVER = DRb::DRbObject.new(nil, MIGEL_URI)
		attr_reader :cleaner, :updater
		def initialize opts={}
      @rss_mutex = Mutex.new
			@admin_threads = ThreadGroup.new
      start = Time.now
			@system = ODBA.cache.fetch_named('oddbapp', self){
				OddbPrevalence.new
			}
			puts "init system"
			@system.init
			@system.odba_store
      puts "init system: #{Time.now - start}"
			puts "setup drb-delegation"
			super(@system)
      return if opts[:auxiliary]
			puts "reset"
			reset()
      puts "reset: #{Time.now - start}"
      log_size
			puts "system initialized"
      puts "initialized: #{Time.now - start}"
		end
		# prevalence-methods ################################
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
    def create_commercial_forms
      @system.each_package { |pac| 
        if(comform = pac.comform)
          possibilities = [
            comform.strip,
            comform.gsub(/\([^\)]+\)/u, '').strip,
            comform.gsub(/[()]/u, '').strip,
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
      user = @system.update(user_pointer.creator, user_data, :admin)
      invoice = @system.update(invoice_pointer.creator, invoice_data, :admin)
      item_pointer = invoice.pointer + [:item]
      @system.update(item_pointer.creator, item_data, :admin)
      user.add_invoice(invoice)
      invoice.payment_received!
      invoice.odba_isolated_store
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
    def merge_indications(source, target)
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
			@system.update(pointer, values, origin)
		end
    def set_all_export_flag_registration(boolean)
      data = {:export_flag => boolean}
      @system.each_registration do |reg|
        update reg.pointer, data, :swissmedic
      end
    end
    def set_all_export_flag_sequence(boolean)
      data = {:export_flag => boolean}
      @system.each_sequence do |seq|
        update seq.pointer, data, :swissmedic
      end
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
		def login_token(email, token)
      YusUser.new(YUS_SERVER.login_token(email, token, YUS_DOMAIN))
		end
    def logout(session)
      YUS_SERVER.logout(session)
    rescue DRb::DRbError, RangeError
    end
    def peer_cache cache
      ODBA.peer cache
    end
		def reset
			@random_updater.kill if(@random_updater.is_a? Thread)
      if RUN_UPDATER
        @random_updater = run_random_updater
      end
			@mutex.synchronize {
				@sessions.clear
			}
		end
    def run_random_updater
      Thread.new {
        Thread.current.abort_on_exception = true
        update_hour = rand(24)
        update_min = rand(60)
        day = (update_hour > Time.now.hour) ? \
          today : today.next
        loop {
          next_run = Time.local(day.year, day.month, day.day,
            update_hour, update_min)
          puts "next random update will take place at #{next_run}"
          $stdout.flush
          sleep(next_run - Time.now)
          Updater.new(self).run_random
          @system.recount
          GC.start
          day = today.next
          update_hour = rand(24)
          update_min = rand(60)
        }
      }
    end
    def unpeer_cache cache
      ODBA.unpeer cache
    end
    def update_feedback_rss_feed
      async {
        begin
        @rss_mutex.synchronize {
          values = @system.sorted_feedbacks
          values.select! do |feedback|
            feedback.item.is_a?(ODDB::Package) if feedback.item
          end
          values.each do |feedback|
            if feedback.item.name
              feedback.item.name.force_encoding('utf-8')
            end
            if feedback.item.respond_to?(:size) and feedback.item.size
              feedback.item.size.force_encoding('utf-8')
            end
            feedback.name.force_encoding('utf-8') if feedback.name
            feedback.email.force_encoding('utf-8') if feedback.email
            feedback.message.force_encoding('utf-8') if feedback.message
          end
          plg = Plugin.new(self)
          plg.update_rss_feeds('feedback.rss', values, View::Rss::Feedback)
        }
        rescue StandardError => e
          puts e.message
          puts e.backtrace
        end
      }
    end

    def ipn(notification)
      Util::Ipn.process notification, self
      nil # don't return the invoice back across drb - it's not defined in yipn
    end
    def grant_download(email, filename, price, expires=Time.now+2592000)
      ip = Persistence::Pointer.new(:invoice)
      inv = update ip.creator, :yus_name => email, :currency => 'EUR'
      itp = inv.pointer + :item
      update itp.creator, :text => filename, :price => price, :time => Time.now,
                          :type => :download, :expiry_time => expires,
                          :duration => (Time.now - expires) / 86400,
                          :vat_rate => 8.0
      inv.payment_received!
      inv.odba_store
      "http://#{SERVER_NAME}/de/gcc/download/invoice/#{inv.oid}/email/#{email}/filename/#{filename}"
    end

		def assign_effective_forms(arg=nil)
      _assign_effective_forms(arg)
		end
		def _assign_effective_forms(arg=nil)
			result = nil
			last = nil
			@system.substances.select { |subs| 
				!subs.has_effective_form? && (arg.nil? || arg.to_s < subs.to_s)
			}.sort_by { |subs| subs.name }.each { |subs|
				puts "Looking for effective form of ->#{subs}<- (#{subs.sequences.size} Sequences)"
				name = subs.to_s
				parts = name.split(/\s/u)
				suggest = if(parts.size == 1)
					subs
				elsif(![nil, '', 'Acidum'].include?(parts.first))
					@system.search_single_substance(parts.first) \
						|| @system.search_single_substance(parts.first.gsub(/i$/u, 'um'))
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
					when /c .+/u
						puts "creating:"
						pointer = Persistence::Pointer.new(:substance)
						puts "pointer: #{pointer}"
						args = { :lt => answer.split(/\s+/u, 2).last.strip }
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
    def migrate_feedbacks
      @system.each_package { |pac|
        _migrate_feedbacks(pac)
      }
      @system.each_migel_product { |prd|
        _migrate_feedbacks(prd)
      }
      @system.feedbacks.odba_store
      @system.odba_store
      update_feedback_rss_feed
    end
    def _migrate_feedbacks(item)
      item = item.odba_instance
      fbs = item.instance_variable_get('@feedbacks').odba_instance
      case fbs
      when Array
        # already migrated, ignore
      when Hash
        new = fbs.values.select { |fb| 
          fb.is_a?(Feedback) 
        }.sort_by { |fb| fb.time }.reverse
        fbs.odba_delete
        new.odba_store
        item.instance_variable_set('@feedbacks', new)
        item.odba_store
        new.each { |fb|
          id = fb.odba_id
          fb.instance_variable_set('@oid', id)
          ptr = Persistence::Pointer.new([:feedback, id])
          fb.instance_variable_set('@pointer', ptr)
          @system.feedbacks.store(id, fb)
          fb.instance_variable_set('@item', item)
          fb.odba_store
        }
      when nil
        item.instance_variable_set('@feedbacks', [])
        item.odba_store
      end
    end
    def utf8ify(object, opts={})
      from = 'ISO-8859-1'
      to = 'UTF-8//TRANSLIT//IGNORE'
      if opts[:reverse]
        from, to = to, from
      end
      iconv = ::Iconv.new to, from
      _migrate_to_utf8([object], {}, iconv)
    end
    def migrate_to_utf8
      iconv = ::Iconv.new 'UTF-8//TRANSLIT//IGNORE', 'ISO-8859-1'
      ODBA.cache.retire_age = 5
      ODBA.cache.cleaner_step = 100000
      system = @system.odba_instance
      table = { system.odba_id => true, :serialized => {} }
      table.store :finalizer, proc { |object_id|
        table[:serialized].delete object_id }
      queue = [ system ]
      last_size = 0
      system.instance_variable_set '@config', nil
      while !queue.empty?
        if (queue.size - last_size).abs >= 10000
          puts last_size = queue.size
        end
        _migrate_to_utf8 queue, table, iconv, :all => true
      end
    end
    def _migrate_to_utf8 queue, table, iconv, opts={}
      obj = queue.shift
      if obj.is_a?(Numeric)
        begin
          obj = ODBA.cache.fetch obj
        rescue ODBA::OdbaError
          return
        end
      else
        obj = obj.odba_instance
      end
      _migrate_obj_to_utf8 obj, queue, table, iconv, opts
      obj.odba_store unless obj.odba_unsaved?
    end
    def _migrate_obj_to_utf8 obj, queue, table, iconv, opts={}
      obj.instance_variables.each do |name|
        child = obj.instance_variable_get name
        if child.respond_to?(:odba_unsaved?) && !child.odba_unsaved? \
          && obj.respond_to?(:odba_serializables) \
          && obj.odba_serializables.include?(name)
          child.instance_variable_set '@odba_persistent', nil
        end
        child = _migrate_child_to_utf8 child, queue, table, iconv, opts
        obj.instance_variable_set name, child
      end
      if obj.is_a?(Array)
        obj.collect! do |child|
          _migrate_child_to_utf8 child, queue, table, iconv, opts
        end
      end
      if obj.is_a?(Hash)
        obj.dup.each do |key, child|
          obj.store key, _migrate_child_to_utf8(child, queue, table, iconv, opts)
        end
        if obj.is_a?(ODDB::SimpleLanguage::Descriptions)
          obj.default = _migrate_child_to_utf8 obj.default, queue, table, iconv, opts
        end
      end
      obj
    end
    def _migrate_child_to_utf8 child, queue, table, iconv, opts={}
      @serialized ||= {}
      case child
      when ODBA::Persistable, ODBA::Stub
        if child = child.odba_instance
          if child.odba_unsaved?
            _migrate_to_utf8 [child], table, iconv, opts
          elsif opts[:all]
            odba_id = child.odba_id
            unless table[odba_id]
              table.store odba_id, true
              queue.push odba_id
            end
          end
        end
      when String
        child = iconv.iconv(child)
      when ODDB::Text::Section, ODDB::Text::Paragraph, ODDB::PatinfoDocument,
           ODDB::PatinfoDocument2001, ODDB::Text::Table, ODDB::Text::Cell,
           ODDB::Analysis::Permission, ODDB::Interaction::AbstractLink,
           ODDB::Dose
        child = _migrate_obj_to_utf8 child, queue, table, iconv, opts
      when ODDB::Address2
        ## Address2 may cause StackOverflow if not controlled
        unless table[:serialized][child.object_id]
          table[:serialized].store child.object_id, true
          ObjectSpace.define_finalizer child, table[:finalizer]
          child = _migrate_obj_to_utf8 child, queue, table, iconv, opts
        end
      when Float, Fixnum, TrueClass, FalseClass, NilClass,
        ODDB::Persistence::Pointer, Symbol, Time, Date, ODDB::Dose, Quanty,
        ODDB::Util::Money, ODDB::Fachinfo::ChangeLogItem, ODDB::AtcNode,
        DateTime, ODDB::NotificationLogger::LogEntry, ODDB::Text::Format,
        ODDB::YusStub, ODDB::Text::ImageLink
        # do nothing
      else
        @ignored ||= {}
        unless @ignored[child.class]
          @ignored.store child.class, true
          warn "ignoring #{child.class}"
        end
      end
      child
    rescue SystemStackError
      puts child.class
      raise
    end

    def log_size
      @size_logger = Thread.new {
        time = Time.now
        bytes = 0
        threads = 0
        sessions = 0
        format = "%s %s: sessions: %4i - threads: %4i - memory: %4iMB %s"
        loop {
          begin
            lasttime = time
            time = Time.now
            alarm = time - lasttime > 60 ? '*' : ' '
            lastthreads = threads
            threads = Thread.list.size
            lastbytes = bytes
            bytes = File.read("/proc/#{$$}/stat").split(' ').at(22).to_i
            mbytes = bytes / (2**20)
            if mbytes > MEMORY_LIMIT
              puts "Footprint exceeds #{MEMORY_LIMIT}MB. Exiting."
              Thread.main.raise SystemExit
            end
            lastsessions = sessions
            sessions = @sessions.size
            gc = ''
            gc << 'S' if sessions < lastsessions
            gc << 'T' if threads < lastthreads
            gc << 'M' if bytes < lastbytes
            path = File.expand_path('../../doc/resources/downloads/status',
                                    File.dirname(__FILE__))
            lines = File.readlines(path)[0,100] rescue []
            lines.unshift sprintf(format, alarm, 
                                  time.strftime('%Y-%m-%d %H:%M:%S'),
                                  sessions, threads, mbytes, gc)
            File.open(path, 'w') { |fh|
              fh.puts lines
            }
          rescue StandardError => e
            puts e.class
            puts e.message
            $stdout.flush
          end
        sleep 5
        }
      }
    end
    # The followings are for migel data to access to migel drb server
    # @system (OddbPreverance) methods are replaced by the following methods
    def search_migel_alphabetical(query, lang)
      search_method = 'search_by_name_' + lang.downcase.to_s
      MIGEL_SERVER.migelid.send(search_method, query)
    end
    def search_migel_products(query, lang)
      migel_code = if query =~ /(\d){9}/
                     query.split(/(\d\d)/).select{|x| !x.empty?}.join('.')
                   elsif query =~ /(\d\d\.){4}\d/
                     query
                   end
      if migel_code
         MIGEL_SERVER.migelid.search_by_migel_code(migel_code)
         #MIGEL_SERVER.search_migel_product_by_migel_code(migel_code)
      else
        MIGEL_SERVER.search_migel_migelid(query, lang)
      end
    end
    def search_migel_subgroup(migel_code)
      code = migel_code.split(/(\d\d)/).select{|x| !x.empty?}.join('.')
      MIGEL_SERVER.subgroup.find_by_migel_code(code)
    end
    def search_migel_limitation(migel_code)
      code = migel_code.split(/(\d\d)/).select{|x| !x.empty?}.join('.')
      MIGEL_SERVER.search_limitation(code)
    end
    def search_migel_items_by_migel_code(query, sortvalue = nil, reverse = nil)
      # migel_search event
      # search items by migel_code
      migel_code = if query =~ /(\d){9}/
                     query.split(/(\d\d)/).select{|x| !x.empty?}.join('.')
                   elsif query =~ /(\d\d\.){4}\d/
                     query
                   end
      MIGEL_SERVER.search_migel_product_by_migel_code(migel_code, sortvalue, reverse)
    end
    def search_migel_items(query, lang, sortvalue = nil, reverse = nil)
      # search event
      # search items by using search box
      if query =~ /^\d{13}$/
        MIGEL_SERVER.product.search_by_ean_code(query)
      elsif query =~ /^\d{6,}$/
        MIGEL_SERVER.product.search_by_pharmacode(query)
      else
        MIGEL_SERVER.search_migel_product(query, lang, sortvalue, reverse)
      end
    end
	end
end

begin 
	require 'testenvironment'
rescue LoadError
end
