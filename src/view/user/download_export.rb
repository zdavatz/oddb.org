#!/usr/bin/env ruby
# View::User::DownloadExport -- oddb -- 20.09.2004 -- mhuggler@ywesee.com

require 'view/publictemplate'
require 'view/form'
require 'view/datadeclaration'
require 'view/user/export'
require 'view/user/oddbdatdownload'
require 'view/user/fachinfopdf_download'
require 'view/user/yamlexport'
require 'htmlgrid/link'
require 'htmlgrid/errormessage'

module ODDB
	module View
		module User
class DownloadExportInnerComposite < HtmlGrid::Composite
	include View::User::Export
	COMPONENTS = {
		[3,0]		=>	'months_1',
		[5,0]		=>	'months_12',
		[0,1]		=>	:csv_export_gz,
		[2,1]		=>	:radio_oddb_csv_gz,
		[6,1]		=>	:datadesc_oddb_csv,
		[0,2]		=>	:csv_export_zip,
		[2,2]		=>	:radio_oddb_csv_zip,
		[0,3]		=>	:yaml_export_gz,
		[2,3]		=>	:radio_oddb_yaml_gz,
		[6,3]		=>	:datadesc_oddb_yaml,
		[0,4]		=>	:yaml_export_zip,
		[2,4]		=>	:radio_oddb_yaml_zip,
		[0,5]		=>	:yaml_fachinfo_export_gz,
		[2,5]		=>	:radio_fachinfo_yaml_gz,
		[6,5]		=>	:datadesc_fachinfo_yaml,
		[0,6]		=>	:yaml_fachinfo_export_zip,
		[2,6]		=>	:radio_fachinfo_yaml_zip,
		[0,7]		=>	:yaml_patinfo_export_gz,
		[3,7]		=>	:yaml_patinfo_price_gz,
		[6,7]		=>	:datadesc_patinfo_yaml,
		[0,8]		=>	:yaml_patinfo_export_zip,
		[3,8]		=>	:yaml_patinfo_price_zip,
		[0,9]		=>	:yaml_doctors_export_gz,
		[3,9]		=>	:yaml_doctors_price_gz,
		[6,9]		=>	:datadesc_doctors_yaml,
		[0,10]	=>	:yaml_doctors_export_zip,
		[3,10]	=>	:yaml_doctors_price_zip,
		[0,11]	=>	:csv_doctors_export_gz,
		[3,11]	=>	:csv_doctors_price_gz,
		[6,11]	=>	:datadesc_doctors_csv,
		[0,12]	=>	:csv_doctors_export_zip,
		[3,12]	=>	:csv_doctors_price_zip,
		[0,14]	=>	:oddbdat_download_tar_gz,
		[2,14]	=>	:radio_oddbdat_tar_gz,
		[6,14]	=>	:datadesc_oddbdat,
		[0,15]	=>	:oddbdat_download_zip,
		[2,15]	=>	:radio_oddbdat_zip,
		[0,16]	=>	:s31x_gz,
		[6,16]	=>	:datadesc_s31x,
		[2,16]	=>	:radio_s31x_gz,
		[0,17]	=>	:s31x_zip,
		[2,17]	=>	:radio_s31x_zip,
	}
	CSS_MAP = {
		[0,0,6]			=>	'subheading',
		[0,1,7,17]	=>	'list',
	}
	COLSPAN_MAP = {
		[5,0]	=>	2,
	}
	CSS_CLASS = 'component'
	def csv_export_gz(model, session)
		checkbox_with_filesize("oddb.csv.gz")
	end
	def csv_export_zip(model, session)
		checkbox_with_filesize("oddb.csv.zip")
	end
	def csv_doctors_export_gz(model, session)
		checkbox_with_filesize("doctors.csv.gz")
	end
	def csv_doctors_export_zip(model, session)
		checkbox_with_filesize("doctors.csv.zip")
	end
	def csv_doctors_price_gz(model, session)
		once('doctors.csv.gz')
	end
	def csv_doctors_price_zip(model, session)
		once('doctors.csv.zip')
	end
	def datadesc_doctors_csv(model, session)
		datadesc('doctors.csv')
	end
	def datadesc_doctors_yaml(model, session)
		datadesc('doctors.yaml')
	end
	def datadesc_fachinfo_yaml(model, session)
		datadesc('fachinfo.yaml')
	end
	def datadesc_oddb_csv(model, session)
		datadesc('oddb.csv')
	end
	def datadesc_oddbdat(model, session)
		datadesc('oddbdat')
	end
	def datadesc_oddb_yaml(model, session)
		datadesc('oddb.yaml')
	end
	def datadesc_patinfo_yaml(model, session)
		datadesc('patinfo.yaml')
	end
	def datadesc_s31x(model, session)
		datadesc('s31x')
	end
	def oddbdat_download_tar_gz(model, session)
		checkbox_with_filesize("oddbdat.tar.gz")
	end
	def oddbdat_download_zip(model, session)
		checkbox_with_filesize("oddbdat.zip")
	end
	def radio_oddb_csv_gz(model, session)
		once_or_year('oddb.csv.gz')
	end
	def radio_oddb_csv_zip(model, session)
		once_or_year('oddb.csv.zip')
	end
	def radio_fachinfo_yaml_gz(model, session)
		once_or_year('fachinfo.yaml.gz')
	end
	def radio_fachinfo_yaml_zip(model, session)
		once_or_year('fachinfo.yaml.zip')
	end
	def radio_oddbdat_tar_gz(model, session)
		once_or_year('oddbdat.tar.gz')
	end
	def radio_oddbdat_zip(model, session)
		once_or_year('oddbdat.zip')
	end
	def radio_oddb_yaml_gz(model, session)
		once_or_year('oddb.yaml.gz')
	end
	def radio_oddb_yaml_zip(model, session)
		once_or_year('oddb.yaml.zip')
	end
	def radio_s31x_gz(model, session)
		once_or_year('s31x.gz')
	end
	def radio_s31x_zip(model, session)
		once_or_year('s31x.zip')
	end
	def s31x_gz(model, session)
		checkbox_with_filesize("s31x.gz")
	end
	def s31x_zip(model, session)
		checkbox_with_filesize("s31x.zip")
	end
	def yaml_doctors_export_gz(model, session)
		checkbox_with_filesize("doctors.yaml.gz")
	end
	def yaml_doctors_export_zip(model, session)
		checkbox_with_filesize("doctors.yaml.zip")
	end
	def yaml_doctors_price_gz(model, session)
		once('doctors.yaml.gz')
	end
	def yaml_doctors_price_zip(model, session)
		once('doctors.yaml.zip')
	end
	def yaml_export_gz(model, session)
		checkbox_with_filesize("oddb.yaml.gz")
	end
	def yaml_export_zip(model, session)
		checkbox_with_filesize("oddb.yaml.zip")
	end
	def yaml_fachinfo_export_gz(model, session)
		checkbox_with_filesize("fachinfo.yaml.gz")
	end
	def yaml_fachinfo_export_zip(model, session)
		checkbox_with_filesize("fachinfo.yaml.zip")
	end
	def yaml_patinfo_export_gz(model, session)
		checkbox_with_filesize("patinfo.yaml.gz")
	end
	def yaml_patinfo_export_zip(model, session)
		checkbox_with_filesize("patinfo.yaml.zip")
	end
	def yaml_patinfo_price_gz(model, session)
		once('patinfo.yaml.gz')
	end
	def yaml_patinfo_price_zip(model, session)
		once('patinfo.yaml.zip')
	end
end
class DownloadExportComposite < Form
	include HtmlGrid::ErrorMessage
	include View::DataDeclaration
	COMPONENTS = {
		[0,0]		=>	'download_export',
		[0,0,0]	=>	'dash_separator',
		[0,0,1]	=>	:data_declaration,
		[0,1]		=>	:download_export_descr,
		[0,2]		=>	DownloadExportInnerComposite,
		[0,3]		=>	:submit,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0] =>  'th',
		[0,1] =>  'list',
		[0,3] =>  'list',
	}
	EVENT = :proceed_download
	SYMBOL_MAP = {
		:yaml_link => HtmlGrid::Link,
	}
	def download_export_descr(model, session)
		pages = {
			'de' => 'Stammdaten', 	
			'en' => 'MasterData', 	
			'fr' => 'DonneesDeBase', 	
		}
		page = pages[@lookandfeel.language]
		link = HtmlGrid::Link.new(:download_export_descr, model, 
			@session, self)
		link.href = "http://wiki.oddb.org/wiki.php?pagename=ODDB.#{page}"
		link
	end
	def init
		super
		error_message(1)
	end
end
class DownloadExport < View::PublicTemplate
	CONTENT = View::User::DownloadExportComposite 	
end
		end
	end
end
