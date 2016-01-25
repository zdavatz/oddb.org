#!/usr/bin/env ruby
# encoding: utf-8

module ODDB
  module ResultStateSort
    def sort
      get_sortby!
      if @model
        @model.each { |atc|
          atc.packages.sort! { |a, b| compare_entries(a, b) }
          atc.packages.reverse! if(@sort_reverse)
        }
      end
      self
    end
  end
  module ResultSort
  private
    IsCurrent           = 20
    IsNotClassified     = 40
    IsNotRefDataListed  = 60
    IsOutOfTrade        = 80
    DebugSort           = false || ENV['ODDB_DEBUG_SORT']
    def add_generic_weight(prio, package, consider_trademark=false)
        prio += 1 unless package.sl_generic_type.eql?(:generic)
        prio += 2 unless package.sl_generic_type.eql?(:original)
        prio += 4 unless package.sl_entry
        prio += 8 unless consider_trademark
        prio
    end
  public
    # zeno defined the sort order in mail of Oktobre 21, 2015
    # Bei Evidentia müssen  E-Mail from November 27 2015
    # redefined by Zeno on Januar 25 as following
    # *Ausser Handel
    # *Nicht mehr zugelassen

    # ist stärker als rot, grün oder nicht klassifiziert, d.h. rote oder
    # grüne die nicht bei Refdata gelistet sind oder bei Swissmedic nicht
    # zugelassen sind, rutschen runter.

    # Somit ist die Reihenfolge:

    # Markenname rot
    # Markenname grün
    # schwarz
    # ausser Handel gemäss Refdata
    # Nicht mehr zugelassen gemäss Swissmedic
    #
    # Innerhalb dieser Gruppen kommmen
    #
    # 1. Infusionslösungen
    # 2. Feste Formen
    # 3. Orale Lösungen
    #
    # Innerhalb dieser Gruppen zuerst Produkte die SL sind, dann die Produkte, welche nicht SL sind.
    #
    # Danach kommen die Produkte wie folgt:
    #
    # 1. Infusionslösungen
    # 2. Feste Formen
    # 3. Orale Lösungen
    #
    # Innerhalb dieser Gruppen aufsteigend nach Packungsgrösse.
    #
    def sort_result(packages, a_session)
      m = a_session && a_session.request_path && /search_query[\/=]([^\/=&]*)/.match(a_session.request_path)
      trademark = false
      trademark = URI.unescape(m[1]) if m
      puts "Resultsort #{__LINE__}: tm #{trademark.inspect} from #{a_session.request_path}" if DebugSort && a_session
      begin
        packages.uniq!
        dbg_packs = [] if DebugSort
        packages.sort_by! do |package|
          name_to_use, prio = adjusted_name_and_prio(package, a_session, trademark)
          sort_info = [
            package.expired?        ? 1 : -1,
            prio,
            package.galenic_forms.collect { |gf| gf.galenic_group.to_s },
            package.galenic_forms.collect { |gf| gf.to_s },
            classified_group(package),
            name_to_use,
            dose_value(package.dose),
            package.comparable_size,
          ]
          sort_info
        end
        packages.each_with_index{|x, idx| puts "packages.sorted #{idx}: #{x.iksnr}/#{x.seqnr}/#{x.ikscd} #{x.name} #{decode_package(x)}" } if DebugSort
        packages
      rescue StandardError => e
        puts e.class
        puts e.message
        puts e.backtrace
        packages
      end
    end
    def dose_value(dose)
      dose || Dose.new(0)
    end
    def package_count
      @packages.size
    end
    def galform_str(galform, session)
      if(galform.odba_instance.nil?)
        ''
      elsif galform.respond_to?(session.language.to_sym)
        galform.send(session.language)
      else
        ''
      end
    end
private
    def decode_package(package)
      decoded = package.ikscat
      decoded += package.sl_entry ? ' / SL' : ''
      if package.sl_generic_type
        if package.sl_generic_type.eql?(:original)
          decoded += ' / SO'
        elsif package.sl_generic_type.eql?(:generic)
          decoded += ' / SG'
        end
      end
      decoded += ' OFT' if package.out_of_trade
      decoded += ' exp' if package.expired?
      decoded
    end
    def adjusted_name_and_prio(package, a_session, trademark)
      package_from_desitin = package.company && /desitin/i.match(package.company.to_s)
      is_desitin = package_from_desitin &&
          !package.out_of_trade &&
          !package.expired? &&
          ( a_session && a_session.lookandfeel.enabled?(:evidentia, false)) ||
            (a_session.user && !a_session.user.is_a?(ODDB::UnknownUser) &&
             /desitin/i.match(a_session.user.name.to_s))
      if is_desitin
        name_to_use = ' ' +  package.registration.name_base
        prio = classified_group(package)
      else
        name_to_use = package.registration.name_base
        prio = classified_group(package)
      end
      name_to_use = name_to_use.clone.downcase.sub(/\s+\d+.*/, '')
      consider_trademark = a_session.lookandfeel.enabled?(:evidentia, false) &&
          trademark &&
          !package.out_of_trade &&
          !package.expired? &&
          (trademark.downcase.eql?(package.registration.name_base.downcase) ||
           Dose.new(package.registration.name_base.downcase.sub(trademark.downcase, '')).qty != 0)
      prio = add_generic_weight(prio, package, consider_trademark)
      # eg.g http://evidentia.oddb-ci2.dyndns.org/de/evidentia/search/zone/drugs/search_query/Cordarone/search_type/st_combined
      if DebugSort
        puts "adjusted_name_and_prio evidentia? #{a_session.lookandfeel.enabled?(:evidentia, false)}" +
            " #{trademark} TM? #{consider_trademark.inspect} pack #{package.iksnr}/#{package.seqnr}/#{package.ikscd} #{package.name_base} -> #{name_to_use} #{decode_package(package)} type #{package.sl_generic_type} expired? #{package.expired?.inspect}" +
            " out_of_trade #{package.out_of_trade.inspect} dose #{package.dose.inspect} #{package.sl_entry != nil} is_desitin #{is_desitin} prio #{prio.inspect}"
      end
      return name_to_use, prio
    end
    def classified_group(package)
      return IsOutOfTrade if package.out_of_trade
      return IsNotRefDataListed if package.expired?
      return IsCurrent if package.sl_entry != nil
      return IsCurrent unless package.out_of_trade # aka ref_data_listed
      return IsNotClassified
    end
    # the following was madly inefficient!
=begin
    types = session.valid_values(:generic_type)
    index = types.index(package.generic_type.to_s).to_i
    10 - (index*2)
=end
  end
end
