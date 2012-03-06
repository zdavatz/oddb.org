#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::User::DownloadExport -- oddb.org -- 06.03.2012 -- yasaka@ywesee.com
# ODDB::View::User::DownloadExport -- oddb.org -- 20.01.2012 -- mhatakeyama@ywesee.com
# ODDB::View::User::DownloadExport -- oddb.org -- 20.09.2004 -- mhuggler@ywesee.com

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
		[2,0]		=>	'months_1',
		[3,0]		=>	'months_12',
		[9,0]		=>	'howto',
		[0,1]		=>	'export_datafiles',
		[0,2]		=>	:csv_analysis_export,
		[2,2]		=>	:csv_analysis_price,
		[5,2]		=>	:datadesc_analysis_csv,
		[7,2]		=>	:example_analysis_csv,
		[0,3]		=>	:csv_doctors_export,
		[2,3]		=>	:csv_doctors_price,
		[5,3]		=>	:datadesc_doctors_csv,
		[7,3]		=>	:example_doctors_csv,
		[0,4]		=>	:yaml_doctors_export,
		[2,4]		=>	:yaml_doctors_price,
		[5,4]		=>	:datadesc_doctors_yaml,
		[7,4]		=>	:example_doctors_yaml,
		[0,5]		=>	:yaml_fachinfo_export,
		[2,5]		=>	:radio_fachinfo_yaml_1,
		[3,5]		=>	:radio_fachinfo_yaml_12,
		[5,5]		=>	:datadesc_fachinfo_yaml,
		[7,5]		=>	:example_fachinfo_yaml,
		[0,6]		=>	:download_index_therapeuticus,
		[2,6]		=>	:radio_index_therapeuticus_1,
		[3,6]		=>	:radio_index_therapeuticus_12,
		[5,6]		=>	:datadesc_index_therapeuticus,
		[7,6]		=>	:example_index_therapeuticus,
		[0,7]		=>	:yaml_interactions_export,
		[2,7]		=>	:radio_interactions_yaml_1,
		[3,7]		=>	:radio_interactions_yaml_12,
		[5,7]		=>	:datadesc_interactions_yaml,
		[7,7]		=>	:example_interactions_yaml,
		[0,8]		=>	:csv_migel_export,
		[2,8]		=>	:csv_migel_price,
		[5,8]		=>	:datadesc_migel_csv,
		[7,8]		=>	:example_migel_csv,
