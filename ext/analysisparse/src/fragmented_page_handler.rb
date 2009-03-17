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
					/^ *teilliste\s*1/iu,
					/^ *teilliste\s*2/iu,
					/^ *allergologie\s*und\s*klinische\s*immunologie/iu,
					/^ *dermatologie\s*und\s*venerologie/iu,
					/^ *endokrinologie\s*-\s*diabetologie/iu,
					/^ *gastroenterologie/iu,
					/^ *gynäkologie\s*und\s*geburtshilfe/iu,
					/^ *hämatologie/iu,
					/^ *kinder-\s*und\s*jugendmedizin/iu,
					/^ *medizinische\s*onkologie/iu,
					/^ *physikalische\s*medizin\s*und\s*rehabilitation/iu,
					/^ *rheumatologie/iu,
					/^ *tropenmedizin/iu,
					/^\s*Liste\s*partielle\s*1/iu,
					/^\s*Liste\s*partielle\s*2/iu,
					/^\s*allergologie\s*et\s*immunologie\s*clinique/iu,
					/^\s*dermatologie\s*et\s*vénérologie/iu,
					/^\s*endocrinologie\s*-\s*diabétologie/iu,
					/^\s*gastro-entérologie/iu,
					/^\s*gynécologie\s*et\s*obstétrique/iu,
					/^\s*hématologie/iu,
					/^\s*médecine\s*physique\s*et\s*réadaptation/iu,
					/^\s*médecine\s*tropicale/iu,
					/^\s*oncologie\s*médicale/iu,
					/^\s*pédiatrie/iu,
					/^\s*rhumatologie/iu,
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
					when /teilliste\s*1/iu, /Liste\s*partielle\s*1/iu
						@taxpoint_type = :fixed
						@permission = src.match(ptrns.at(idx)).to_s.lstrip
					when /teilliste\s*2/iu, /Liste\s*partielle\s*2/iu
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
