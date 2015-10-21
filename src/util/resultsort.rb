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
    IsOriginal = 1
    IsGenerikum = 2
    IsNotClassified = 3
    IsNotRefDataListed = 4

    # zeno defined the sort order on May 11 2015 as follow
    # 1. Original (SL)
    # 2. Generikum (SL)
    # 3. Nicht klassifiziert (SL)
    # 4. Bei Refdata nicht gelistet.
    #
    # Innerhalb dieser Reihenfolge (Gruppe) ist wie folgt sortiert:
    #
    # Alphabetisch aufsteigend nach Galenik, Stärke, Packung.
    #
    # Bei Desitin (evidentia und Desitin Power-User Login) müssen die
    # Produkte unter 3 vor 2 kommen (siehe oben).
    # def show_package(package)
    #   puts "result_sort: #{package.class} #{package.iksnr}/#{package.seqnr}/#{package.ikscd} package.sl_generic_type #{package.sl_generic_type.inspect} classified #{classified_group(package)} #{package.sort_info}"
    # end
    def sort_result(packages, session)
      begin
        packages.uniq!
        packages.sort_by! { |package|
          package_from_desitin = (package.company and /desitin/i.match(package.company.to_s) != nil)
          priorize_desitin = false
          priorize_desitin = true if package_from_desitin and session and session.lookandfeel.enabled?(:evidentia, false)
          priorize_desitin = true if package_from_desitin and session and
                                      session.user and not session.user.is_a?(ODDB::UnknownUser) and
                                      /desitin/i.match(session.user.name.to_s)
          name_to_use = (priorize_desitin ? ' '+package.name_base.clone.to_s : package.name_base.clone.to_s).sub(/\s+\d+.+/, '')
          prio = classified_group(package)
          if package_from_desitin and priorize_desitin
            prio = IsGenerikum - 0.1 if prio >= IsGenerikum # must come before IsGenerikum # must come before IsGenerikum
          end
          sort_info = [
            package.expired? ? 1 : -1,
            prio,
            package.galenic_forms.collect { |gf| gf.galenic_group.to_s },
            package.galenic_forms.collect { |gf| gf.to_s },
            name_to_use,
            dose_value(package.dose),
            package.comparable_size,
          ]
          sort_info
        }
        # packages.each{ |package| show_package(package) }
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
    # the following was madly inefficient!
=begin
    types = session.valid_values(:generic_type)
    index = types.index(package.generic_type.to_s).to_i
    10 - (index*2)
=end
    end
  end
end
