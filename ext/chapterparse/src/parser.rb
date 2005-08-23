#!/usr/bin/env ruby

# ChapterParse::Parser -- oddb -- 09.08.2005 -- ffricker@ywesee.com

require 'util/html_parser'

module ODDB
	module ChapterParse
		class Parser < BasicHtmlParser
			def initialize(*args)
				super
				@release_stack = []
			end
			def end_div
				release_tag
			end
			def end_font
				release_tag
			end
			def end_span
				release_tag
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
			def start_div(attrs)
				if(attrs == [["class", "\"preformatted\""]])
					register_release_tag { |release|
						start_pre(attrs)
						release.push(:end_pre)
					}	
				end
				@formatter.add_line_break
			end
			def start_font(attrs)
				register_release_tag { |release|
					if(face = fetch_attribute('face', attrs))
						if(/\bmono\b/i.match(face))
							start_pre(attrs)
							release.push(:end_pre)
						end
					end
				}
			end
			def start_span(attrs)
				register_release_tag { |release|
					if(style = fetch_attribute('style', attrs))
						if(/\bmono\b/i.match(style))
							start_pre(attrs)
							release.push(:end_pre)
						end
						if(/\bbold\b/i.match(style))
							start_b(attrs)
							release.push(:end_b)
						end
						if(/\bitalic\b/i.match(style))
							start_i(attrs)
							#puts attrs.inspect
							release.push(:end_i)
						end
					end
				}
			end
			def unknown_charref(ref)
				#puts "unknwon charref #{ref}"
				chartable = {
				
				  # Signs
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
					'969' => 'w'
				
				}
				if(char = chartable[ref])
					@formatter.push_fonthandler([['face', 'Symbol']])
					self.handle_data(char)
					@formatter.pop_fonthandler
				end
			end
		end
	end
end
