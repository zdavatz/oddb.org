#!/usr/bin/env ruby
# Exporter -- oddb -- 30.07.2003 -- hwyss@ywesee.com 

require 'plugin/galdat_export'
require 'plugin/fipdf'
require 'plugin/yaml'

module ODDB
	class Exporter
		def initialize(app)
			@app = app
		end
		def run
			export_yaml
			GC.start
			export_galdat
			GC.start
		end
		def export_galdat
			GaldatExport.new(@app).run
		end
		def export_yaml
			YamlExporter.new(@app).run
		end
		def export_pdf
			FiPDFExporter.new(@app).run
		end
	end
end
