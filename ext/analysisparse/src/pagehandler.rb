#!/usr/bin/env ruby
# AnalysisParse::PageHandler -- oddb.org -- 12.04.2006 -- sfrischknecht@ywesee.com

require 'rpdf2txt/parser'
require 'anonymous_list_parser'
require 'antibody_list_parser'
require 'appendix_list_parser'
require 'extended_list_parser'
require 'fragmented_page_handler'
require 'list_parser'
require 'block_list_parser'
require 'simple_list_parser'

module ODDB
	module AnalysisParse
		class PageHandler
			def analyze(page, pagenum)
				handler = Rpdf2txt::SimpleHandler.new
				page.text(handler)
				txt = handler.out
				next_pagehandler(txt)
			end
			def next_pagehandler(txt)
				self
			end
		end
		class IndexHandler < PageHandler
			attr_reader :index, :positions
			def initialize(index)
				@index = index
				@incomplete = {}
				@positions = []
				@list_title = ''
			end
			def analyze(page, pagenum)
				case @index[pagenum]
				when /Chemie\/H\344matologie\/Immunologie/i
					@parser = ListParser.new
				when /genetik/i
					@parser = ListParser.new
				when /mikrobiologie/i
					@parser = ListParser.new
				when /allgemeine positionen/i
					@parser = SimpleListParser.new
				when /Anonyme Positionen/i
					@parser = AnonymousListParser.new
				when /Fixe Analysenblöcke/
					@parser = BlockListParser.new
				when /Liste seltener Autoantikörper/
					@parser = nil #AntibodyListParser.new
				when /Im Rahmen der Grundversorgung durchgef\374hrte Analysen/i
					@parser = FragmentedPageHandler.new
				when /Von Chiropraktoren oder Chiropraktorinnen veranlasste Analysen/i
					@parser = AppendixListParser.new
				when /Von Hebammen veranlasste Analysen/i
					@parser = AppendixListParser.new
				end
				@list_title = $~.to_s
				if(@parser)
					@parser.list_title = @list_title
					handler = Rpdf2txt::SimpleHandler.new
					page.text(handler)
					txt = handler.out
					parse_pages(txt, pagenum, @parser)
				end
				self
			end
			def parse_pages(txt, pagenum, parser)
				pos = parser.parse_page(txt, pagenum)
				pos.each { |ps|
					fn = ps[:footnote]
					if(fn.is_a?(Integer))
						@incomplete.store(fn, ps)
					end
				}
				parser.footnotes.each { |key, fn|
					if(ps = @incomplete.delete(key))
						ps[:footnote] = fn
					end
				}
				@positions.concat(pos)
				@list_title = parser.list_title
				pos
			end
		end
		class IndexFinder < PageHandler
			attr_reader :index
			def find_subchapters(pattern, txt)
				lines = []
				txt.each { |part|
					lines << ''
					lines.each { |line|
						line << ' ' << part.strip
						if(match = pattern.match(line))
							unless(match[1].strip == '')
								@index.store(match[2].to_i, match[1].strip)
								lines = []
							end
						end
					}
				}
			end
			def next_pagehandler(txt)
				@index ||= {}
				if(/vorbemerkungen/i.match(txt) && !@index.empty?)
					IndexHandler.new(@index)
				else
					find_subchapters(/^\s*\d\.\s+(.*?)\.*\s*(\d*)/, txt)
					find_subchapters(/^\s*\d\.\s*([^\d]+?)\..+?(\d+)/, txt)
					find_subchapters(/^\s*\d\.\s*kapitel\s*:\s*(.*?)\s*[\d\.]{2,7}\s*.*?\.*\s*(\d+)\s*/im, txt)
					find_subchapters(/^\s*4\.\d\s*([\w\säöü]+)\.*\s*?(\d{3})\s*?$/i, txt)
					find_subchapters(/^\s*5\.\d\s*anhang\s*[ABC]\s*(.*?)\s*\.*\s*(\d+)\s*$/, txt)
					find_subchapters(/^\s*5\.\d\s*anhang\s*[ABC]\s*(.*?)[\d\.]{5,7}\s*.*?\.*\s*(\d+)\s*$/im, txt)
					self
				end
			end
		end
	end
end
