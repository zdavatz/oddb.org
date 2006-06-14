#!/usr/bin/env ruby
# AnalysisParse::FragmentedPageHandler -- oddb.org -- 17.05.2006 -- sfrischknecht@ywesee.com

require 'parser'
require 'extended_list_parser'
require 'appendix_list_parser'

module ODDB
	module AnalysisParse
		class FragmentedPageHandler
			attr_accessor :list_title
			attr_reader :footnotes
			def initialize
				@footnotes = {}
				@chapters = [
					/^ *teilliste\s*1/i,
					/^ *teilliste\s*2/i,
					/^ *allergologie\s*und\s*klinische\s*immunologie/i,
					/^ *dermatologie\s*und\s*venerologie/i,
					/^ *endokrinologie\s*-\s*diabetologie/i,
					/^ *gastroenterologie/i,
					/^ *gynäkologie\s*und\s*geburtshilfe/i,
					/^ *hämatologie/i,
					/^ *kinder-\s*und\s*jugendmedizin/i,
					/^ *medizinische\s*onkologie/i,
					/^ *physikalische\s*medizin\s*und\s*rehabilitation/i,
					/^ *rheumatologie/i,
					/^ *tropenmedizin/i,
				]
			end
			def parse_page(txt, pagenum)
				positions = []
				each_fragment(txt) { |fragment|
					if(!fragment.empty?)
						positions += parse_fragment(fragment, pagenum)
					end
				}
				positions
			end
			def parse_fragment(fragment, pagenum)
				parser = ExtendedListParser.new
				positions = parser.parse_page(fragment, pagenum)
				positions.each { |pos| 
					pos.store(:list_title, @list_title)
				}
				@footnotes.update(parser.footnotes)
				positions
			end
			def each_fragment(txt)
				start = 0
				indices = []
				ptrns = []
				@chapters.each { |ptrn|
					if(idx = txt.index(ptrn))
						indices.push(idx)
						ptrns.push(ptrn)
					end
				}
				first = indices.first
				unless(first == 0)
					yield txt[0..(first.to_i - 1)]
				end
				indices.each_with_index { |start, idx|
					stop = indices.at(idx.next).to_i - 1	
					src = txt[start..stop]
					@list_title = src.match(ptrns.at(idx)).to_s
					yield src
				}
			end
		end
	end
end
