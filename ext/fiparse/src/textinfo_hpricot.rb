#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::FiParse::PatinfoHpricot -- oddb.org -- 11.07.2012 -- yasaka@ywesee.com
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
  attr_accessor :new_format_flag
  def chapter(elem)
    chapter = Text::Chapter.new
    code = nil
    ptr = OpenStruct.new
    ptr.chapter = chapter
    title_tag = @new_format_flag ? "div.absTitle" : "h2"
    if(title = elem.at(title_tag))
      elem.children.delete(title)
      anchor = title.at("a")
      code = anchor['name'] unless anchor.nil?
      chapter.heading = text(anchor)
    end
    handle_element(elem, ptr)
    chapter.clean!
    [code, chapter]
  end
  def extract(doc)
    title_tag = @new_format_flag ? "div.MonTitle" : "h1"
    @name = text(doc.at(title_tag))
    @company = simple_chapter(doc.at("div.ownerCompany"))
    @galenic_form = simple_chapter(doc.at("div.shortCharacteristic"))
    (doc/"div.paragraph").each { |elem|
      identify_chapter(*chapter(elem))
    }
    to_textinfo
  end
  private
  def handle_element(elem, ptr)
    elem.each_child { |child|
      case child
      when Hpricot::Text
        if ptr.target.is_a? Text::Table or
           ptr.target.is_a? Text::MultiCell
          ptr.target = ptr.target.next_paragraph
        end
        handle_text(ptr, child)
      when Hpricot::Elem
        case child.name
        when 'h3'
          ptr.section = ptr.chapter.next_section
          ptr.target = ptr.section.subheading
          handle_text(ptr, child)
          ptr.target << "\n"
        when 'p'
          if ptr.container
            ptr.target = ptr.container.next_paragraph
          else
            ptr.section ||= ptr.chapter.next_section
            ptr.target = ptr.section.next_paragraph
          end
          handle_element(child, ptr)
        when 'span', 'em', 'strong'
          target = ptr.target
          target << ' '
          target.augment_format(:italic) if target.is_a?(Text::Paragraph)
          handle_element(child, ptr)
          target = ptr.target
          target.reduce_format(:italic) if target.is_a?(Text::Paragraph)
          target << ' '
        when 'sub', 'sup'
          target = ptr.target
          handle_text(ptr, child)
          target << ' '
        when 'table'
          ptr.section = ptr.chapter.next_section
          unless child.classes.empty? # old line-table in pre
            ptr.tablewidth = nil
            ptr.target = ptr.section.next_paragraph
            ptr.target.preformatted!
          else
            ptr.target = ptr.section.next_table
            ptr.container = ptr.target # marking of 'in-table'
          end
          handle_element(child, ptr)
          ptr.section = ptr.chapter.next_section
          ptr.container = nil
        when 'thead', 'tbody'
          handle_element(child, ptr)
        when 'tr'
          if ptr.container
            ptr.container.next_row!
            handle_element(child, ptr)
            ptr.target = ptr.container
          else
            handle_element(child, ptr)
            ptr.target << "\n"
          end
        when 'td', 'th'
          ## the new format uses td-borders as "row-separators"
          if(child.classes.include?("rowSepBelow"))
            ptr.target << preformatted_text(child)
            ptr.tablewidth ||= ptr.target.to_s.split("\n").collect{ |line| line.length }.max
            ptr.target << "\n" << ("-" * ptr.tablewidth.to_i)
          else
            if ptr.container
              ptr.target = ptr.container.next_multi_cell!
              handle_element(child, ptr)
            else
              ptr.target << preformatted_text(child)
            end
          end
        when 'div'
          handle_element(child, ptr)
        when 'img'
          if ptr.container
            ptr.target = ptr.target.next_image
            handle_image(ptr, child)
          else
            ptr.section = ptr.chapter.next_section
            ptr.target = ptr.section.next_image
            handle_image(ptr, child)
            ptr.section = ptr.chapter.next_section
            ptr.target = ptr.section.next_paragraph
          end
        end
      end
    }
  end
  def handle_image(ptr, child)
    file_name = File.basename child[:src].gsub('&#xA;','').strip
    lang = file_name[0].upcase == 'D' ? 'de' : 'fr'
    dir = File.join '/', 'resources', 'images', 'fachinfo', lang
    ptr.target.src = File.join dir, file_name
  end
  def handle_text(ptr, child)
    ptr.section ||= ptr.chapter.next_section
    ptr.target ||= ptr.section.next_paragraph
    ptr.target << text(child)
  end
  def preformatted(target)
    target.respond_to?(:preformatted?) && target.preformatted?
  end
  def preformatted_text(elem)
    str = elem.inner_text || elem.to_s
    target_encoding(str.gsub(/(&nbsp;|\302\240)/u, ' '))
  end
  def simple_chapter(elem)
    if(elem)
      chapter = Text::Chapter.new
      chapter.heading = text(elem)
      chapter
    end
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
