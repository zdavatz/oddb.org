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
		[0,1]		=>	'export_datafiles',
		[0,2]		=>	:csv_doctors_export,
		[3,2]		=>	:csv_doctors_price,
		[6,2]		=>	:datadesc_doctors_csv,
		[7,2]		=>	:example_doctors_csv,
		[0,3]		=>	:yaml_doctors_export,
		[3,3]		=>	:yaml_doctors_price,
		[6,3]		=>	:datadesc_doctors_yaml,
		[7,3]		=>	:example_doctors_yaml,
		[0,4]		=>	:yaml_fachinfo_export,
		[2,4]		=>	:radio_fachinfo_yaml,
		[6,4]		=>	:datadesc_fachinfo_yaml,
		[7,4]		=>	:example_fachinfo_yaml,
		[0,5]		=>	:csv_migel_export,
		[3,5]		=>	:csv_migel_price,
		[6,5]		=>	:datadesc_migel_csv,
		[7,5]		=>	:example_migel_csv,
		[0,6]		=>	:csv_narcotics_export,
		[2,6]		=>	:radio_narcotics_csv,
		[6,6]		=>	:datadesc_narcotics_csv,
		[7,6]		=>	:example_narcotics_csv,
		[0,7]		=>	:yaml_narcotics_export,
		[2,7]		=>	:radio_narcotics_yaml,
		[6,7]		=>	:datadesc_narcotics_yaml,
		[7,7]		=>	:example_narcotics_yaml,
		[0,8]		=>	:csv_export,
		[2,8]		=>	:radio_oddb_csv,
		[6,8]		=>	:datadesc_oddb_csv,
		[7,8]		=>	:example_oddb_csv,
		[0,9]		=>	:yaml_export,
		[2,9]		=>	:radio_oddb_yaml,
		[6,9]		=>	:datadesc_oddb_yaml,
		[7,9]		=>	:example_oddb_yaml,
		[0,10]		=>	:yaml_patinfo_export,
		[3,10]		=>	:yaml_patinfo_price,
		[6,10]		=>	:datadesc_patinfo_yaml,
		[7,10]		=>	:example_patinfo_yaml,

		[0,12]	=>	'export_added_value',
		[0,13]	=>	:xls_generics,
		[2,13]	=>	:radio_generics_xls,
		[6,13]	=>	:datadesc_generics_xls,
		[7,13]	=>	:example_generics_xls,
		[0,14]	=>	:xls_meddrugs_update,
		[2,14]	=>	:radio_meddrugs_update_xls,
		[6,14]	=>	:datadesc_meddrugs_update_xls,
		[7,14]	=>	:example_meddrugs_update_xls,

		[0,16]	=>	'export_compatibility',
		[0,17]	=>	:oddbdat_download,
		[2,17]	=>	:radio_oddbdat,
		[6,17]	=>	:datadesc_oddbdat,
		[0,18]	=>	:s31x,
		[2,18]	=>	:radio_s31x,
		[6,18]	=>	:datadesc_s31x,
		[0,19]	=>	:compression_label,
		[0,20]	=>	:compression,
	}
	CSS_MAP = {
		[0,0,8]			=>	'subheading',
		[0,1,8]			=>	'list-bg sum',
		[0,2,8,17]	=>	'list',
		[0,3,8]			=>	'list-bg',
		[0,5,8]			=>	'list-bg',
		[0,7,8]			=>	'list-bg',
		[0,9,8]			=>	'list-bg',
		[0,12,8]		=>	'list-bg sum',
		[0,14,8]		=>	'list-bg',
		[0,16,8]		=>	'list-bg sum',
		[0,18,8]		=>	'list-bg',
	}
	COLSPAN_MAP = {
		[5,0]	=>	2,
		[0,1]	=>	8,
		[0,12]=>	8,
		[0,16]=>	8,
		[0,19]=>	8,
		[0,20]=>	8,
	}
	CSS_CLASS = 'component'
	SYMBOL_MAP = {
		:compression => HtmlGrid::Select,
	}
	def compression_label(model, session)
		HtmlGrid::LabelText.new(:compression, model, session, self)
	end
	def csv_export(model, session)
		checkbox_with_filesize("oddb.csv")
	end
	def csv_doctors_export(model, session)
		checkbox_with_filesize("doctors.csv")
	end
	def csv_doctors_price(model, session)
		once('doctors.csv')
	end
	def csv_migel_export(model, session)
		checkbox_with_filesize('migel.csv')
	end
	def csv_narcotics_export(model, session)
		checkbox_with_filesize('narcotics.csv')
	end
	def csv_migel_price(model, session)
		once('migel.csv')
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
	def datadesc_generics_xls(model, session)
		datadesc('generics.xls')
	end
	def datadesc_meddrugs_update_xls(model, session)
		datadesc('meddrugs-update.xls')
	end
	def datadesc_migel_csv(model, session)
		datadesc('migel.csv')
	end
	def datadesc_narcotics_csv(model, session)
		datadesc('narcotics.csv')
	end
	def datadesc_narcotics_yaml(model, session)
		datadesc('narcotics.yaml')
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
	def example_doctors_csv(model, session)
		example('doctors.csv')
	end
	def example_doctors_yaml(model, session)
		example('doctors.yaml')
	end
	def example_fachinfo_yaml(model, session)
		example('fachinfo.yaml')
	end
	def example_generics_xls(model, session)
		example('generics.xls')
	end
	def example_meddrugs_update_xls(model, session)
		example('meddrugs-update.xls')
	end
	def example_migel_csv(model, session)
		example('migel.csv')
	end
	def example_narcotics_csv(model, session)
		example('narcotics.csv')
	end
	def example_narcotics_yaml(model, session)
		example('narcotics.yaml')
	end
	def example_oddb_csv(model, session)
		example('oddb.csv')
	end
	def example_oddb_yaml(model, session)
		example('oddb.yaml')
	end
	def example_patinfo_yaml(model, session)
		example('patinfo.yaml')
	end
	def oddbdat_download(model, session)
		checkbox_with_filesize("oddbdat")
	end
	def radio_oddb_csv(model, session)
		once_or_year('oddb.csv')
	end
	def radio_fachinfo_yaml(model, session)
		once_or_year('fachinfo.yaml')
	end
	def radio_generics_xls(model, session)
		once_or_year('generics.xls')
	end
	def radio_meddrugs_update_xls(model, session)
		once_or_year('meddrugs-update.xls')
	end
	def radio_narcotics_csv(model, session)
		once_or_year('narcotics.csv')
	end
	def radio_narcotics_yaml(model, session)
		once_or_year('narcotics.yaml')
	end
	def radio_oddbdat(model, session)
		once_or_year('oddbdat')
	end
	def radio_oddb_yaml(model, session)
		once_or_year('oddb.yaml')
	end
	def radio_s31x(model, session)
		once_or_year('s31x')
	end
	def s31x(model, session)
		checkbox_with_filesize("s31x")
	end
	def xls_generics(model, session)
		checkbox_with_filesize('generics.xls')
	end
	def xls_meddrugs_update(model, session)
		checkbox_with_filesize('meddrugs-update.xls')
	end
	def yaml_doctors_export(model, session)
		checkbox_with_filesize("doctors.yaml")
	end
	def yaml_doctors_price(model, session)
		once('doctors.yaml')
	end
	def yaml_export(model, session)
		checkbox_with_filesize("oddb.yaml")
	end
	def yaml_fachinfo_export(model, session)
		checkbox_with_filesize("fachinfo.yaml")
	end
	def yaml_narcotics_export(model, session)
		checkbox_with_filesize('narcotics.yaml')
	end
	def yaml_patinfo_export(model, session)
		checkbox_with_filesize("patinfo.yaml")
	end
	def yaml_patinfo_price(model, session)
		once('patinfo.yaml')
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
class DownloadExport < View::ResultTemplate
	CONTENT = View::User::DownloadExportComposite 	
end
		end
	end
end
