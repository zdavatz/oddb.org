#!/usr/bin/env ruby
#encoding : utf-8
#FachinfoWriter -- oddb -- 02.02.2004 -- mwalder@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.dirname(__FILE__)

require 'pdf/writer'
require 'model/text'
require 'util/searchterms'
require 'substance_index'
require 'format'
require 'fachinfo_wrapper'
require 'cgi'
require 'RMagick'


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
		class FachinfoWriter < PDF::Writer
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
      SYMBOL_FONT = 'Symbol'
      LANGUAGES = {
        :de => {
          :combinations    => 'Kombinationen',
          :substance_index => 'Wirkstoffregister',
        },
        :fr => {
          :combinations    => 'Combinations',
          :substance_index => 'Registre de substances actives',
        },
      }
			def initialize opts = {}
        @opts = {:color => true, :language => :de}.update(opts)
				super(:paper => 'A4', :orientation => :portrait)
        @black = Color::RGB.from_fraction(0, 0, 0)
        @white = Color::RGB.from_fraction(1, 1, 1)
        @color = Color::RGB.from_fraction(*COLOR_STD)
				@text_space_height = @page_height - MARGIN_TOP - MARGIN_BOTTOM
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
				select_font(SYMBOL_FONT, 
					:differences => ISO_8859_1_DIFFERENCES)
				select_font(VARIABLE_WIDTH_FONT, 
					:differences => ISO_8859_1_DIFFERENCES)
				initialize_formats
			end
      def _ key
        LANGUAGES[@opts[:language]][key]
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
			def add_text_wrap(left, y, width, text, *args)
        text.gsub!(/\302\255/u, '')
				rest = super(@left_margin, y, width, text, *args)
				@first_line_of_page = false
				@enforce_line_count += 1
				if(@enforce_page_break == @enforce_line_count)
					start_new_page
				end
				rest
			end
			def anchor_name(num)
				"anchor" + num.to_s
			end
			def draw_background(color_map = COLOR_BG)
				return if @page_element_type == :page_type_substance_title
        color = generic_color(@current_generic_type, color_map)
        save_state
        fill_color color
        rectangle(*@bg_bounds).fill
        restore_state
			end
			def draw_column_line
				save_state
				xpos = @left_margin - (@column_gap / 2)
				y2pos = @page_height - @margin_top_column
				stroke_style StrokeStyle.new(0.1, :cap => :round) 
				stroke_color(Color::RGB.from_fraction(0, 0, 0))
				line(xpos, MARGIN_BOTTOM, xpos, y2pos).stroke
				restore_state
			end
			def draw_page_title(title)
				save_state
				fill_color @black
				xpos = @left_margin
				ypos = @page_height - MARGIN_TOP - PAGE_TITLE_HEIGHT
				width = @page_width - MARGIN_IN - MARGIN_OUT
				rectangle(xpos, ypos, width, PAGE_TITLE_HEIGHT).fill
				restore_state
				fill_color @white
        y_text_pos =  @page_height - PAGE_TITLE_HEIGHT - font_height(FONT_SIZE_TITLE)
				add_text(xpos, y_text_pos, title, FONT_SIZE_TITLE)
				fill_color @black
				@first_line_of_page = true
			end
      def encrypted?
        false
      end
			def start_new_page(force=false)
        draw_column_line if column_number > 1
        num_pages = @pageset.size
				super
        if @pageset.size > num_pages
					fi_new_page
				else
					fi_new_column
				end
				if(@opts[:color])
					#@bg_bounds[3] = @bottom_margin - @bg_bounds[1]
          set_bg_bounds
					draw_background
				end
			end
			def move_pointer(dy, *args)
				unless @first_line_of_page
					super -dy, *args
				end
			end
			def fi_new_column
				if(@opts[:color])
					set_bg_bounds
				end
				@first_line_of_page = true
			end
			def fi_new_page
				@fi_page_number ||= 0
				@fi_page_number += 1
				unless(@page_element_type)
					set_page_element_type(:page_type_standard)
				end
				set_page_type_elements
				@current_width = column_width
				@first_line_of_page = true
				@blank_flic_name = true
			end
			def generic_color(generic_type=:unknown, color_map=COLOR_BG)
				Color::RGB.from_fraction(*(color_map[generic_type] \
					|| color_map[:unknown] \
					|| COLOR_BG[:unknown]))
			end
      def hyphenator=(hyphenator)
        @formats.each_value { |fmt| fmt.writer.hyphenator = hyphenator }
        @hyphenator = hyphenator
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
        @formats.each_value { |fmt|
          @fonts.each_key { |font| 
            fmt.writer.select_font font, :differences => ISO_8859_1_DIFFERENCES
          }
        }
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
				format.spacing_before = -5
				format.spacing_after = -1
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
				format.spacing_before = -2.5
				format.spacing_after = -1
				format.size = 7
				format.font = VARIABLE_WIDTH_FONT
				format
			end
			def paragraph_format
				format = Format.new
				format.spacing_before = -1
				#format.spacing_after = -0.5
				format.size = 7
				format.font = VARIABLE_WIDTH_FONT
				format.justification = :full
				format
			end
			def preformatted_format
				format = Format.new
				format.spacing_before = -3
				format.spacing_after = -3
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
				format.spacing_before = -1
				format.size = 6
				format.font = VARIABLE_WIDTH_FONT 
				format
			end
			def text_index_format
				format = Format.new
				format.spacing_before = -1
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
				@target_columns = COLUMNS_FI
				@column_gap = COLUMN_GAP_FI
				@write_alphabet = true
				@write_flic_name = true
				stop_columns()
				fill_color @color
				ptype = page_type
				set_ptype_margins(ptype)
				@y = @page_height - @top_margin
				@margin_top_column = MARGIN_TOP
				write_page_number(@fi_page_number, ptype)
				start_columns(@target_columns, @column_gap)
				if(@opts[:color])
					set_bg_bounds
				end
			end
			def page_type_substance_title
				stop_columns()
				fill_color @color
				ptype = page_type
				set_ptype_margins(ptype)
				@y = @page_height - @top_margin - 30
				@margin_top_column = MARGIN_TOP + 30
				@column_gap = COLUMN_GAP_INDEX
				@target_columns	= COLUMNS_INDEX
				@write_alphabet = false
				@write_flic_name = false
				start_columns(@target_columns, @column_gap)
				if(@opts[:color])
					set_bg_bounds
				end
			end
			def page_type_substance_index
				stop_columns()
				fill_color @color
				ptype = page_type
				set_ptype_margins(ptype)
				@y = @page_height - @top_margin
				@margin_top_column = MARGIN_TOP
				@column_gap = COLUMN_GAP_INDEX
				@target_columns	= COLUMNS_INDEX
				@write_alphabet = false
				@write_flic_name = false
				start_columns(@target_columns, @column_gap)
				write_flic_name
				if(@opts[:color])
					set_bg_bounds
				end
			end
			def set_page_element_type(symbol)
				@page_element_type = symbol
			end
			def set_bg_bounds(xpos=nil, ypos=nil, width=nil, height=nil)
				@bg_bounds ||= []
				xpos ||= @left_margin - (@column_gap / 2)
				ypos ||= @bottom_margin
				width ||= @page_width - @right_margin \
					- xpos + (@column_gap / 2)
				height ||= @y - @bottom_margin
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
        left, right = side_margins
				margins_pt(MARGIN_TOP, left, MARGIN_BOTTOM, right)
			end
			def set_page_type_elements
				self.send(@page_element_type)
			end
