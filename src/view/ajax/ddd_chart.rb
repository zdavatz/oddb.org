#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Ajax::View::DDDChart -- oddb.org -- 06.07.2009 -- hwyss@ywesee.com
# ODDB::Ajax::View::DDDChart -- oddb.org -- 17.04.2009 -- hwyss@ywesee.com

require 'htmlgrid/component'
require 'view/additional_information'
require 'gruff'

class SideBar < Gruff::Base
  LABEL_MARGIN = LEGEND_MARGIN = TITLE_MARGIN = 4
  def draw
    @has_left_labels = true
    super

    return unless @has_data

    # Setup spacing.
    #
    spacing_factor = 0.8

    @bars_width = @graph_height / @column_count.to_f
    @bar_width = @bars_width * spacing_factor / @norm_data.size
    @d         = @d.stroke_opacity 0.0
    height     = Array.new(@column_count, 0)
    length     = Array.new(@column_count, @graph_left)

    @norm_data.each_with_index do |data_row, row_index|
      @d = @d.fill data_row[DATA_COLOR_INDEX]

      data_row[DATA_VALUES_INDEX].each_with_index do |data_point, point_index|

        if clrs = @theme_options[:custom_colors]
          @d = @d.fill clrs[point_index] || data_row[DATA_COLOR_INDEX]
        end

        # Using the original calcs from the stacked bar chart
        # to get the difference between
        # part of the bart chart we wish to stack.
        temp1      = @graph_left + (@graph_width - data_point * @graph_width - height[point_index])
        temp2      = @graph_left + @graph_width - height[point_index]
        difference = temp2 - temp1

        left_x     = length[point_index] - 1
        left_y     = @graph_top + (@bars_width * point_index) + (@bar_width * row_index)
        right_x    = left_x + difference
        right_y    = left_y + @bar_width

        height[point_index] += (data_point * @graph_width)

        @d           = @d.rectangle(left_x, left_y, right_x, right_y)

        # Calculate center based on bar_width and current row
        label_center = @graph_top + (@bars_width * point_index + @bars_width / 2)
        draw_label(label_center, point_index)
      end

    end

    draw_source

    @d.draw(@base_image)
  end
  FACTOR_PTRN = /^[\s\d.\/]+x\s*/
  def draw_label(y_offset, index)
    if (text = @labels[index]) && @labels_seen[index].nil?
      price = text.slice! /[A-Z]{3}\s+[\d.]+$/
      @d.fill             = @font_color
      @d.font             = @font if @font
      @d.stroke           = 'transparent'
      @d.pointsize        = scale_fontsize(@marker_font_size)
      @d.gravity          = WestGravity
      x_offset = @left_margin + LABEL_MARGIN
      if factor = text.slice!(FACTOR_PTRN)
        @d.font_weight    = BoldWeight
        @d                = @d.annotate_scaled(@base_image,
                            1, 1, x_offset, y_offset, factor, @scale)
      end
      @d.font_weight      = NormalWeight
      @d                  = @d.annotate_scaled(@base_image,
                              1, 1, x_offset + @factor_width, y_offset,
                              text, @scale)

      @d.gravity          = EastGravity
      @d                  = @d.annotate_scaled(@base_image,
                              1, 1,
                              -@graph_left + LABEL_MARGIN * 2.0, y_offset,
                              price, @scale)

      @labels_seen[index] = 1
    end
  end
  def draw_line_markers

    return if @hide_line_markers

    @d = @d.stroke_antialias false

    # Draw horizontal line markers and annotate with numbers
    @d = @d.stroke(@marker_color)
    @d = @d.stroke_width 1
    number_of_lines = [@maximum_value.to_f / 0.5, 4].min

    # TODO Round maximum marker value to a round number like 100, 0.1, 0.5, etc.
    increment = significant(@maximum_value.to_f / number_of_lines)
    (0..number_of_lines).each do |index|

      line_diff    = (@graph_right - @graph_left) / number_of_lines
      x            = @graph_right - (line_diff * index) - 1
      @d           = @d.line(x, @graph_bottom, x, @graph_top)
      diff         = index - number_of_lines
      marker_label = "%4.2f" % (diff.abs * increment)

      unless @hide_line_numbers
        @d.fill      = @font_color
        @d.font      = @font if @font
        @d.stroke    = 'transparent'
        @d.pointsize = scale_fontsize(@marker_font_size)
        @d.gravity   = CenterGravity
        # TODO Center text over line
        @d           = @d.annotate_scaled( @base_image,
                          0, 0, # Width of box to draw text in
                          x, @graph_bottom + (LABEL_MARGIN * 2.0), # Coordinates of text
                          marker_label, @scale)
      end # unless
      @d = @d.stroke_antialias true
    end
  end
  def draw_source
      @d.fill             = @font_color
      @d.font             = @font if @font
      @d.stroke           = 'transparent'
      @d.font_weight      = NormalWeight
      @d.pointsize        = scale_fontsize(@theme_options[:source_font_size])
      @d.gravity          = WestGravity
      @d                  = @d.annotate_scaled(@base_image,
                              1, 1,
                              @left_margin + LABEL_MARGIN,
                              @graph_bottom + (LABEL_MARGIN * 2.0),
                              @theme_options[:source], @scale)
  end
  def draw_title
    return if (@hide_title || @title.nil?)

    @d.fill = @font_color
    @d.font = @font if @font
    @d.stroke('transparent')
    @d.pointsize = scale_fontsize(@title_font_size)
    @d.font_weight = BoldWeight
    @d.gravity = NorthWestGravity
    @d = @d.annotate_scaled( @base_image,
    @raw_columns, 1.0,
    TITLE_MARGIN, @top_margin,
    @title, @scale)
  end
  def setup_graph_measurements
    @marker_caps_height = @hide_line_markers ? 0 :
    calculate_caps_height(@marker_font_size)
    @title_caps_height = @hide_title ? 0 :
    calculate_caps_height(@title_font_size)
    @legend_caps_height = @hide_legend ? 0 :
    calculate_caps_height(@legend_font_size)

    @factor_width = 0
    label_kerning = 1.2

    if @hide_line_markers
      (@graph_left,
      @graph_right_margin,
      @graph_bottom_margin) = [@left_margin, @right_margin, @bottom_margin]
    else
      longest_left_label_width = 0
      if @has_left_labels
        longest_factor = longest_label = ''
        labels.values.each do |label|
          if label.to_s.length > longest_label.length
            longest_label = label.to_s
          end
          if (factor = label[FACTOR_PTRN]) \
            && factor.length > longest_factor.length
            longest_factor = factor
          end
        end
        unless longest_label.empty?
          longest_left_label_width = calculate_width(@marker_font_size,
                                                     longest_label) * label_kerning
        end
        unless longest_factor.empty?
          @factor_width = calculate_width(@marker_font_size,
                                          longest_factor) * label_kerning
        end
      else
        longest_left_label_width = calculate_width(@marker_font_size,
        label(@maximum_value.to_f))
      end

      # Shift graph if left line numbers are hidden
      line_number_width = @hide_line_numbers && !@has_left_labels ?  0.0 : (longest_left_label_width + LABEL_MARGIN)

      @graph_left = @left_margin +
      line_number_width +
      (@y_axis_label.nil? ? 0.0 : @marker_caps_height + LABEL_MARGIN * 2)

      # Make space for half the width of the rightmost column label.
      # Might be greater than the number of columns if between-style bar markers are used.
      last_label = "%4.2f" % @maximum_value
      extra_room_for_long_label = calculate_width(@marker_font_size, last_label) / 2.0
      @graph_right_margin = @right_margin + extra_room_for_long_label

      @graph_bottom_margin = @bottom_margin +
      @marker_caps_height + LABEL_MARGIN
    end

    @graph_right = @raw_columns - @graph_right_margin
    @graph_width = @raw_columns - @graph_left - @graph_right_margin

    # When @hide title, leave a TITLE_MARGIN space for aesthetics.
    # Same with @hide_legend
    @graph_top = @top_margin +
    (@hide_title  ? TITLE_MARGIN  : @title_caps_height  + TITLE_MARGIN  * 2) +
    (@hide_legend ? LEGEND_MARGIN : @legend_caps_height + LEGEND_MARGIN * 2)

    x_axis_label_height = @x_axis_label.nil? ? 0.0 : @marker_caps_height + LABEL_MARGIN
    @graph_bottom = @raw_rows - @graph_bottom_margin - x_axis_label_height
    @graph_height = @graph_bottom - @graph_top
  end
