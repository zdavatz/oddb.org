#!/usr/bin/env ruby
# encoding: utf-8

require 'model/text'
require 'util/logfile'

module ODDB
  module FiParse
  class TextinfoPseudoFachinfo
    attr_accessor :name, :lang
    LANGUAGES = [:de, :fr]
    LOCALIZED_CHAPTER_EXPRESSION = {
      :de => {
        :composition          => /^Zusammensetzung|Wirkstoffe|Hilsstoffe/u, # 2
        :indications          => /^Indikation(en)?\s*\/\s*Anwendungsm.glichkeit(en)?/,
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
        :indications         => /^Indications\s*\/\s*[pP]ossibilit.s\s*d.emploi/,
        :usage               => /^Posologie\/Mode d’emploi/u, # 5
        :contra_indications  => /^Contre\-indications/iu, # 6
        :restrictions        => /^Mises/u, # 7
        :interactions        => /^Interactions/u, # 8
        :unwanted_effects    => /^Effets/u, # 11
        :effects             => /^Propriétés/iu, # 13
        :other_advice        => /^Remarques/u, # 16
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
      xml_file = docx_file.path.sub('.docx', '.xml')
      cmd = "docx2xml #{docx_file.path} --format plain "
      res = system(cmd)
      cmd = "xmllint --format --output #{xml_file} #{xml_file}"
      res = system(cmd)
      lang = nil
      doc = Nokogiri::XML(open(xml_file))
      doc.xpath("//paragraph/bold/italic").each {
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
      return nil unless lang
      allChapters = {}
      ptr = nil
      chapterName = nil
      doc.xpath("//paragraph").each {
        |paragraph|
          short = paragraph.text.gsub("\n", "").strip
          if paragraph.xpath("//bold/italic") and paragraph.children.size > 1
            found = LOCALIZED_CHAPTER_EXPRESSION[lang].find_all{ |key, value| key if short.match(value) }
            if found.size == 1
              allChapters[chapterName] = ptr.chapter if ptr
              chapterName = found[0][0]
              ptr = OpenStruct.new
              ptr.chapter = Text::Chapter.new
              ptr.chapter.heading = short
            end
          end
          if ptr
            inhalt = paragraph.text.gsub("\n", "").strip
            if ptr.chapter and ptr.chapter.heading != inhalt
              if ptr.chapter.sections.size == 0
                ptr.chapter.next_section.next_paragraph << paragraph.text
              else
                ptr.chapter.sections.last.next_paragraph << paragraph.text
              end
            end
          end
      }
      allChapters[chapterName] = ptr.chapter if ptr.chapter
      info =  self.to_textinfo(allChapters)
      info.iksnrs = []
      info.packages.paragraphs.each{ |pack| m=pack.match(/\d{13}/); info.iksnrs << m[0] if m  } if info.packages
      info.name =  doc.xpath("//paragraph").first.text.gsub("\n",'').gsub(/\s+/,' ').gsub(' ®','®').strip
      info.lang = lang
      info
      end
    end
  private
  end
end
