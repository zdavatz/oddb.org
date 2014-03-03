#!/usr/bin/env ruby
# encoding: utf-8

require 'model/text'
require 'util/logfile'

module ODDB
  module FiParse
  class TextinfoPseudoFachinfo
    LANGUAGES = [:de, :fr]
    LOCALIZED_CHAPTER_EXPRESSION = {
      :de => {
        :composition          => /^Zusammensetzung|Wirkstoffe|Hilsstoffe/u, # 2
#        :indications          => /^Indikationen(\s+|\s*(\/|und)\s*)Anwendungsmöglichkeiten$/u, # 4
        :usage                => /^Dosierung\s*(\/|und)\s*Anwendung/u, # 5
        :contra_indications   => /^Kontraindikationen($|\s*\(\s*absolute\s+Kontraindikationen\s*\)$)/u, # 6
        :restrictions         => /^Warnhinweise\s+und\s+Vorsichtsmassnahmen($|\s*\/\s*(relative\s+Kontraindikationen|Warnhinweise\s*und\s*Vorsichtsmassnahmen)$)/u, # 7
        :interactions         => /^Interaktionen$/u, # 8
        :unwanted_effects     => /^Unerw.nschte Wirkungen/, # 11
        :effects              => /^Eigenschaften\s*\/\s*Wirkungen($|\s*\(\s*(ATC\-Code|Wirkungsmechanismus|Pharmakodyamik|Klinische\s+Wirksamkeit)\s*\)\s*$)/iu, # 13
        :other_advice         => /^Sonstige\s*Hinweise($|\s*\(\s*(Inkompatibilitäten|Beeinflussung\s*diagnostischer\s*Methoden|Haltbarkeit|Besondere\s*Lagerungshinweise|Hinweise\s+für\s+die\s+Handhabung)\s*\)$)/u, # 16
        :packages             => /^Packungen($|\s*\(\s*mit\s+Angabe\s+der\s+Abgabekategorie\s*\)$)/u, # 18
        :date                 => /^Stand\s+der\s+Information$/iu, # 20
        :fabrication          => /^Herstellerin/u,
        :distributor          => /^Vertriebsfirma/u,
        :date                 => /^Stand der Information/u,
      },
      :fr => {
        :composition         => /^Composition$/u, # 2
#        :indications         => /^Indications/u, # 4
        :usage               => /^Posologiei/u, # 5
        :contra_indications  => /^Contre\-indications/iu, # 6
        :restrictions        => /^Mises/u, # 7
        :interactions        => /^Interactions/u, # 8
        :unwanted_effects    => /^Effets/u, # 11
        :effects             => /^Propriétés/iu, # 13
        :other_advice        => /^Remarques/u, # 16
        :iksnrs              => /^Numéro\s+dautorisation$/u, # 17
        :packages            => /^Présentation/iu, # 18
        :registration_owner  => /^Titulaire\s+de\s+lautorisation$/u, # 19
        :date                => /^Mise à jour/iu, # 20
        :fabrication         => /^Fabricant$/u,
        :distributor         => /^Distributeur/u,
        :date                => /^Mise à jour de l’information/u,
      }
    }
    def to_textinfo(allChapters)
      fi = PseudoFachinfoDocument.new
      allChapters.each{ |name, chapter| eval "fi.#{name.to_s} = chapter"; }
      fi
    end
    def extract(docx_file)
      LogFile.debug("extract #{docx_file.path} #{File.exists?(docx_file)}")
      return false unless File.exists?(docx_file)
      doc = YDocx::Document.open(docx_file, {:format => :plain})
      xml_file = docx_file.path.sub('.docx', '.xml')
      doc.to_xml(xml_file)
      doc = Nokogiri::XML(open(xml_file))
      lang = nil
      doc.xpath("//chapters/chapter/heading").each {
        |heading|
          LANGUAGES.each {|try_lang| LOCALIZED_CHAPTER_EXPRESSION[try_lang].each {
                          |chapter, expression|
                          if heading.text.match(LOCALIZED_CHAPTER_EXPRESSION[try_lang][chapter])
                            lang = try_lang
                            break
                          end
          }
          break if lang
        }
        break if lang
      }
      LogFile.debug("lang #{lang.inspect}")
      return nil unless lang
      allChapters = {}
#      require 'pry'; binding.pry
      doc.xpath("//heading").each {
        |chapter|      
          LOCALIZED_CHAPTER_EXPRESSION[lang].each {
            |name, expression|
                                                 if name.match(/interaction/i)
                                                             #  require 'pry'; binding.pry
                                                              end
            if chapter.text.match(LOCALIZED_CHAPTER_EXPRESSION[lang][name])
              txtChapter = Text::Chapter.new
              txtChapter.heading = name.to_s.strip
              doc.xpath("//chapters/chapter[contains(heading, '#{chapter.text}')]/paragraph").each{
                |para|
                  inhalt=para.text
                  txtChapter.next_section.next_paragraph << inhalt
                  allChapters[name] = txtChapter
              }
            end
        }
      }
      info =  self.to_textinfo(allChapters)
      info.iksnrs = []
      info.packages.paragraphs.each{ |pack| m=pack.match(/\d{13}/); info.iksnrs << m[0] if m  } if info.packages
      info 
      end
    end
  private
  end
end
