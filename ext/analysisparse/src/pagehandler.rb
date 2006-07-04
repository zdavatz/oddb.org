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
			attr_reader :index
			def initialize(index)
				@index = index
				@incomplete = {}
				@positions = {}
			end
			def analyze(page, pagenum)
				case @index[pagenum]
				when /Chemie\/H\344matologie\/Immunologie/i
					@parser = ListParser.new
					@list_title = $~.to_s
				when /genetik/i
					@parser = ListParser.new
					@list_title = $~.to_s
				when /mikrobiologie/i
					@parser = ListParser.new
					@list_title = $~.to_s
				when /allgemeine positionen/i
					@parser = SimpleListParser.new
					@list_title = $~.to_s
				when /Anonyme Positionen/i
					@list_title = nil
					@parser = AnonymousListParser.new
				when /Fixe Analysenblöcke/
					@parser = BlockListParser.new
					@list_title = $~.to_s
				when /Liste seltener Autoantikörper/
					@parser = nil #AntibodyListParser.new
				when /Im Rahmen der Grundversorgung durchgef\374hrte Analysen/i
					@parser = FragmentedPageHandler.new
					@list_title = nil
					@permission = nil
				when /Von Chiropraktoren oder Chiropraktorinnen veranlasste Analysen/i
					@parser = AppendixListParser.new
					@permission = $~.to_s
				when /Von Hebammen veranlasste Analysen/i
					@parser = AppendixListParser.new
					@permission = $~.to_s
				end
				if(@parser)
					handler = Rpdf2txt::SimpleHandler.new
					page.text(handler)
					txt = handler.out
					parse_page(txt, pagenum, @parser)
				end
				self
			end
			def parse_page(txt, pagenum, parser)
				parser.list_title = @list_title
				parser.permission = @permission
				pos = parser.parse_page(txt, pagenum)
				parser.footnotes.each { |key, fn|
					if(pairs = @incomplete.delete(key))
						pairs.each { |pair|
							pair[1] = fn
						}
					end
				}
				pos.each { |ps|
					same = nil
					fn = ps.delete(:footnote)
					perm = ps.delete(:permission)
					if(same = @positions[ps[:code]])
						ps.delete_if { |key, value|
							value.nil?
						}
						same.update(ps)
					else
						same = ps
						ps.store(:permissions, [])
						@positions.store(ps[:code], ps)
					end
					pair = [perm, fn]
					if(perm)
						same[:permissions].push(pair)
					end
					if(/^\d+$/.match(fn))
						(@incomplete[fn] ||= []).push(pair)
					end
				}
				@list_title = parser.list_title
				@permission = parser.permission 
				pos
			end
			def positions
				@positions.values
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
