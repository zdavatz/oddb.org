#!/usr/bin/env ruby
# YamlExportView -- oddb -- 05.09.2003 -- rwaltert@ywesee.com

require 'view/publictemplate'
require 'view/export'
require 'view/galdatdownload'
require 'htmlgrid/link'

module ODDB
	class YamlExportInnerComposite < HtmlGrid::Composite
		include ExportView
		COMPONENTS = {
			[0,0]		=>	:yaml_export_gz,
			[0,1]		=>	:yaml_export_zip,
			[0,2]		=>	:yaml_fachinfo_export_gz,
			[0,3]		=>	:yaml_fachinfo_export_zip,
			[0,4]		=>	:yaml_patinfo_export_gz,
			[0,5]		=>	:yaml_patinfo_export_zip,
		}
		CSS_MAP = {
			[0,1,1,2]	=>	'list',
		}
		EXPORT_FILE = 'oddb.yaml'
		def yaml_export_gz(model, session)
			link_with_filesize("oddb.yaml.gz")
		end
		def yaml_export_zip(model, session)
			link_with_filesize("oddb.yaml.zip")
		end
		def yaml_fachinfo_export_gz(model, session)
			link_with_filesize("fachinfo.yaml.gz")
		end
		def yaml_fachinfo_export_zip(model, session)
			link_with_filesize("fachinfo.yaml.zip")
		end
		def yaml_patinfo_export_gz(model, session)
			link_with_filesize("patinfo.yaml.gz")
		end
		def yaml_patinfo_export_zip(model, session)
			link_with_filesize("patinfo.yaml.zip")
		end
	end
	class YamlExportComposite < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]		=>	'yaml_export_title',
			[0,1]		=>	'yaml_export_descr',
			[0,2]		=>	'yaml_export_feedback',
			[0,3]		=>  'yaml_link_descr',
			[0,3,1] =>	:yaml_link,
			[0,4]		=>	YamlExportInnerComposite,
			[0,5]		=>	GaldatDownloadInnerComposite,
		}
		CSS_MAP = {
			[0,0]			=>	'th',
			[0,1,1,5]	=>	'list',
		}
		EXPORT_FILE = 'oddb.yaml'
		SYMBOL_MAP = {
			:yaml_link => HtmlGrid::Link,
		}
	end
	class YamlExportView < PublicTemplate
		CONTENT = YamlExportComposite 	
	end
end
