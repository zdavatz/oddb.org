#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::YamlPlugin -- oddb.org -- 26.04.2013 -- yasaka@ywesee.com
# ODDB::YamlPlugin -- oddb.org -- 19.01.2012 -- mhatakeyama@ywesee.com
# ODDB::YamlPlugin -- oddb.org -- 02.09.2003 -- rwaltert@ywesee.com

require 'plugin/plugin'
require 'drb'
require 'util/log'

module ODDB 
	class YamlExporter < Plugin
		EXPORT_SERVER = DRbObject.new(nil, EXPORT_URI)
		EXPORT_DIR = File.join(ARCHIVE_PATH, 'downloads')
		def export(name='oddb.yaml')
			export_array(name, @app.companies.values)
		end
		def export_array(name, array, opts={})
			ids = array.collect { |item| item.odba_id }
			EXPORT_SERVER.export_yaml(ids, EXPORT_DIR, name, opts)
		end
		def export_atc_classes(name='atc.yaml')
			export_array(name, @app.atc_classes.values.sort_by { |atc| atc.code.to_s })
		end
    def export_doctors(name='doctors.yaml')
      export_array(name, @app.doctors.values)
    end
    def export_galenic_forms(name='galenic_forms.yaml')
      forms =  []
      @app.each_galenic_form.sort.map { |key,value| forms << value} 
      export_array(name, forms.values)
    end
    def export_galenic_groups(name='galenic_groups.yaml')
      groups = []
      @app.galenic_groups.sort.map { |key,value| groups << value }
      export_array(name, groups)
    end
    def check_infos(name, group, &block)
      # Check missing data of fachinfo/patinfo data
      no_descr = {'de' => [], 'fr' => []}
      valid_infos = [] # option
      block.call(no_descr, valid_infos)
      # Send a warning report of fachinfo/patinfo description
      if no_descr.values.flatten.length > 0
        log = Log.new(@@today)
        info = File.basename(name, ".yaml")
        message = []
        no_descr.keys.each do |language|
          unless no_descr[language].empty?
            i = 0
            message.concat([
              "There is no '#{language}' description of #{info.capitalize} of the following",
              "Swissmedic #{group} (Company, Product, Numbers):",
              no_descr[language].map{|list| " " + (i+=1).to_s + ". " + list.join(", ") + "\n"}.to_s
            ])
          end
        end
        log.report = [
          "Message: ",
          "YamlExporter#export_#{info}s method is still running,",
          "but I found some missing #{info.capitalize} document data.",
          "This may cause an error in export ebooks process of ebps.",
          "",
        ].concat(message).join("\n")
        log.notify(" Warning Export: #{name}")
      end
      return valid_infos
    end
    def no_description(fachinfo)
      swissmedic_registration_numbers = ODBA.cache.fetch(fachinfo.odba_id, nil).iksnrs
      if !fachinfo.company_name.to_s.empty? or
         !fachinfo.name_base.to_s.empty? or
         !swissmedic_registration_numbers.empty?
        [fachinfo.company_name, fachinfo.name_base].concat(swissmedic_registration_numbers)
      else
        nil
      end
    end
    def export_effective_fachinfos(name='fachinfo_now.yaml')
      _fachinfos = @app.effective_fachinfos
      check_infos(name, "Registration") do |no_descr|
        _fachinfos.each do |fachinfo|
          no_descr.keys.each do |language|
            unless fachinfo.descriptions and fachinfo.descriptions[language]
              note = no_description(fachinfo)
              no_descr[language].push(note) if note
            end
          end
        end
      end
      export_array(name, _fachinfos, {:expired => false})
    end
    def export_fachinfos(name='fachinfo.yaml')
      check_infos(name, "Registration") do |no_descr|
        @app.fachinfos.values.each do |fachinfo|
          no_descr.keys.each do |language|
            next if fachinfo.iksnrs.size == 0 # ignore invalid fachinfos
            unless fachinfo.descriptions and fachinfo.descriptions[language]
              note = no_description(fachinfo)
              no_descr[language].push(note) if note
            end
          end
        end
      end
      export_array(name, @app.fachinfos.values)
    end
		def export_obj(name, obj)
			EXPORT_SERVER.export_yaml([obj.odba_id], EXPORT_DIR, name)
		end
    def export_effective_patinfos(name='patinfo.yaml')
      valid_patinfos = check_infos(name, "Sequence") do |no_descr, valid_infos|
        @app.effective_patinfos.each do |patinfo|
          patinfo = ODBA.cache.fetch(patinfo.odba_id, nil)
          if (!patinfo.sequences.empty? and
              (patinfo.descriptions['de'] || patinfo.descriptions['fr'])) then
            valid_infos.push patinfo
          end
          no_descr.keys.each do |language|
            begin
              unless patinfo.descriptions[language]
                if sequence = patinfo.sequences.first then
                  swissmedic_registration_number = sequence.registration.iksnr
                  swissbedic_sequence_number     = sequence.seqnr
                  no_descr[language].push(
                    [patinfo.company_name, patinfo.name_base].concat([
                      swissmedic_registration_number,
                      swissbedic_sequence_number
                    ])
                  )
                end
              end
            rescue StandardError
              next # unexpected patinfo
            end
          end
        end
      end
      export_array(name, valid_patinfos)
    end
    alias :export_patinfos :export_effective_patinfos
    def export_prices(name='price_history.yaml')
      packages = @app.packages.reject do |pac|
      pac.prices.all? do |key, prices| prices.empty? end
      end
      export_array(name, packages, :export_prices => true)
    end
	end
end
