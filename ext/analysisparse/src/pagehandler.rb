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
				when /Chemie\/H\344matologie\/Immunologie/iu \
					, /Chimie\/Hématologie\/Immunologie/iu
					@parser = ListParser.new
					@list_title = $~.to_s
				when /genetik/iu, /génétique/iu
					@parser = ListParser.new
					@list_title = $~.to_s
				when /mikrobiologie/iu, /microbiologie/iu
					@parser = ListParser.new
					@list_title = $~.to_s
				when /allgemeine positionen/iu, /positions générales/iu
					@parser = SimpleListParser.new
					@list_title = $~.to_s
				when /Anonyme Positionen/iu, /positions anonymes/iu
					@list_title = nil
					@parser = AnonymousListParser.new
				when /Fixe Analysenblöcke/iu, /Blocs\s*d[\'\302\222]analyses\s*fixes/iu
					@parser = BlockListParser.new
					@list_title = $~.to_s
				when /Liste seltener Autoantikörper/u
					@parser = nil #AntibodyListParser.new
				when /Im Rahmen der Grundversorgung durchgef\374hrte Analysen/iu, /analyses effectuées dans le cadre des soins de base/iu
					@parser = FragmentedPageHandler.new
					@list_title = nil
					@permission = nil
				when /Von Chiropraktoren oder Chiropraktorinnen veranlasste Analysen/iu, /analyses prescrites par des chiropraticiens/iu
					@parser = AppendixListParser.new
					@permission = $~.to_s
				when /Von Hebammen veranlasste Analysen/iu,
             /analyses prescrites par des sages-femmes/iu
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
				parser.footnotes.each { |key, rs|
					if(pairs = @incomplete.delete(key))
						pairs.each { |pair|
							pair[1] = rs
						}
					end
				}
				pos.each { |ps|
					same = nil
					rs = ps.delete(:restriction)
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
					pair = [perm, rs]
					if(perm)
						same[:permissions].push(pair)
					end
					if(/^\d+$/u.match(rs))
						(@incomplete[rs] ||= []).push(pair)
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
				if((/vorbemerkungen/iu.match(txt) \
						|| /remarques\s*préliminaires/iu.match(txt)) \
						&& !@index.empty?)
					IndexHandler.new(@index)
				else
					txt.gsub!(/~R/u, '\'')
					txt.gsub!(/\302\222/u, '\'')
					find_subchapters(/^\s*\d\.\s+(.*?)\.*\s*(\d*)/u, txt)
					find_subchapters(/^\s*\d\.\s*([^\d]+?)\..+?(\d+)/u, txt)
					find_subchapters(/^\s*\d\.\s*kapitel\s*:\s*(.*?)\s*[\d\.]{2,7}\s*.*?\.*\s*(\d+)\s*/imu, txt)
					find_subchapters(/\s*4\.\d\s*([\w\säöü\-\']+)\.*\s*?(\d{3})\s*?/iu, txt)
					find_subchapters(/^\s*5\.\d\s*anhang\s*[ABC]\s*(.*?)\s*\.*\s*(\d+)\s*$/u, txt)
					find_subchapters(/^\s*5\.\d\s*anhang\s*[ABC]\s*(.*?)[\d\.]{5,7}\s*.*?\.*\s*(\d+)\s*$/imu, txt)
					find_subchapters(/^\s*chapitre\s*\d:\s*(.*?)\s*[\d\.]{2,7}\s*.*?\.*\s*(\d+)\s*/imu, txt)
					find_subchapters(/\s*4\.\d\s*([\w\s\302\222éèà]+)\.*\s*(\d+)\s*/iu, txt)
					find_subchapters(/^\s*5\.\d\s*annexe\s*A\s*:\s*(.*?)\s*[\d\.]{5,7}\s*.*?\.*\s*(\d+)/imu, txt)
					find_subchapters(/^\s*5\.\d\s*annexe\s*[BC]\s*:\s*(.*?)\.*\s*(\d+)/iu, txt)
					@index.each_value { |val| 
						val = val.gsub!(/\s*\/\s*/u,'/')
					}
					@index.each_value { |val| val.gsub!(/\302\222/,'\'')}
					self
				end
			end
		end
	end
end
