#!/usr/bin/env ruby
# View::User::YamlExport -- oddb -- 05.09.2003 -- rwaltert@ywesee.com

require 'view/publictemplate'
require 'view/user/export'
require 'view/user/oddbdatdownload'
require 'htmlgrid/link'

module ODDB
	module View
		module User
class YamlExportInnerComposite < HtmlGrid::Composite
	include View::User::Export
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
		[0,4]		=>	View::User::YamlExportInnerComposite,
		[0,5]		=>	View::User::OddbDatDownloadInnerComposite,
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
class YamlExport < View::PublicTemplate
	CONTENT = View::User::YamlExportComposite 	
end
		end
	end
end
