#!/usr/bin/env ruby

# View::Doctors::CenteredSearchForm -- oddb -- 17.09.2004 -- jlang@ywesee.com

require "view/centeredsearchform"
require	"view/language_chooser"

module ODDB
  module View
    module Doctors
      class CenteredSearchComposite < View::CenteredSearchComposite
        COMPONENTS = {
          [0, 0]	=>	:language_chooser,
          [0, 1]	=>	View::CenteredSearchForm,
          [0, 2]	=>	"doctors_search_explain",
          [0, 3]	=>	View::CenteredNavigation,
          [0, 4, 0]	=>	"download_doctors0",
          [0, 4, 1]	=>	:download_doctors,
          [0, 4, 2]	=>	"download_doctors2",
          [0, 5, 0]	=>	:doctor_count,
          [0, 5, 1]	=>	"doctor_count_text",
          [0, 5, 2]	=>	:refdata_registration,
          [0, 5, 3]	=>	"comma_separator",
          [0, 5, 6]	=>	"database_last_updated_txt",
          [0, 5, 7]	=>	:database_last_updated,
          [0, 6]	=>	:legal_note,
          [0, 7]	=>	:paypal
        }
        CSS_MAP = {
          [0, 0, 1, 8]	=>	"list center"
        }
        COMPONENT_CSS_MAP = {}
        # Die Abfrageseite der Partner-refdatabase, in der Sprache des
        # Besuchers. Refdata hat kein englisches Angebot, englisch bekommt
        # deshalb die deutsche Seite.
        REFDATA_URLS = {
          "fr" => "https://www.refdata.ch/fr/partenaires/requete/base-de-donnees-des-partenaires-gln"
        }
        REFDATA_URL_DEFAULT = "https://www.refdata.ch/de/partner/abfrage/partner-refdatabase-gln"

        def doctor_count(model, session)
          @session.doctor_count.to_s << "&nbsp;"
        end

        # Die Zahl ist nicht "Aerzte in der Schweiz": Refdata vergibt eine
        # GLN an jeden mit anerkanntem Diplom, und wir fuehren seit
        # 25.11.2026 genau die mit STATUS=A (113431 am 25.11.2026, davon
        # 4059 Altbestaende ohne GLN). Die FMH zaehlt 44612 berufstaetige.
        # Deshalb sagt die Beschriftung, was gezaehlt wird, und verlinkt
        # dorthin. target setzt externallinks.js sonst selbst; hier steht es
        # ausdruecklich, damit es nicht an einem Skript haengt.
        def refdata_registration(model, session)
          link = HtmlGrid::Link.new(:refdata_registration, model, session, self)
          link.href = REFDATA_URLS[@session.language.to_s] || REFDATA_URL_DEFAULT
          link.set_attribute("class", "list")
          link.set_attribute("target", "_blank")
          link.set_attribute("rel", "noopener noreferrer")
          link
        end

        def download_doctors(model, session)
          link = HtmlGrid::Link.new(:download_doctors1, model, session, self)
          link.href = @lookandfeel._event_url(:download_export)
          link
        end
      end

      class GoogleAdSenseComposite < View::GoogleAdSenseComposite
        CONTENT = CenteredSearchComposite
        GOOGLE_CHANNEL = "1634362463"
      end
    end
  end
end
