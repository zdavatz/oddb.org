#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::FiParse::PatinfoHpricot -- oddb.org -- 27.06.2012 -- yasaka@ywesee.com
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
      code = anchor['name']
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
        handle_text(ptr, child)
      when Hpricot::Elem
        case child.name
        when 'h3'
          ptr.section = ptr.chapter.next_section
          ptr.target = ptr.section.subheading
          handle_text(ptr, child)
          ptr.target << "\n"
        when 'p'
          ptr.section ||= ptr.chapter.next_section
          ptr.target = ptr.section.next_paragraph
          handle_element(child, ptr)
        when 'span'
          target = ptr.target
          target << ' '
          target.augment_format(:italic) if(target.is_a?(Text::Paragraph))
          handle_element(child, ptr)
          target = ptr.target
          target.reduce_format(:italic) if(target.is_a?(Text::Paragraph))
          target << ' '
        when 'sub'
          target = ptr.target
          handle_text(ptr, child)
          target << ' '
        when 'table'
          ptr.tablewidth = nil
          ptr.target = ptr.section.next_paragraph
          ptr.target.preformatted!
          handle_element(child, ptr)
          ptr.target = ptr.section.next_paragraph
        when 'thead', 'tbody'
          handle_element(child, ptr)
        when 'tr'
          handle_element(child, ptr)
          ptr.target << "\n"
        when 'td', 'th'
          ptr.target << preformatted_text(child)
          ## the new format uses td-borders as "row-separators"
          if(child.classes.include?("rowSepBelow"))
            ptr.tablewidth ||= ptr.target.to_s.split("\n").collect { |line| 
              line.length }.max
            ptr.target << "\n" << ("-" * ptr.tablewidth)
          end
        end
      end
    }
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
