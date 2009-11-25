#!/usr/bin/env ruby
# FiParse::MiniFi -- oddb.org -- 23.04.2007 -- hwyss@ywesee.com

require 'rpdf2txt/parser'
require 'model/text'
require 'facet/integer/even'

module ODDB
  module FiParse
    module MiniFi
      class Handler  < Rpdf2txt::ColumnHandler
        attr_reader :minifis
        SECTION_HEADINGS =  %r{^(Indi[ck]ation
                                |Dosierung:?$|Posologie:?$
                                |Wirksamkeit|Efficacit.
                                |Unerw.nschte Wirkungen|Effets ind.sirables
                                |Pharmakokinetik|Pharmacocin.tique
                                |Interaktionen|Interactions
                                |Kontraindikationen|Contre-?indications
                                )
                              }uix
        HYPHEN = /-$/u
        NAME_PTRN = %r{
                    (?:Wirk?s?toffe?s:
                    [^\(]*\((?<name>[^,\s®\(]+))(®|\(TM\))
                    |
                    (?:(?:(?:(?:Impf|Wirk?)stoffe?s?)
                         |(?:Zulassung\s*des\s*ersten[^:]+)):
                    (?:\s+Informationen\s+zu)?
                    \s*(?<name>[^,\s®\(]+(,?\s*ad\s*us\.\s*vet\.)?))
                    |
                    ^(?:Zulassung\s*von\s*[,"„«]{1,2})(?<name>[^,"“»]+)
                    }ux
        def initialize
          super('', '')
          @minifis = []
          start_page
        end
        def clean!
          if(@chapter.respond_to?(:clean!))
            @chapter.clean!
            @chapter = nil
          end
        end
        def create_document
          clean!
          @chapter = Text::Chapter.new
        end
        def new_font(font)
          set_bold(font)
          @font = font
        end
        def send_column
          super
          set_bold(@font)
        end
        def send_line_break
          line = (@lines.last || []).join.strip
          case line
          when %r{^Zulassung eines( pflanzlichen)? Arzneimittels mit( einem)? neue[mn] Wirk?stoff}iu,
            %r{^Neuzulassung eines Medikamente?s mit( einem)? neue[mn] Wirkstoff}iu,
            %r{^(Erst)?Zulassung eines neuen (Impf|Wirk)stoffe?s}iu,
            %r{^Zulassung des ersten}iu, %r{^Zulassung von [,"„«]{1,2}}iu
            if(@reached_news)
              @current = {}
              @minifis.push(@current)
              @current[:de] = create_document
            end
          when %r{^Autorisation d.un (phyto)?m.dicament contenant un nouveau}iu,
            %r{^Autorisation d.livr.es? pour (un|de) nouveaux? principes? actifs?}iu,
            %r{^Autorisation d.livr.es? pour (un|de) nouveaux? produits? de vaccins?}iu,
            %r{^Autorisation d.un nouveau (principe actif|vaccin)}iu,
            %r{^Autorisation du premier}iu, %r{^Autorisation de [,"„«]{1,2}}iu,
            %r{^Autorisation d.(livr.e pour )?un m.dicament avec un nouveau}iu
            @current[:fr] = create_document if @current
          when %r{Arzneimittel Nachrichten( / M.dicaments)?$}u,
            %r{^M.dicaments$}u
            @reached_news = true
            #ignore
          when %r{Arzneimittel\s*Statistik\s*/\s*Miscellan.es}u,
            %r{Regulatory News / R.glementation}u, %r{Regulatory News}u,
            %r{Infosplitter(\s*/\s*En\s*vrac)?}u, 
            %r{Richtigstellung}u, %r{Berichtigung}u,
            %r{Medizinprodukte(\s*/\s*Dispositifs m.dicaux)?}u,
            %r{Zulassung eines Tierarzneimittels}u,
            %r{Entlassung aus der Heilmittelkontrolle}u, 
            %r{Mitteilung an die Fachpersonen}u,
            %r{Zum Vertrieb freigegebene Chargen}u,
            %r{^Heparinum natricum ad usum externum}u # dtstcpw for 02/2006
            clean!
            @current = nil
          end
          super
        end
        def column_count
          2
        end
        def send_page
          if(@chapter)
            max_idx = @lines.collect { |line| 
              line.size }.push(1).max - 1
            @lines.each { |line|
              line[max_idx] ||= nil
            }
            target, section = nil
            if(@chapter.empty?)
              target = @chapter.heading 
              section = @chapter.next_section
            else
              section = @chapter.sections.last 
              target = section.paragraphs.last || section.next_paragraph
            end
            previous_was_hyphenated = false
            row = 0
            @lines.transpose.each_with_index { |column, col|
              previous_width = nil
              column.each_with_index { |line, row|
                if(line.is_a?(String))
                  line.gsub!(/\s+/, ' ')
                  line.strip!
                  case line
                  when ''
                    if(!target.empty? && !previous_was_hyphenated)
                      if(section.subheading.empty?)
                        section = @chapter.next_section
                      end
                      target = section.next_paragraph
                    end
                  when %r{Arzneimittel Nachrichten( / M.dicaments)?}u,
                    %r{^\s*/?\s*M.dicaments$}u, %r{^Actualit.s$}u,
                    # misplaced header in 05/2003:416
                    %r{^Arzneimittel Statistik$}u
                    #ignore
                  when %r{Swissmedic\s*Journal\s+[_\d]+}u, %r{^\d+$}u
                    target = section.next_paragraph
                  else
                    bold = @bold_lines[col][row]
                    title = [@chapter.heading, 
                      section.subheading].any? { |ttl| ttl.equal?(target) }
                    if(bold && !previous_was_hyphenated \
                       && (!title || (target == @chapter.heading \
                                      && SECTION_HEADINGS.match(line))))
                      section = @chapter.next_section
                      target = section.subheading
                    elsif(!bold && title)
                      target << "\n"
                      target = section.next_paragraph
                    elsif(/^[o·-]\s/u.match(line))
                      target = section.next_paragraph
                    elsif(!title && previous_width \
                          && previous_width < (line.length * 0.65))
                      target = section.next_paragraph
                    end
                    previous_width = line.length
                    if(line.match(HYPHEN))
                      previous_was_hyphenated = true
                      if(!((nxt = column.at(row.next)) \
                           && /^[A-Z]/u.match(nxt.to_s)))
                        target << line.gsub(HYPHEN, '')
                      else
                        target << line
                      end
                    else
                      previous_was_hyphenated = false
                      target << line << ' '
                    end
                    # Ensure all bold text at the start of a page counts
                    # towards the heading - this solution works post 12/2005
                    if bold && target == @chapter.heading \
                      && (other = @lines[row][1])
                      target << other
                      other.replace ''
                    end
                  end
                elsif(@chapter.heading == target && NAME_PTRN.match(target))
                  target = section.next_paragraph
                end
              }
            }
            if(match = NAME_PTRN.match(@chapter.heading))
              @current[:name] = match['name']
            end
          end
          start_page
          send_line_break
        end
        def set_bold(font)
          line = @columns[@current_column].to_s
          bold = @bold_lines[@current_column]
          prev = (@lines[-2] || [])[@current_column]
          if(font && font.bold? \
             && (bold[@lines.size - 1] || line.empty? \
                 || SECTION_HEADINGS.match(line)))
            bold[@lines.size - 1] = true
          elsif(!(font && font.symbol?))
            bold[@lines.size - 1] = false
          end
        end
        def start_page
          @bold_lines = Hash.new { |me, key| me[key] = Hash.new }
          @lines.clear
        end
      end
      def MiniFi.extract(filename)
        pdf = Rpdf2txt::Parser.new(File.read(filename), 'UTF-8')
        handler = Handler.new
        pdf.extract_text(handler)
        handler.minifis.reject { |minifi|
          minifi[:name].nil? || /ad\s*us\.\s*vet/u.match(minifi[:de].heading)
        }
      end
    end
  end
end
