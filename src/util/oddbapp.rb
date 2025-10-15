#!/usr/bin/env ruby

# OddbApp -- oddb.org -- 15.03.2013 -- yasaka@ywesee.com
# OddbApp -- oddb.org -- 21.02.2012 -- mhatakeyama@ywesee.com
# OddbApp -- oddb.org -- 21.06.2010 -- hwyss@ywesee.com

require "odba"
require "odba/index_definition"
require "odba/drbwrapper"
require "odba/18_19_loading_compatibility"
require "custom/lookandfeelbase"
require "util/failsafe"
require "util/ipn"
require "util/oddbconfig"
require "util/searchterms"
require "util/session"
require "util/updater"
require "util/exporter"
require "util/validator"
require "util/loggroup"
require "util/soundex"
require "util/iso-latin1"
require "util/notification_logger"
require "util/ngram_similarity"
require "util/today"
require "models"
require "commands"
# next line to fix an error paypal-2.0.0/lib/notification.rb
require "active_support/core_ext/class/attribute_accessors"
require "paypal"
require "sbsm/app"
require "sbsm/index"
require "util/config"
require "fileutils"
require "yus/session"
require "remote/migel/model"
require "util/logfile"

module ODBA
  class Cache
    puts("\n#{__FILE__}:#{__LINE__} Please remove this ugly hack to avoid problems. see https://github.com/zdavatz/oddb.org/issues/386 as soon as possible\n\n")
    attr_reader :deferred_indices
    def update_indices(odba_object) # :nodoc:
      if odba_object.odba_indexable?
        indices.each do |index_name, index|
          index.update(odba_object)
        rescue => error
          ODDB::LogFile.debug("#{index_name} odba_id: #{index.odba_id} #{odba_object.odba_id} #{error} #{error.backtrace[0..10].join("\n")}")
        end
      end
    end
  end
end

