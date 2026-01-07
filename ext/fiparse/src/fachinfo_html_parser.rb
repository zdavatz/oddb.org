#!/usr/bin/env ruby

require "util/logfile"
require "model/fachinfo"
require "textinfo_html_parser"

module ODDB
  module FiParse
    class FachinfoHtmlParser < TextinfoHtmlParser
      attr_reader :amzv, :name, :composition, :galenic_form, :indications, :effects, :indications,
        :usage, :kinetic, :restrictions, :unwanted_effects, :interactions,
        :overdose, :other_advice, :iksnrs, :date, :pregnancy, :driving_ability,
        :contra_indications, :packages
      @@section_to_code = {
       '2' => 7000,
       '3' => 7050,
       '4' => 7100,
       '5' => 7150,
       '6' => 7200,
       '7' => 7250,
       '8' => 7300,
       '9' => 7350,
       '10'=> 7400,
       '11'=> 7450,
       '12'=> 7500,
       '13'=> 7550,
       '14'=> 7600,
       '15'=> 7650,
       '16'=> 7700,
       '17'=> 7750,
       '18'=> 7850,
       '19'=> 7860,
       '20'=> 8000,
        }
      def identify_chapter(code, chapter)
        case code
        when "6900"
          @amzv = chapter
        when "6950"
          @name = chapter
        when "3300", "7000"
          @composition = chapter
        when "7050"
          @galenic_form = chapter
        when "4000", "7100"
          @indications = chapter
        when "7200"
          @contra_indications = chapter
        when "4400", "7250"
          @restrictions = chapter
        when "3500", "7550"
          @effects = chapter
        when "4200", "7150"
          @usage = chapter
        when "3700", "7600"
          @kinetic = chapter
        when "4700", "7450"
          @unwanted_effects = chapter
        when "4800", "7300"
          @interactions = chapter
        when "7350"
          @pregnancy = chapter
        when "7400"
          @driving_ability = chapter
        when "5000", "7500"
          @overdose = chapter
        when "5200", "7700"
          @other_advice = chapter
        when "5998", "7750"
          @iksnrs = chapter
        when "6100", "8000"
          @date = chapter
        when "7650"
          @preclinic = chapter
        when "7850"
          @registration_owner = chapter
        when "5610", "7860"
          @fabrication = chapter
        when "7870"
          @delivery = chapter
        when "5595"
          @distribution = chapter
        when "7800", "9100"
          @packages = chapter
        when nil # special chapers without heading
          @galenic_form ||= chapter
        when "9200", "8500", "8100"
          # skip "Beschreibung" and unexpected 'AMZV'
        else
          msg = "Unknown chapter-code #{code}, while parsing #{@name} from #{chapter.to_s}"
          ODDB::LogFile.debug msg
        end
      end

      def to_textinfo
        fi = if @amzv or (@format == :swissmedicinfo)
          fi = FachinfoDocument2001.new
          fi.amzv = @amzv
          fi.contra_indications = @contra_indications
          fi.pregnancy = @pregnancy
          fi.registration_owner = @registration_owner
          fi.driving_ability = @driving_ability
          fi.preclinic = @preclinic
          if m = /(Code ATC|ATC[ -]Code)\s*[\b:\\n]*\s*([A-Z][0-9 A-Z]{0,9})/m.match(@effects.to_s)
           fi.atc_code = m[2].gsub("\s", "")
          end
          fi
        else
          fi = FachinfoDocument.new
          fi
        end
        fi.name = @name
        fi.galenic_form = @galenic_form
        fi.effects = @effects
        fi.kinetic = @kinetic
        fi.indications = @indications
        fi.usage = @usage
        fi.restrictions = @restrictions
        fi.unwanted_effects = @unwanted_effects
        fi.interactions = @interactions
        fi.overdose = @overdose
        fi.other_advice = @other_advice
        fi.composition = @composition
        fi.packages = @packages
        fi.reference = @reference
        fi.delivery = @delivery
        fi.distribution = @distribution
        fi.fabrication = @fabrication
        fi.iksnrs = @iksnrs
        fi.date = @date
        fi
      end

      private

      def detect_chapter(elem)
        # TODO
        #   Update chapter detection if swissmedic repairs FI/PI format.
        #
        #   Currently, id attribute 'section*' is not fixed number.
        #   And Section order is also not fixed :(
        text = nil
        if elem.at("p") and elem.at("div")
          if elem.at("p") and elem.at("div")
            text = elem.at("div").inner_text
            text += "\n" + elem.at("p").inner_text
          end
        else
          unless /^section[0-9]*$/i.match?(elem.attributes["id"]&.value.to_s)
            return [nil, nil]
          end
          text = text(elem).sub(/^\s/, "")
        end
        code =
          case text
          when /^Zusammensetzung(en)?|^Composition[s]?/ then "7000"
          when /^Darreichungsform und Wirkstoffmenge pro Einheit|^Galenische\s*Form(en)?\s*und\s*Wirkstoffmenge[n]?\s*pro\s*Einheit|^Forme pharmaceutique et quantité de principe actif par unité/ then "7050"
          when /^Indikation(en)?\s*\/\s*Anwendungsm.glichkeit(en)?|^Indications\s*\/\s*[pP]ossibilit.s\s*d.emploi/ then "7100"
          when /^Dosierung\s*\/\s*Anwendung|^Posologie\s*\/\s*[mM]ode\s*d.emploi/ then "7150"
          when /^Kontraindikation(en)?|^Contre\s*-\s*[iI]ndication(s)?/ then "7200"
          when /^Warnhinweise\s*und\s*[vV]orsichtsmassnahm(en)?|^Mises\s*en\s*garde\s*et\s*pr.cautions/ then "7250"
          when /^Interaktion(en)\s*$|^Interaction(s)\s*$/ then "7300"
          when /^Schwangerschaft\s*[,\/]?\s*Stillzeit|^Grossesse\s*[,\/]?\s*[aA]llaitement/ then "7350"
          when /^Wirkung(en|)\s*auf\s*die\sFahrt.chtigkeit\s*und\s*auf\s*das\s*Bedienen\s*von\sMaschinen|^Effet\s*sur\s*l.aptitude\s*.\s*la\s*conduite\s*et\s*/ then "7400"
          when /^Unerwünschte\s*Wirkung(en)?|^Effets\s*ind.sirables/ then "7450"
          when /^Überdosierung|^Surdosage/ then "7500"
          when /^Eigenschaft(en)?\s*\/\s*Wirkung(en)?|^Propri.t.s\s*\/\s*[eE]ffets/ then "7550"
          when /^Pharmakokinetik|^Pharmacocin.tique/ then "7600"
          when /^Pr.klinische\s*Daten|Donn.es\s*pr.cliniques/ then "7650"
          when /^Sonstige\s*Hinweise|^Remarques\s*particuli.res/ then "7700"
          when /^Zulassungsnummer[n]?|^Num.ro\s*d.autorisation/ then "7750"
          when /^Packungen|^Pr.sentation[s]?/ then "7800"
          when /^Zulassungsinhaberin(en)?|^Titulaire\s*de\s*l.autorisation/ then "7850"
          when /^Herstellerin(en)?|^Fabricant/ then "7860"
          when /^Stand\s*der\s*Information|^Mise\s*.\s*jour\s*de\s*l.information/ then "8000"
        end
        if code.nil? && elem.respond_to?(:attributes) && elem.attributes && elem.attributes["id"]
            section = elem.attributes["id"].value
            m = elem.attributes["id"]&.value.match(/section(\d+)/i)
            if m && m[1].to_i != 1
              code = @@section_to_code[m[1]].to_s
              code = m[1] if  m[1].to_i > 1000
              msg = "Setting code #{code} for #{elem.attributes["id"].value} #{@name} #{lang} #{File.basename(File.dirname(@image_folder||'dummy'))} from #{text}"
              ODDB::LogFile.debug msg
            end
        end
        [code, text]
      end
    end
  end
end
