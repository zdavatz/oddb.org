#!/usr/bin/env ruby
#FachinfoWriter -- oddb -- 02.02.2004 -- mwalder@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.dirname(__FILE__)

require 'pdf/ezwriter'
require 'model/text'
require 'substance_index'
require 'format'
require 'fachinfo_wrapper'
require 'cgi'


$dumped_ids = []
class Object
	def dump_bigvars(offset = '')
		unless($dumped_ids.include? self.__id__)
			$dumped_ids << self.__id__
			line = [
				self.class,
				self.__id__,
				(Marshal.dump(self).size/1024).to_s << 'K'
			].join(':')
			vars = instance_variables.collect { |name|
				[name, instance_variable_get(name)]
			}
			if(is_a?(Array))
				each_with_index { |item, idx|
					vars << [idx.to_s, item]
				}
			elsif(is_a?(Hash))
				each { |key, item|
					vars << [key.to_s, item]
				}
			end
			bigvars = vars.sort_by { |name, item|
				Marshal.dump(item).size
			}.reverse[0,5]
			final = bigvars.collect { |name, var|
				offset.to_s + name.to_s + var.dump_bigvars(offset.to_s + '  ').to_s
			}.unshift(offset.to_s + line.to_s)
			"\n" << final.join("\n")
		else
			":" << self.class.to_s << ":" << self.__id__.to_s
		end
	end
	@@obj_path_id = 0
	def obj_path(id, obj_path_id=nil)
		if(obj_path_id.nil?)
			obj_path_id = @@obj_path_id += 1
		end
		return if(frozen? || @obj_path_id == obj_path_id)
		@obj_path_id = obj_path_id
		instance_variables.each { |name|
			var = instance_variable_get(name)
			if(var.__id__ == id)
				return [name]
			end
		}
		instance_variables.each { |name|
			var = instance_variable_get(name)
			if(path = var.obj_path(id, obj_path_id))
				path.unshift(name)
				return path
			end
		}
		nil
	end
end
class Array
	def obj_path(id, obj_path_id=nil)
		super or begin
			each_with_index { |item, idx|
				if(item.__id__ == id)
					return [idx]
				elsif(path = item.obj_path(id, obj_path_id))
					path.unshift(idx)
					return path
				end
			}
			nil
		end
	end
end
class Hash
	def obj_path(id, obj_path_id=nil)
		super or begin
			each { |key, item|
				if(item.__id__ == id)
					return [key]
				elsif(key.__id__ == id)
					return ["hash-key"]
				elsif(path = item.obj_path(id, obj_path_id))
					path.unshift(key)
					return path
				end
			}
			nil
		end
	end
end


