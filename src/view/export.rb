#!/usr/bin/env ruby
# ExportView -- oddb -- 05.09.2003 -- hwyss@ywesee.com

module ODDB
	module ExportView
		EXPORT_DIR = File.expand_path(
			'../../doc/resources/downloads',
			File.dirname(__FILE__))
		EXPORT_FILE = ''
		def display?(path)
			File.exists?(path) && File.size(path) > 0
		end
		def export_link(key, filename)
			link = HtmlGrid::Link.new(key, @model, @session, self)
			args = {'filename'=>filename}
			link.href = @lookandfeel.event_url(:download, args)
			link.label = true
			link.set_attribute('class', 'list')
			link
		end
		def convert_filesize(path)
			kilo = (2**10).to_f
			size = File.size(path).to_f / kilo
			unit = "kB"
			if(size > kilo)
				size = size/kilo
				unit = "MB"
			end
			rounded = sprintf('%.2f', size)
			[
				"(",
				rounded,
				unit,
				")",
			].join("&nbsp;")
		end
		def link_with_filesize(filename)
			if(display?(file_path(filename)))
				symbol = filename.tr(".", "_").intern
				link = export_link(symbol, filename)
				size = filesize(filename)
				[link, size]
			end
		end
		def file_path(filename)
			File.expand_path(filename, self::class::EXPORT_DIR)
		end
		def filesize(filename)
			if(display?(file_path(filename)))
				convert_filesize(file_path(filename))
			end
		end
	end
end