class OddbPrevalence
  include ODDB::Failsafe
  include ODBA::Persistable
  RESULT_SIZE_LIMIT = 500
  ODBA_EXCLUDE_VARS = [
    "@atc_chooser", "@bean_counter", "@sorted_fachinfos", "@sorted_feedbacks",
    "@sorted_minifis"
  ]
  ODBA_SERIALIZABLE = ["@rss_updates"]
  attr_reader :address_suggestions, :atc_chooser, :atc_classes,
    :companies, :divisions, :doctors, :experiences, :fachinfos,
    :galenic_groups, :hospitals, :invoices, :last_medication_update, :last_update,
    :minifis, :notification_logger, :orphaned_fachinfos,
    :orphaned_patinfos, :patinfos, :patinfos_deprived_sequences,
    :registrations, :slates, :users, :narcotics, :accepted_orphans,
    :commercial_forms, :rss_updates, :feedbacks, :indices_therapeutici,
    :generic_groups, :shorten_paths
  attr_accessor :epha_interactions_hash, :epha_interactions
  VALID_EAN13 = /^\d{13}/
  def initialize
    init
    @last_medication_update ||= Time.now
  end

  def init
    create_unknown_galenic_group
    @accepted_orphans ||= {}
    @address_suggestions ||= {}
    @atc_classes ||= {}
    @commercial_forms ||= {}
    @companies ||= {}
    @divisions ||= {}
    @doctors ||= {}
    @epha_interactions ||= []
    @epha_interactions_hash ||= {}
    @experiences ||= {}
    @fachinfos ||= {}
    @feedbacks ||= {}
    @galenic_forms ||= []
    @galenic_groups ||= []
    @generic_groups ||= {}
    # for historical reasons the keys for hospitals are Strings, whereas for companies they are integers
    @hospitals ||= {}
    @indications ||= {}
    @indices_therapeutici ||= {}
    @invoices ||= {}
    @log_groups ||= {}
    @minifis ||= {}
    @narcotics ||= {}
    @notification_logger ||= ODDB::NotificationLogger.new
    @orphaned_fachinfos ||= {}
    @orphaned_patinfos ||= {}
    @patinfos ||= {}
    @patinfos_deprived_sequences ||= []
    @registrations ||= {}
    @rss_updates ||= {}
    @shorten_paths ||= []
    @slates ||= {}
    @sponsors ||= {}
    @substances ||= {}
    # recount()
    sorted_minifis
    sorted_feedbacks
    sorted_fachinfos
    ODDB::EphaInteractions.read_from_csv(ODDB::EphaInteractions::CSV_FILE) unless defined?(Minitest)
    rebuild_atc_chooser
  end

  def retrieve_from_index(index_name, query, result = nil)
    # $stdout.puts "#{caller[0]}: retrieve_from_index #{index_name} #{query}"; $stdout.flush
    ODBA.cache.retrieve_from_index(index_name, query, result)
  rescue KeyError
    result || []
  end

  # prevalence-methods ################################
  def create(pointer)
    @last_update = Time.now
    failsafe {
      if (item = pointer.issue_create(self))
        updated(item)
        item
      end
    }
  end

  def delete(pointer)
    @last_update = Time.now
    failsafe(ODDB::Persistence::UninitializedPathError) {
      if (item = pointer.resolve(self))
        updated(item)
      end
      pointer.issue_delete(self)
    }
  end

  def update(pointer, values, origin = nil)
    # $stdout.puts [__FILE__,__LINE__,"update(#{pointer}, #{values})"].join(':')
    @last_update = Time.now
    item = nil
    failsafe(ODDB::Persistence::UninitializedPathError, nil) {
      next unless pointer
      item = pointer.issue_update(self, values, origin)
      updated(item) unless item.nil?
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
    if hash.values.any? { |val| val.odba_instance.nil? }
      hash.delete_if { |key, val| val.odba_instance.nil? }
      hash.odba_store
    end
  end

  def _clean_odba_stubs_array(array)
    if array.any? { |val| val.odba_instance.nil? }
      array.delete_if { |val| val.odba_instance.nil? }
      array.odba_store
    end
  end

  #####################################################
  def admin(oid)
    @users[oid.to_i]
  end

  def admin_subsystem
    ODBA.cache.fetch_named("admin", self) {
      ODDB::Admin::Subsystem.new
    }
  end

  def active_fachinfos
    active = {}
    @registrations.each_value { |reg|
      if reg.active? && reg.fachinfo
        active.store(reg.pointer, 1)
      end
    }
    active
  end

  def active_pdf_patinfos
    active = {}
    each_sequence { |seq|
      if (str = seq.active_patinfo)
        active.store(str, 1)
      end
    }
    active
  end

  def active_packages
    packages.find_all { |pac| pac.active? }
  end

  def active_packages_has_fachinfo
    @registrations.inject([]) { |pacs, (iksnr, reg)|
      pacs.concat(reg.active_packages.select { |pac| pac.has_fachinfo? })
    }
  end

  def address_suggestion(oid)
    @address_suggestions[oid.to_i]
  end

  def atcless_sequences
    retrieve_from_index("atcless", "true")
  end

  def atc_class(code)
    @atc_classes[code]
  end

  def atc_ddd_count
    @atc_ddd_count ||= count_atc_ddd
  end

  def clean_invoices
    @invoices.delete_if { |oid, invoice| invoice.odba_instance.nil? }
    deletables = @invoices.values.select { |invoice|
      invoice.deletable?
    }
    unless deletables.empty?
      deletables.each { |invoice|
        # # replaced by Yus
        #         if((ptr = invoice.user_pointer)
        #           && (user = ptr.resolve(self))
        #           && user.respond_to?(:remove_invoice))
        #           user.remove_invoice(invoice)
        #         end
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

  def company(ean13_or_oid)
    return company_by_gln(ean13_or_oid) if ean13_or_oid.to_s.match(VALID_EAN13)
    @companies[ean13_or_oid.to_i]
  end

  def pharmacy_by_gln(gln)
    return nil unless gln.to_s.match(VALID_EAN13)
    company_by_gln(gln.to_s)
  end

  def company_by_gln(gln)
    return nil unless gln.to_s.match(VALID_EAN13)
    @companies.values.each { |company|
      if company && company.respond_to?(:ean13) &&
          company.ean13.to_s == gln.to_s
        return company
      end
    }
    nil
  end

  def doctor_by_gln(gln)
    return nil unless gln.to_s.match(VALID_EAN13)
    @doctors.values.each { |doctor|
      if doctor && doctor.respond_to?(:ean13) && doctor.ean13.to_s == gln.to_s
        return doctor
      end
    }
    nil
  end

  def hospital_by_gln(gln)
    return nil unless gln.to_s.match(VALID_EAN13)
    hospital(gln.to_s)
  end

  def company_by_name(name, ngram_cutoff = nil)
    _company_by_name(name, ngram_cutoff) \
      || _company_by_name(name, ngram_cutoff, /\s*(ag|gmbh|sa)\b/i)
  end

  def _company_by_name(name, ngram_cutoff = nil, filter = nil)
    namedown = name.to_s.downcase
    if filter
      namedown.gsub! filter, ""
    end
    @companies.each_value { |company|
      name = company.name.to_s.downcase
      if filter
        name.gsub! filter, ""
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
    if @config.nil?
      @config = ODDB::Config.new
      @config.pointer = ODDB::Persistence::Pointer.new(:config)
      odba_store
    end
    hook = @config
    args.each { |arg|
      conf = hook.send(arg)
      if conf.nil?
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
      inj += 1 if atc.has_ddd?
      inj
    }
  end

  def count_limitation_texts
    @registrations.values.inject(0) { |inj, reg|
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
    if (grp = log_group(:swissmedic) || log_group(:swissmedic_journal)) \
       && (log = grp.latest)
      log.change_flags.select { |ptr, flags|
        flags.include?(:new)
      }.size
    else
      0
    end
  end

  def count_vaccines
    @registrations.values.inject(0) { |inj, reg|
      if reg.vaccine
        inj += reg.active_package_count
      end
      inj
    }
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
    company.pointer = ODDB::Persistence::Pointer.new([:company, company.oid])
    @companies.store(company.oid, company)
    company
  end

  def create_division
    div = ODDB::Division.new
    @divisions.store(div.oid, div)
  end

  def create_doctor
    doctor = ODDB::Doctor.new
    doctor.pointer = ODDB::Persistence::Pointer.new([:doctor, doctor.oid])
    @doctors ||= {}
    @doctors.store(doctor.oid, doctor)
  end

  def create_experience
    experience = ODDB::Experience.new
    @experiences.store(experience.oid, experience)
  end

  def create_hospital(ean13)
    raise "ean13 #{ean13.to_s[0..80]} not valid" unless ean13.to_s.match(VALID_EAN13)
    hospital = ODDB::Hospital.new(ean13.to_s)
    @hospitals.store(ean13.to_s, hospital)
  end

  def create_fachinfo
    fachinfo = ODDB::Fachinfo.new
    fachinfo.pointer = ODDB::Persistence::Pointer.new([:fachinfo, fachinfo.oid])
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
    # narc = ODDB::Narcotic.new
    narc = ODDB::Narcotic2.new
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
    patinfo.pointer = ODDB::Persistence::Pointer.new([:patinfo, patinfo.oid])
    @patinfos.store(patinfo.oid, patinfo)
  end

  def create_poweruser
    user = ODDB::PowerUser.new
    @users.store(user.oid, user)
  end

  def create_registration(iksnr)
    if reg = registration(iksnr)
      return reg
    end
    reg = ODDB::Registration.new(iksnr)
    reg.pointer = ODDB::Persistence::Pointer.new([:registration, iksnr])
    @registrations.store(iksnr, reg)
    reg.odba_store
    @registrations.odba_store
    reg
  end

  def create_slate(name)
    slate = ODDB::Slate.new(name)
    @slates.store(name, slate)
  end

  def create_sponsor(flavor)
    sponsor = ODDB::Sponsor.new
    @sponsors.store(flavor, sponsor)
  end

  def create_substance(key = nil)
    if !key.nil? && (subs = substance(key))
      subs
    else
      subs = ODDB::Substance.new
      unless key.nil?
        values = {
          "lt"	=>	key
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

  def delete_all_narcotics
    @narcotics.values.each do |narc|
      delete(narc.pointer)
    end
    @narcotics.odba_isolated_store
  end

  def delete_address_suggestion(oid)
    if (sug = @address_suggestions.delete(oid))
      @address_suggestions.odba_isolated_store
      sug
    end
  end

  def delete_atc_class(atccode)
    atc = @atc_classes[atccode]
    @atc_chooser.delete(atccode)
    if @atc_classes.delete(atccode)
      @atc_classes.odba_isolated_store
    end
    atc
  end

  def delete_commercial_form(oid)
    if (form = @commercial_forms.delete(oid))
      @commercial_forms.odba_isolated_store
      form
    end
  end

  def delete_company(oid)
    if (comp = @companies.delete(oid))
      @companies.odba_isolated_store
      comp
    end
  end

  def delete_doctor(oid)
    if (doc = @doctors.delete(oid.to_i))
      @doctors.odba_isolated_store
      doc
    end
  end

  def delete_fachinfo(oid)
    if (fi = @fachinfos.delete(oid))
      @fachinfos.odba_isolated_store
      fi
    end
  end

  def delete_galenic_group(oid)
    group = galenic_group(oid)
    unless group.nil? || group.empty?
      raise "e_nonempty_galenic_group"
    end
    if (grp = @galenic_groups.delete(oid.to_i))
      @galenic_groups.odba_isolated_store
      grp
    end
  end

  def delete_index_therapeuticus(code)
    code = code.to_s
    if (it = @indices_therapeutici.delete(code))
      @indices_therapeutici.odba_isolated_store
      it
    end
  end

  def delete_indication(oid)
    if (ind = @indications.delete(oid))
      @indications.odba_isolated_store
      ind
    end
  end

  def delete_invoice(oid)
    if (inv = @invoices.delete(oid))
      @invoices.odba_isolated_store
      inv
    end
  end

  def delete_minifi(oid)
    if (minifi = @minifis.delete(oid.to_i))
      @minifis.odba_isolated_store
      minifi
    end
  end

  def delete_orphaned_fachinfo(oid)
    if (fi = @orphaned_fachinfos.delete(oid.to_i))
      @orphaned_fachinfos.odba_isolated_store
      fi
    end
  end

  def delete_orphaned_patinfo(oid)
    if (pi = @orphaned_patinfos.delete(oid.to_i))
      @orphaned_patinfos.odba_isolated_store
      pi
    end
  end

  def delete_patinfo(oid)
    if (fi = @patinfos.delete(oid))
      @patinfos.odba_isolated_store
      fi
    end
  end

  def delete_registration(iksnr)
    if (reg = @registrations.delete(iksnr))
      @registrations.odba_isolated_store
      reg
    end
  end

  def delete_substance(key)
    substance = if key.to_i.to_s == key.to_s
      @substances.delete(key.to_i)
    else
      @substances.delete(key.to_s.downcase)
    end
    if substance
      @substances.odba_isolated_store
      substance
    end
  end

  def division(oid)
    @divisions[oid.to_i]
  end

  def doctor(oid)
    @doctors[oid.to_i]
  end

  def experience(oid)
    @experiences[oid.to_i]
  end

  def get_epha_interaction(atc_code_self, atc_code_other)
    ODDB::EphaInteractions.get_epha_interaction(atc_code_self, atc_code_other)
  end

  def epha_interaction(oid)
    @epha_interactions_hash[oid.to_i]
  end

  def epha_interaction_count
    @epha_interactions_hash.size
  end

  def pharmacy(ean13)
    pharmacy_by_gln(ean13)
  end

  def pharmacy_count
    doctor_count + hospital_count + company_count
  end

  def hospital(ean13)
    return nil unless ean13.to_s.match(VALID_EAN13)
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
      if doctor.record_match?(origin_db, origin_id)
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

  # return only active fachinfos/patinfos via active container.
  # @fachinfos/@patinfos has also old patinfos.
  def effective_fachinfos
    _fachinfos = []
    @registrations.values.compact.map do |reg|
      next unless reg.active? and reg.public? and reg.has_fachinfo?
      if _fachinfo = reg.fachinfo
        _fachinfos << _fachinfo
      end
    end
    _fachinfos.uniq
  end

  def effective_patinfos
    _patinfos = []
    @registrations.values.compact.map do |reg|
      next unless reg.active?
      reg.sequences.values.compact.map do |seq|
        next unless seq.public? and seq.has_patinfo?
        if _patinfo = seq.patinfo
          _patinfos << _patinfo
        end
      end
    end
    _patinfos.uniq
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
    if lang.to_s != "fr"
      lang = "de"
    end
    retrieve_from_index("fachinfo_name_#{lang}", name)
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
    @limitation_text_count ||= count_limitation_texts
  end

  def log_group(key)
    @log_groups[key]
  end

  def minifi(oid)
    @minifis[oid.to_i]
  end

  def narcotic(oid)
    @narcotics[oid.to_i]
  end

  def narcotic_by_ikskey(ikskey)
    @narcotics.values.find do |narc|
      narc.ikskey == ikskey
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
    ODDB::Package.find_by_pharmacode(pcode.to_s.gsub(/^0+/u, ""))
  end

  def package_by_ikskey(ikskey)
    ikskey = ikskey.to_s
    iksnr = "%05i" % ikskey[-8..-4].to_i
    ikscd = ikskey[-3..-1]
    if reg = registration(iksnr)
      reg.package ikscd
    end
  end

  def package_by_ean13(ean13)
    return false unless ean13.to_s.match(VALID_EAN13)
    if ean13.to_s[2..3].eql?("80") # swissmedic-iksnrs
      iksnr = ean13.to_s[4..8]
      ikscd = ean13.to_s[9..11]
    else # pseudo_fachinfo (introduced in march 2014)
      iksnr = ean13.to_s[2..11]
      ikscd = ean13.to_s[9..11]
    end
    if reg = registration(iksnr)
      reg.package ikscd
    end
  end

  def package_count
    @package_count ||= count_packages
  end

  def packages
    @registrations.inject([]) do |pacs, (iksnr, reg)|
      if reg.instance_of?(ODDB::Registration)
        problems = reg.packages.find_all { |pack| !pack.instance_of?(ODDB::Package) }
        ODDB::LogFile.debug("Reg #{iksnr} has invalid packages odba_id #{reg.odba_id} #{reg.class} #{problems}") if problems.size > 0
        reg.packages.delete_if { |pack| !pack.instance_of?(ODDB::Package) }
        pacs.concat(reg.packages.find_all { |pack| pack.instance_of?(ODDB::Package) })
      else
        ODDB::LogFile.debug("Reg #{reg.odba_id} #{reg.class} is not a Registration (fetch #{ODBA.cache.fetch(reg.odba_id).class}) is not an instance of ODDB::Registration")
        pacs
      end
    end
  end

  def patinfo(oid)
    @patinfos[oid.to_i]
  end

  def patinfo_count
    @patinfo_count ||= count_patinfos
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
    @recent_registration_count ||= count_recent_registrations
  end

  def recount
    again = true
    if @bean_counter.is_a?(Thread) && @bean_counter.status
      return again = true
    end
    @bean_counter = Thread.new {
      while again
        again = false
        @atc_ddd_count = count_atc_ddd
        @doctor_count = @doctors.size
        @company_count = @companies.size
        @substance_count = @substances.size
        @limitation_text_count = count_limitation_texts
        @package_count = count_packages
        @patinfo_count = count_patinfos
        @recent_registration_count = count_recent_registrations
        @vaccine_count = count_vaccines
        odba_isolated_store
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
  @@iks_or_ean = /(?:\d{4})?(\d{5})(?:\d{4})?/u
  def search_oddb(query, lang)
    # current search_order:
    # 1. atcless
    # 2. drug_shortage
    # 3. iksnr or ean13
    # 4. atc-code
    # 5. exact word in sequence name
    # 6. company-name
    # 7. substance
    # 8. indication
    # 9. sequence
    result = ODDB::SearchResult.new
    result.exact = true
    result.search_query = query
    # atcless
    if query == "atcless"
      atc = ODDB::AtcClass.new("n.n.")
      atc.sequences = atcless_sequences
      atc.instance_eval {
        alias :active_packages :packages
      }
      result.atc_classes = [atc]
      result.search_type = :atcless
      return result
    end
    if query == "drug_shortage" || query == "drugshortage"
      atc = ODDB::AtcClass.new("n.n.")
      atc.sequences = []
      pacs = active_packages.find_all { |x| x.shortage_state && /^1/.match(x.shortage_state) }
      pacs.each do |pac|
        seq = ODDB::Sequence.new(pac.sequence.seqnr)
        seq.registration = pac.registration
        seq.packages.store pac.ikscd, pac
        atc.sequences << seq
      end
      result.atc_classes = [atc]
      result.search_type = :drug_shortage
      return result
    end
    # iksnr or ean13
    if (match = @@iks_or_ean.match(query))
      iksnr = match[1]
      if (reg = registration(iksnr))
        atc = ODDB::AtcClass.new("n.n.")
        atc.sequences = reg.sequences.values
        result.atc_classes = [atc]
        result.search_type = :iksnr
        return result
      end
    end
    # pharmacode
    if /^\d{6,}$/u.match?(query)
      if (pac = package(query))
        atc = ODDB::AtcClass.new("n.n.")
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
    if atcs.empty?
      atcs = search_by_sequence(key, result)
      result.search_type = :sequence
    end
    # company-name
    if atcs.empty?
      atcs = search_by_company(key)
      result.search_type = :company
    end
    # substance
    if atcs.empty?
      atcs = search_by_substance(key)
      result.search_type = :substance
    end
    # indication
    if atcs.empty?
      atcs = search_by_indication(key, lang)
      result.search_type = :indication
    end
    # sequence
    if atcs.empty?
      atcs = search_by_sequence(key)
      result.search_type = :sequence
    end
    result.atc_classes = atcs
    result
  end

  def search_btm(query = "")
    result = ODDB::SearchResult.new
    result.exact = true
    result.search_query = query
    result.atc_classes = []
    unless query.empty?
      atc = ODDB::AtcClass.new("n.n.")
      atc.sequences = []
      pacs = @narcotics.values.map { |narc| narc.package }
      pacs.each do |pac|
        if pac and pac.name_base[0].downcase == query
          seq = ODDB::Sequence.new(pac.sequence.seqnr)
          seq.registration = pac.registration
          seq.packages.store pac.ikscd, pac
          atc.sequences << seq
        end
      end
      result.atc_classes << atc
    end
    result.search_type = :btm
    result
  end

  def search_by_atc(key)
    retrieve_from_index("atc_index", key.dup)
  end

  def search_by_company(key)
    result = ODDB::SearchResult.new
    result.error_limit = RESULT_SIZE_LIMIT
    atcs = retrieve_from_index("atc_index_company", key.dup, result)
    filtered = atcs.collect { |atc|
      atc.company_filter_search(key.dup)
    }
    filtered.flatten.compact.uniq
  end

  def search_by_indication(key, lang = :de)
    key.gsub(/[^A-z0-9]/, ".")
    atcs = []
    indications.map do |indication|
      if /#{key}/i.match?(indication.search_text)
        atcs.concat indication.atc_classes
      end
    end
    atcs.uniq
  end

  def search_by_sequence(key, result = nil)
    retrieve_from_index("sequence_index_atc", key.dup, result)
  end

  def search_by_interaction(key, lang)
    result = ODDB::SearchResult.new
    result.error_limit = RESULT_SIZE_LIMIT
    if lang.to_s != "fr"
      lang = "de"
    end
    sequences = retrieve_from_index("interactions_index_#{lang}", key, result)
    key = key.downcase
    sequences.reject! do |seq|
      ODDB.search_terms(seq.search_terms, downcase: true).include?(key) \
        || seq.substances.any? do |sub|
             sub.search_keys.any? { |skey| skey.downcase.include?(key) }
           end
    end
    _search_exact_classified_result(sequences, :interaction, result)
  end

  def search_by_substance(key)
    retrieve_from_index("substance_index_atc", key.dup)
  end

  def search_by_unwanted_effect(key, lang)
    result = ODDB::SearchResult.new
    if lang.to_s != "fr"
      lang = "de"
    end
    sequences = retrieve_from_index("unwanted_effects_index_#{lang}", key, result)
    _search_exact_classified_result(sequences, :unwanted_effect, result)
  end

  def search_doctors(key)
    return [doctor_by_gln(key)] if key.to_s.match(VALID_EAN13)
    retrieve_from_index("doctor_index", key)
  end

  def search_companies(key)
    result = [company_by_gln(key)].compact if key.to_s.match(VALID_EAN13)
    return [] unless result && result.size > 0
    return result unless result.first.is_pharmacy?
    companies = retrieve_from_index("company_index", key)
    companies.find_all { |item|
      !item.is_pharmacy? and
        item.business_area.to_s != ODDB::BA_type::BA_research_institute.to_s and
        item.business_area.to_s != ODDB::BA_type::BA_cantonal_authority.to_s
    }
  end

  def search_exact_company(query)
    result = ODDB::SearchResult.new
    result.search_type = :company
    result.atc_classes = search_by_company(query)
    result
  end

  def search_exact_indication(query)
    result = ODDB::SearchResult.new
    result.exact = true
    result.search_type = :indication
    result.atc_classes = search_by_indication(query)
    result
  end

  def search_narcotics(query, lang)
    if lang.to_s != "fr"
      lang = "de"
    end
    index_name = "narcotics_#{lang}"
    retrieve_from_index(index_name, query)
  end

  def search_patinfos(query)
    retrieve_from_index("sequence_patinfos", query)
  end

  def search_vaccines(query)
    retrieve_from_index("sequence_vaccine", query)
  end

  def search_exact_sequence(query)
    sequences = search_sequences(query)
    _search_exact_classified_result(sequences, :sequence)
  end

  def search_combined(query, lang)
    result = search_oddb(query, lang)
    result_substances = search_exact_substance(query)
    result_substances.atc_classes.each do |atc|
      add_it = true
      result.atc_classes.each do |item|
        add_it = false if item.code == atc.code
        break unless add_it
      end
      result.atc_classes << atc if add_it
    end
    result.search_type = :combined
    result
  end

  def search_exact_substance(query)
    sequences = ODBA.cache.retrieve_from_index("substance_index_sequence", query).collect { |x| x if x.active? }.compact
    _search_exact_classified_result(sequences, :substance)
  end

  def _search_exact_classified_result(sequences, type = :unknown, result = nil)
    atc_classes = {}
    sequences.each do |seq|
      next unless seq.active?
      code = (atc = seq.atc_class) ? atc.code : "n.n"
      new_atc = atc_classes.fetch(code) do
        atc_class = ODDB::AtcClass.new(code)
        unless atc.nil?
          atc_class.descriptions = atc.descriptions
          atc_class.db_id = atc.db_id
          atc_class.ni_id = atc.ni_id
        end
        atc_classes.store(code, atc_class)
      end
      new_atc.sequences.push(seq)
    end
    result ||= ODDB::SearchResult.new
    result.search_type = type
    result.atc_classes = atc_classes.values
    result
  end

  def pharmacies
    companies.select { |key, item| item.is_pharmacy? }
  end

  def registration_holders
    companies.select { |key, item| item.business_area.to_s == ODDB::BA_type::BA_pharma.to_s }
  end

  def search_pharmacies(key)
    result = [pharmacy_by_gln(key)] if key.to_s.match(VALID_EAN13)
    return result if result && result.first && result.first.is_pharmacy?
    companies = retrieve_from_index("company_index", key)
    companies.find_all { |item| item && item.is_pharmacy? }
  end

  def search_registration_holder(key)
    result = [company_by_gln(key)] if key.to_s.match(VALID_EAN13)
    return result if result and result.size > 0 and result.first.business_area.to_s == ODDB::BA_type::BA_pharma.to_s
    companies = retrieve_from_index("company_index", key)
    companies.find_all { |item| item.business_area.to_s == ODDB::BA_type::BA_pharma.to_s }
  end

  def search_hospitals(key)
    retrieve_from_index("hospital_index", key)
  end

  def search_indications(query)
    retrieve_from_index("indication_index", query)
  end

  def search_interactions(query)
    result = retrieve_from_index("sequence_index_substance", query)
    if (subs = substance(query, false))
      result.unshift(subs)
    end
    if result.empty?
      result = soundex_substances(query)
    end
    result
  end

  def search_sequences(query, chk_all_words = true)
    index = chk_all_words ? "sequence_index" : "sequence_index_exact"
    retrieve_from_index(index, query)
  end

  def search_single_substance(key)
    substance = substances.find { |x| !x.nil? and x.to_s.eql?(key) }
    return substance if substance
    result = ODDB::SearchResult.new
    result.exact = true
    key = ODDB.search_term(key)
    retrieve_from_index("substance_index", key, result).find_all { |sub| sub.is_a?(ODDB::Substance) }.find { |sub| sub.same_as? key }
  end

  def search_substances(query)
    if (subs = substance(query))
      [subs]
    else
      soundex_substances(query)
    end
  end

  def active_sequences
    sequences.find_all { |x| x.active? }
  end

  def sequences
    @registrations.values.inject([]) { |seq, reg|
      seq.concat(reg.sequences.values)
    }
  end

  def slate(name)
    @slates[name]
  end

  def rebuild_slates(name = :patinfo, type = :annual_fee)
    case name
    when :patinfo
      slate(name).items.values.select { |i| i.type == type }.each do |item|
        rebuild_patinfo_slate_item(item, type)
      end
    when :fachinfo
      slate(name).items.values.select { |i| i.type == type }.each do |item|
        rebuild_fachinfo_slate_item(item, type)
      end
    end
  end

  def rebuild_patinfo_slate_item(item, type)
    # p "item.pointer = #{item.pointer}"
    sequence = item.sequence || resolve(item.item_pointer)
    if sequence and sequence.is_a?(ODDB::Sequence)
      values = {
        data: {name: sequence.name},
        duration: ODDB::PI_UPLOAD_DURATION,
        expiry_time: item.expiry_time,
        item_pointer: sequence.pointer,
        price: ODDB::PI_UPLOAD_PRICES[type],
        text: item.text,
        time: item.time,
        type: type,
        unit: item.unit,
        yus_name: item.yus_name,
        vat_rate: ODDB::VAT_RATE
      }
      # puts "values = #{values.pretty_inspect}"
      begin
        item.data[:name]
        update(item.pointer, values, :admin)
      rescue
        delete(item.pointer)
        slate_pointer = ODDB::Persistence::Pointer.new([:slate, :patinfo])
        create(slate_pointer)
        item_pointer = slate_pointer + :item
        # p "item_pointer = #{item_pointer}"
        update(item_pointer.creator, values, :admin)
        # p "obj.pointer = #{obj.pointer}"
      end
    end
  end

  def rebuild_fachinfo_slate_item(item, type)
    if registration = resolve(item.item_pointer) and registration.is_a?(ODDB::Registration)
      values = {
        data: {name: registration.name_base},
        duration: ODDB::FI_UPLOAD_DURATION,
        expiry_time: item.expiry_time,
        item_pointer: registration.pointer,
        price: ODDB::FI_UPLOAD_PRICES[type],
        text: registration.iksnr,
        time: item.time,
        type: type,
        unit: item.unit,
        yus_name: item.yus_name,
        vat_rate: ODDB::VAT_RATE
      }
      # puts "values = #{values.pretty_inspect}"
      begin
        item.data[:name]
        update(item.pointer, values, :admin)
      rescue
        delete(item.pointer)
        slate_pointer = ODDB::Persistence::Pointer.new([:slate, :fachinfo])
        create(slate_pointer)
        item_pointer = slate_pointer + :item
        # p "item_pointer = #{item_pointer}"
        update(item_pointer.creator, values, :admin)
        # p "obj.pointer = #{obj.pointer}"
      end
    end
  end

  def soundex_substances(name)
    parts = ODDB::Text::Soundex.prepare(name).split(/\s+/u)
    soundex = ODDB::Text::Soundex.soundex(parts)
    key = soundex.join(" ")
    retrieve_from_index("substance_soundex_index", key)
  end

  def sorted_fachinfos
    @sorted_fachinfos ||= @fachinfos.values.select { |fi|
      fi.revision
    }.sort_by { |fi| fi.revision }.reverse
  end

  def sorted_feedbacks
    @sorted_feedbacks ||= @feedbacks.values.sort_by { |fb| fb.time }.reverse
  end

  def sorted_minifis
    @sorted_minifis ||= @minifis.values.sort_by { |minifi|
      [-minifi.publication_date.year,
        -minifi.publication_date.month, minifi.name]
    }
  end

  def sorted_patented_registrations
    @registrations.values.select { |reg|
      (pat = reg.patent) && pat.expiry_date # _protected?
    }.sort_by { |reg| reg.patent.expiry_date }
  end

  def sponsor(flavor)
    @sponsors[flavor.to_s]
  end

  def substance(key, neurotic = false)
    if key.to_i.to_s == key.to_s
      @substances[key.to_i]
    elsif (substance = search_single_substance(key))
      substance
    elsif neurotic
      @substances.values.find { |subs|
        subs and subs.same_as?(key)
      }
    end
  end


  def repair_non_utf8_strings
    # Added this helper method in October 2025 to fix very old errors in the database, as some ISO-8859-1 strings
    # were never correctly converted to UTF-8. See https://github.com/zdavatz/oddb.org/issues/386
    # It took almost an hour to complete on my local laptop
    startTime = Time.now
    ODDB::LogFile.debug("Starting")
    res =  @registrations.find_all { |key, value| !value.instance_of?(ODDB::Registration) }
    if res.size > 0
      @registrations.delete_if { |key, value| !value.instance_of?(ODDB::Registration) }
      @registrations.odba_store
    end
    ODDB::LogFile.debug("Finished step 1 for @registrations deleted #{res}")
    @my_errors = []
    @registrations.values.find_all do |x|
      begin
        next unless x.instance_of?(ODDB::Registration)
        next unless x.fachinfo
        l2 = x.fachinfo&.links if x.respond_to?(:fachinfo)
      rescue => error
        @my_errors << x.iksnr
        x.fachinfo&.links = []
        x.fachinfo.odba_store
      end
    end
    ODDB::LogFile.debug("Repaired #{@my_errors.size} links in fachinfo: #{@my_errors.join(" ")}")
    @hospitals.values.each { |hospital| hospital.search_terms; hospital.odba_store}
    ODDB::LogFile.debug("Finished repairing hospital. Reparing doctors will take 30 minutes or more")
    @doctors.values.each { |doc| doc.search_terms; doc.odba_store}
    ODDB::LogFile.debug("Finished repairing doctors")
    @companies.values.each { |comp| comp.search_terms; comp.odba_store}
    ODDB::LogFile.debug("Finished repairing companies")
    res =  @substances.find_all { |key, value| !value.instance_of?(ODDB::Substance) }
    if res.size > 0
      @substances.delete_if { |key, value| !value.instance_of?(ODDB::Substance) }
      @substances.odba_store
    end
    ODDB::LogFile.debug("Finished step 1 for @substances deleted #{res}")
    @substances.values.find_all{|sub| !sub.respond_to?(:_search_keys)}.each{|x|ODBA.cache.delete(ODBA.cache.fetch(x.odba_id))}
    @substances.odba_store
    ODDB::LogFile.debug("Finished step 2 for @substances")
    @substances.collect { |key, value| value._search_keys }
    ODDB::LogFile.debug("Finished step 3 for @substances")
    @substances.each do |key, value|
      begin
        value.name.encode("UTF-8")
      rescue Encoding::UndefinedConversionError => error
        ODDB::LogFile.debug("#{error} name #{value.name.encoding} from substance with odba_id #{value.odba_id} #{value.name[0..40]}")
        value.name.force_encoding("ISO-8859-1")
        value.descriptions["en"] = value.name.encode("UTF-8")
        value.odba_store
      end
      begin
        value.lt.encode("UTF-8")
      rescue Encoding::UndefinedConversionError => error
        ODDB::LogFile.debug("#{error} lt #{value.lt.encoding} from substance with odba_id #{value.odba_id} #{value.lt[0..40]}")
        new_name = value.lt.dup
        new_name.force_encoding("ISO-8859-1")
        value.descriptions["en"] = new_name.encode("UTF-8")
        value.descriptions.odba_store
        value.odba_store
      end
      if value.respond_to?(:synonyms)
        value.synonyms.each_with_index do |term, idx|
          term.encode("UTF-8")
        rescue Encoding::UndefinedConversionError => error
          ODDB::LogFile.debug("#{error} #{term.encoding} from substance with odba_id #{value.odba_id} #{term[0..40]}")
          term.force_encoding("ISO-8859-1")
          value.synonyms[idx] = term.encode("UTF-8")
          value.synonyms.odba_store
          value.odba_store
        end
      end
      if value.respond_to?(:descriptions)
        value.descriptions.each do |lang, term|
          term.encode("UTF-8")
        rescue Encoding::UndefinedConversionError => error
          ODDB::LogFile.debug("#{error} #{lang} #{term.encoding} from substance with odba_id #{value.odba_id} #{term[0..40]}")
          term.force_encoding("ISO-8859-1")
          value.descriptions[lang] = term.encode("UTF-8")
          value.descriptions.odba_store
          value.odba_store
        end
      else
        ODDB::LogFile.debug("Value #{value} odba_id #{value.odba_id} has no descriptions")
      end
    end
    ODDB::LogFile.debug("Finished repairing substances with wrong name, lt, synonyms or descriptions")
    sequences.values.each do |seq|
      # First handle cases where a package is of a wrong type
      found = seq.packages.find_all {|key, val| !val.instance_of?(ODDB::Package) }
      if found.size > 0
        ODDB::LogFile.debug("DB_ERROR wrong type #{seq.iksnr} #{seq.seqnr} found #{found.size} not correct packages")
        seq.packages.delete_if do |key, val|
          !val.instance_of?(ODDB::Package)
        end
        seq.packages.odba_store
      end

      # Second handle cases where sl_entry or its limitation_text is invalid
      begin
        seq.packages.values.each do |pack|
          begin
            valid1 = pack.sl_entry
            valid2 = pack.limitation_text
          rescue => error
            ODDB::LogFile.debug("#{error} #{pack.iksnr} #{pack.seqnr} invalid sl_entry #{pack.odba_id}")
            pack.delete_sl_entry
            pack.odba_store
          end
        end
      end
    end
    ODDB::LogFile.debug("Finished repairing packages with wrong sl_entry or limitation_text")
    duration = Time.now - startTime
    msg = "Took #{(duration/60).to_i} m #{sprintf("%3.2f", (duration % 60))} seconds. "
    ODDB::LogFile.debug(msg)
    msg
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
        if !subs.is_effective_form? && subs.effective_form == item
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
    # ## this is much too unstable, completely wrong assignment is
    #        ## probable!
    #    if(atc_array.size > 1)
    #      atc_array = atc_array.select { |atc|
    #        atc.substances.size == 1
    #      }
    #    end
    if atc_array.size == 1
      atc_array.first
    end
  end

  def vaccine_count
    @vaccine_count ||= count_vaccines
  end

  ## indices
  def rebuild_indices(name = nil, &block)
    verbose = !defined?(Minitest)
    path = File.join(ODDB::PROJECT_ROOT, "etc/index_definitions.yaml")
    file = File.open(path)
    @rebuilt = []
    @failures = []
    @current_index = "none"
    ODBA.cache.indices.size
    @deffered_indices = []
    ODBA.cache.deferred_indices.each{|index| @deffered_indices << index.index_name}
    begin
      start = Time.now
      file = File.open(path)
      YAML.load_stream(file) do |index_definition|
        @current_index = index_definition.index_name
        doit = if name and name.length > 0
          name.match(@current_index)
        elsif block
          block.call(index_definition)
        else
          true
        end
        if doit
          index_start = Time.now
          @failures << @current_index
          begin
            ODBA.cache.drop_index(@current_index)
          rescue => e
            ODDB::LogFile.debug("#{@current_index} #{e} #{e.backtrace[0..8].join("\n")}")
          end
          begin
            ODBA.cache.create_index(index_definition, ODDB)
            source = instance_eval(index_definition.init_source)
            ODDB::LogFile.debug("filling: #{@current_index} source.size: #{source.size}") if verbose
            ODBA.cache.fill_index(@current_index, source)
            @rebuilt << @current_index
            @failures.delete_if{|x| x.eql?( @current_index)}
            ODDB::LogFile.debug("finished rebuild #{@current_index} in #{(Time.now - index_start).to_i} seconds") if verbose
          rescue => e
            ODDB::LogFile.debug("failed rebuild #{@current_index} #{e} #{e.backtrace[0..8].join("\n")}")
          end
        end
      end
      duration = Time.now - start
      msg = "Took #{(duration/60).to_i} m #{sprintf("%3.2f", (duration % 60))} seconds. "
      # ["oddb_commercialform_name", "oddb_galenicform_name", "oddb_indextherapeuticus_code", "oddb_minifi_publication_date", "oddb_package_pharmacode", "oddb_persistence_pointer"]
      @to_drop = ODBA.cache.indices.keys  - @deffered_indices - @rebuilt
      ODDB::LogFile.debug("Deferred_indices are #{@deffered_indices.join(" ")}")
      ODDB::LogFile.debug("We should remove the following indices #{@to_drop.sort} which are not defined in #{path}") if @to_drop.size > 0
      # @to_drop.each { |index_name| ODBA.cache.drop_index(index_name)}
      # @to_drop.each { |index_name| ODBA.storage.drop_index(index_name)}
      if @failures.size == 0
        msg += "Built #{@rebuilt.size} indices: #{@rebuilt.join(" ")}"
      else
        msg += "Built #{@rebuilt.size} indices. Failed building #{@failures.size} indices\n  #{@failures.join(" ")}"
      end
      #  substance_index_atc sequence_limitation_text sequence_index_substance
      ODDB::LogFile.debug msg
      exit 1 unless @failures.size == 0
    rescue => e
      ODDB::LogFile.debug "INDEX CREATION ERROR: #{@current_index} #{e} #{e.backtrace[0..8].join("\n")}"
    ensure
      file.close
    end
  end

  def generate_dictionary(language)
    ODBA.storage.remove_dictionary(language)
    ODBA.storage.generate_dictionary(language)
  end

  def generate_dictionaries
    generate_french_dictionary
    generate_german_dictionary
  end

  def generate_french_dictionary
    generate_dictionary("french")
  end

  def generate_german_dictionary
    generate_dictionary("german")
  end

  def update_ibflag
    @registrations.values.select { |r| r.production_science =~ /Blutprodukte/ or r.production_science =~ /Impfstoffe/ }.sort_by { |r| r.iksnr }.each do |reg|
      unless reg.vaccine
        ptr = reg.pointer
        args = {vaccine: true}
        update ptr, args, :swissmedic
      end
    end
  end

  def set_inactive_date_nil(date)
    @registrations.values.each do |reg|
      if reg.inactive_date == date
        update reg.pointer, {inactive_date: nil}, :admin
      end
    end
  end

  private

  def create_unknown_galenic_group
    unless @galenic_groups.is_a?(Hash) && @galenic_groups.size > 0
      @galenic_groups = {}
      pointer = ODDB::Persistence::Pointer.new([:galenic_group])
      group = create(pointer)
      raise "Default GalenicGroup has illegal Object ID (#{group.oid})" unless group.oid == 1 or defined?(Minitest)
      update(group.pointer, {"de" => "Unbekannt"})
    end
  end
end

module ODDB
  class App < SBSM::App
    include Failsafe
    AUTOSNAPSHOT = true
    CLEANING_INTERVAL = 5 * 60
    EXPORT_HOUR = 2
    UPDATE_HOUR = 9
    MEMORY_LIMIT = 6 * 1024 # 7 GB # 5 are normally enough, but running unit tests needs between 6 and 7 GB
    MEMORY_LIMIT_CRAWLER = 4000  # ruby 1.9.3 worked with 1450 # 1,4 GB. Ruby 2.4.0 show (via htop) useages between 1200 and 1700 MB
    RUN_CLEANER = true
    RUN_UPDATER = false
    SESSION = Session
    UPDATE_INTERVAL = 24 * 60 * 60
    VALIDATOR = Validator
    YUS_SERVER = DRb::DRbObject.new(nil, YUS_URI)
    MIGEL_SERVER = DRb::DRbObject.new(nil, MIGEL_URI)
    REFDATA_SERVER = DRbObject.new(nil, ODDB::Refdata::RefdataArticle::URI)
    @@primary_server = nil
    attr_reader :cleaner, :updater, :system # system aka persistence
    def initialize(process: nil, auxiliary: nil, app: nil, server_uri: ODDB.config.server_url, unknown_user: nil)
      @process = process || :user
      @@last_start_time ||= 0
      start = Time.now
      @unknown_user = unknown_user
      @app = app
      super()
      ODDB::LogFile.debug("process: #{$0} server_uri #{server_uri}  auxiliary #{auxiliary} after #{Time.now - start} seconds") unless defined?(Minitest)
      @rss_mutex = Mutex.new
      @cache_mutex = Mutex.new
      @admin_threads = ThreadGroup.new
      @system = ODBA.cache.fetch_named("oddbapp", self) { OddbPrevalence.new }
      ODDB::LogFile.debug("init system starting after #{Time.now - start} seconds") unless defined?(Minitest)
      begin
        @system.init
        @system.odba_store
      rescue => error
        ODDB::LogFile.debug("odba_id: #{index.odba_id} #{odba_object.odba_id} #{error} #{error.backtrace[0..10].join("\n")}")
        nil
      end
      return if auxiliary
      reset
      log_size
      DRb.install_id_conv ODBA::DRbIdConv.new
      @cache_mutex.synchronize do
        if @@primary_server && defined?(Minitest)
          GC.start # start a garbage collection
          DRb.remove_server(@@primary_server)
          Thread.kill(DRb.thread)
          @@primary_server = nil
          GC.start
        end
        @@primary_server = DRb.start_service(server_uri, self)
        ODDB::LogFile.debug("initialized: #{Time.now - start}") unless defined?(Minitest)
        @@last_start_time = (Time.now - start).to_i
      end
    rescue => error
      ODDB::LogFile.debug("Error initializing #{error} #{error.backtrace[0..10].join("\n")} with @@primary_server #{@@primary_server}") unless defined?(Minitest)
    end

    def method_missing(m, *args, &block)
      @cache_mutex.synchronize do
        @system.send(m, *args, &block)
      end
    end

    # prevalence-methods ################################
    def accept_orphaned(orphan, pointer, symbol, origin = nil)
      command = AcceptOrphan.new(orphan, pointer, symbol, origin)
      @system.execute_command(command)
    end

    def clean
      @system.clean_invoices
    end

    def create(pointer)
      @system.execute_command(CreateCommand.new(pointer))
    end

    def create_commercial_forms
      @system.each_package { |pac|
        if (comform = pac.comform)
          possibilities = [
            comform.strip,
            comform.gsub(/\([^\)]+\)/u, "").strip,
            comform.gsub(/[()]/u, "").strip
          ].uniq.delete_if { |possibility| possibility.empty? }
          cform = nil
          possibilities.each { |possibility|
            if (cform = CommercialForm.find_by_name(possibility))
              break
            end
          }
          if cform.nil?
            args = {de: possibilities.first,
                    synonyms: possibilities[1..-1]}
            possibilities.each { |possibility|
              if (form = @system.galenic_form(possibility))
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
        unique_email: email,
        pass_hash: Digest::MD5.hexdigest(pass)
      }
      invoice_pointer = Persistence::Pointer.new(:invoice)
      time = Time.now
      expiry = InvoiceItem.expiry_time(days, time)
      invoice_data = {}
      item_data = {
        duration: days,
        expiry_time: expiry,
        total_netto: State::Limit.price(days.to_i),
        quantity: days,
        text: "unlimited access",
        time: time,
        type: :poweruser,
        vat_rate: VAT_RATE
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

    def update(pointer, values, origin = nil)
      @system.update(pointer, values, origin)
    end

    def set_all_export_flag_registration(boolean)
      data = {export_flag: boolean}
      @system.each_registration do |reg|
        update reg.pointer, data, :swissmedic
      end
    end

    def set_all_export_flag_sequence(boolean)
      data = {export_flag: boolean}
      @system.each_sequence do |seq|
        update seq.pointer, data, :swissmedic
      end
    end

    #####################################################
    def _admin(src, result, priority = 0)
      t = Thread.new {
        Thread.current.abort_on_exception = false
        result =+ result # result String must be unfrozen!
        result << failsafe {
          response = instance_eval(src)
          str = response.to_s
          if str.length > 200
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
      @random_updater.kill if @random_updater.is_a? Thread
      if RUN_UPDATER && @process == :user && !defined?(Minitest)
        @random_updater = run_random_updater
      end
      SBSM::SessionStore.clear
    end

    def run_random_updater
      Thread.new {
        Thread.current.abort_on_exception = true
        update_hour = rand(24)
        update_min = rand(60)
        day = (update_hour > Time.now.hour) ?
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
                feedback.item.name.force_encoding("utf-8")
              end
              if feedback.item.respond_to?(:size) and feedback.item.size
                feedback.item.size.force_encoding("utf-8")
              end
              feedback.name.force_encoding("utf-8") if feedback.name
              feedback.email.force_encoding("utf-8") if feedback.email
              feedback.message.force_encoding("utf-8") if feedback.message
            end
            plg = Plugin.new(self)
            plg.update_rss_feeds("feedback.rss", values, View::Rss::Feedback)
          }
        rescue => e
          puts e.message
          puts e.backtrace
        end
      }
    end

    def ipn(notification)
      Util::Ipn.process notification, self
      nil # don't return the invoice back across drb - it's not defined in yipn
    end

    def grant_download(email, filename, price, expires = Time.now + 2592000)
      ip = Persistence::Pointer.new(:invoice)
      inv = update ip.creator, yus_name: email
      itp = inv.pointer + :item
      update itp.creator, text: filename, price: price, time: Time.now,
        type: :download, expiry_time: expires,
        duration: (Time.now - expires) / 86400,
        vat_rate: 8.0
      inv.payment_received!
      inv.odba_store
      "https://#{SERVER_NAME}/de/gcc/download/invoice/#{inv.oid}/email/#{email}/filename/#{filename}"
    end

    def assign_effective_forms(arg = nil)
      _assign_effective_forms(arg)
    end

    def _assign_effective_forms(arg = nil)
      result = nil
      last = nil
      @system.substances.select { |subs|
        !subs.has_effective_form? && (arg.nil? || arg.to_s < subs.to_s)
      }.sort_by { |subs| subs.name }.each { |subs|
        puts "Looking for effective form of ->#{subs}<- (#{subs.sequences.size} Sequences)"
        name = subs.to_s
        parts = name.split(/\s/u)
        suggest = if parts.size == 1
          subs
        elsif ![nil, "", "Acidum"].include?(parts.first)
          @system.search_single_substance(parts.first) \
            || @system.search_single_substance(parts.first.gsub(/i$/u, "um"))
        end
        last = result
        result = nil
        while result.nil?
          possibles = [
            "d(elete)",
            "S(elf)",
            "n(othing)",
            "other_name"
          ]
          if suggest
            puts "Suggestion:                   ->#{suggest}<-"
            possibles.unshift("s(uggestion)")
          end
          if last
            puts "Last:                         ->#{last}<-"
            possibles.unshift("l(ast)")
          end
          print possibles.join(", ")
          print " > "
          $stdout.flush
          answer = $stdin.readline.strip
          puts "you typed:                    ->#{answer}<-"
          case answer
          when ""
            # do nothing
          when "l"
            result = last
          when "s"
            result = suggest
          when "S"
            result = subs
          when "d"
            subs.sequences.each { |seq|
              seq.delete_active_agent(subs)
              seq.active_agents.odba_isolated_store
            }
            subs.odba_delete
            break
          when "n"
            break
          when "q"
            return
          when /c .+/u
            puts "creating:"
            pointer = Persistence::Pointer.new(:substance)
            puts "pointer: #{pointer}"
            args = {lt: answer.split(/\s+/u, 2).last.strip}
            argstr = args.collect { |*pair| pair.join(" => ") }.join(", ")
            puts "args: #{argstr}"
            result = @system.update(pointer.creator, args)
            result.effective_form = result
            result.odba_store
            puts "result: #{result}"
          else
            result = @system.substance(answer)
          end
        end
        if result
          subs.effective_form = result
          subs.odba_store
        end
      }
      nil
    end

    def yus_allowed?(email, action, key = nil)
      YUS_SERVER.autosession(YUS_DOMAIN) { |session|
        session.entity_allowed?(email, action, key)
      }
    end

    def yus_create_user(email, pass = nil)
      YUS_SERVER.autosession(YUS_DOMAIN) { |session|
        session.create_entity(email, pass)
      }
      # if there is a password, we can log in
      login(email, pass) if pass
    end

    def yus_grant(name, key, item, expires = nil)
      YUS_SERVER.autosession(YUS_DOMAIN) { |session|
        session.grant(name, key, item, expires)
      }
    end

    def yus_get_preference(name, key)
      YUS_SERVER.autosession(YUS_DOMAIN) { |session|
        session.get_entity_preference(name, key)
      }
    rescue RangeError, Yus::YusError
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
      if (odba_id = yus_get_preference(name, "association"))
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

    def yus_set_preference(name, key, value, domain = YUS_DOMAIN)
      YUS_SERVER.autosession(YUS_DOMAIN) { |session|
        session.set_entity_preference(name, key, value, domain)
      }
    end

    def migrate_feedbacks
      @system.each_package { |pac|
        _migrate_feedbacks(pac)
      }
      @system.feedbacks.odba_store
      @system.odba_store
      update_feedback_rss_feed
    end

    def _migrate_feedbacks(item)
      item = item.odba_instance
      fbs = item.instance_variable_get(:@feedbacks).odba_instance
      case fbs
      when Array
        # already migrated, ignore
      when Hash
        new = fbs.values.select { |fb|
          fb.is_a?(Feedback)
        }.sort_by { |fb| fb.time }.reverse
        fbs.odba_delete
        new.odba_store
        item.instance_variable_set(:@feedbacks, new)
        item.odba_store
        new.each { |fb|
          id = fb.odba_id
          fb.instance_variable_set(:@oid, id)
          ptr = Persistence::Pointer.new([:feedback, id])
          fb.instance_variable_set(:@pointer, ptr)
          @system.feedbacks.store(id, fb)
          fb.instance_variable_set(:@item, item)
          fb.odba_store
        }
      when nil
        item.instance_variable_set(:@feedbacks, [])
        item.odba_store
      end
    end

    def log_size
      @@size_logger ||= nil
      @@size_logger ||= Thread.new {
        time = Time.now
        bytes = 0
        threads = 0
        nr_sessions = 0
        format = "%s %s: sessions: %4i - threads: %4i  - memory: %4iMB %s"
        status = case @process
        when :google_crawler then "status_google_crawler"
        when :crawler then "status_crawler"
        when :user then "status"
        else; "status_#{@process}"
        end
        loop {
          begin
            next if defined?(Minitest)
            max_threads = 100
            max_sessions = 40000
            lasttime = time
            time = Time.now
            alarm = (time - lasttime > 60) ? "*" : " "
            lastthreads = threads
            threads = Thread.list.size
            lastbytes = bytes
            bytes = File.read("/proc/#{$$}/stat").split(" ").at(22).to_i
            mbytes = (bytes / (2**20)).to_i

            # Shutdown if more than #{max_threads} threads are created, probably because of spiders
            info = "#{@process} #{threads} threads, footprint of #{mbytes}MB,  #{nr_sessions} sessions. Exiting as "
            if threads > max_threads
              puts info += "more than #{max_threads} threads"
              SBSM.error(info)
              @@size_logger = nil
              exit
            end
            if mbytes > MEMORY_LIMIT
              puts info += "exceeds #{MEMORY_LIMIT}MB"
              SBSM.error(info)
              @@size_logger = nil
              Thread.main.raise SystemExit
            elsif /crawler/i.match(status) and mbytes > MEMORY_LIMIT_CRAWLER
              puts info += "exceeds #{MEMORY_LIMIT_CRAWLER}MB"
              SBSM.error(info)
              @@size_logger = nil
              Thread.main.raise SystemExit
            end
            lastsessions = nr_sessions
            nr_sessions = SBSM::SessionStore.sessions.size
            if lastsessions > max_sessions
              puts info += "more than #{max_sessions} sessions"
              SBSM.error(info)
              @@size_logger = nil
              exit
            end
            gc = ""
            gc << "S" if nr_sessions < lastsessions
            gc << "T" if threads < lastthreads
            gc << "M" if bytes < lastbytes
            path = File.join(ODDB::RESOURCES_DIR, "downloads/" + status)
            lines = begin
              File.readlines(path)[0, 100]
            rescue
              []
            end
            lines.unshift sprintf(format, alarm,
              time.strftime("%Y-%m-%d %H:%M:%S"),
              nr_sessions, threads, mbytes, gc)
            File.open(path, "w") { |fh|
              fh.puts lines
            }
          rescue => e
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
      if lang == "de" or lang == "fr"
        search_method = "search_by_name_" + lang.downcase.to_s
        MIGEL_SERVER.migelid.send(search_method, query)
      else
        []
      end
    end

    def search_migel_products(query, lang)
      migel_code = if /(\d){9}/.match?(query)
        query.split(/(\d\d)/).select { |x| !x.empty? }.join(".")
      elsif /(\d\d\.){4}\d/.match?(query)
        query
      end
      if migel_code
        MIGEL_SERVER.migelid.search_by_migel_code(migel_code)
      # MIGEL_SERVER.search_migel_product_by_migel_code(migel_code)
      else
        MIGEL_SERVER.search_migel_migelid(query, lang)
      end
    end

    def search_migel_group(migel_code)
      MIGEL_SERVER.group.find_by_migel_code(migel_code)
    end

    def search_migel_subgroup(migel_code)
      code = migel_code.split(/(\d\d)/).select { |x| !x.empty? }.join(".")
      MIGEL_SERVER.subgroup.find_by_migel_code(code)
    end

    def search_migel_limitation(migel_code)
      code = migel_code.split(/(\d\d)/).select { |x| !x.empty? }.join(".")
      MIGEL_SERVER.search_limitation(code)
    end

    # e.g. search_migel_items_by_migel_code('100101001').first.name.de
    def search_migel_items_by_migel_code(query, sortvalue = nil, reverse = nil)
      # migel_search event
      # search items by migel_code
      migel_code = if /(\d){9}/.match?(query)
        query.split(/(\d\d)/).select { |x| !x.empty? }.join(".")
      elsif /(\d\d\.){4}\d/.match?(query)
        query
      end
      MIGEL_SERVER.search_migel_product_by_migel_code(migel_code, sortvalue, reverse)
    end

    # search_migel_items('7610472169537', 'de')
    # 1163158
    def search_migel_items(query, lang, sortvalue = nil, reverse = nil)
      # search event
      # search items by using search box
      if /^\d{13}$/.match?(query)
        MIGEL_SERVER.product.search_by_ean_code(query)
      elsif /^\d{6,}$/.match?(query)
        MIGEL_SERVER.product.search_by_pharmacode(query)
      else
        MIGEL_SERVER.search_migel_product(query, lang, sortvalue, reverse)
      end
    end

    def migel_product_index_keys(lang)
      MIGEL_SERVER.migelid_index_keys(lang)
    end

    # Niklaus used this to debug the part of migel/jobs/update_migel under oddb.org
    def migel_count
      @migel_count ||= MIGEL_SERVER.migelids.length
    end

    def get_refdata_info(iksnr)
      infos = {}
      return infos unless registration(iksnr.to_s) and registration(iksnr.to_s).active_packages
      infos[iksnr] = []
      REFDATA_SERVER.session(ODDB::Refdata::RefdataArticle) do |swissindex|
        gtins = registration(iksnr.to_s).active_packages.collect { |x| x.barcode }
        gtins.each do |gtin|
          infos[iksnr] << swissindex.search_item(gtin)
        end
      end
      infos
    end
  end
end

begin
  require ODDB.config.testenvironment1
rescue LoadError
rescue
end
