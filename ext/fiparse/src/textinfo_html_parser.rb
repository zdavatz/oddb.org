#!/usr/bin/env ruby

require 'debug'
require "ostruct"
require "util/oddbconfig"
require "model/text"

module ODDB
  module FiParse
    class TextinfoHtmlParser
      attr_reader :name, :company
      # options for swissmedicinfo
      attr_accessor :format, :title, :lang, :image_folder
      def chapter(elem)
        chapter = Text::Chapter.new
        code = nil
        ptr = OpenStruct.new
        ptr.chapter = chapter
        ptr.table = nil
        if @format == :swissmedicinfo
          if elem.at("div") and elem.at("p") # formatted like cipralex iksnr 62184
            heading = elem.at("div").inner_text
            code, _ = detect_chapter(elem)
            chapter.heading = heading
            elem = elem.children[3] # Here we find the first relevant children
            until end_element_in_chapter?(elem)
              handle_element(elem, ptr)
              elem = elem.next
            end
          else
            code, text = detect_chapter(elem)
            if code && text
              code = code
              chapter.heading = text
              # content
              old = elem
              elem = elem.next
              until end_element_in_chapter?(elem)
                handle_element(elem, ptr)
                elem = elem.next
              end
            end
          end
        else
          title_tag = ((@format == :compendium) ? "div.absTitle" : "h2")
          if (title = elem.at(title_tag))
            anchor = title.at("a")
            if !anchor.nil?
              code = anchor["name"]
              heading = anchor.next || elem.at(title_tag).text
              chapter.heading = text(heading) # <a><p></p></a>
            elsif id = title.parent.attributes["id"] and !id.empty? # :compendium format of swissmedicinfo
              code = id.gsub(/[^0-9]/, "")
              chapter.heading = text(title) # <p></p>
            end
            elem.children.delete(title)
          end
          handle_element(elem, ptr)
        end
        chapter.clean!
        [code, chapter]
      end

      def extract(doc, type = :fi, name = nil, styles = nil, image_folder: nil, **kwargs)
        # Support both positional and keyword calling conventions
        # e.g. extract(doc, :fi, "Name", styles) or extract(doc, type: :fi, name: "Name")
        if type.is_a?(Hash)
          kwargs = type.merge(kwargs)
          type = kwargs.delete(:type) || :fi
          name = kwargs.delete(:name)
          styles = kwargs.delete(:styles)
          image_folder = kwargs.delete(:image_folder)
        end
        name = kwargs.delete(:name) if name.nil? && kwargs.key?(:name)
        @image_folder ||= image_folder
        @stylesWithItalic = TextinfoHtmlParser.get_italic_style(styles)
        @stylesWithFixedFont = TextinfoHtmlParser.get_fixed_font_style(styles)
        @format = :swissmedicinfo if doc.to_s.index("section1") or doc.to_s.index("Section7000")
        case @format
        when :compendium
          @name = simple_chapter(doc.at("div.MonTitle"))
          @galenic_form = simple_chapter(doc.at("div.shortCharacteristic"))
          paragraph_tag = "div.paragraph"
        when :swissmedicinfo
          if name
            @name = name
          else
            @name = doc.at('title')&.text&.strip
            # Extract just the text from section1, not the whole element
            if @name.nil? || @name.empty?
              section1 = doc.at('#section1')
              if section1
                # Get the first significant text content (usually the heading)
                @name = section1.css('span').first&.text&.strip
                @name ||= section1.inner_text&.strip
              end
            end
          end
          paragraph_tag = "p"
          handler = Class.new {
          def regex node_set, regex
            node_set.find_all { |node| node['id'] =~ /section/ }
          end
        }.new
          paragraph_tag = '"//p", handler'
          paragraph_tag = "p"
        else
          @name = simple_chapter(doc.at("h1"))
          @company = simple_chapter(doc.at("div.ownerCompany"))
          @galenic_form = simple_chapter(doc.at("div.shortCharacteristic"))
          paragraph_tag = "div.paragraph"
        end
        (doc.search paragraph_tag, handler).each { |elem|
          if !name or elem != name
            code, text = chapter(elem)
            identify_chapter(code, text)
          end
        }
        paragraph_tag_pre_2013 = "div[@id^='Section']"
        (doc / paragraph_tag_pre_2013).each { |elem|
          if !name or elem != name
            code, text = chapter(elem)
            identify_chapter(code, text)
          end
        }
        to_textinfo
      end

      # return array of styles which have the attribute
      def self.get_italic_style(styles)
        return ["s8"] unless styles # this was the default assumed for swissmedicinfo
        styleNamesWithItalic = []
        styles.split("}").each { |style|
          matches = /([^{]+){(.+)/.match(style)
          next unless matches
          styleNamesWithItalic << matches[1].sub(".", "") if ItalicRegexp.match(matches[2])
        }
        styleNamesWithItalic
      end

      # return array of styles which are in fixed font (at the moment == have font courier
      def self.get_fixed_font_style(styles)
        return [] unless styles
        styleNamesWithFixedFont = []
        styles.split("}").each { |style|
          matches = /([^{]+){(.+)/.match(style)
          next unless matches
          styleNamesWithFixedFont << matches[1].sub(".", "") if FixedFontRegexp.match(matches[2])
        }
        styleNamesWithFixedFont
      end

      private

      FixedFontRegexp = /font-family:Courier/i
      ItalicRegexp = /font-style:italic/i
      def valid_heading?(text)
        true # overwrite me
      end

      def has_fixed_font?(elem, ptr)
        if @format == :swissmedicinfo
          return false unless elem.respond_to?(:attributes)
          return true if FixedFontRegexp.match(elem.attributes["style"]&.value)
          if ptr.target.is_a?(Text::Paragraph) and elem.respond_to?(:attributes)
            @stylesWithFixedFont.each { |style| return true if elem.attributes["class"]&.value.eql?(style) }
          end
        end
        false
      end

      def has_italic?(elem, ptr)
        if @format == :swissmedicinfo
          return true if ItalicRegexp.match(elem.attributes["style"]&.value)
          if ptr.target.is_a?(Text::Paragraph) and elem.respond_to?(:attributes)
            @stylesWithItalic.each { |style| return true if elem.attributes["class"]&.value.eql?(style) }
          end
          false
        elsif ptr.target.is_a?(Text::Paragraph) && elem.respond_to?(:attributes)
          /italic/.match(elem.attributes["style"]&.value)
        else
          false
        end
      end

      def end_element_in_chapter?(elem)
        elem.nil? || (elem.respond_to?(:attributes) && !elem.attributes["id"].nil?)
      end

      def detect_text_block(elem) # for swissmedicinfo format
        text = ""
        until end_element_in_chapter?(elem)
          text << text(elem)
          elem = elem.next
        end
        text
      end

      def handle_element(child, ptr, isParagraph = false)
        case child
        when Nokogiri::XML::EntityReference
            ptr.target << HTMLEntities.new.decode(child.to_s)
        when Nokogiri::XML::Text
          if ptr.target.is_a? Text::Table
            # # ignore text "\r\n        " in between tag.
          elsif child.text.match('span>')
          elsif !child.to_s.eql?("\n")
            ptr.section ||= ptr.chapter.next_section
            ptr.target ||= ptr.section.next_paragraph
            handle_text(ptr, child)
          end
        when Nokogiri::XML::Element
          case child.name
          when "colgroup"
            @@do_break = true
            handle_all_children(child, ptr, false)
          when "h3"
            ptr.section = ptr.chapter.next_section
            ptr.target = ptr.section.subheading
            handle_text(ptr, child)
            ptr.target << "\n"
          when "p"
            if ptr.table
              if ptr.target.is_a?(ODDB::Text::Paragraph)
                ptr.target << "\n"
              elsif !ptr.target.is_a?(Text::MultiCell)
                ptr.target.next_paragraph
              end
            else
              ptr.section ||= ptr.chapter.next_section
              ptr.target = ptr.section.next_paragraph
            end
            handle_all_children(child, ptr, true)
          when "span", "em", "strong", "b", "br"
            ptr.target = ptr.target.next_paragraph if ptr.target.is_a?(Text::MultiCell)
            if child.name == "br"
              ptr.target << "\n" if ptr.table
            else
              ptr.target.augment_format(:italic) if has_italic?(child, ptr)
              if defined?(child.parent.attributes) and /untertitle/.match(child.parent.attributes["class"])
                ptr.target = ptr.section.next_paragraph
              end
              handle_all_children(child, ptr)
              ptr.target.reduce_format(:italic) if has_italic?(child, ptr)
            end
          when "sub", "sup"
            handle_text(ptr, child)
          when "table"
            ptr.section = ptr.chapter.next_section
            if detect_table?(child)
              ptr.target = ptr.section.next_table
              ptr.table = ptr.target
            else
              # Preformatted table - collect all rows first for alignment
              ptr.target = ptr.section.next_paragraph
              ptr.table = nil
              ptr.tablewidth = nil
              ptr.preformatted_table_rows = []
              ptr.target.preformatted!
            end
            handle_all_children(child, ptr)
            # After processing all children, format the preformatted table
            if ptr.preformatted_table_rows && !ptr.preformatted_table_rows.empty?
              format_preformatted_table(ptr)
            end
            ptr.section = ptr.chapter.next_section
            ptr.table = nil
            ptr.preformatted_table_rows = nil
          when "thead", "tbody"
            handle_all_children(child, ptr)
          when "tr"
            if ptr.table
              ptr.table.next_row!
              handle_all_children(child, ptr)
              ptr.target = ptr.table
            else
              # Collect row cells for later formatting
              ptr.current_row_cells = []
              handle_all_children(child, ptr)
              # Store the row
              if ptr.preformatted_table_rows && ptr.current_row_cells
                ptr.preformatted_table_rows << ptr.current_row_cells
              end
              ptr.current_row_cells = nil
            end
          when "td", "th"
            if ptr.table
              ptr.target = ptr.table.next_multi_cell!
              ptr.target.row_span = child.attributes["rowspan"]&.value.to_i
              ptr.target.col_span = child.attributes["colspan"]&.value.to_i
              handle_all_children(child, ptr)
              ptr.target = ptr.table
            elsif ptr.current_row_cells
              # Collect cell text for preformatted table
              cell_text = preformatted_text(child).strip
              ptr.current_row_cells << cell_text
            end
          when "div"
            handle_all_children(child, ptr)
          when "img"
            if ptr.table
              unless ptr.target.respond_to?(:next_image) # after something text (paragraph) in cell
                ptr.target = ptr.table.next_multi_cell!
                ptr.target.row_span = child.attributes["rowspan"]&.value.to_i
                ptr.target.col_span = child.attributes["colspan"]&.value.to_i
              end
              insert_image(ptr, child)
              ptr.target = ptr.table.next_paragraph
            else
              ptr.section = ptr.chapter.next_section
              unless ptr.target.respond_to?(:next_image)
                ptr.target = ptr.section
              end
              insert_image(ptr, child)
              ptr.section = ptr.chapter.next_section
              ptr.target = ptr.section.next_paragraph
            end
          end
        end
      end

      def handle_all_children(elem, ptr, isParagraph = false)
        elem.children.each { |child|
          handle_element(child, ptr, isParagraph)
        }
      end

      def handle_image(ptr, child)
        lang = "de"
        file_name = ""
        if @format == :swissmedicinfo
          @image_index ||= 0
          @image_index += 1
          src, _ = child[:src].split(",")
          # next regexp must be in sync with src/plugin/text_info.rb
          if src =~ /^data:image\/(jp[e]?g|gif|png|x-[ew]mf);base64($|,)/
            ptr.target.style = child[:style]
            ext = $1
            file_name = File.join(@image_folder || @title, "#{@image_index}.#{ext}")
            @lang || "de"
          end
          dir = File.join("/", "resources", "images")
        else
          file_name = File.basename(child[:src]
                                    .gsub("&#xA;", "")
                                    .gsub(/\?px=[0-9]*$/, "").strip)
          lang = ((file_name[0].upcase == "F") ? "fr" : "de") unless file_name.empty?
          type = (is_a?(ODDB::FiParse::FachinfoHtmlParser) ? "fi" : "pi")
          dir = File.join("/", "resources", "images", type, lang)
        end
        ptr.target.src = File.join(dir, file_name)
      end

      def insert_image(ptr, child)
        # skip image in packungen table
        unless /Packungen|Présentations/u.match?(ptr.chapter.heading)
          ptr.target = ptr.target.next_image
          handle_image(ptr, child)
        end
      end

      def handle_text(ptr, child)
        return if child.parent.name.eql?("tbody") or child.parent.name.eql?("table")
        # handling a situation found only in Baraclude® IKSNR 57'435/436
        # child.to_s may return HTML-encoded form (span&gt;) and may have leading whitespace
        return if /^\s*span(>|&gt;)/.match?(child.to_s)
        string = text(child)
        m = URI::RFC2396_PARSER.make_regexp.match(string)
        if m and m[0].downcase.index("http")
          link = m[0].sub(/\/\)$/, "/")
          first = string.index(link)
          last = string.index(link) + link.length - 1
          ptr.target << string[0..(first - 1)] if first > 0
          ptr.target.add_link(link)
          ptr.target << string[(last + 1)..-1] if (last + 1) < string.length
        else
          ptr.target << string
        end
      rescue ArgumentError => e
        $stdout.puts "rescue exception #{e} for #{child.inspect}"
        $stdout.puts "  ptr.target #{ptr.target}"
        $stdout.puts "  caller #{caller.join("\n")}"
      end

      def preformatted(target)
        target.respond_to?(:preformatted?) && target.preformatted?
      end

      def preformatted_text(elem)
        str = elem.inner_text || elem.to_s
        # Filter out malformed "span>" text artifacts (e.g., Baraclude IKSNR 57'435/436)
        str.delete("\n").gsub(/span>/, "").gsub(/(\302\240)/u, " ").gsub("&nbsp;&nbsp;", "&nbsp;")
      end

      def format_preformatted_table(ptr)
        rows = ptr.preformatted_table_rows
        return if rows.empty?
        
        # Maximum line width before wrapping (adjust as needed)
        max_line_width = 100
        
        # Calculate maximum width for each column
        max_cols = rows.map(&:length).max
        col_widths = Array.new(max_cols, 0)
        
        # First pass: get natural column widths
        rows.each do |row|
          row.each_with_index do |cell, idx|
            cell_width = cell.to_s.length
            col_widths[idx] = [col_widths[idx], cell_width].max
          end
        end
        
        # Calculate total width needed
        total_width = col_widths.sum + (max_cols - 1) * 2  # 2 spaces between columns
        
        # If total width exceeds max, we need to wrap cells
        if total_width > max_line_width
          # Adjust column widths proportionally, but with minimum width
          available_width = max_line_width - (max_cols - 1) * 2
          min_col_width = 20  # Minimum width per column
          
          # Calculate proportional widths
          total_natural = col_widths.sum.to_f
          col_widths = col_widths.map do |w|
            proportional = (w / total_natural * available_width).to_i
            [proportional, min_col_width].max
          end
          
          # Adjust if we're still over
          while col_widths.sum > available_width && col_widths.max > min_col_width
            max_idx = col_widths.index(col_widths.max)
            col_widths[max_idx] -= 1
          end
        end
        
        # Format each row with wrapping
        rows.each do |row|
          # Wrap cells that are too long
          wrapped_cells = row.each_with_index.map do |cell, idx|
            wrap_text(cell.to_s, col_widths[idx])
          end
          
          # Find maximum number of lines in any cell
          max_lines = wrapped_cells.map { |lines| lines.length }.max
          
          # Output each line of the row
          (0...max_lines).each do |line_idx|
            formatted_line = wrapped_cells.each_with_index.map do |lines, col_idx|
              line_text = lines[line_idx] || ""
              # Pad to column width (except last column)
              if col_idx < row.length - 1
                line_text.ljust(col_widths[col_idx])
              else
                line_text
              end
            end
            
            ptr.target << formatted_line.join("  ")
            ptr.target << "\n"
          end
        end
      end
      
      def wrap_text(text, width)
        return [text] if text.length <= width
        
        lines = []
        remaining = text.dup
        
        while remaining.length > width
          # Try to break at a space
          break_pos = remaining[0...width].rindex(' ')
          
          if break_pos && break_pos > width * 0.6  # Don't break too early
            lines << remaining[0...break_pos]
            remaining = remaining[break_pos + 1..-1]
          else
            # No good break point, hard break
            lines << remaining[0...width]
            remaining = remaining[width..-1]
          end
        end
        
        lines << remaining unless remaining.empty?
        lines
      end

      def simple_chapter(elem_or_str)
        if elem_or_str
          chapter = Text::Chapter.new
          if elem_or_str.is_a?(Nokogiri::XML::Element)
            chapter.heading = text(elem_or_str).strip
          elsif elem_or_str.is_a?(String)
            chapter.heading = elem_or_str
          end
          chapter
        end
      end

      def detect_table?(elem)
        found = true
        if @stylesWithFixedFont && @stylesWithFixedFont.index(elem.attributes["class"]&.value)
          found = false
        elsif elem.attributes["class"]&.value == "s24"
          found = true
        elsif elem.attributes["border"]&.value == "0"
          catch :pre do
            [
              (elem / :thead / :tr / :th),
              (elem / :tbody / :tr / :td),
              (elem / :tr / :th),
              (elem / :tr / :td)
            ].each do |tags|
              tags.each do |tag|
                if tag.attributes["class"] == "rowSepBelow"
                  found = false
                  throw :pre
                end
              end
            end
          end
          if ((elem / :thead).empty? and (elem / :tbody).empty?) or
              (elem.attributes["cellspacing"] == "0" and elem.attributes["cellpadding"] == "0" and elem.attributes["style"].nil?)
            found = false
          end
        end
        found
      end

      def text(elem)
        return "" unless elem
        if elem.instance_of?(String)
          str = elem
        else
          str = elem.inner_text || elem.to_s
        end
        # Collapse whitespace runs (but preserve non-breaking spaces for formatting)
        str.gsub(/(\s)+/u, " ").gsub(/[■]/u, "").gsub("&nbsp;&nbsp;", "&nbsp;")
      end
    end
  end
end
