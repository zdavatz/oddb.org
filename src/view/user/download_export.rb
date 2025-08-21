#!/usr/bin/env ruby

# ODDB::View::User::DownloadExport -- oddb.org -- 22.08.2012 -- yasaka@ywesee.com
# ODDB::View::User::DownloadExport -- oddb.org -- 20.01.2012 -- mhatakeyama@ywesee.com
# ODDB::View::User::DownloadExport -- oddb.org -- 20.09.2004 -- mhuggler@ywesee.com

require "view/publictemplate"
require "view/form"
require "view/datadeclaration"
require "view/user/export"
require "view/user/yamlexport"
require "htmlgrid/link"
require "htmlgrid/errormessage"

module ODDB
  module View
    module User
      class DownloadExportInnerComposite < HtmlGrid::Composite
        include View::User::Export
        COMPONENTS = {
          [2, 0] => "months_1",
          [3, 0] => "months_12",
          [9, 0] => "direct_link",

          [0, 1] => "export_datafiles",
          [0, 3] => :csv_doctors_export,
          [2, 3] => :csv_doctors_price,
          [5, 3] => :datadesc_doctors_csv,
          [7, 3] => :example_doctors_csv,
          [9, 3] => :directlink_doctors_csv,
          [0, 4] => :yaml_doctors_export,
          [2, 4] => :yaml_doctors_price,
          [5, 4] => :datadesc_doctors_yaml,
          [7, 4] => :example_doctors_yaml,
          [9, 4] => :directlink_doctors_yaml,
          [0, 5] => :download_index_therapeuticus,
          [2, 5] => :radio_index_therapeuticus_1,
          [3, 5] => :radio_index_therapeuticus_12,
          [5, 5] => :datadesc_index_therapeuticus,
          [7, 5] => :example_index_therapeuticus,
          [9, 5] => :directlink_index_therapeuticus,
          [0, 6] => :csv_migel_export,
          [2, 6] => :csv_migel_price,
          [5, 6] => :datadesc_migel_csv,
          [7, 6] => :example_migel_csv,
          [9, 6] => :directlink_migel_csv,
          [0, 7] => :csv_export,
          [2, 7] => :radio_oddb_csv_1,
          [3, 7] => :radio_oddb_csv_12,
          [5, 7] => :datadesc_oddb_csv,
          [7, 7] => :example_oddb_csv,
          [9, 7] => :directlink_oddb_csv,
          [0, 8] => :csv_export2,
          [2, 8] => :radio_oddb2_csv_1,
          [3, 8] => :radio_oddb2_csv_12,
          [5, 8] => :datadesc_oddb2_csv,
          [7, 8] => :example_oddb2_csv,
          [9, 8] => :directlink_oddb2_csv,
          [0, 9] => :yaml_export,
          [2, 9] => :radio_oddb_yaml_1,
          [3, 9] => :radio_oddb_yaml_12,
          [5, 9] => :datadesc_oddb_yaml,
          [7, 9] => :example_oddb_yaml,
          [9, 9] => :directlink_oddb_yaml,
          [0, 10] => :yaml_price_history_export,
          [2, 10] => :yaml_price_history_price_1,
          [3, 10] => :yaml_price_history_price_12,
          [5, 10] => :datadesc_price_history_yaml,
          [7, 10] => :example_price_history_yaml,
          [9, 10] => :directlink_price_history_yaml,
          [0, 11] => :csv_price_history_export,
          [2, 11] => :csv_price_history_price_1,
          [3, 11] => :csv_price_history_price_12,
          [5, 11] => :datadesc_price_history_csv,
          [7, 11] => :example_price_history_csv,
          [9, 11] => :directlink_price_history_csv,

          [0, 13] => "export_added_value",
          [0, 14] => :xls_generics,
          [2, 14] => :radio_generics_xls_1,
          [3, 14] => :radio_generics_xls_12,
          [5, 14] => :datadesc_generics_xls,
          [7, 14] => :example_generics_xls,
          [9, 14] => :directlink_generics_xls,
          [0, 15] => :xls_patents,
          [2, 15] => :radio_patents_xls,
          [5, 15] => :datadesc_patents_xls,
          [7, 15] => :example_patents_xls,
          [9, 15] => :directlink_patents_xls,
          [0, 16] => :xls_swissdrug_update,
          [2, 16] => :radio_swissdrug_update_xls_1,
          [3, 16] => :radio_swissdrug_update_xls_12,
          [5, 16] => :datadesc_swissdrug_update_xls,
          [7, 16] => :example_swissdrug_update_xls,
          [9, 16] => :directlink_swissdrug_update_xls,
          [0, 17] => :compression_label,
          [0, 18] => :compression
        }
        CSS_MAP = {
          [0, 0, 11] => "subheading",

          [0, 1, 11] => "list bg sum",
          [0, 2, 11] => "list",
          [0, 3, 11] => "list bg",
          [0, 4, 11] => "list",
          [0, 5, 11] => "list bg",
          [0, 6, 11] => "list",
          [0, 7, 11] => "list bg",
          [0, 8, 11] => "list",
          [0, 9, 11] => "list bg",
          [0, 10, 11] => "list",
          [0, 11, 11] => "list bg",
          [0, 12, 11] => "list",
          [0, 13, 11] => "list bg sum",
          [0, 14, 11] => "list",
          [0, 15, 11] => "list bg",
          [0, 16, 11] => "list",
          [0, 17, 11] => "list bg",
          [0, 18] => "list",
          [0, 19] => "list"

        }
        COLSPAN_MAP = {
          [5, 0] => 3,
          [6, 0] => 3,
          [9, 0] => 2,
          [0, 1, 13] => 13,
          [0, 13, 11] => 13
        }
        CSS_CLASS = "component"
        SYMBOL_MAP = {
          compression: HtmlGrid::Select
        }
        %w[
          doctors.csv doctors.yaml index_therapeuticus
          oddb.csv migel.csv oddb2.csv oddb.yaml
          price_history.yaml price_history.csv oddb.dat
          generics.xls patents.xls swissdrug_update.xls
        ].each do |file|
          name = :"directlink_#{file.tr(".", "_")}"
          define_method(name) do |model, session|
            link = HtmlGrid::Link.new(name, model, session, self)
            args = {"buy" => file}
            link.href = @lookandfeel._event_url(:data, args)
            link.label = false
            link.value = @lookandfeel.lookup(:direct_link)
            link
          end
        end
        def compression_label(model, session)
          HtmlGrid::LabelText.new(:compression, model, session, self)
        end

        def csv_export(model, session)
          checkbox_with_filesize("oddb.csv")
        end

        def csv_export2(model, session)
          checkbox_with_filesize("oddb2.csv")
        end

        def csv_doctors_export(model, session)
          checkbox_with_filesize("doctors.csv")
        end

        def csv_doctors_price(model, session)
          once("doctors.csv")
        end

        def csv_migel_export(model, session)
          checkbox_with_filesize("migel.csv")
        end

        def csv_migel_price(model, session)
          once("migel.csv")
        end

        def csv_narcotics_export(model, session)
          checkbox_with_filesize("narcotics.csv")
        end

        def csv_price_history_export(model, session)
          checkbox_with_filesize("price_history.csv")
        end

        def csv_price_history_price_1(model, session)
          radio_price("price_history.csv", 1)
        end

        def csv_price_history_price_12(model, session)
          radio_price("price_history.csv", 12)
        end

        def datadesc_doctors_csv(model, session)
          datadesc("doctors.csv")
        end

        def datadesc_doctors_yaml(model, session)
          datadesc("doctors.yaml")
        end

        def datadesc_epub(model, session)
          link = HtmlGrid::Link.new(:data_description, @model, @session, self)
          link.href = "http://www.openebook.org/specs.htm"
          link.css_class = "small"
          link
        end

        def datadesc_generics_xls(model, session)
          datadesc("generics.xls")
        end

        def datadesc_index_therapeuticus(model, session)
          datadesc("index_therapeuticus")
        end

        def datadesc_swissdrug_update_xls(model, session)
          datadesc("swissdrug-update.xls")
        end

        def datadesc_migel_csv(model, session)
          datadesc("migel.csv")
        end

        def datadesc_narcotics_csv(model, session)
          datadesc("narcotics.csv")
        end

        def datadesc_narcotics_yaml(model, session)
          datadesc("narcotics.yaml")
        end

        def datadesc_oddb_csv(model, session)
          datadesc("oddb.csv")
        end

        def datadesc_oddb2_csv(model, session)
          datadesc("oddb2.csv")
        end

        def datadesc_oddb_yaml(model, session)
          datadesc("oddb.yaml")
        end

        def datadesc_patents_xls(model, session)
          datadesc("patents.xls")
        end

        def datadesc_price_history_csv(model, session)
          datadesc("price_history.csv")
        end

        def datadesc_price_history_yaml(model, session)
          datadesc("price_history.yaml")
        end

        def example_doctors_csv(model, session)
          example("doctors.csv")
        end

        def example_doctors_yaml(model, session)
          example("doctors.yaml")
        end

        def example_generics_xls(model, session)
          example("generics.xls")
        end

        def example_index_therapeuticus(model, session)
          example("index_therapeuticus.tar.gz")
        end

        def example_swissdrug_update_xls(model, session)
          example("swissdrug-update.xls")
        end

        def example_migel_csv(model, session)
          example("migel.csv")
        end

        def example_narcotics_csv(model, session)
          example("narcotics.csv")
        end

        def example_narcotics_yaml(model, session)
          example("narcotics.yaml")
        end

        def example_oddb_csv(model, session)
          example("oddb.csv")
        end

        def example_oddb2_csv(model, session)
          example("oddb2.csv")
        end

        def example_oddb_yaml(model, session)
          example("oddb.yaml")
        end

        def example_oddb_dat(model, session)
          example("oddb.dat.zip")
        end

        def example_patents_xls(model, session)
          example("patents.xls")
        end

        def example_price_history_csv(model, session)
          example("price_history.csv")
        end

        def example_price_history_yaml(model, session)
          example("price_history.yaml")
        end

        def download_index_therapeuticus(model, session)
          checkbox_with_filesize("index_therapeuticus")
        end

        def oddb_with_migel_dat_export(model, session)
          checkbox_with_filesize("oddb_with_migel.dat")
        end

        def radio_oddb_csv_1(model, session)
          radio_price("oddb.csv", 1)
        end

        def radio_oddb_csv_12(model, session)
          radio_price("oddb.csv", 12)
        end

        def radio_oddb2_csv_1(model, session)
          radio_price("oddb2.csv", 1)
        end

        def radio_oddb2_csv_12(model, session)
          radio_price("oddb2.csv", 12)
        end

        def radio_generics_xls_1(model, session)
          radio_price("generics.xls", 1)
        end

        def radio_generics_xls_12(model, session)
          radio_price("generics.xls", 12)
        end

        def radio_index_therapeuticus_1(model, session)
          radio_price("index_therapeuticus", 1)
        end

        def radio_index_therapeuticus_12(model, session)
          radio_price("index_therapeuticus", 12)
        end

        def radio_swissdrug_update_xls_1(model, session)
          radio_price("swissdrug-update.xls", 1)
        end

        def radio_swissdrug_update_xls_12(model, session)
          radio_price("swissdrug-update.xls", 12)
        end

        def radio_narcotics_csv(model, session)
          once_or_year("narcotics.csv")
        end

        def radio_narcotics_yaml(model, session)
          once_or_year("narcotics.yaml")
        end

        def radio_oddb_yaml_1(model, session)
          radio_price("oddb.yaml", 1)
        end

        def radio_oddb_yaml_12(model, session)
          radio_price("oddb.yaml", 12)
        end

        def radio_patents_xls(model, session)
          once("patents.xls")
        end

        def xls_generics(model, session)
          checkbox_with_filesize("generics.xls")
        end

        def xls_patents(model, session)
          checkbox_with_filesize("patents.xls")
        end

        def xls_swissdrug_update(model, session)
          checkbox_with_filesize("swissdrug-update.xls")
        end

        def yaml_doctors_export(model, session)
          checkbox_with_filesize("doctors.yaml")
        end

        def yaml_doctors_price(model, session)
          once("doctors.yaml")
        end

        def yaml_export(model, session)
          checkbox_with_filesize("oddb.yaml")
        end

        def yaml_narcotics_export(model, session)
          checkbox_with_filesize("narcotics.yaml")
        end

        def yaml_price_history_export(model, session)
          checkbox_with_filesize("price_history.yaml")
        end

        def yaml_price_history_price_1(model, session)
          radio_price("price_history.yaml", 1)
        end

        def yaml_price_history_price_12(model, session)
          radio_price("price_history.yaml", 12)
        end
      end

      class DownloadExportComposite < Form
        include HtmlGrid::ErrorMessage
        include View::DataDeclaration
        COMPONENTS = {
          [0, 0, 0] => "download_export",
          [0, 0, 1] => "dash_separator",
          [0, 0, 2] => :data_declaration,
          [0, 1] => :download_export_descr,
          [0, 2] => DownloadExportInnerComposite,
          [0, 3] => :submit
        }
        CSS_CLASS = "composite"
        CSS_MAP = {
          [0, 0] => "th",
          [0, 1] => "list",
          [0, 3] => "list"
        }
        EVENT = :proceed_download
        SYMBOL_MAP = {
          yaml_link: HtmlGrid::Link
        }
        def download_export_descr(model, session)
          pages = {
            "de" => "Stammdaten",
            "en" => "MasterData",
            "fr" => "DonneesDeBase"
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
