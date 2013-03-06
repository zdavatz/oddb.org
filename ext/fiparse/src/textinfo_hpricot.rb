#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::FiParse::PatinfoHpricot -- oddb.org -- 06.03.2013 -- yasaka@ywesee.com
# ODDB::FiParse::PatinfoHpricot -- oddb.org -- 30.01.2012 -- mhatakeyama@ywesee.com
# ODDB::FiParse::PatinfoHpricot -- oddb.org -- 17.08.2006 -- hwyss@ywesee.com

require 'hpricot'
require 'iconv'
require 'ostruct'
require 'util/oddbconfig'
require 'model/text'

##
# This Open-Class is needed for server that dose not have LANG env.
#
# String#force_encoding
# See:: /path/to/gems/hpricot/lib/hpricot/builder.rb
module Hpricot
  def self.uxs(str)
    str.to_s.force_encoding('utf-8').
        gsub(/\&(\w+);/) { [NamedCharacters[$1] || 63].pack("U*") }. # 63 = ?? (query char)
        gsub(/\&\#(\d+);/) { [$1.to_i].pack("U*") }
  end
  class Text
    def to_s
      str = content.force_encoding('utf-8')
      Hpricot.uxs(str)
    end
  end
end

module ODDB
  module FiParse
class TextinfoHpricot
  attr_reader :name, :company
  # options for swissmedicinfo
  attr_accessor :format, :title, :lang
  def chapter(elem)
    chapter = Text::Chapter.new
    code = nil
    ptr = OpenStruct.new
    ptr.chapter = chapter
    if @format == :swissmedicinfo
      code,text = detect_chapter(elem)
      if code and text
        code            = code
        chapter.heading = text
        # content
        elem = elem.next
        until end_element_in_chapter?(elem)
          _handle_element(elem, ptr)
          elem = elem.next
        end
      end
    else
      title_tag = ((@format == :compendium) ? 'div.absTitle' : 'h2')
      if(title = elem.at(title_tag))
        elem.children.delete(title)
        anchor = title.at('a')
        if !anchor.nil?
          code            = anchor['name']
          chapter.heading = text(anchor.next) # <a><p></p></a>
        elsif id = title.parent.attributes['id']  and !id.empty? # :compendium format of swissmedicinfo
          code            = id.gsub(/[^0-9]/, '')
          chapter.heading = text(title) # <p></p>
        end
      end
      handle_element(elem, ptr)
    end
    chapter.clean!
    [code, chapter]
  end
  def extract(doc, type=:fi)
    paragraph = ''
    name      = nil
    case @format
    when :compendium
      @name         = simple_chapter(doc.at('div.MonTitle'))
      @galenic_form = simple_chapter(doc.at('div.shortCharacteristic'))
      paragraph_tag = 'div.paragraph'
    when :swissmedicinfo
      name          = doc.at("p[text()*='#{@title}']")
      @name         = simple_chapter(name)
      paragraph_tag = "p[@id^='section']"
    else
      @name    = simple_chapter(doc.at('h1'))
      @company = simple_chapter(doc.at('div.ownerCompany'))
      @galenic_form = simple_chapter(doc.at('div.shortCharacteristic'))
      paragraph_tag = 'div.paragraph'
    end
    (doc/paragraph_tag).each { |elem|
      identify_chapter(*chapter(elem)) if !name or elem != name
    }
    to_textinfo
  end
  private
  def valid_heading?(text)
    true # overwrite me
  end
  def has_italic?(elem, ptr)
    if @format == :swissmedicinfo
      (ptr.target.is_a?(Text::Paragraph) and
      elem.respond_to?(:attributes) and
      elem.attributes['class'] == 's8')
    else
      ptr.target.is_a?(Text::Paragraph)
    end
  end
  def end_element_in_chapter?(elem)
    (elem.nil?) or
    (elem.respond_to?(:attributes) and !elem.attributes['id'].empty?)
  end
  def detect_text_block(elem) # for swissmedicinfo format
    text = ''
    until end_element_in_chapter?(elem)
      text << text(elem)
      elem = elem.next
    end
    text
  end
  def _handle_element(child, ptr)
    case child
    when Hpricot::Text
      if ptr.target.is_a? Text::Table
        # ignore text "\r\n        " in between tag.
      else
        if ptr.target.is_a? Text::MultiCell
          ptr.target.next_paragraph
        end
        ptr.section ||= ptr.chapter.next_section
        ptr.target  ||= ptr.section.next_paragraph
        handle_text(ptr, child)
      end
    when Hpricot::Elem
      case child.name
      when 'h3'
        ptr.section = ptr.chapter.next_section
        ptr.target  = ptr.section.subheading
        handle_text(ptr, child)
        ptr.target << "\n"
      when 'p'
        if ptr.table
          ptr.target.next_paragraph if ptr.target.is_a?(Text::MultiCell)
        else
          ptr.section ||= ptr.chapter.next_section
          ptr.target = ptr.section.next_paragraph
        end
        handle_element(child, ptr)
      when 'span', 'em', 'strong', 'b'
        if ptr.target.is_a?(Text::MultiCell)
          ptr.target = ptr.target.next_paragraph
        end
        ptr.target << ' '
        ptr.target.augment_format(:italic) if has_italic?(child, ptr)
        handle_element(child, ptr)
        ptr.target.reduce_format(:italic)  if has_italic?(child, ptr)
        ptr.target << ' '
      when 'sub', 'sup'
        ptr.target << ' '
        handle_text(ptr, child)
        ptr.target << ' '
      when 'table'
        ptr.section = ptr.chapter.next_section
        if detect_table?(child)
          ptr.target = ptr.section.next_table
          ptr.table = ptr.target
        else
          ptr.target = ptr.section.next_paragraph
          ptr.table = nil
          ptr.tablewidth = nil
          ptr.target.preformatted!
        end
        handle_element(child, ptr)
        ptr.section = ptr.chapter.next_section
        ptr.table = nil
      when 'thead', 'tbody'
        handle_element(child, ptr)
      when 'tr'
        if ptr.table
          ptr.table.next_row!
          handle_element(child, ptr)
          ptr.target = ptr.table
        else
          handle_element(child, ptr)
          ptr.target << "\n"
        end
      when 'td', 'th'
        if ptr.table
          ptr.target = ptr.table.next_multi_cell!
          ptr.target.row_span = child.attributes['rowspan'].to_i unless child.attributes['rowspan'].empty?
          ptr.target.col_span = child.attributes['colspan'].to_i unless child.attributes['colspan'].empty?
          handle_element(child, ptr)
          ptr.target = ptr.table
        else
          ## the new format uses td-borders as "row-separators"
          ptr.target << preformatted_text(child)
          if child.classes.include?('rowSepBelow')
            ptr.tablewidth ||= ptr.target.to_s.split("\n").collect{ |line| line.length }.max
            ptr.target << "\n" << ("-" * ptr.tablewidth.to_i)
          end
        end
      when 'div'
        handle_element(child, ptr)
      when 'img'
        if ptr.table
          unless ptr.target.respond_to?(:next_image) # after something text (paragraph) in cell
            ptr.target = ptr.table.next_multi_cell!
            ptr.target.row_span = child.attributes['rowspan'].to_i unless child.attributes['rowspan'].empty?
            ptr.target.col_span = child.attributes['colspan'].to_i unless child.attributes['colspan'].empty?
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
  def handle_element(elem, ptr)
    elem.each_child { |child|
      _handle_element(child, ptr)
    }
  end
  def handle_image(ptr, child)
    lang      = 'de'
    file_name = ''
    if @format == :swissmedicinfo
      @image_index ||= 0
      @image_index += 1
      type,_ = child[:src].split(',')
      if type =~ /^data:image\/(jp[e]?g|gif|png);base64$/
        ext       = $1
        name_base = File.basename(@name.to_s.gsub(/[^A-z0-9]/, '_')).strip
        file_name = File.join(name_base + '_files', "#{@image_index.to_s}.#{ext}")
        lang = (@lang || 'de')
      end
    else
      file_name = File.basename(child[:src].
                                gsub('&#xA;','').
                                gsub(/\?px=[0-9]*$/, '').strip)
      lang = (file_name[0].upcase == 'F' ? 'fr' : 'de') unless file_name.empty?
    end
    dir = File.join('/', 'resources', 'images', 'fachinfo', lang)
    ptr.target.src = File.join(dir, file_name)
  end
  def insert_image(ptr, child)
    # skip image in packungen table
    unless ptr.chapter.heading =~ /Packungen|Présentations/u
      ptr.target = ptr.target.next_image
      handle_image(ptr, child)
    end
  end
  def handle_text(ptr, child)
    # ptr.section ||= ptr.chapter.next_section
    # unless ptr.target.is_a?(Text::Paragraph)
      # p ptr.target.class
      # ptr.target = ptr.section.next_paragraph
    # end
    ptr.target << text(child)
  end
  def preformatted(target)
    target.respond_to?(:preformatted?) && target.preformatted?
  end
  def preformatted_text(elem)
    str = elem.inner_text || elem.to_s
    target_encoding(str.gsub(/(&nbsp;|\302\240)/u, ' '))
  end
  def simple_chapter(elem_or_str)
    if(elem_or_str)
      chapter = Text::Chapter.new
      if elem_or_str.is_a?(Hpricot::Elem)
        chapter.heading = text(elem_or_str)
      elsif elem_or_str.is_a?(String)
        chapter.heading = elem_or_str
      end
      chapter
    end
  end
  def detect_table?(elem)
    found = true
    if elem.attributes['class'] == 's24' # :swissmedicinfo
      found = true
    elsif elem.attributes['border'] == '0'
      # if 'rowSepBelow' class is found,
      # then this elem must be handled as pre-format style paragraph
      catch :pre do
        [
          (elem/:thead/:tr/:th),
          (elem/:tbody/:tr/:td),
          (elem/:tr/:th),
          (elem/:tr/:td)
        ].each do |tags|
          tags.each do |tag|
            if tag.attributes['class'] == 'rowSepBelow'
              found = false
              throw :pre
            end
          end
        end
      end
      if ((elem/:thead).empty? and (elem/:tbody).empty?) or
         (elem.attributes['cellspacing'] == '0' and elem.attributes['cellpadding'] == '0' and elem.attributes['style'].empty?)
        found = false
      end
    end
    found
  end
  def target_encoding(text)
    Iconv.iconv(ENCODING + "//TRANSLIT//IGNORE", 'utf8', text).first
  rescue
    text
  end
  def text(elem)
    return '' unless elem
    str = elem.inner_text || elem.to_s
    target_encoding(str.gsub(/(&nbsp;|\s)+/u, ' ').gsub(/[■]/u, '').strip)
  end
end
  end
end
