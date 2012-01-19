#!/usr/bin/env ruby
# encoding: utf-8
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
			export_obj(name, @app.companies)
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
        def check_fachinfos(name='fachinfo.yaml')
          # Check missing data of fachinfo data
          no_descr = {'de' => [], 'fr' => []}
          @app.fachinfos.values.each do |fachinfo|
            no_descr.keys.each do |language|
              unless fachinfo.descriptions[language]
                swissmedic_registration_numbers = ODBA.cache.fetch(fachinfo.odba_id, nil).iksnrs
                no_descr[language].push(
                  [fachinfo.company_name, fachinfo.name_base].concat(swissmedic_registration_numbers)
                )
              end
            end
          end
          # Send a warning report of fachinfo description
          if no_descr.values.flatten.length > 0
            log = Log.new(@@today)
            message = []
            no_descr.keys.each do |language|
              unless no_descr[language].empty?
                i = 0
                message.concat([
                  "There is no '#{language}' description of Fachinformation of the following",
                  "Swissmedic Registration (Company, Product, Numbers):",
                  no_descr[language].map{|fachlist| " " + (i+=1).to_s + ". " + fachlist.join(", ") + "\n"}.to_s
                ])
              end
            end
            log.report = [
              "Message: ",
              "YamlExporter#export_fachinfs method is still running,",
              "but I found some missing Fachinfo document data.",
              "This may cause an error in export ebooks process of ebps.",
              "",
            ].concat(message).join("\n")
            log.notify(" Warning Export: #{name}")
          end
          return no_descr
        end
		def export_fachinfos(name='fachinfo.yaml')
          check_fachinfos(name)
          export_array(name, @app.fachinfos.values)
		end
    def export_interactions(name='interactions.yaml')
      export_array(name, @app.substances.inject([]) { |memo, sub| memo.concat sub.substrate_connections.values })
    end
		def export_obj(name, obj)
			EXPORT_SERVER.export_yaml([obj.odba_id], EXPORT_DIR, name)
		end
		def export_patinfos(name='patinfo.yaml')
			export_array(name, @app.patinfos.values)
		end
    def export_prices(name='price_history.yaml')
      packages = @app.packages.reject do |pac|
        pac.prices.all? do |key, prices| prices.empty? end
      end
      export_array(name, packages, :export_prices => true)
    end
	end
end
