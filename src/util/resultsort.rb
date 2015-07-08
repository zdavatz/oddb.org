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

    def sort_result(packages, session)
      begin
        packages = packages.uniq.sort_by! { |package|
          classify_package(package, session)
          if @package_from_desitin and @priorize_desitin
            if @priority == IsNotClassified
              @priority = IsGenerikum - 0.1 # must come before IsGenerikum
            end
          end
          [
            package.expired? ? 1 : -1,
            @priority,
            package.galenic_forms.collect { |gf| galform_str(gf, session) },
            @name_to_use,
            dose_value(package.dose),
            package.comparable_size,
          ]
        }
        if false # only for debug purposes
          id = 0
          packages.each{
            |package|
            id += 1
            classify_package(package, session)
            gal_name = package.galenic_forms.collect { |gf| galform_str(gf, session) }
            puts "id #{sprintf('%3d', id)}: #{package.barcode} expired? #{package.expired?.inspect[0..2]} out_of_trade #{package.out_of_trade.inspect[0..2]} priorize #{@priorize_desitin.to_s[0..3]} #{@priority} (#{package.generic_type.inspect[0..2]}/#{package.sl_generic_type.inspect[0..2]}) '#{package.name_base.to_s}' gal_name #{gal_name} name #{@name_to_use.inspect}"
          }
        end
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
  def classify_package(package, session)
    @package_from_desitin = (package.company and /desitin/i.match(package.company.to_s) != nil)
    @priorize_desitin = false
    @priorize_desitin = true if @package_from_desitin and session and session.lookandfeel.enabled?(:evidentia, false)
    @priorize_desitin = true if @package_from_desitin and session and
                                session.user and not session.user.is_a?(ODDB::UnknownUser) and
                                /desitin/i.match(session.user.name.to_s)
    @priority = classified_group(package)
    @name_to_use = (@priorize_desitin ? ' '+package.name_base.clone.to_s : package.name_base.clone.to_s).sub(/\s+\d+.+/, '')
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
      # the following was madly inefficient!
=begin
    types = session.valid_values(:generic_type)
    index = types.index(package.generic_type.to_s).to_i
    10 - (index*2)
=end
    end
  end
end