=begin
			def typographic_line_break_index(y_pos)
				if(@y < y_pos)
					@ez[:insertOptions][:id] = @first_page
					@ez[:insertOptions][:pos] = :before
					start_new_page			
				end
			end
=end
			def write_alphabet
				save_state
				letter = ODDB.search_term(@flic_name[0,1]).upcase
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
				xpos = @page_width - width
		#		select_layer(1)
        fill_color @black
				rectangle(xpos, ypos, width, height - ALPHA_GAP / 2).fill
		#		select_layer(0)
				fill_color @white
				size = FONT_SIZE_ALPHA
				offset = (height - font_height(size) - \
					font_descender(size)) / 2
				xpos = @page_width - \
					(text_width(letter, size) + width) / 2
        previous = @current_font
				select_font(ALPHA_FONT)
				add_text(xpos, ypos + offset, letter, size)
				restore_state
				select_font(previous)
			end
			def write_chapter(chapter)
				if(chapter.need_new_page?((@y - MARGIN_BOTTOM), @current_width, @formats))
					start_new_page
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
				move_pointer(format.spacing_before(name))
				if(@opts[:color])
					set_bg_bounds
					draw_background
				end
				text(name, :font_size => format.size, 
                   :justification => format.justification)
				move_pointer(format.spacing_after(name))
			end
			def write_drug_name(fachinfo_name)
				format = @formats[:drug_name]
				add_destination(anchor_name(@anchor), "XYZ",
					@left_margin,@y,0)
				move_pointer(format.spacing_before(fachinfo_name))
        height = format.get_height(fachinfo_name, @current_width) - format.margin
				set_bg_bounds(nil, @y - height, nil, height)
				map = (@opts[:color]) ? COLOR_DRUG_NAME_BG : GRAY_DRUG_NAME_BG
				draw_background(map)
        color = generic_color(@current_generic_type, COLOR_DRUG_NAME_FNT)
				fill_color color
				text(fachinfo_name, :font_size => format.size)
				move_pointer(-format.margin)
				name = CGI.escape(fachinfo_name[3..-1][/[^<®\ ]+/u])
				url = "http://www.oddb.org/de/gcc/search/search_query/#{name}"
				add_link(url, @bg_bounds.at(0), @bg_bounds.at(1),
					@bg_bounds.at(0) + @bg_bounds.at(2),
					@bg_bounds.at(1) + @bg_bounds.at(3))
				#set_bg_bounds(nil, @y)
				move_pointer(format.spacing_after(fachinfo_name))
				fill_color @color
			end
			def write_heading(chapter)
				format = @formats[:chapter]
        heading = chapter.heading
				if(heading != "")
					#save_state
					select_font(format.font)
					move_pointer(format.spacing_before(heading))
					text("<b>" << chapter.heading << "</b>", :font_size => format.size)
				  move_pointer(format.spacing_after(heading))
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
					start_new_page
				end
				@anchor += 1
				add_substance_name(fachinfo)
				set_flic_name(fachinfo.name)
				@current_generic_type = fachinfo_wrapper.generic_type
				write_drug_name(fachinfo_wrapper.name)
				write_company_name(fachinfo_wrapper.company_name)
				fachinfo_wrapper.each_chapter { |chapter_wrapper|
					write_chapter(chapter_wrapper)
				}
				@bg_bounds[3] = @y - @bg_bounds.at(1) + @formats[:drug_name].spacing_before(fachinfo_wrapper.name)
			end
			def write_flic_name
				format = @formats[:flic_name]
				save_state
        previous = @current_font
				select_font(format.font)
				write_outside_bound_text(format.ypos, format.size, @flic_name, page_type)
				restore_state
				select_font(previous)
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
					tw = text_width(txt, size)
					@page_width - MARGIN_OUT - tw
				end
				add_text(xpos, ypos, txt, size)
			end
			def write_page_number(number = 1, ptype = nil)
				save_state
				ptype ||= page_type(number)
        previous = @current_font
				select_font(VARIABLE_WIDTH_FONT)
				write_outside_bound_text(PAGE_NUMBER_YPOS, 
					PAGE_NUMBER_SIZE, number.to_s, ptype)
				restore_state
        select_font previous
			end
			def write_paragraph(paragraph)
				format = if(paragraph.preformatted?)
					@formats[:preformatted]
				else
					@formats[:paragraph]
				end
        paragraph.hyphenator = @hyphenator
				available_height = @y - MARGIN_BOTTOM
				if(paragraph.need_new_page?(available_height, @current_width, @formats))
					start_new_page
					available_height = @y - MARGIN_BOTTOM
				end
				unless(@first_line_of_page)
					available_height += format.spacing_before(paragraph.text)
				end
				column_height = @page_height - MARGIN_BOTTOM - MARGIN_TOP
				@enforce_line_count = 0 
				@enforce_page_break = paragraph.enforce_page_break?(available_height, 
                                                            @text_space_height,
                                                            @current_width,
                                                            format)
				#save_state
				previous_font = @current_base_font
				select_font(format.font)
        if paragraph.image?
          path = File.join(PROJECT_ROOT, 'doc', paragraph.src)
          if File.exist?(path)
            data = File.read(path)
            img, = Magick::Image.from_blob(data) do |info|
              info.size = size
            end
            size = "#{@current_width}x"
            data = img.to_blob do |info|
              info.depth = 8
            end
            height = @current_width * img.rows / img.columns
            move_pointer(-height)
            move_pointer(format.spacing_before(paragraph.text))
            add_image data, @left_margin, @y, @current_width
          end
        else
          move_pointer(format.spacing_before(paragraph.text))
          text = paragraph.text
          paragraph.text.each_line { |line|
            if paragraph.preformatted? && /^-{53,}/u.match(line)
              line = line[0,52]
            end
            text(line.rstrip, :font_size => format.size,
                              :justification => format.justification)
          }
        end
        #restore_state
				move_pointer(format.spacing_after(paragraph.text))
				select_font(previous_font)
			end
			def write_section(section)
				format = @formats[:section]
				if(section.need_new_page?(@y - MARGIN_BOTTOM, @current_width, @formats))
					start_new_page
				end
				subheading = section.subheading
        if (paragraph = section.paragraphs.first) \
          && paragraph.preformatted? && subheading[-1] != ?\n
          subheading += "\n"
        end
				move_pointer(format.spacing_before(subheading))
				text(section.subheading, :font_size => format.size)
				move_pointer(format.spacing_after(subheading))
				section.each_paragraph { |paragraph_wrapper|
					write_paragraph(paragraph_wrapper)
				}
			end
			def prepare_substance_index
				#prepend a new page
        #@pageset.unshift 
				insert_mode(:on => true, :page => 0, :position => :before)
				set_page_element_type(:page_type_substance_title)
				start_new_page true #(true, @first_page, :before)
				set_page_type_elements
				@fi_page_number = 0
				fi_new_page
        stop_columns
				select_font(VARIABLE_WIDTH_FONT)
				draw_page_title("<b> #{_(:substance_index).upcase} </b>")
			end
			def write_substance_index
				prepare_substance_index
				set_page_element_type(:page_type_substance_index)
				@flic_name = _(:substance_index)
				start_columns(@target_columns, @column_gap)
				write_index
        draw_column_line if column_number > 1
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
				height = @y - @bottom_margin \
					- format_chapter.get_height(bsubstance, @current_width) - format_kombi.get_height("fo", @current_width)
				if(para.need_new_page?(height, @current_width, formats))
					start_new_page
				end
				link_y = nil
				move_pointer(format_chapter.spacing_before(bsubstance))
				if((singles.size \
					+ combinations.size) == 1)
					link_y = @y
				end
				text(bsubstance, :font_size => format_chapter.size, 
					               :justification => format_chapter.justification)
				move_pointer(format_chapter.spacing_after(bsubstance))
				singles.each{ |tuple|
					write_tuple(tuple, link_y)
					link_y = nil
				}
				unless(combinations.empty?)
					para = wrap_tuple(combinations.first)
					fmt_str = "<i>#{_(:combinations)}</i>"
					height = @y - @bottom_margin \
					  - format_kombi.get_height(fmt_str, @current_width)
					if(para.need_new_page?(height, @current_width, formats))
						start_new_page
					end
					move_pointer(format_kombi.spacing_before(fmt_str))
					text(fmt_str, :font_size => format_kombi.size,
						            :justification => format_kombi.justification)
					move_pointer(format_kombi.spacing_after(fmt_str))
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
				height = @y - @bottom_margin
				# these two lines are important
				# the insert mode must be reset for every tuple
				# otherwise new pages won't be added to the page index
				# and will not display in the reader
					#@ez[:insertOptions][:id] = @first_page
					#@ez[:insertOptions][:pos] = :before
				if(para.need_new_page?(height, @current_width, formats))
					start_new_page
				end
				if(link_y.nil?)
					link_y = @y
				end
				format = @formats[:text_index]
        color = generic_color(generic_type.intern, COLOR_DRUG_NAME_INDEX )
				fill_color color
				text(para.text, :font_size => format.size, 
                        :justification => format.justification)
=begin
				medic_name, company_name, 
				page_number, generic_type, combination, anchor = tuple
				fill_color(generic_color(generic_type.intern, COLOR_DRUG_NAME_INDEX ))
				output_name = " " + medic_name.to_s + "  ("+page_number.to_s + ")"
				output_company = "<i>"+"  "+ company_name.to_s + "</i>"
				y_pos = (@bottom_margin \
					+ format.get_height(output_name, \
					@current_width) \
					+ format.get_height(output_company, \
					@current_width))
					typographic_line_break_index(y_pos)
				ez_text(output_name,
					format.size, :justification => format.justification)
				ez_text(output_company, format.size, :justification => format.justification)
=end
				add_internal_link(anchor.to_s, @left_margin \
					, link_y, @left_margin + @current_width, @y \
					+ font_descender(format.size))
				fill_color @color
			end
		end
	end
end
