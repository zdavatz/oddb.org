#!/usr/bin/env ruby
# AnalysisParse::FragmentedPageHandler -- oddb.org -- 17.05.2006 -- sfrischknecht@ywesee.com

require 'parser'
require 'extended_list_parser'
require 'appendix_list_parser'

module ODDB
	module AnalysisParse
		class FragmentedPageHandler
			attr_accessor :permission, :taxpoint_type, :list_title
			attr_reader :footnotes
			def initialize
				@taxpoint_type = nil
				@permission = nil
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
					/^\s*Liste\s*partielle\s*1/i,
					/^\s*Liste\s*partielle\s*2/i,
					/^\s*allergologie\s*et\s*immunologie\s*clinique/i,
					/^\s*dermatologie\s*et\s*vénérologie/i,
					/^\s*endocrinologie\s*-\s*diabétologie/i,
					/^\s*gastro-entérologie/i,
					/^\s*gynécologie\s*et\s*obstétrique/i,
					/^\s*hématologie/i,
					/^\s*médecine\s*physique\s*et\s*réadaptation/i,
					/^\s*médecine\s*tropicale/i,
					/^\s*oncologie\s*médicale/i,
					/^\s*pédiatrie/i,
					/^\s*rhumatologie/i,
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
				parser.taxpoint_type = @taxpoint_type
				parser.permission = @permission
				parser.list_title = @list_title
				positions = parser.parse_page(fragment, pagenum)
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
					case src
					when /teilliste\s*1/i , /Liste\s*partielle\s*1/i
						@taxpoint_type = :fixed
						@permission = src.match(ptrns.at(idx)).to_s.lstrip
					when /teilliste\s*2/i , /Liste\s*partielle\s*2/i
						@taxpoint_type = :default
						@permission = src.match(ptrns.at(idx)).to_s.lstrip
					else
						@taxpoint_type = nil
						@permission = src.match(ptrns.at(idx)).to_s.lstrip
					end
					yield src
				}
			end
		end
	end
end