module ODDB
	module FiPDF
		class FachinfoWriter < PDF::EZWriter
			ALPHA_GAP = 5
			ALPHA_FONT = "Helvetica-Bold"
			COLOR_DRUG_NAME_BG = {
				:generic => [0.168, 0.640, 0.461], 
				:original => [1, 0, 0],
				:unknown => [0.667, 0.667, 0.667],
			}
			COLOR_DRUG_NAME_INDEX = {
				:generic => [0, 0.4 , 0], 
				:original => [1, 0, 0],
				:unknown => [0, 0, 0],
			}
			COLOR_DRUG_NAME_FNT = {
				:generic => [1, 1, 1],
				:original => [1, 1, 1],
				:unknown => [0, 0, 0],
			}
			COLOR_BG = {
				:generic => [0.635, 1, 0.627], 
				:original => [1, 0.700, 0.700],
				:unknown => [1, 1, 1],
			}
			COLOR_STD = [0, 0, 0]
			COLUMNS_FI = 3
			COLUMNS_INDEX = 4
			COLUMN_GAP_FI = 10
			COLUMN_GAP_INDEX = 10
			FIXED_WIDTH_FONT = "Courier"
			FLIC_YPOS = 825
			FONT_SIZE_ALPHA = 16
			FONT_SIZE_FLIC = 10
			FONT_SIZE_FIXED_WIDTH = 5.3
			FONT_SIZE_TITLE = 14
			GRAY_DRUG_NAME_BG = {
				:generic => [0.7, 0.7, 0.7], 
				:original => [0, 0, 0],
				:unknown => [0.3, 0.3, 0.3],
			}
			ISO_8859_1_DIFFERENCES = {
				160	=>	'space',
				164	=>	'currency',										214	=>	'Odieresis',
				166	=>	'brokenbar',          				215	=>	'multiply',
				168	=>	'dieresis',           				216	=>	'Oslash',
				169	=>	'copyright',          				217	=>	'Ugrave',
				170	=>	'ordfeminine',        				218	=>	'Uacute',
				172	=>	'logicalnot',         				219	=>	'Ucircumflex',
				173	=>	'endash',             				220	=>	'Udieresis',
				174	=>	'registered',         				221	=>	'Yacute',
				175	=>	'macron',             				222	=>	'Thorn',
				176	=>	'degree',             				223	=>	'germandbls',
				177	=>	'plusminus',          				224	=>	'agrave',
				178	=>	'twosuperior',        				225	=>	'aacute',
				179	=>	'threesuperior',      				226	=>	'acircumflex',
				180	=>	'acute',              				227	=>	'atilde',
				181	=>	'mu',                 				228	=>	'adieresis',
				184	=>	'cedilla',            				229	=>	'aring',
				185	=>	'onesuperior',        				230	=>	'ae',
				186	=>	'ordmasculine',       				231	=>	'ccedilla',
				188	=>	'onequarter',         				232	=>	'egrave',
				189	=>	'onehalf',            				233	=>	'eacute',
				190	=>	'threequarters',      				234	=>	'ecircumflex',
				192	=>	'Agrave',             				235	=>	'edieresis',
				193	=>	'Aacute',             				236	=>	'igrave',
				194	=>	'Acircumflex',        				237	=>	'iacute',
				195	=>	'Atilde',             				238	=>	'icircumflex',
				196	=>	'Adieresis',          				239	=>	'idieresis',
				197	=>	'Aring',              				240	=>	'eth',
				198	=>	'AE',                 				241	=>	'ntilde',
				199	=>	'Ccedilla',           				242	=>	'ograve',
				200	=>	'Egrave',             				243	=>	'oacute',
				201	=>	'Eacute',             				244	=>	'ocircumflex',
				202	=>	'Ecircumflex',        				245	=>	'otilde',
				203	=>	'Edieresis',          				246	=>	'odieresis',
				204	=>	'Igrave',             				247	=>	'divide',
				205	=>	'Iacute',             				248	=>	'oslash',
				206	=>	'Icircumflex',        				249	=>	'ugrave',
				207	=>	'Idieresis',          				250	=>	'uacute',
				208	=>	'Eth',                				251	=>	'ucircumflex',
				209	=>	'Ntilde',             				252	=>	'udieresis',
				210	=>	'Ograve',             				253	=>	'yacute',
				211	=>	'Oacute',             				254	=>	'thorn',
				212	=>	'Ocircumflex',        				255	=>	'ydieresis',
				213	=>	'Otilde',
			}
			MARGIN_BOTTOM = 20 
			MARGIN_IN = 40
			MARGIN_OUT = 30
			MARGIN_TOP = 20
			PAGE_NUMBER_SIZE = 8
			PAGE_NUMBER_YPOS = 10
			PAGE_TITLE_HEIGHT = 20
			VARIABLE_WIDTH_FONT = "Helvetica"
			def initialize(paper = "A4", orientation = :portrait, color = true)
				super(paper, orientation)
				@text_space_height = @ez[:pageHeight] - MARGIN_TOP - MARGIN_BOTTOM
				@colored_output = color
				@current_generic_type = :unknown
				@flic_name = ""
				@anchor = 0
				@enforce_line_count = 0 
				@substance_index = SubstanceIndex.new
				# prepare basefonts (load them including differences)
				select_font(ALPHA_FONT, 
					:differences => ISO_8859_1_DIFFERENCES)
				select_font(FIXED_WIDTH_FONT, 
					:differences => ISO_8859_1_DIFFERENCES)
				select_font(VARIABLE_WIDTH_FONT, 
					:differences => ISO_8859_1_DIFFERENCES)
				initialize_formats
			end
			def add_substance_name(fachinfo)
				value = [
					fachinfo.name, 
					fachinfo.company_name,
					@fi_page_number, 
					fachinfo.generic_type, 
					fachinfo.substance_names.size, 
					anchor_name(@anchor)
				]
				fachinfo.substance_names.each { |substance|
					@substance_index.store(substance, value)
				}
				@substance_index
			end
			def add_text_wrap(*args)
				rest = super
				@first_line_of_page = false
				@enforce_line_count += 1
				if(@enforce_page_break == @enforce_line_count)
					ez_new_page
				end
				rest
			end
			def anchor_name(num)
				"anchor" + num.to_s
			end
			def draw_background(color_map = COLOR_BG)
				select_layer(1)
				save_state
				set_color(generic_color(@current_generic_type, color_map))
				#set_color(PDF::Color.new(*COLOR_BG[@current_generic_type]))
				filled_rectangle(*@bg_bounds)
				restore_state
				select_layer(0)
			end
			def draw_column_line
				xpos = @ez[:leftMargin] - (@column_gap / 2)
				y2pos = @ez[:pageHeight] - @margin_top_column
				set_line_style(0.1, :round) 
				line(xpos, MARGIN_BOTTOM, xpos, y2pos)
			end
			def draw_page_title(title)
				select_layer(1)
				save_state
				set_color(PDF::Color.new(0, 0, 0))
				xpos = @ez[:leftMargin]
				ypos = @ez[:pageHeight] - MARGIN_TOP - PAGE_TITLE_HEIGHT
				width = @ez[:pageWidth] - MARGIN_IN - MARGIN_OUT
				filled_rectangle(xpos, ypos, width, PAGE_TITLE_HEIGHT)
				restore_state
				select_layer(0)
				set_color(PDF::Color.new(1, 1, 1))
				y_text_pos =  @ez[:pageHeight] - PAGE_TITLE_HEIGHT - get_font_height(FONT_SIZE_TITLE)
				add_text(xpos, y_text_pos, FONT_SIZE_TITLE, title)
				set_color(PDF::Color.new(0, 0, 0))
				@first_line_of_page = true
			end
			def ez_new_page
				if(@colored_output)
					@bg_bounds[3] = @ez[:bottomMargin] - @bg_bounds[1]
					draw_background
				end
				if(super)
					fi_new_page
				else
					fi_new_column
				end
			end
			def ez_set_dy(*args)
				unless @first_line_of_page
					super 
				end
			end
			def fi_new_column
				if(@colored_output)
					set_bg_bounds
				end
				draw_column_line
				@first_line_of_page = true
			end
			def fi_new_page
				@fi_page_number ||= 0
				@fi_page_number += 1
				unless(@page_element_type)
					set_page_element_type(:page_type_standard)
				end
				set_page_type_elements
				@current_width = @ez[:columns][:width]
				@first_line_of_page = true
				@blank_flic_name = true
			end
			def generic_color(generic_type=:unknown, color_map=COLOR_BG)
				PDF::Color.new(*(color_map[generic_type] \
					|| color_map[:unknown] \
					|| COLOR_BG[:unknown]))
			end
			def initialize_formats
				@formats = {}	
				@formats[:drug_name] = drug_name_format
				@formats[:company_name] = company_name_format
				@formats[:chapter] = chapter_format
				@formats[:flic_name] = flic_name_format
				@formats[:section] = section_format
				@formats[:paragraph] = paragraph_format
				@formats[:preformatted] = preformatted_format
				@formats[:chapter_index] = chapter_index_format
				@formats[:kombi_index] = kombi_index_format
				@formats[:text_index] = text_index_format
			end
			def drug_name_format
				format = Format.new
				format.spacing_before = -8
				format.size = 10
				format.margin = 3
				format.font = VARIABLE_WIDTH_FONT
				format
			end
			def company_name_format
				format = Format.new
				format.spacing_before = -1
				format.size = 7
				format.font = VARIABLE_WIDTH_FONT
				format.justification = :right
				format
			end
			def chapter_format
				format = Format.new
				format.spacing_before = -4
				format.size = 7
				format.font = VARIABLE_WIDTH_FONT
				format
			end
			def flic_name_format
				format = Format.new
				format.ypos = 825
				format.size = 10
				format.font = VARIABLE_WIDTH_FONT
				format
			end
			def section_format
				format = Format.new
				format.spacing_before = -1.5
				format.size = 7
				format.font = VARIABLE_WIDTH_FONT
				format
			end
			def paragraph_format
				format = Format.new
				format.spacing_before = -0.5
				#format.spacing_after = -0.5
				format.size = 7
				format.font = VARIABLE_WIDTH_FONT
				format.justification = :full
				format
			end
			def preformatted_format
				format = Format.new
				format.spacing_before = -2.5
				format.spacing_after = -2.5
				format.size = 5.3
				format.font = FIXED_WIDTH_FONT
				format.justification = :left
				format
			end
			def chapter_index_format
				format = Format.new
				format.spacing_before = -3
				format.size = 7
				format.font = VARIABLE_WIDTH_FONT 
				format
			end
			def kombi_index_format
				format = Format.new
				format.spacing_before = -0.5
				format.size = 6
				format.font = VARIABLE_WIDTH_FONT 
				format
			end
			def text_index_format
				format = Format.new
				format.spacing_before = -0.5
				format.size = 5.5 
				format.justification = :left
				format.font = VARIABLE_WIDTH_FONT 
				format
			end
			def new_page(*args)
				write_last_minute
				super(*args)
			end
			def page_type(num = @fi_page_number)
				((num.to_i % 2) == 0) ? :even : :odd
			end
			def page_type_standard
				@columns = COLUMNS_FI
				@column_gap = COLUMN_GAP_FI
				@write_alphabet = true
				@write_flic_name = true
				ez_columns_stop()
				set_color(PDF::Color.new(*COLOR_STD))
				ptype = page_type
				set_ptype_margins(ptype)
				@y = @ez[:pageHeight] - @ez[:topMargin]
				@margin_top_column = MARGIN_TOP
				write_page_number(@fi_page_number, ptype)
				ez_columns_start(:num => @columns, 
					:gap => @column_gap)
				if(@colored_output)
					set_bg_bounds
				end
			end
			def page_type_substance_title
				ez_columns_stop()
				set_color(PDF::Color.new(*COLOR_STD))
				ptype = page_type
				set_ptype_margins(ptype)
				@y = @ez[:pageHeight] - @ez[:topMargin] - 30
				@margin_top_column = MARGIN_TOP + 30
				@column_gap = COLUMN_GAP_INDEX
				@columns	= COLUMNS_INDEX
				@write_alphabet = false
				@write_flic_name = false
				ez_columns_start(:num => @columns, 
					:gap => @column_gap)
				if(@colored_output)
					set_bg_bounds
				end
			end
			def page_type_substance_index
				ez_columns_stop()
				set_color(PDF::Color.new(*COLOR_STD))
				ptype = page_type
				set_ptype_margins(ptype)
				@y = @ez[:pageHeight] - @ez[:topMargin]
				@margin_top_column = MARGIN_TOP
				@column_gap = COLUMN_GAP_INDEX
				@columns	= COLUMNS_INDEX
				@write_alphabet = false
				@write_flic_name = false
				ez_columns_start(:num => @columns, 
					:gap => @column_gap)
				write_flic_name
				if(@colored_output)
					set_bg_bounds
				end
			end
			def set_page_element_type(symbol)
				@page_element_type = symbol
			end
			def set_bg_bounds(xpos=nil, ypos=nil, width=nil, height=nil)
				@bg_bounds ||= []
				xpos ||= @ez[:leftMargin] - (@column_gap / 2)
				ypos ||= @y
				width ||= @ez[:pageWidth] - @ez[:rightMargin] \
					- xpos + (@column_gap / 2)
				height ||= @y - @ez[:bottomMargin]
				@bg_bounds[0] = xpos 
				@bg_bounds[1] = ypos
				@bg_bounds[2] = width
				@bg_bounds[3] = height
			end
			def set_ptype_margins(ptype)
				side_margins = [
					MARGIN_IN, # left on odd pages
					MARGIN_OUT,  # right on odd pages
				]
				if(ptype == :even)
					side_margins.reverse!
				end
				ez_set_margins(MARGIN_TOP, 
					MARGIN_BOTTOM, *side_margins)
			end
			def set_page_type_elements
				self.send(@page_element_type)
			end