end

module ODDB
  module View
    module Ajax
class DDDChart < HtmlGrid::Component
  include PartSize
  HTTP_HEADERS = {
    'Content-Type'  =>  'image/png',
  }
  MAX_LEN = 50
  def init
    @labels = {}
    @data = []
    @original_index = 0
    img_name = @session.user_input(:for)
    ikskey = img_name[/^\d{8}/]
    original = @session.package_by_ikskey ikskey
    my_factor = (original.generic_group_factor || 1).to_f
    oseq = original.sequence
    @model.each_with_index do |pac, idx|
      ddd_price = pac.ddd_price
      @data.push ddd_price
      base = pac.name_base
      size = comparable_size(pac)
      fullname = u sprintf("%s, %s", base, size)
      name = fullname.length > MAX_LEN ? fullname[0, MAX_LEN - 1] + "…" : fullname
      label = sprintf "%s: CHF %4.2f", name, ddd_price
      pac_factor = (pac.generic_group_factor || 1).to_f / my_factor
      if pac == original
        @original_index = idx
        @title = @lookandfeel.lookup(:ddd_chart_title, fullname)
      elsif pac_factor == 2 || pac.sequence.comparable?(oseq, 2)
        label = sprintf "2 x %s: CHF %4.2f", name, ddd_price
      elsif pac_factor == 0.5 || pac.sequence.comparable?(oseq, 0.5)
        label = sprintf "1/2 x %s: CHF %4.2f", name, ddd_price
      end
      @labels.store idx, label
    end
    super
  end
  def to_html(cgi)
    factor = (@session.user_input(:factor) || 1).to_f
    height = (60 + @data.size * 20) * factor
    width = 750 * factor
    gr = SideBar.new "#{width}x#{height}"

    gr.title = @title

    gr.hide_legend = true
    gr.marker_font_size = 15
    gr.title_font_size = 16
    gr.sort = false
    gr.margins = 4
    gr.left_margin = 0

    gr.theme = {
      :colors => ['#ccff99'],
      :marker_color => '#dddddd',
      :font_color => 'black',      
      :background_colors => "white",
      :custom_colors => { @original_index => '#2ba476' },
      :source => @lookandfeel.lookup(:ddd_chart_source),
      :source_font_size => 12
    }

    gr.data "Data", @data

    labels = {}
    gr.labels = @labels
    gr.maximum_value = (@data.max * 2).to_f.ceil / 2.0
    gr.minimum_value = 0

    gr.to_blob
  end
end
    end
  end
end
