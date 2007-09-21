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
		[0,2]		=>	:csv_analysis_export,
		[3,2]		=>	:csv_analysis_price,
		[6,2]		=>	:datadesc_analysis_csv,
		[7,2]		=>	:example_analysis_csv,
		[0,3]		=>	:csv_doctors_export,
		[3,3]		=>	:csv_doctors_price,
		[6,3]		=>	:datadesc_doctors_csv,
		[7,3]		=>	:example_doctors_csv,
		[0,4]		=>	:yaml_doctors_export,
		[3,4]		=>	:yaml_doctors_price,
		[6,4]		=>	:datadesc_doctors_yaml,
		[7,4]		=>	:example_doctors_yaml,
		[0,5]		=>	:yaml_fachinfo_export,
		[2,5]		=>	:radio_fachinfo_yaml,
		[6,5]		=>	:datadesc_fachinfo_yaml,
		[7,5]		=>	:example_fachinfo_yaml,
		[0,6]		=>	:yaml_interactions_export,
		[2,6]		=>	:radio_interactions_yaml,
		[6,6]		=>	:datadesc_interactions_yaml,
		[7,6]		=>	:example_interactions_yaml,
		[0,7]		=>	:csv_migel_export,
		[3,7]		=>	:csv_migel_price,
		[6,7]		=>	:datadesc_migel_csv,
		[7,7]		=>	:example_migel_csv,
		[0,8]		=>	:csv_narcotics_export,
		[2,8]		=>	:radio_narcotics_csv,
		[6,8]		=>	:datadesc_narcotics_csv,
		[7,8]		=>	:example_narcotics_csv,
		[0,9]		=>	:yaml_narcotics_export,
		[2,9]		=>	:radio_narcotics_yaml,
		[6,9]		=>	:datadesc_narcotics_yaml,
		[7,9]		=>	:example_narcotics_yaml,
		[0,10]	=>	:csv_export,
		[2,10]	=>	:radio_oddb_csv,
		[6,10]	=>	:datadesc_oddb_csv,
		[7,10]	=>	:example_oddb_csv,
		[0,11]	=>	:yaml_export,
		[2,11]	=>	:radio_oddb_yaml,
		[6,11]	=>	:datadesc_oddb_yaml,
		[7,11]	=>	:example_oddb_yaml,
		[0,12]	=>	:yaml_patinfo_export,
		[3,12]	=>	:yaml_patinfo_price,
		[6,12]	=>	:datadesc_patinfo_yaml,
		[7,12]	=>	:example_patinfo_yaml,

		[0,14]	=>	'export_added_value',
		[0,15]	=>	:xls_generics,
		[2,15]	=>	:radio_generics_xls,
		[6,15]	=>	:datadesc_generics_xls,
		[7,15]	=>	:example_generics_xls,
		[0,16]	=>	:xls_patents,
		[3,16]	=>	:radio_patents_xls,
		[6,16]	=>	:datadesc_patents_xls,
		[7,16]	=>	:example_patents_xls,
		[0,17]	=>	:xls_swissdrug_update,
		[2,17]	=>	:radio_swissdrug_update_xls,
		[6,17]	=>	:datadesc_swissdrug_update_xls,
		[7,17]	=>	:example_swissdrug_update_xls,

		[0,19]	=>	'export_compatibility',
		[0,20]	=>	:oddbdat_download,
		[2,20]	=>	:radio_oddbdat,
		[6,20]	=>	:datadesc_oddbdat,
		[0,21]	=>	:s31x,
		[2,21]	=>	:radio_s31x,
		[6,21]	=>	:datadesc_s31x,
		[0,22]	=>	:compression_label,
		[0,23]	=>	:compression,
	}
	CSS_MAP = {
		[0,0,8]			=>	'subheading',
		[0,1,8]			=>	'list bg sum',
		[0,2,8,21]	=>	'list',
		[0,3,8]			=>	'list bg',
		[0,5,8]			=>	'list bg',
		[0,7,8]			=>	'list bg',
		[0,9,8]			=>	'list bg',
		[0,11,8]		=>	'list bg',
		[0,14,8]		=>	'list bg sum',
		[0,16,8]		=>	'list bg',
		[0,19,8]		=>	'list bg sum',
	}
	COLSPAN_MAP = {
		[5,0]	=>	2,
		[0,1]	=>	8,
		[0,14]=>	8,
		[0,19]=>	8,
		[0,22]=>	8,
		[0,23]=>	8,
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
	def csv_analysis_export(model, session)
		checkbox_with_filesize("analysis.csv")
	end
	def csv_analysis_price(model, session)
		once('analysis.csv')
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
	def datadesc_analysis_csv(model, session)
		datadesc('analysis.csv')
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
	def datadesc_interactions_yaml(model, session)
		datadesc('interactions.yaml')
	end
	def datadesc_swissdrug_update_xls(model, session)
		datadesc('swissdrug-update.xls')
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
	def datadesc_patents_xls(model, session)
		datadesc('patents.xls')
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
	def example_analysis_csv(model, session)
		example('analysis.csv')
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
	def example_interactions_yaml(model, session)
		example('interactions.yaml')
	end
	def example_swissdrug_update_xls(model, session)
		example('swissdrug-update.xls')
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
	def example_patents_xls(model, session)
		example('patents.xls')
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
	def radio_interactions_yaml(model, session)
		once_or_year('interactions.yaml')
	end
	def radio_swissdrug_update_xls(model, session)
		once_or_year('swissdrug-update.xls')
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
	def radio_patents_xls(model, session)
		once('patents.xls')
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
	def xls_patents(model, session)
		checkbox_with_filesize('patents.xls')
	end
	def xls_swissdrug_update(model, session)
		checkbox_with_filesize('swissdrug-update.xls')
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
	def yaml_interactions_export(model, session)
		checkbox_with_filesize("interactions.yaml")
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
		[0,0,0]		=>	'download_export',
		[0,0,1]	=>	'dash_separator',
		[0,0,2]	=>	:data_declaration,
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