=begin
			def typographic_line_break_index(y_pos)
				if(@y < y_pos)
					@ez[:insertOptions][:id] = @first_page
					@ez[:insertOptions][:pos] = :before
					ez_new_page			
				end
			end
=end
			def write_alphabet
				save_state
				letter = @flic_name[0,1].upcase
				# scope: define num outside of if-block
				num = 0
				if(("A".."Z").include?(letter))
					# 26 letters plus "*" for others
					# "A"[0] == 65
					# num("A") == 27
					# num("Z") == 1
					# num("*") == 0
					num = (26 + 65) - letter[0]
				else
					# "*" for others 
					letter = "*"
				end
				height = @text_space_height / 27.0 
				ypos = MARGIN_BOTTOM + num * height
				width = MARGIN_OUT - ALPHA_GAP
				xpos = @ez[:pageWidth] - width
				select_layer(1)
				set_color(PDF::Color.new(0,0,0))
				filled_rectangle(xpos, ypos, width, height - ALPHA_GAP / 2)
				select_layer(0)
				set_color(PDF::Color.new(1,1,1))
				size = FONT_SIZE_ALPHA
				offset = (height - get_font_height(size) - \
					get_font_descender(size)) / 2
				xpos = @ez[:pageWidth] - \
					(get_text_width(size, letter) + width) / 2
				select_font(ALPHA_FONT)
				add_text(xpos, ypos + offset, size, letter)
				restore_state
			end
			def write_chapter(chapter)
				if(chapter.need_new_page?((@y - MARGIN_BOTTOM), @current_width, @formats))
					ez_new_page
				end
				write_heading(chapter)
				chapter.each_section { |section_wrapper|
					write_section(section_wrapper)
				}
			end
			def write_company_name(name)
				format = @formats[:company_name]
				if(name.nil?)
					name = ""
				end
				ez_set_dy(format.spacing_before(name))
				ez_text(name, format.size, :justification => format.justification)
			end
			def write_drug_name(fachinfo_name)
				format = @formats[:drug_name]
				add_destination(anchor_name(@anchor), "XYZ",
					@ez[:leftMargin],@y,0)
				ez_set_dy(format.spacing_before(fachinfo_name))
				y1 = @y
				set_color(generic_color(@current_generic_type, COLOR_DRUG_NAME_FNT))
				ez_text(fachinfo_name, format.size)
				ez_set_dy(-format.margin)
				# positions also matter for background
				set_bg_bounds(nil, @y, nil, y1 - @y)
				map = (@colored_output) ? COLOR_DRUG_NAME_BG : GRAY_DRUG_NAME_BG
				name = CGI.escape(fachinfo_name[3..-1][/[^<®\ ]+/])
				url = "http://www.oddb.org/de/gcc/search/search_query/#{name}"
				add_link(url, @bg_bounds.at(0), @bg_bounds.at(1),
					@bg_bounds.at(0) + @bg_bounds.at(2),
					@bg_bounds.at(1) + @bg_bounds.at(3), 'P')
				draw_background(map)
				set_bg_bounds(nil, @y)
				set_color(PDF::Color.new(*COLOR_STD))
			end
			def write_heading(chapter)
				format = @formats[:chapter]
				if(chapter.heading != "")
					#save_state
					select_font(format.font)
					ez_set_dy(format.spacing_before(chapter.heading))
					puts chapter.heading
					ez_text("<b>" << chapter.heading << "</b>", format.size)
					#restore_state
				end
			end
			def write_fachinfo(fachinfo)
				if(@fi_page_number.nil?)
					fi_new_page
				end
				puts fachinfo.name
				fachinfo_wrapper = FachinfoWrapper.new(fachinfo)
				if(fachinfo_wrapper.need_new_page?((@y - MARGIN_BOTTOM),  @current_width, @formats))
					ez_new_page
				end
				@anchor += 1
				add_substance_name(fachinfo)
				set_flic_name(fachinfo.name)
				@current_generic_type = fachinfo_wrapper.generic_type
				if(@colored_output)
					set_bg_bounds
				end
				write_drug_name(fachinfo_wrapper.name)
				write_company_name(fachinfo_wrapper.company_name)
				fachinfo_wrapper.each_chapter { |chapter_wrapper|
					write_chapter(chapter_wrapper)
				}
				@bg_bounds[3] = @y - @bg_bounds.at(1) + @formats[:drug_name].spacing_before(fachinfo_wrapper.name)
				if(@colored_output)
					draw_background
				end
				ez_cache_completed_pages
			end
			def write_flic_name
				format = @formats[:flic_name]
				save_state
				select_font(format.font)
				write_outside_bound_text(format.ypos, format.size, @flic_name, page_type)
				restore_state
			end
			def write_last_minute
				if(@write_flic_name == true)
					write_flic_name
				end
				if(page_type == :odd && @write_alphabet == true)
					write_alphabet
				end
			end
			def set_flic_name(fachinfo_name)
				if(page_type == :odd)
					@flic_name = fachinfo_name
				elsif(@blank_flic_name)
					@flic_name = fachinfo_name
					@blank_flic_name = false
				end
			end
			def write_outside_bound_text(ypos, size, txt, ptype)
				xpos = if(ptype == :even)
					MARGIN_OUT
				else
					tw = get_text_width(size, txt)
					@ez[:pageWidth] - MARGIN_OUT - tw
				end
				add_text(xpos, ypos, size, txt)
			end
			def write_page_number(number = 1, ptype = nil)
				save_state
				ptype ||= page_type(number)
				select_font(VARIABLE_WIDTH_FONT)
				write_outside_bound_text(PAGE_NUMBER_YPOS, 
					PAGE_NUMBER_SIZE, number.to_s, ptype)
				restore_state
			end
			def write_paragraph(paragraph)
				format = if(paragraph.preformatted?)
					@formats[:preformatted]
				else
					@formats[:paragraph]
				end
				available_height = @y - MARGIN_BOTTOM
				if(paragraph.need_new_page?(available_height, @current_width, @formats))
					ez_new_page
					available_height = @y - MARGIN_BOTTOM
				end
				unless(@first_line_of_page)
					available_height += format.spacing_before(paragraph.text)
				end
				column_height = @ez[:pageHeight] - MARGIN_BOTTOM - MARGIN_TOP
				@enforce_line_count = 0 
				@enforce_page_break = paragraph.enforce_page_break?(available_height, column_height, @current_width, format)
				#save_state
				previous_font = @current_font
				select_font(format.font)
				ez_set_dy(format.spacing_before(paragraph.text))
				text = paragraph.text
				paragraph.text.each_line { |line|
					ez_text(line, format.size, :justification => format.justification)
				}
				select_font(previous_font)
				#restore_state
			end
			def write_section(section)
				format = @formats[:section]
				if(section.need_new_page?(@y - MARGIN_BOTTOM, @current_width, @formats))
					ez_new_page
				end
				subheading = section.subheading
				ez_set_dy(format.spacing_before(subheading))
				ez_text(section.subheading, format.size)
				section.each_paragraph { |paragraph_wrapper|
					write_paragraph(paragraph_wrapper)
				}
			end
			def prepare_substance_index
				#prepend a new page
				@ezPages.unshift(new_page(true, @first_page, :before))
				set_page_element_type(:page_type_substance_title)
				set_page_type_elements
				ez_insert_mode(true, 0, :after)
				@fi_page_number = 0
				fi_new_page
				@ez[:insertOptions][:id] = @first_page
				@ez[:insertOptions][:pos] = :before
				@ez[:columns][:colNum] = 1
				select_font(VARIABLE_WIDTH_FONT)
				draw_page_title("<b> WIRKSTOFFREGISTER </b>")
			end
			def write_substance_index
				prepare_substance_index
				set_page_element_type(:page_type_substance_index)
				@flic_name = "Wirkstoffregister"
				write_index
			end
			def write_index
				@substance_index.sort.each { |substance, tuples|
					singles = single_substances(tuples)
					combinations = combination_substances(tuples)
					first = unless(singles.empty?)
						singles.first	
					else
						combinations.first
					end
					unless(first.nil?)
						write_index_entry(substance, singles,\
							combinations, first)
					end
				}
			end
			def write_index_entry(substance, singles, combinations, first)
				format_chapter = @formats[:chapter_index]
				format_kombi = @formats[:kombi_index]
				format_text = @formats[:text_index]
				formats = {
					:paragraph	=>	format_text,
				}
				bsubstance = "<b>" << substance << "</b>"
				para = wrap_tuple(first)
				height = @y - @ez[:bottomMargin] \
					- format_chapter.get_height(bsubstance, @current_width) - format_kombi.get_height("fo", @current_width)
				if(para.need_new_page?(height, @current_width, formats))
					ez_new_page
				end
				link_y = nil
				ez_set_dy(format_chapter.spacing_before(bsubstance))
				if((singles.size \
					+ combinations.size) == 1)
					link_y = @y
				end
				ez_text(bsubstance, format_chapter.size, 
					:justification => format_chapter.justification)
				singles.each{ |tuple|
					write_tuple(tuple, link_y)
					link_y = nil
				}
				unless(combinations.empty?)
					para = wrap_tuple(combinations.first)
					fmt_str = "<i>Kombinationen</i>"
					height = @y - @ez[:bottomMargin] \
					- format_kombi.get_height(fmt_str, @current_width)
					if(para.need_new_page?(height, @current_width, formats))
						ez_new_page
					end
					ez_set_dy(format_kombi.spacing_before(fmt_str))
					ez_text(fmt_str, format_kombi.size,
						:justification => format_kombi.justification)
					combinations.each{ |tuple|
						write_tuple(tuple, link_y)
						link_y = nil
					}
				end
			end
			def combination_substances(tuples)
				tuples.select { |tuple|
					#max number of combination substances we want in 
					#the index
					(tuple[4].to_i > 1) && (tuple[4].to_i < 6)
					
				}.compact
			end
			def single_substances(tuples)
				tuples.select { |tuple|
					#only one substance in the single substance array
					tuple[4].to_i == 1
				}.compact
			end
			def hyphenator=(hyphenator)
				@hyphenator = hyphenator
				@formats.each_value { |format|
					format.writer.hyphenator = @hyphenator
				}
				@hyphenator
			end
			def wrap_tuple(tuple)
				paragraph = ODDB::Text::Paragraph.new
				paragraph << tuple.at(0).to_s
				paragraph << " ("
				paragraph << tuple.at(2).to_s
				paragraph << ")\n"
				paragraph.set_format(:italic)
				paragraph << tuple.at(1)
				ParagraphWrapper.new(paragraph)
			end
			def write_tuple(tuple, link_y = nil)
				format = @formats[:text_index]
				generic_type = tuple.at(3)
				anchor = tuple.at(5)
				para = wrap_tuple(tuple)
				formats = {
					:paragraph	=>	format,
				}
				height = @y - @ez[:bottomMargin]
				# these two lines are important
				# the insert mode must be reset for every tuple
				# otherwise new pages won't be added to the page index
				# and will not display in the reader
					@ez[:insertOptions][:id] = @first_page
					@ez[:insertOptions][:pos] = :before
				if(para.need_new_page?(height, @current_width, formats))
					ez_new_page
				end
				if(link_y.nil?)
					link_y = @y
				end
				format = @formats[:text_index]
				set_color(generic_color(generic_type.intern, COLOR_DRUG_NAME_INDEX ))
				ez_text(para.text, format.size, :justification => format.justification)
=begin
				medic_name, company_name, 
				page_number, generic_type, combination, anchor = tuple
				set_color(generic_color(generic_type.intern, COLOR_DRUG_NAME_INDEX ))
				output_name = " " + medic_name.to_s + "  ("+page_number.to_s + ")"
				output_company = "<i>"+"  "+ company_name.to_s + "</i>"
				y_pos = (@ez[:bottomMargin] \
					+ format.get_height(output_name, \
					@current_width) \
					+ format.get_height(output_company, \
					@current_width))
					typographic_line_break_index(y_pos)
				ez_text(output_name,
					format.size, :justification => format.justification)
				ez_text(output_company, format.size, :justification => format.justification)
=end
				add_internal_link(anchor.to_s, @ez[:leftMargin] \
					, link_y, @ez[:leftMargin] + @current_width, @y \
					+ get_font_descender(format.size))
				set_color(PDF::Color.new(*COLOR_STD))
			end
		end
	end
end
