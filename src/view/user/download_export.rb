#!/usr/bin/env ruby
# View::User::DownloadExport -- oddb -- 20.09.2004 -- maege@ywesee.com

require 'view/publictemplate'
require 'view/user/export'
require 'view/user/oddbdatdownload'
require 'view/user/fachinfopdf_download'
require 'view/user/yamlexport'
require 'htmlgrid/link'

module ODDB
	module View
		module User
class DownloadExportComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]		=>	'download_export_title',
		[0,1]		=>	:download_export_descr,
		[0,2]		=>	'download_export_feedback',
		[0,3]		=>  'yaml_link_descr',
		[0,3,1] =>	:yaml_link,
		[0,4]		=>	View::User::YamlExportInnerComposite,
		[0,5]		=>	View::User::OddbDatDownloadInnerComposite,
		[0,6]		=>	View::User::FachinfoPDFDownloadInnerComposite,
	}
	CSS_MAP = {
		[0,0]     =>  'th',
		[0,1,1,6] =>  'list',
	}
	SYMBOL_MAP = {
		:yaml_link => HtmlGrid::Link,
	}
				def download_export_descr(model, session)
					link = HtmlGrid::Link.new(:download_export_descr, model, @session, self)
					if(@lookandfeel.language == 'de')
					link.href =  "http://wiki.oddb.org/wiki.php?pagename=ODDB.Stammdaten"
					elsif(@lookandfeel.language == 'fr')
					link.href = "http://wiki.oddb.org/wiki.php?pagename=ODDB.DonneesDeBase"
					elsif(@lookandfeel.language == 'en')
					link.href = "http://wiki.oddb.org/wiki.php?pagename=ODDB.MasterData"
					end
					link
				end
	CSS_CLASS = 'composite'
end
class DownloadExport < View::PublicTemplate
	CONTENT = View::User::DownloadExportComposite 	
end
		end
	end
end
