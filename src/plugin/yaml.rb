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
      @app.each_galenic_form { |x| forms << x }
      export_array(name, forms)
    end
    def export_galenic_groups(name='galenic_groups.yaml')
      groups = []
      @app.galenic_groups.sort.map { |key,value| groups << value }
      export_array(name, groups)
    end
		def export_obj(name, obj)
			EXPORT_SERVER.export_yaml([obj.odba_id], EXPORT_DIR, name)
		end
    def export_prices(name='price_history.yaml')
      packages = @app.packages.reject do |pac|
      pac.prices.all? do |key, prices| prices.empty? end
      end
      export_array(name, packages, :export_prices => true)
    end
	end
end
