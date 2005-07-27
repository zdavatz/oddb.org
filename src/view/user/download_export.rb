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
		[0,2]		=>	:csv_export_zip,
		[2,2]		=>	:radio_oddb_csv_zip,
		[0,3]		=>	:yaml_export_gz,
		[2,3]		=>	:radio_oddb_yaml_gz,
		[0,4]		=>	:yaml_export_zip,
		[2,4]		=>	:radio_oddb_yaml_zip,
		[0,5]		=>	:yaml_fachinfo_export_gz,
		[2,5]		=>	:radio_fachinfo_yaml_gz,
		[0,6]		=>	:yaml_fachinfo_export_zip,
		[2,6]		=>	:radio_fachinfo_yaml_zip,
		[0,7]		=>	:yaml_patinfo_export_gz,
		[3,7]		=>	:yaml_patinfo_price_gz,
		[0,8]		=>	:yaml_patinfo_export_zip,
		[3,8]		=>	:yaml_patinfo_price_zip,
		[0,9]		=>	:yaml_doctors_export_gz,
		[3,9]		=>	:yaml_doctors_price_gz,
		[0,10]	=>	:yaml_doctors_export_zip,
		[3,10]	=>	:yaml_doctors_price_zip,
		[0,12]	=>	:oddbdat_download_tar_gz,
		[2,12]	=>	:radio_oddbdat_tar_gz,
		[0,13]	=>	:oddbdat_download_zip,
		[2,13]	=>	:radio_oddbdat_zip,
		[0,14]	=>	:s31x_gz,
		[2,14]	=>	:radio_s31x_gz,
		[0,15]	=>	:s31x_zip,
		[2,15]	=>	:radio_s31x_zip,
	}
	CSS_MAP = {
		[0,0,6]			=>	'subheading',
		[0,1,6,15]	=>	'list',
	}
	CSS_CLASS = 'component'
	def csv_export_gz(model, session)
		checkbox_with_filesize("oddb.csv.gz")
	end
	def csv_export_zip(model, session)
		checkbox_with_filesize("oddb.csv.zip")
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
		price = State::User::DownloadExport.price('doctors.yaml')
		hidden = HtmlGrid::Input.new('months[doctors.yaml.gz]', 
			model, session, self)
		hidden.set_attribute('type', 'hidden')
		hidden.value = '1'
		[@lookandfeel.format_price(price.to_i * 100, 'EUR'), hidden]
	end
	def yaml_doctors_price_zip(model, session)
		price = State::User::DownloadExport.price('doctors.yaml')
		hidden = HtmlGrid::Input.new('months[doctors.yaml.zip]', 
			model, session, self)
		hidden.set_attribute('type', 'hidden')
		hidden.value = '1'
		[@lookandfeel.format_price(price.to_i * 100, 'EUR'), hidden]
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
		price = State::User::DownloadExport.price('patinfo.yaml')
		hidden = HtmlGrid::Input.new('months[patinfo.yaml.gz]', 
			model, session, self)
		hidden.set_attribute('type', 'hidden')
		hidden.value = '1'
		[@lookandfeel.format_price(price.to_i * 100, 'EUR'), hidden]
	end
	def yaml_patinfo_price_zip(model, session)
		price = State::User::DownloadExport.price('patinfo.yaml')
		hidden = HtmlGrid::Input.new('months[patinfo.yaml.zip]', 
			model, session, self)
		hidden.set_attribute('type', 'hidden')
		hidden.value = '1'
		[@lookandfeel.format_price(price.to_i * 100, 'EUR'), hidden]
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
	EVENT = :proceed
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
