#!/usr/bin/env ruby
# View::User::YamlExport -- oddb -- 05.09.2003 -- rwaltert@ywesee.com

require 'view/publictemplate'
require 'view/user/export'
require 'view/user/oddbdatdownload'
require 'view/user/fachinfopdf_download'
require 'htmlgrid/link'

module ODDB
	module View
		module User
class YamlExportInnerComposite < HtmlGrid::Composite
	include View::User::Export
	COMPONENTS = {
		[0,1]		=>	:yaml_export_gz,
		[0,2]		=>	:yaml_export_zip,
		[0,3]		=>	:yaml_fachinfo_export_gz,
		[0,4]		=>	:yaml_fachinfo_export_zip,
		[0,5]		=>	:yaml_patinfo_export_gz,
		[0,6]		=>	:yaml_patinfo_export_zip,
	}
	CSS_MAP = {
		[0,1,1,6]	=>	'list',
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
		end
	end
end
