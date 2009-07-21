#!/usr/bin/env ruby
# HtmlParser -- oddb -- 06.10.2003 -- mhuggler@ywesee.com


require 'html-parser'
require 'formatter'
require 'iconv'

module ODDB
	class NullWriter < ::NullWriter
		def new_fonthandler(fonthandler); end
		def new_linkhandler(linkhandler); end
		def new_tablehandler(tablehandler); end
		def send_image(src); end
		def send_meta(attributes); end
	end
	class BasicHtmlParser < HTMLParser
    iconv = Iconv.new('utf-8', 'iso-8859-1')
		entities = {}
		[
			'nbsp', 'iexcl', 'cent', 'pound', 'curren',
			'yen', 'brvbar', 'sect', 'uml', 'copy',
			'ordf', 'laquo', 'not', 'shy', 'reg',
			'macr', 'deg', 'plusmn', 'sup2', 'sup3',
			'acute', 'micro', 'para', 'middot', 'cedil',
			'sup1', 'ordm', 'raquo', 'frac14', 'frac12',
			'frac34', 'iquest', 'Agrave', 'Aacute', 'Acirc',
			'Atilde', 'Auml', 'Aring', 'AElig', 'Ccedil',
			'Egrave', 'Eacute', 'Ecirc', 'Euml', 'Igrave',
			'Iacute', 'Icirc', 'Iuml', 'ETH', 'Ntilde',
			'Ograve', 'Oacute', 'Ocirc', 'Otilde', 'Ouml',
			'times', 'Oslash', 'Ugrave', 'Uacute', 'Ucirc',
			'Uuml', 'Yacute', 'THORN', 'szlig', 'agrave',
			'aacute', 'acirc', 'atilde', 'auml', 'aring',
			'aelig', 'ccedil', 'egrave', 'eacute', 'ecirc',
			'euml', 'igrave', 'iacute', 'icirc', 'iuml',
			'eth', 'ntilde', 'ograve', 'oacute', 'ocirc',
			'otilde', 'ouml', 'divide', 'oslash', 'ugrave',
			'uacute', 'ucirc', 'uuml', 'yacute', 'thorn',
			'yuml', 
		].each_with_index { |name, idx| 
			# Html-Entities start at chr 160
			entities.store(name, iconv.iconv((idx + 160).chr))
		}
		Entitydefs = entities	

		def end_table
			@formatter.pop_table
		end
		def end_td
			@formatter.pop_alignment
			@formatter.pop_tablecell
		end
		def end_tr
			@formatter.pop_tablerow
		end
    def finish_endtag(tag)
			if tag == ''
				found = @stack.length - 1
				if found < 0
					unknown_endtag(tag)
					return
				end
			else
				unless @stack.include? tag
					method = 'end_' + tag
					unless self.respond_to?(method)
						unknown_endtag(tag)
					end
					return
				end
				found = @stack.rindex(tag) #or @stack.length
			end
			if(@stack.last == 'pre')
				if(tag == 'pre')
					handle_endtag(tag, :end_pre)
					@stack.pop
				end
			else
				while @stack.length > found
					tag = @stack[-1]
					method = 'end_' + tag
					if respond_to?(method)
						handle_endtag(tag, method)
					else
						unknown_endtag(tag)
					end
					@stack.pop
				end
			end
		end
		def unknown_entityref(name)
			if(data = self::class::Entitydefs[name])
				handle_data(data)
			end
		end
		def start_table(attrs)
			@formatter.push_table(attrs)
		end
		def start_td(attrs)
			align = attrs.collect { |key, val|	
				val if(key == 'align')
			}.compact.last
			align = align.downcase if(align.is_a? String)
			@formatter.push_alignment(align)
			@formatter.push_tablecell(attrs)
		end
		def start_tr(attrs)
			@formatter.push_tablerow(attrs)
		end
	end
	class HtmlParser < BasicHtmlParser
		def do_img(attrs)
			align = nil
			alt = '(image)'
			ismap = nil
			src = nil
			width = 0
			height = 0
			for attrname, value in attrs
				if attrname == 'align'
					align = value
				end
				if attrname == 'alt'
					alt = value
				end
				if attrname == 'ismap'
					ismap = value
				end
				if attrname == 'src'
					src = value
				end
				if attrname == 'width'
					width = value.to_i
				end
				if attrname == 'height'
					height = value.to_i
				end
			end
			handle_image(src, alt, ismap, align, width, height)
		end
		def do_meta(attrs)
			@formatter.send_meta(attrs)
		end
		def end_a
			@formatter.pop_link
		end
		def end_font
			@formatter.pop_fonthandler
		end
		def feed(data)
			super(data.gsub("\302\222", "’"))
		end
		def handle_image(src, *args)
			@formatter.send_image(src.to_s.gsub(/["']/u, ''))
		end
		def start_a(attrs)
			@formatter.push_link(attrs)
		end
		def start_font(attrs)
			@formatter.push_fonthandler(attrs)
		end
	end
	class HtmlTableHandler
		class Cell
			attr_reader :attributes, :colspan, :children, :rowspan
			MAX_WIDTH = 32
			def initialize(attr, keep=false)
				@keep_empty_lines = keep
				@attributes = attr.inject({}) { |inj, pair| 
					key, val = pair
					inj.store(key.downcase, val.gsub(/(^['"])|(['"])$/u, ''))
					inj
				}
				@current_line = ''
				@cdata = [@current_line]
				@children = []
				@colspan = [@attributes["colspan"].to_i, 1].max
				@rowspan = [@attributes["rowspan"].to_i, 1].max
				@current_formats = {}
				@formats = [@current_formats]
			end
			def add_child(child)
				@children.push(child)
			end
			def cdata
				cdata = _cdata
				if(cdata.empty?)
					''
				elsif(cdata.size == 1)
					cdata.first
				else
					cdata
				end
			end
			def _cdata(flatten=true)
				cdata = @cdata.collect { |data|
					data.strip
				}
				cdata.delete('') unless @keep_empty_lines
				cdata
			end
			def formatted_cdata
				cdata = []
				@cdata.each_with_index { |data, idx|
					ddata = data.dup
					@formats[idx].sort.reverse.each { |pos, fmt|
						if(pos <= ddata.length)
							ddata[pos, 0] = fmt
						end
					}
					cdata << ddata
				}
				cdata
			end
			def height
				_cdata.size
			end
			def next_line
				@current_formats = {}
				@formats << @current_formats
				@current_line = ''
				@cdata << @current_line
			end
			def send_cdata(data)
				@current_line << data
        @current_line.gsub!(/\s+/u, ' ')
        @current_line
			end
			def send_format(fmtstr)
				@current_formats[@current_line.size] = fmtstr
			end
			def width
				width = @cdata.collect { |line| 
					line.strip.size }.max
				(width.to_f / @colspan.to_f).ceil
			end
		end
		class Row
			attr_reader :attributes, :cells
			def initialize(attr)
				@attributes = attr
				@cells = []
			end
			def add_child(child)
				@current_cell.add_child(child)
			end
			def cdata(x)
				if(@cells.size > x)
					@cells.at(x).cdata
				end
			end
			def children(x)
				if(@cells.size > x)
					@cells.at(x).children
				end
			end
			def current_colspan
				@current_cell.colspan
			end
			def each_cell_with_index(&block)
				@cells.each_with_index(&block)
			end
			def height
				@cells.collect { |cell| cell.height }.max
			end
			def next_cell(attr={}, keep=false)
				@current_cell = Cell.new(attr, keep)
				@cells += Array.new(@current_cell.colspan, @current_cell)
				@current_cell
			end
			def next_line
				@current_cell.next_line
			end
			def send_cdata(data)
				(@current_cell || next_cell).send_cdata(data)
			end
			def send_format(fmtstr)
				(@current_cell || next_cell).send_format(fmtstr)
			end
		end
		attr_reader :attributes
		def initialize(attributes)
			@attributes = attributes
			@rows = []
      @rowspans = []
		end
		def add_child(child)
			@current_row.add_child(child)
		end
		def cdata(x, y)
			if(@rows.size > y)
				@rows.at(y).cdata(x)
			end
		end
		def children(x, y)
			if(@rows.size > y)
				@rows.at(y).children(x)
			end
		end
		def current_colspan
			@current_row.current_colspan
		end
		def each_row(&block)
			@rows.each(&block)
		end
		def extract_cdata(template)
			template.inject({}) { |inj, pair|
				key, pos = pair
				inj.store(key, cdata(*pos))
				inj
			}
		end
		def next_line
			@current_row.next_line
		end
		def next_cell(attr, keep=false)
      row = @current_row || next_row({})
      @rows.each_with_index { |rw, idy|
        test = @rows.size - idy
        while((cl = rw.cells[row.cells.size]) && (cl.rowspan >= test))
          row.next_cell({}, keep)
        end
      }
			row.next_cell(attr, keep)
		end
		def next_row(attr={})
			@current_row = Row.new(attr)
			@rows.push(@current_row)
			@current_row
		end
		def send_cdata(data)
			(@current_row || next_row).send_cdata(data.gsub(/\s/u, ' '))
		end
		alias :<< :send_cdata
		def to_s
			if(@rows.empty?)
				return ''
			end
			hline = "-" * width
			lines = [ hline ]
      rowspans = []
			@rows.each_with_index { |row, rdx|
			  hline = "-" * width
				row.height.times { |idy|
					cells = []
					colspan = 1
          #row_w = 1
					@column_widths.each_with_index { |pad, idx|
            if(colspan > 1)
							colspan -= 1
							next
						end
						cdata = ''
						#formatted_cdata = ''
						if(cell = row.cells[idx])
              rowspan = cell.rowspan
              #str = " " * pad
              if(idy == 0)
                if(rowspan > 1)
                  rowspans[idx] = rowspan
                end
                if(rowspans[idx].to_i > 1)
                  rowspans[idx] -= 1
                  #hline[row_w - 1, str.length+4] = '  ' << str << '  '
                end
              end
							colspan = cell.colspan
							cdata = cell._cdata(false)[idy].to_s.strip
							if(colspan > 1)
								total_w = 0
								colspan.times { |offset|
									total_w += @column_widths[offset + idx]
								}
								#total_w += (colspan - 1) * 3
								total_w += (colspan - 1) * 2
								pad = total_w - cdata.size 
							else
								pad -= cdata.size
							end
						end

            padded = cdata << (" " * pad)
            #row_w += padded.length + 3
						cells.push(padded)
					}
					#lines.push("| " << cells.join(' | ') << " |")
					lines.push(cells.join('  '))
				}
				#lines.push(hline)
			}
		  lines.push(hline)
			lines.join("\n") << "\n"
		end
		def width
			@column_widths = []
			@rows.each { |row|
				row.each_cell_with_index { |cell, idx|
					oldval = @column_widths[idx].to_i
					newval = cell.width 
					@column_widths[idx] = [oldval, newval].max
				}
			}
			width = @column_widths.inject { |wdt, inj|
				wdt + inj 
			}
			#width + (@column_widths.size * 3) + 1
			width + ((@column_widths.size - 1) * 2)
		end
	end
	class HtmlLimitationHandler
		attr_reader :rows
		def initialize
			@rows ||= []
		end
		def feed(row)
			@rows << row
		end
	end
	class HtmlAttributesHandler
		def initialize(attr)
			@attributes = attr.inject({}) { |inj, pair| 
				key, val = pair
				inj.store(key.downcase, val.gsub(/["']/u, ''))
				inj
			}
		end
		def attribute(key)
			@attributes[key.downcase]
		end
	end
	class HtmlLinkHandler < HtmlAttributesHandler
		attr_reader :value, :attributes
		def send_adata(string)
			@value = string.strip
		end
		def to_s
			@value.to_s
		end
	end
	class HtmlFontHandler < HtmlAttributesHandler
	end
	class HtmlFormatter < AbstractFormatter
		def initialize(writer)
			super
			@fonthandler_stack = []
			@table_stack = []
			@link_stack = []
		end
		def pop_alignment
			@align_stack.pop
		end
		def pop_fonthandler
			@fonthandler_stack.pop
			@fonthandler = @fonthandler_stack.last
			@writer.new_fonthandler(@fonthandler)
		end
		def pop_link
			@link_stack.pop
			@linkhandler = @link_stack.last
			@writer.new_linkhandler(@linkhandler)
		end
		def pop_table
			@table_stack.pop
			@tablehandler = @table_stack.last
			@writer.new_tablehandler(@tablehandler)
		end
		def pop_tablerow
		end
		def pop_tablecell
		end
		def push_alignment(alignment)
			if(@align_stack.last != alignment)
				@writer.new_alignment(alignment)
			end
			@align_stack.push(alignment)
		end
		def push_link(attributes)
			@linkhandler = HtmlLinkHandler.new(attributes)
			@link_stack << @linkhandler
			@writer.new_linkhandler(@linkhandler)
		end
		def push_fonthandler(attributes)
			@fonthandler = HtmlFontHandler.new(attributes)
			@fonthandler_stack << @fonthandler
			@writer.new_fonthandler(@fonthandler)
		end
		def push_table(attributes)
			@tablehandler = HtmlTableHandler.new(attributes)
			@table_stack << @tablehandler 
			@writer.new_tablehandler(@tablehandler)			
		end
		def push_tablecell(attributes)
			unless(@tablehandler.nil?)
				@tablehandler.next_cell(attributes)
			end
		end
		def push_tablerow(attributes)
			unless(@tablehandler.nil?)
				@tablehandler.next_row(attributes)
			end
		end
		def send_image(src)
			@writer.send_image(src)
		end
		def send_meta(attrs)
			@writer.send_meta(attrs)
		end
	end
end
