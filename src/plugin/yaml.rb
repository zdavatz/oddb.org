#!/usr/bin/env ruby
# YamlPlugin -- oddb -- 02.09.2003 -- rwaltert@ywesee.com

require 'plugin/plugin'

module ODDB 
	class YamlExporter < Plugin
		DOCUMENT_ROOT = File.expand_path('../../doc/', File.dirname(__FILE__))
		EXPORT_DIR = File.expand_path('resources/downloads', DOCUMENT_ROOT)
		EXPORT_SERVER = DRbObject.new(nil, EXPORT_URI)
		def run
			db_name = 'oddb.yaml'
			fi_name = 'fachinfo.yaml'
			pi_name = 'patinfo.yaml'
			atc_name = 'atc.yaml'
			export(db_name)
			export_atc_classes(atc_name)
			if(Date.today.wday==2)
				export_fachinfos(fi_name)
			end
			if(Date.today.wday==3)
				export_patinfos(pi_name)
			end
		end
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
