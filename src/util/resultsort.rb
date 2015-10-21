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
    IsOriginal          = 1     # always come first
    IsSponsored         = 10
    IsGenerikum         = 20
    IsNotClassified     = 21
    IsNotRefDataListed  = 23

    # zeno defined the sort order in mail of Oktobre 21, 2015
    # Bei Evidentia kommen zuerst die Originale und dann die Produkte von Desitin wie folgt:
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
    # Innerhalb dieser Gruppen zuerst Produkte die SL sind, dann die Produkte, welche nicht SL sind.
    #
    # Es gibt zwei Gruppen:
    #
    # A: Refdata gelistet
    # B: Refdata nicht gelistet
    #
    # dann
    #
    # A: Original
    # B: Generikum
    #
    # [ Beim Sponsoring wie z.B. Desitin erscheinen die in Refdata nicht gelisteten Produkte innerhalb vom Desitin Block, wiederum zuunterst wie oben erwähnt. ]
    #
    # Innerhalb dieser Gruppen wird sortiert nach:
    #
    # 1. Infusionslösungen
    # 2. Feste Formen
    # 3. Orale Lösungen
    #
    # Innerhalb dieser Gruppen zuerst Produkte die SL sind, dann die Produkte, welche nicht SL sind.
    #
    # Innerhalb dieser Gruppen aufsteigend nach Packungsgrösse.
    #
    def show_package_sort_info(package, session)
      name_to_use, prio = adjusted_name_and_prio(package, session)
      puts "result_sort: #{package.class} #{package.iksnr}/#{package.seqnr}/#{package.ikscd} ["+
          "#{package.expired? ? 1 : -1}," +
          "#{package.out_of_trade    ? IsNotRefDataListed : 1}, " +
          "#{prio}, " +
          "#{classified_group(package)}, " +
          "#{package.galenic_forms.collect { |gf| gf.galenic_group.to_s } }, " +
          "#{package.galenic_forms.collect { |gf| gf.to_s } }, " +
          "#{name_to_use}, #{dose_value(package.dose)}, #{package.comparable_size}"
    end
    def sort_result(packages, session)
      # http://ch.oddb.org/de/gcc/show/reg/61848/seq/01/pack/001 sl_entry nil
      # http://ch.oddb.org/de/gcc/show/reg/61848/seq/01/pack/002 sl_entry.sl_generic_type = :generic
      begin
        packages.uniq!
        packages.sort_by! { |package|
          name_to_use, prio = adjusted_name_and_prio(package, session)
          sort_info = [
            package.expired?        ? 1 : -1,
            package.out_of_trade    ? IsNotRefDataListed : 1,
            prio,
            package.galenic_forms.collect { |gf| gf.galenic_group.to_s },
            package.galenic_forms.collect { |gf| gf.to_s },
            classified_group(package),
            name_to_use,
            dose_value(package.dose),
            package.comparable_size,
          ]
          sort_info
        }
        packages.each{ |package| show_package_sort_info(package, session) }
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
    def adjusted_name_and_prio(package, session)
      package_from_desitin = (package.company and /desitin/i.match(package.company.to_s) != nil)
      is_desitin = false
      is_desitin = true if package_from_desitin and session and session.lookandfeel.enabled?(:evidentia, false)
      is_desitin = true if package_from_desitin and session and
                                  session.user and not session.user.is_a?(ODDB::UnknownUser) and
                                  /desitin/i.match(session.user.name.to_s)
      if is_desitin
        name_to_use = ' '+package.name_base.clone.to_s
        prio = IsSponsored
      else
        name_to_use = package.name_base.clone.to_s.sub(/\s+\d+.+/, '')
        prio = classified_group(package)
      end
      return name_to_use, prio
    end

    def classified_group(package)
      return IsNotRefDataListed if package.out_of_trade
      if package.sl_generic_type
        if package.sl_generic_type.eql?(:original)
          return IsOriginal
        elsif package.sl_generic_type.eql?(:generic)
          return IsGenerikum
        end
      end
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
