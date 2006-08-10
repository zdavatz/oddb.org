#!/usr/bin/env ruby

# ChapterParse::Parser -- oddb -- 09.08.2005 -- ffricker@ywesee.com

require 'util/html_parser'

module ODDB
	module ChapterParse
		class Parser < BasicHtmlParser
			SYMBOL_ENTITIES = {
				# Symbol
				'913' => 'A',
				'914' => 'B',
				'915' => 'G',
				'916' => 'D',
				'917' => 'E',
				'918' => 'Z',
				'919' => 'H',
				'920' => 'Q',
				'921' => 'I',
				'922' => 'K',
				'923' => 'L',
				'924' => 'M',
				'925' => 'N',
				'926' => 'X',
				'927' => 'O',
				'928' => 'P',
				'929' => 'R',
				'931' => 'S',
				'932' => 'T',
				'933' => 'U',
				'934' => 'F',
				'935' => 'C',
				'936' => 'Y',
				'937' => 'W',
				'945' => 'a',
				'946'	=> 'b',
				'947' => 'g',
				'948' => 'd',
				'949' => 'e',
				'950' => 'z',
				'951' => 'h',
				'952' => 'q',
				'953' => 'i',
				'954' => 'k',
				'955' => 'l',
				'956' => 'm',
				'957' => 'n',
				'958' => 'x',
				'959' => 'o',
				'960' => 'p',
				'961' => 'r',
				'963' => 's',
				'964' => 't',	
				'965' => 'u',	
				'966' => 'f',
				'967' => 'c',
				'968' => 'y',
				'969' => 'w',
				'8704'=>  34.chr, # forall
				'8707'=>  36.chr, # exist
				'8727'=>  42.chr, # lowast
				'8722'=>  45.chr, # minus
				'8773'=>  64.chr, # cong
				'8869'=>  94.chr, # perp
				'8764'=> 126.chr, # sim
				'8804'=> 163.chr, # le
				'8734'=> 165.chr, # infin
				'402'	=> 166.chr, # fnof
				'8596'=> 171.chr, # harr
				'8592'=> 172.chr, # larr
				'8593'=> 173.chr, # uarr
				'8594'=> 174.chr, # rarr
				'8595'=> 175.chr, # darr
				'8805'=> 179.chr, # ge
				'8733'=> 181.chr, # prop
				'8706'=> 182.chr, # part
				'8800'=> 185.chr, # ne
				'8801'=> 186.chr, # equiv
				'8776'=> 187.chr, # asymp
				'8629'=> 191.chr, # crarr
				'8855'=> 196.chr, # otimes
				'8853'=> 197.chr, # oplus
				'8709'=> 198.chr, # empty
				'8745'=> 199.chr, # cap
				'8746'=> 200.chr, # cup
				'8835'=> 201.chr, # sup
				'8839'=> 202.chr, # supe
				'8836'=> 203.chr, # nsub
				'8834'=> 204.chr, # sub
				'8838'=> 205.chr, # sube
				'8712'=> 206.chr, # isin
				'8713'=> 207.chr, # notin
				'8736'=> 208.chr, # ang
				'8711'=> 209.chr, # nabla
				'8719'=> 213.chr, # prod
				'8730'=> 214.chr, # radic
				'8901'=> 215.chr, # sdot
				'8743'=> 217.chr, # and
				'8744'=> 218.chr, # or
				'8660'=> 219.chr, # hArr
				'8656'=> 220.chr, # lArr
				'8657'=> 221.chr, # uArr
				'8658'=> 222.chr, # rArr
				'8659'=> 223.chr, # dArr
				'8721'=> 229.chr, # sum
				'8747'=> 242.chr, # int
			}
			def initialize(*args)
				super
				@release_stack = []
			end
			def analyse_attributes(attrs, release)
				if(style = fetch_attribute('style', attrs))
					if(/\bmono(space)?\b/i.match(style))
						start_pre(attrs)
						release.push(:end_pre)
					elsif(/\bsans-serif\b/i.match(style))
						suspend_pre(release)
					end
					if(/\bbold\b/i.match(style))
						start_b(attrs)
						release.push(:end_b)
					end
					if(/\bitalic\b/i.match(style))
						start_i(attrs)
						release.push(:end_i)
					end
					if(/\bvertical-align\s*:\s*super\b/i.match(style))
						start_sup(attrs)
						release.push(:end_sup)
					elsif(/\bvertical-align\s*:\s*sub\b/i.match(style))
						start_sub(attrs)
						release.push(:end_sub)
					end
				elsif((klass = fetch_attribute('class', attrs)) \
					&& /\bpreformatted\b/i.match(klass))
					start_pre(attrs)
					release.push(:end_pre)
				end
			end
			def end_div
				release_tag
			end
			def end_font
				release_tag
			end
			def end_h2
				end_i
			end
      def end_pre
        @nofill = @nofill - 1
        if(@nofill <= 0)
          @nofill = 0
          @formatter.end_paragraph(1)
        end
        @formatter.pop_font()
      end
			def end_span
				release_tag
			end
      def end_sub
				@formatter.pop_fonthandler
      end
      def end_sup
				@formatter.pop_fonthandler
      end
			def fetch_attribute(name, attrs)
				attrs.reverse.each { |key, value|
					if(key == name)
						return value
					end
				}
				nil
			end
			def release_tag
				if(release = @release_stack.pop)
					release.each { |symbol|
						self.send(symbol)
					}
				end		
			end
			def register_release_tag(&block)
				release = []
				block.call(release)
				@release_stack.push(release)
			end
			def restart_pre
				start_pre({})
			end
			def start_div(attrs)
				register_release_tag { |release|
					analyse_attributes(attrs, release)
				}	
				@formatter.add_line_break
			end
			def start_font(attrs)
				register_release_tag { |release|
					if(face = fetch_attribute('face', attrs))
						if(/\bmono(space)?\b/i.match(face))
							start_pre(attrs)
							release.push(:end_pre)
						elsif(/\bsans-serif\b/i.match(face))
							suspend_pre(release)
						end
					end
				}
			end
			def start_h2(attrs)
				start_i(attrs)
			end
      def start_pre(attrs)
        if(@nofill <= 0)
          @formatter.end_paragraph(1)
        end
        @formatter.push_font(nil, nil, nil, 1)
        @nofill = @nofill + 1
      end
			def start_span(attrs)
				register_release_tag { |release|
					analyse_attributes(attrs, release)
				}
			end
      def start_sub(attrs)
				@formatter.push_fonthandler([['vertical-align', 'subscript']])
      end
      def start_sup(attrs)
				@formatter.push_fonthandler([['vertical-align', 'superscript']])
      end
			def suspend_pre(release)
				if(@nofill > 0)
					end_pre
					release.push(:restart_pre)
				end
			end
			def unknown_charref(ref)
				if(char = SYMBOL_ENTITIES[ref])
					@formatter.push_fonthandler([['face', 'Symbol']])
					self.handle_data(char)
					@formatter.pop_fonthandler
        else 
					self.handle_data("?")
				end
			end
		end
	end
end