#		[0,9]	=>	:csv_narcotics_export,
#		[2,9]	=>	:radio_narcotics_csv,
#		[6,9]	=>	:datadesc_narcotics_csv,
#		[7,9]	=>	:example_narcotics_csv,
#		[0,10]	=>	:yaml_narcotics_export,
#		[2,10]	=>	:radio_narcotics_yaml,
#		[6,10]	=>	:datadesc_narcotics_yaml,
#		[7,10]	=>	:example_narcotics_yaml,
		[0,9]	=>	:csv_export,
		[2,9]	=>	:radio_oddb_csv_1,
		[3,9]	=>	:radio_oddb_csv_12,
		[5,9]	=>	:datadesc_oddb_csv,
		[7,9]	=>	:example_oddb_csv,
		[0,10]	=>	:csv_export2,
		[2,10]	=>	:radio_oddb2_csv_1,
		[3,10]	=>	:radio_oddb2_csv_12,
		[5,10]	=>	:datadesc_oddb2_csv,
		[7,10]	=>	:example_oddb2_csv,
		[0,11]	=>	:yaml_export,
		[2,11]	=>	:radio_oddb_yaml_1,
		[3,11]	=>	:radio_oddb_yaml_12,
		[5,11]	=>	:datadesc_oddb_yaml,
		[7,11]	=>	:example_oddb_yaml,
		[0,12]	=>	:yaml_patinfo_export,
		[2,12]	=>	:yaml_patinfo_price,
		[5,12]	=>	:datadesc_patinfo_yaml,
		[7,12]	=>	:example_patinfo_yaml,
		[0,13]	=>	:yaml_price_history_export,
		[2,13]	=>	:yaml_price_history_price_1,
		[3,13]	=>	:yaml_price_history_price_12,
		[5,13]	=>	:datadesc_price_history_yaml,
		[7,13]	=>	:example_price_history_yaml,
		[0,14]	=>	:csv_price_history_export,
		[2,14]	=>	:csv_price_history_price_1,
		[3,14]	=>	:csv_price_history_price_12,
		[5,14]	=>	:datadesc_price_history_csv,
		[7,14]	=>	:example_price_history_csv,

		[0,16]	=>	'export_added_value',
		[0,17]	=>	:fachinfos_de_pdf,
		[2,17]	=>	:radio_fachinfos_de_pdf_1,
		[3,17]	=>	:radio_fachinfos_de_pdf_12,
		[7,17]	=>	:example_fachinfos_de_pdf,
		[0,18]	=>	:fachinfos_fr_pdf,
		[2,18]	=>	:radio_fachinfos_fr_pdf_1,
		[3,18]	=>	:radio_fachinfos_fr_pdf_12,
		[7,18]	=>	:example_fachinfos_fr_pdf,
		[0,19]	=>	:fachinfo_epub_firefox,
		[2,19]	=>	:price_fachinfo_firefox_epub,
		[5,19]	=>	:datadesc_epub,
		[7,19]	=>	:example_fachinfo_firefox_epub,
		[9,19]	=>	:howto_epub_firefox,
		[0,20]	=>	:fachinfo_htc,
		[2,20]	=>	:price_fachinfo_htc,
		[5,20]	=>	:datadesc_kindle,
		[7,20]	=>	:example_fachinfo_htc,
		[9,20]	=>	:howto_htc,
		[0,21]	=>	:fachinfo_kindle,
		[2,21]	=>	:price_fachinfo_kindle,
		[5,21]	=>	:datadesc_kindle,
		[7,21]	=>	:example_fachinfo_kindle,
		[9,21]	=>	:howto_kindle,
		[0,22]	=>	:fachinfo_epub_stanza,
		[2,22]	=>	:price_fachinfo_stanza_epub,
		[5,22]	=>	:datadesc_epub,
		[7,22]	=>	:example_fachinfo_stanza_epub,
		[9,22]	=>	:howto_epub_stanza,
		[0,23]	=>	:xls_generics,
		[2,23]	=>	:radio_generics_xls_1,
		[3,23]	=>	:radio_generics_xls_12,
		[5,23]	=>	:datadesc_generics_xls,
		[7,23]	=>	:example_generics_xls,
		[0,24]	=>	:xls_patents,
		[2,24]	=>	:radio_patents_xls,
		[5,24]	=>	:datadesc_patents_xls,
		[7,24]	=>	:example_patents_xls,
		[0,25]	=>	:xls_swissdrug_update,
		[2,25]	=>	:radio_swissdrug_update_xls_1,
		[3,25]	=>	:radio_swissdrug_update_xls_12,
		[5,25]	=>	:datadesc_swissdrug_update_xls,
		[7,25]	=>	:example_swissdrug_update_xls,

		[0,27]	=>	'export_compatibility',
		[0,28]	=>	:oddbdat_download,
		[2,28]	=>	:radio_oddbdat_1,
		[3,28]	=>	:radio_oddbdat_12,
		[5,28]	=>	:datadesc_oddbdat,
		[7,28]	=>	:example_oddbdat,
		[0,29]	=>	:s31x,
		[2,29]	=>	:radio_s31x_1,
		[3,29]	=>	:radio_s31x_12,
		[5,29]	=>	:datadesc_s31x,
		[0,30]	=>	:compression_label,
		[0,31]	=>	:compression,
	}
	CSS_MAP = {
		[0,0,10]			=>	'subheading',
		[0,1,10]			=>	'list bg sum',
		[0,2,10,32]	=>	'list',
		[0,3,10]			=>	'list bg',
		[0,5,10]			=>	'list bg',
		[0,7,10]			=>	'list bg',
		[0,9,10]		=>	'list bg',
		[0,11,10]		=>	'list bg',
		[0,13,10]		=>	'list bg',
		[0,15,10]		=>	'list bg sum',
		[0,18,10]		=>	'list bg',
		[0,20,10]		=>	'list bg',
		[0,22,10]		=>	'list bg',
		[0,24,10]		=>	'list bg',
		[0,27,10]		=>	'list bg sum',
	}
	COLSPAN_MAP = {
		[5,0]	=>	3,
		[6,0]	=>	2,
		[0,1]	=>	10,
		[0,16]=>	10,
		[0,27]=>	10,
		[0,30]=>	10,
		[0,31]=>	10,
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
	def csv_export2(model, session)
		checkbox_with_filesize("oddb2.csv")
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
	def csv_migel_price(model, session)
		once('migel.csv')
	end
	def csv_narcotics_export(model, session)
		checkbox_with_filesize('narcotics.csv')
	end
  def csv_price_history_export(model, session)
    checkbox_with_filesize("price_history.csv")
  end
  def csv_price_history_price_1(model, session)
    radio_price('price_history.csv', 1)
  end
  def csv_price_history_price_12(model, session)
    radio_price('price_history.csv', 12)
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
  def datadesc_epub(model, session)
    link = HtmlGrid::Link.new(:data_description, @model, @session, self)
    link.href = "http://www.openebook.org/specs.htm"
    link.css_class = 'small'
    link
  end
	def datadesc_fachinfo_yaml(model, session)
		datadesc('fachinfo.yaml')
	end
	def datadesc_generics_xls(model, session)
		datadesc('generics.xls')
	end
	def datadesc_index_therapeuticus(model, session)
		datadesc('index_therapeuticus')
	end
	def datadesc_interactions_yaml(model, session)
		datadesc('interactions.yaml')
	end
  def datadesc_kindle(model, session)
    link = HtmlGrid::Link.new(:data_description, @model, @session, self)
    link.href = "http://www.mobipocket.com/dev/article.asp?BaseFolder=prcgen&File=mobiformat.htm"
    link.css_class = 'small'
    link
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
	def datadesc_oddb2_csv(model, session)
		datadesc('oddb2.csv')
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
  def datadesc_price_history_csv(model, session)
    datadesc('price_history.csv')
  end
  def datadesc_price_history_yaml(model, session)
    datadesc('price_history.yaml')
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
  def example_fachinfo_firefox_epub(model, session)
    example('compendium_ch.oddb.org.firefox.epub')
  end
  def example_fachinfo_htc(model, session)
    example('compendium_ch.oddb.org.htc.prc')
  end
  def example_fachinfo_kindle(model, session)
    example('compendium_ch.oddb.org.kindle.mobi')
  end
  def example_fachinfo_stanza_epub(model, session)
    link = example('compendium_ch.oddb.org.stanza.epub')
    url = URI.parse link.href
    url.scheme = 'stanza'
    link.href = url.to_s
    link
  end
	def example_fachinfo_yaml(model, session)
		example('fachinfo.yaml')
	end
	def example_fachinfos_de_pdf(model, session)
		example('fachinfos_de.pdf')
	end
	def example_fachinfos_fr_pdf(model, session)
		example('fachinfos_fr.pdf')
	end
	def example_generics_xls(model, session)
		example('generics.xls')
	end
	def example_index_therapeuticus(model, session)
		example('index_therapeuticus.tar.gz')
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
	def example_oddb2_csv(model, session)
		example('oddb2.csv')
	end
	def example_oddb_yaml(model, session)
		example('oddb.yaml')
	end
	def example_oddbdat(model, session)
		example('oddbdat.tar.gz')
	end
	def example_patinfo_yaml(model, session)
		example('patinfo.yaml')
	end
	def example_patents_xls(model, session)
		example('patents.xls')
	end
  def example_price_history_csv(model, session)
    example('price_history.csv')
  end
  def example_price_history_yaml(model, session)
    example('price_history.yaml')
  end
  def fachinfo_epub_firefox(model, session)
    checkbox_with_filesize('compendium_ch.oddb.org.firefox.epub')
  end
  def fachinfo_htc(model, session)
    checkbox_with_filesize('compendium_ch.oddb.org.htc.prc')
  end
  def fachinfo_kindle(model, session)
    checkbox_with_filesize('compendium_ch.oddb.org.kindle.mobi')
  end
  def fachinfo_epub_stanza(model, session)
    checkbox_with_filesize('compendium_ch.oddb.org.stanza.epub')
  end
	def fachinfos_de_pdf(model, session)
		checkbox_with_filesize('fachinfos_de.pdf')
	end
	def fachinfos_fr_pdf(model, session)
		checkbox_with_filesize('fachinfos_fr.pdf')
	end
  def howto_epub_firefox(model, session)
    link = HtmlGrid::Link.new(:howto_epub_firefox, @model, @session, self)
    link.href = "http://www.ywesee.com/pmwiki.php/Main/EPUB"
    link.css_class = 'small'
    link
  end
  def howto_epub_stanza(model, session)
    link = HtmlGrid::Link.new(:howto_epub_stanza, @model, @session, self)
    link.href = "http://www.ywesee.com/pmwiki.php/Ywesee/Stanza"
    link.css_class = 'small'
    link
  end
  def howto_htc(model, session)
    link = HtmlGrid::Link.new(:howto_htc, @model, @session, self)
    link.href = "http://www.ywesee.com/pmwiki.php/Ywesee/HTC"
    link.css_class = 'small'
    link
  end
  def howto_kindle(model, session)
    link = HtmlGrid::Link.new(:howto_kindle, @model, @session, self)
    link.href = "http://www.ywesee.com/pmwiki.php/Ywesee/Kindle"
    link.css_class = 'small'
    link
  end
	def download_index_therapeuticus(model, session)
		checkbox_with_filesize('index_therapeuticus')
	end
	def oddbdat_download(model, session)
		checkbox_with_filesize("oddbdat")
	end
	def price_fachinfo_firefox_epub(model, session)
		once('compendium_ch.oddb.org.firefox.epub')
	end
	def price_fachinfo_htc(model, session)
		once('compendium_ch.oddb.org.htc.prc')
	end
	def price_fachinfo_kindle(model, session)
		once('compendium_ch.oddb.org.kindle.mobi')
	end
	def price_fachinfo_stanza_epub(model, session)
		once('compendium_ch.oddb.org.stanza.epub')
	end
	def radio_fachinfos_de_pdf_1(model, session)
		radio_price('fachinfos_de.pdf', 1)
	end
	def radio_fachinfos_de_pdf_12(model, session)
		radio_price('fachinfos_de.pdf', 12)
	end
	def radio_fachinfos_fr_pdf_1(model, session)
		radio_price('fachinfos_fr.pdf', 1)
	end
	def radio_fachinfos_fr_pdf_12(model, session)
		radio_price('fachinfos_fr.pdf', 12)
	end
	def radio_oddb_csv_1(model, session)
		radio_price('oddb.csv', 1)
	end
	def radio_oddb_csv_12(model, session)
		radio_price('oddb.csv', 12)
	end
	def radio_oddb2_csv_1(model, session)
		radio_price('oddb2.csv', 1)
	end
	def radio_oddb2_csv_12(model, session)
		radio_price('oddb2.csv', 12)
	end
	def radio_fachinfo_yaml_1(model, session)
		radio_price('fachinfo.yaml', 1)
	end
	def radio_fachinfo_yaml_12(model, session)
		radio_price('fachinfo.yaml', 12)
	end
	def radio_generics_xls_1(model, session)
		radio_price('generics.xls', 1)
	end
	def radio_generics_xls_12(model, session)
		radio_price('generics.xls', 12)
	end
	def radio_index_therapeuticus_1(model, session)
		radio_price('index_therapeuticus', 1)
	end
	def radio_index_therapeuticus_12(model, session)
		radio_price('index_therapeuticus', 12)
	end
	def radio_interactions_yaml_1(model, session)
		radio_price('interactions.yaml', 1)
	end
	def radio_interactions_yaml_12(model, session)
		radio_price('interactions.yaml', 12)
	end
	def radio_swissdrug_update_xls_1(model, session)
		radio_price('swissdrug-update.xls', 1)
	end
	def radio_swissdrug_update_xls_12(model, session)
		radio_price('swissdrug-update.xls', 12)
	end
	def radio_narcotics_csv(model, session)
		once_or_year('narcotics.csv')
	end
	def radio_narcotics_yaml(model, session)
		once_or_year('narcotics.yaml')
	end
	def radio_oddbdat_1(model, session)
		radio_price('oddbdat', 1)
	end
	def radio_oddbdat_12(model, session)
		radio_price('oddbdat', 12)
	end
	def radio_oddb_yaml_1(model, session)
		radio_price('oddb.yaml', 1)
	end
	def radio_oddb_yaml_12(model, session)
		radio_price('oddb.yaml', 12)
	end
	def radio_patents_xls(model, session)
		once('patents.xls')
	end
	def radio_s31x_1(model, session)
		radio_price('s31x', 1)
	end
	def radio_s31x_12(model, session)
		radio_price('s31x', 12)
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
  def yaml_price_history_export(model, session)
    checkbox_with_filesize("price_history.yaml")
  end
  def yaml_price_history_price_1(model, session)
    radio_price('price_history.yaml', 1)
  end
  def yaml_price_history_price_12(model, session)
    radio_price('price_history.yaml', 12)
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
