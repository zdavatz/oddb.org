#!/usr/bin/env ruby

# ODDB::View::Drugs::ResultLimit -- oddb -- 27.07.2012 -- yasaka@ywesee.com
# ODDB::View::Drugs::ResultLimit -- oddb -- 26.07.2005 -- hwyss@ywesee.com

require "view/resulttemplate"
require "view/limit"
require "view/drugs/result"
require "view/additional_information"
require "view/dataformat"
require "view/welcomehead"

module ODDB
  module View
    module Drugs
      class ResultLimitList < HtmlGrid::List
        include DataFormat
        include View::AdditionalInformation

        COMPONENTS = {
          [0, 0] => :minifi,
          [1, 0]	=> :fachinfo,
          [2, 0]	=>	:patinfo,
          [3, 0]	=>	:narcotic,
          [4, 0]	=>	:name_base,
          [5, 0]	=>	:galenic_form,
          [6, 0]	=>	:comparable_size,
          [7, 0]	=>	:price_exfactory,
          [8, 0]	=>	:price_public,
          [9, 0] =>	:ikscat,
          [10, 0] =>	:feedback,
          [11, 0] => :google_search,
          [12, 0] =>	:notify
        }
        DEFAULT_CLASS = HtmlGrid::Value
        CSS_CLASS = "composite"
        SORT_HEADER = false
        # Je Spalte ausgeschrieben statt in Spannen, damit jede ihre
        # col-<schluessel>-Klasse tragen kann. Diese Liste baut ihre Spalten
        # fest auf und geht nicht durch reorganize_components, bekam die
        # Klassen also nirgends her - auf dem Telefon blieb ausgerechnet die
        # Seite mit der Abfragebeschraenkung eine breite Tabelle. Die
        # Grundklassen sind unveraendert, am Desktop aendert sich nichts.
        CSS_MAP = {
          [0, 0] => "list col-minifi",
          [1, 0] => "list col-fachinfo",
          [2, 0] => "list col-patinfo",
          [3, 0] => "list col-narcotic",
          [4, 0] => "list big col-name_base",
          [5, 0] => "list col-galenic_form",
          [6, 0] => "list right col-comparable_size",
          [7, 0] => "list right col-price_exfactory",
          [8, 0] => "list right col-price_public",
          [9, 0] => "list right col-ikscat",
          [10, 0] => "list right col-feedback",
          [11, 0] => "list right col-google_search",
          [12, 0] => "list right col-notify"
        }
        CSS_HEAD_MAP = {
          [0, 0] => "th col-minifi",
          [1, 0] => "th col-fachinfo",
          [2, 0] => "th col-patinfo",
          [3, 0] => "th col-narcotic",
          [4, 0] => "th col-name_base",
          [5, 0] => "th col-galenic_form",
          [6, 0] => "th right col-comparable_size",
          [7, 0] => "th right col-price_exfactory",
          [8, 0] => "th right col-price_public",
          [9, 0] => "th right col-ikscat",
          [10, 0] => "th right col-feedback",
          [11, 0] => "th right col-google_search",
          [12, 0] => "th right col-notify"
        }
        def compose_empty_list(offset)
          count = @session.state.package_count.to_i
          if count > 0
            @grid.add(@lookandfeel.lookup(:query_limit_empty,
              @session.state.package_count,
              @session.class.const_get(:QUERY_LIMIT)), *offset)
            @grid.add_attribute("class", "list", *offset)
            @grid.set_colspan(*offset)
          else
            super
          end
        end

        def fachinfo(model, session)
          super(model, session, "square important infos")
        end

        def name_base(model, session)
          model.name_base
        end

        def most_precise_dose(model, session = @session)
          model.pretty_dose || if model.active_agents.size == 1
                                 model.dose
                               end
        end
      end

      class ResultLimitComposite < HtmlGrid::Composite
        COMPONENTS = {
          [0, 0]	=> SearchForm,
          [0, 1] => ResultLimitList,
          [0, 2]	=> View::LimitComposite
        }
        LEGACY_INTERFACE = false
        CSS_MAP = {
          [0, 0] => "right"
        }
      end

      class ResultLimit < ResultTemplate
        HEAD = View::WelcomeHead
        CONTENT = ResultLimitComposite
      end
    end
  end
end
