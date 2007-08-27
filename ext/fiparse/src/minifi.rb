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
                              }ix
        HYPHEN = /-$/
        NAME_PTRN = /
                    (?:Wirk?toffe?s:
                    [^\(]*\((?<name>[^,\s\256\(]+))(\256|\(TM\))
                    |
                    (?:(?:(?:(?:Impf|Wirk?)stoffe?s?)
                         |(?:Zulassung\s*des\s*ersten[^:]+)):
                    (?:\s+Informationen\s+zu)?
                    \s*(?<name>[^,\s\256\(]+(,?\s*ad\s*us\.\s*vet\.)?))
                    /x
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
          set_symbol(font)
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
          #when %r{^(Neu|Erst)?Zulassung eines (Arzneimittels|Medikamente?s) 
          #         mit( einem)? neue[mn] Wirkstoff}ix,
          when %r{^Zulassung eines( pflanzlichen)? Arzneimittels mit( einem)? neue[mn] Wirk?stoff}i,
            %r{^Neuzulassung eines Medikamente?s mit( einem)? neue[mn] Wirkstoff}i,
            %r{^(Erst)?Zulassung eines neuen (Impf|Wirk)stoffe?s}i,
            %r{^Zulassung des ersten}i
            if(@reached_news)
              @current = {}
              @minifis.push(@current)
              @current[:de] = create_document
            end
          when %r{^Autorisation d.un (phyto)?m.dicament contenant un nouveau}i,
            %r{^Autorisation d.livr.es? pour (un|de) nouveaux? principes? actifs?}i,
            %r{^Autorisation d.livr.es? pour (un|de) nouveaux? produits? de vaccins?}i,
            %r{^Autorisation d.un nouveau (principe actif|vaccin)}i,
            %r{^Autorisation du premier}i,
            %r{^Autorisation d.(livr.e pour )?un m.dicament avec un nouveau}i
            @current[:fr] = create_document if @current
          when %r{Arzneimittel Nachrichten( / M.dicaments)?$},
            %r{^M.dicaments$}
            @reached_news = true
            #ignore
          when %r{Arzneimittel\s*Statistik\s*/\s*Miscellan.es}, 
            %r{Regulatory News / R.glementation}, %r{Regulatory News}, 
            %r{Infosplitter(\s*/\s*En\s*vrac)?}, 
            %r{Richtigstellung}, %r{Berichtigung},
            %r{Medizinprodukte(\s*/\s*Dispositifs m.dicaux)?},
            %r{Zulassung eines Tierarzneimittels},
            %r{Entlassung aus der Heilmittelkontrolle}, 
            %r{Mitteilung an die Fachpersonen},
            %r{Zum Vertrieb freigegebene Chargen},
            %r{^Heparinum natricum ad usum externum} # dtstcpw for 02/2006
            clean!
            @current = nil
          end
          super
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
                      #FIXME && (target != @chapter.heading))
                      #      this was supposed to ensure all bold text at the
                      #      start of a page counts towards the heading - that 
                      #      won't work post 12/2005 however...
                      if(section.subheading.empty?)
                        section = @chapter.next_section
                      end
                      target = section.next_paragraph
                    end
                  when %r{Arzneimittel Nachrichten( / M.dicaments)?},
                    %r{^M.dicaments$}, %r{^Actualit.s$},
                    # misplaced header in 05/2003:416
                    %r{^Arzneimittel Statistik$}
                    #ignore
                  when %r{Swissmedic\s*Journal\s+[_\d]+}, %r{^\d+$}
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
                    elsif(/^[o-·]\s/.match(line))
                      target = section.next_paragraph
                    elsif(!title && previous_width \
                          && previous_width < (line.length * 0.65))
                      target = section.next_paragraph
                    end
                    previous_width = line.length
                    if(target.is_a?(Text::Paragraph))
                      symbols = @symbols[col][row] || []
                      offset = 0
                      symbols.each_with_index { |pos, idx|
                        target << line.slice!(0, pos-offset)
                        if(idx.even?)
                          target.augment_format(:symbol)
                        else
                          target.reduce_format(:symbol)
                        end
                        offset = pos
                      }
                    end
                    if(line.match(HYPHEN))
                      previous_was_hyphenated = true
                      if(!((nxt = column.at(row.next)) \
                           && /^[A-Z]/.match(nxt.to_s)))
                        target << line.gsub(HYPHEN, '')
                      else
                        target << line
                      end
                    else
                      previous_was_hyphenated = false
                      target << line << ' '
                    end
                    if(target.is_a?(Text::Paragraph) \
                       && (format = target.formats.last) \
                       && format.symbol?)
                      target.reduce_format(:symbol)
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
        def set_symbol(font)
          line = @symbols[@current_column][@lines.size - 1] ||= []
          symbol = (font.respond_to?(:basefont_name) \
                    && /Symbol/.match(font.basefont_name))
          if((symbol && line.size.even?) \
             || (!symbol && line.size.odd?))
            line.push @columns[@current_column].length
          end
        end
        def start_page
          @bold_lines = Hash.new { |me, key| me[key] = Hash.new }
          @symbols = Hash.new { |me, key| me[key] = Hash.new }
          @lines.clear
        end
      end
      def MiniFi.extract(filename)
        pdf = Rpdf2txt::Parser.new(File.read(filename), 'latin1')
        handler = Handler.new
        pdf.extract_text(handler)
        handler.minifis.reject { |minifi|
          minifi[:name].nil? || /ad\s*us\.\s*vet/.match(minifi[:de].heading)
        }
      end
    end
  end
end
