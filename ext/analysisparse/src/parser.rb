#!/usr/bin/env ruby
# AnalysisParse::Parser -- oddb.org -- 06.06.2006 -- sfrischknecht@ywesee.com

require 'rockit/rockit'

module ODDB
	module AnalysisParse
		class Parser
			FOOTNOTE_PTRN = /^\s*_*\s*(\d|\*)\s*_*\s*[^\d\*\.]+/mu
			FOOTNOTE_TYPE = :footnote
			LINE_PTRN = /^\s*([CNS]|N,\s*ex|TP)?\s*\d{4}\.\d{2,}\s*[\d\*]/u
			STOPCHARS = ";.\n"
			attr_reader :footnotes
			attr_accessor :list_title, :permission, :taxpoint_type
			def initialize
				@footnotes = {}
			end
			def footnote_line(footnotes, src, start, stop)
				line = src[start..stop].strip
				fn = line.slice!(/^\d+|\*/u)
				#line.gsub!(/_/,'')
				line.strip!
				line.gsub!(/\s+/, ' ')
				footnotes.store(fn, line)
			end
			def footnote_type
				self.class::FOOTNOTE_TYPE
			end
			def parse_footnotes(src)
				src.gsub!(/_*/u, '')
				src.gsub!(/~R/u, '\'')
				footnotes = {}
				stop = 0
				start = 0
				while(nextstart = src.index(FOOTNOTE_PTRN, start + 5))
					stop = nextstart - 1
					footnote_line(footnotes, src, start, stop)
					start = nextstart
				end
				footnote_line(footnotes, src, stop, -1)
				@footnotes.update(footnotes)
			end
			def parse_line(src)
				data = {
					:list_title			=> @list_title,
					:permission			=> @permission,
					:taxpoint_type	=> @taxpoint_type,
				}
				src << "\n"
				ast = self.class::PARSER.parse(src)
			rescue Exception	=>	e
				ptrn = /(\d{4})\.(\d{2})\s*(\d{1,2})\s*(.*)/u
				data.update({
					:error			=>	e,
					:line						=>	src,
				})
				if(match = ptrn.match(src))
					data.update({
						:code					=> [match[1], match[2]].join('.'), 
						:group				=> match[1],
						:position			=> match[2],
						:taxpoints		=> match[3],
						:description	=> match[4],
					})
				end
				data
			else
				desc = ''
				position = ast.position.value
				group = ast.group.value
				if(position.size > 2)
					data.store(footnote_type, position.slice!(2..-1))
				end
				data.update({
					:code					=> [group, position].join('.'),
					:group				=> group,
					:position			=> position,
					:taxpoints		=> ast.taxpoints.value.to_i,	
					:description	=> desc,
				})
				extract_text(ast.description, desc)
				if(lba = child_if_exists(ast, 'labarea'))
					data.store(:lab_areas, lba.value.strip.split(''))
				end
				if(agroup = child_if_exists(ast, 'anonymousgroup'))
					data.store(:anonymousgroup, agroup.value)
				end
				if(apos = child_if_exists(ast, 'anonymouspos'))
					data.store(:anonymouspos, apos.value)
				end
				if(lim = child_if_exists(ast, 'limitation'))
					limitation = extract_text(lim.description)
					if(ml = child_if_exists(ast, 'morelines'))
						extract_text(ml, limitation)
					end
					data.store(:limitation, limitation)
				elsif(more = child_if_exists(ast, 'morelines'))
					extract_text(more, desc)
					if(lim = child_if_exists(ast, 'limitation2'))
						limitation = extract_text(lim.description)
						data.store(:limitation, limitation)
					end
				elsif(lim2 = child_if_exists(ast, 'limitation2'))
					limitation = extract_text(lim2.description)
					data.store(:limitation, limitation)
				end
				if((number = child_if_exists(ast, 'taxnumber')) \
						&& (note = child_if_exists(ast, 'taxnote')))
					taxnote = extract_text(note.description)
					taxnumber = number.value[/\d+/u]
					data.store(:taxnumber, taxnumber)
					data.store(:taxnote, taxnote)
				end
				if(revision = child_if_exists(ast, 'revision'))
					data.store(:analysis_revision, revision.value)
				end
				[:finding, footnote_type].each { |key|
					if(node = child_if_exists(ast, key.to_s))
						data.store(key, node.value)
					end
				}
				if(child_if_exists(ast, 'anonymous'))
					data.store(:anonymous, true)
				end
				data
			end
			def parse_page(page, pagenum)
				stop = 0
				new_data = []
				footnotes = {}
				line_ptrn = self.class::LINE_PTRN
				if(start = page.index(line_ptrn))
					while(nextstart = page.index(line_ptrn, start + $~.to_s.length))
						stop = nextstart - 1
						line = page[start..stop]
						new_data.push(parse_line(line))
						start = nextstart
					end
					pagenum_pos = page.rindex(pagenum.to_s).to_i - 1
					if(stop = page.index(FOOTNOTE_PTRN, start + $~.to_s.length))
						parse_footnotes(page[stop..pagenum_pos])
					else
						stop = pagenum_pos
					end
					stop -= 1
					line = page[start..stop]
					new_data.push(parse_line(line))
					update_footnotes(new_data, @footnotes)
				end
				new_data
			end
			def update_footnotes(new_data, footnotes)
				new_data.each { |data|
					if(fn = footnotes[data[:footnote]])
						data.store(:footnote, fn)
					end
				}
				new_data
			end
			private
			def child_if_exists(ast, name)
				if(ast.children_names.include?(name))
					ast.send(name)
				end
			end
			def extract_text(node, target='')
				if(node)
					tmp = ''
					target << ' '
					node.each { |subnode| 
						str = ''
						if(subnode.is_a?(ArrayNode))
							subnode.each { |nd| 
								val = nd.value
								unless(/^[#{STOPCHARS}]/u.match(val) \
											 || str.empty?)
									str.strip!
									str << ' '	
								end
								str << val
							}
						elsif(subnode.is_a?(String))
							str = subnode
						else
							str = subnode.value
						end
						target << tmp
						unless(/^[#{STOPCHARS}]/u.match(str) \
									 || target.empty?)
							target.strip!
							target << ' '	
						end
						tmp = str
					}
					target << tmp
					if(/ - .* - /u.match(target))
						target.gsub!(/ - /u, "\n- ")
					end
					ptrn = /([a-zäöü])-\s+(?!(?:und|oder))([a-zäöü])/u
					target.gsub!(ptrn, '\\1\\2')
					target.gsub!(/(\S-)\s+(?!(?:und|oder))/u,'\\1\\2')
					target.gsub!(/\s*\/\s*/u,'/')
					target.gsub!(/(\()\s+(\S)/u, '\\1\\2')
					target.gsub!(/(\S)\s+(\))/u,'\\1\\2')
					target.gsub!(/(\.)\s*(,)/u,'\\1\\2')
					target.gsub!(/(\w)\s+(-\S)/u, '\\1\\2')
					target.gsub!(/(_+)/u, '')
					target.strip!
				end
				target
			end
		end
	end
end
