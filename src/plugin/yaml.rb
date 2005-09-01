#!/usr/bin/env ruby
# YamlPlugin -- oddb -- 02.09.2003 -- rwaltert@ywesee.com

require 'plugin/plugin'
require 'drb'

module ODDB 
	class YamlExporter < Plugin
		EXPORT_SERVER = DRbObject.new(nil, EXPORT_URI)
		EXPORT_DIR = File.join(ARCHIVE_PATH, 'downloads')
		def export(name='oddb.yaml')
			export_obj(name, @app.companies)
		end
		def export_array(name, array)
			ids = array.collect { |item| item.odba_id }
			EXPORT_SERVER.export_yaml(ids, EXPORT_DIR, name)
		end
		def export_atc_classes(name='atc.yaml')
			export_array(name, @app.atc_classes.values.sort_by { |atc| atc.code.to_s })
		end
		def export_doctors(name='doctors.yaml')
			export_array(name, @app.doctors.values)
		end
		def export_fachinfos(name='fachinfo.yaml')
			export_array(name, @app.fachinfos.values)
		end
		def export_obj(name, obj)
			EXPORT_SERVER.export_yaml([obj.odba_id], EXPORT_DIR, name)
		end
		def export_patinfos(name='patinfo.yaml')
			export_array(name, @app.patinfos.values)
		end
	end
end
