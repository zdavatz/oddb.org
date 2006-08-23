#!/usr/bin/env ruby
# FiParse::PatinfoHpricot -- oddb -- 17.08.2006 -- hwyss@ywesee.com

require 'hpricot'
require 'iconv'
require 'ostruct'
require 'util/oddbconfig'
require 'model/text'
require 'model/patinfo'

module ODDB
  module FiParse
class PatinfoHpricot
  attr_reader :amendments, :amzv, :company, :composition, :contra_indications,
    :date, :distribution, :effects, :iksnrs, :galenic_form, :general_advice,
    :name, :packages, :precautions, :pregnancy, :unwanted_effects, :usage
  def chapter(elem)
    chapter = Text::Chapter.new
    code = nil
    ptr = OpenStruct.new
    ptr.chapter = chapter
    if(title = elem.at("div.AbschnittTitel"))
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
    @name = text(doc.at("div.MonographieTitel"))
    @company = simple_chapter(doc.at("div.FirmenTitel"))
    @galenic_form = simple_chapter(doc.at("div.Kurzcharakteristikum"))
    (doc/"div.Abschnitt").each { |elem|
      identify_chapter(*chapter(elem))
    }
    to_patinfo
  end
  def identify_chapter(code, chapter)
    case code
    when '7600'
      @amzv = chapter
    when '7620'
      @effects = chapter
    when '7640'
      @amendments = chapter
    when '7660', '7680'
      @contra_indications = chapter
    when '7700'
      @precautions = chapter
    when '7720'
      @pregnancy = chapter
    when '7740'
      @usage = chapter
    when '7760'
      @unwanted_effects = chapter
    when '7780'
      @general_advice = chapter
    when '7840'
      @composition = chapter
    when '7880'
      @packages = chapter
    when '7900'
      @distribution = chapter
    when nil # special chapers without heading
      case chapter.to_s
      when /^\d{5}/
        @iksnrs = chapter
      when /\b\d{4}\b/
        @date = chapter
      end
    else
      raise "Unknown chapter-code #{code}, while parsing #{@name}"
    end
  end
  def to_patinfo
    pat = if(@amzv)
      pat = PatinfoDocument2001.new
      pat.amzv = @amzv
      pat.iksnrs = @iksnrs
      pat
    else
      pat = PatinfoDocument.new
      pat
    end
    pat.name = @name
    pat.company = @company
    pat.galenic_form = @galenic_form
    pat.effects = @effects
    pat.amendments = @amendments
    pat.contra_indications = @contra_indications
    pat.precautions = @precautions
    pat.pregnancy = @pregnancy
    pat.usage	= @usage
    pat.unwanted_effects = @unwanted_effects
    pat.general_advice	= @general_advice
    #pat.other_advice = @other_advice ## not identified yet.
    pat.composition	= @composition
    pat.packages = @packages
    pat.distribution = @distribution
    pat.date = @date
    pat
  end
  private
  def handle_element(elem, ptr)
    elem.each_child { |child|
      case child
      when Hpricot::Text
        ptr.section ||= ptr.chapter.next_section
        ptr.target ||= ptr.section.next_paragraph
        ptr.target << text(child)
      when Hpricot::Elem
        case child.name
        when 'div'
          ptr.section = ptr.chapter.next_section
          ptr.target = ptr.section.subheading
          handle_element(child, ptr)
          ptr.target << "\n"
          ptr.target = ptr.section.next_paragraph
        when 'br'
          ptr.section ||= ptr.chapter.next_section
          ptr.target = ptr.section.next_paragraph
        when 'span'
          ptr.target << ' '
          ptr.target.augment_format(:italic)
          handle_element(child, ptr)
          ptr.target.reduce_format(:italic)
          ptr.target << ' '
        when 'table'
          ptr.target = ptr.section.next_paragraph
          ptr.target.preformatted!
          handle_element(child, ptr)
          ptr.target = ptr.section.next_paragraph
        when 'tr'
          handle_element(child, ptr)
          ptr.target << "\n"
        when 'td'
          ptr.target << preformatted_text(child)
        end
      end
    }
  end
  def preformatted(target)
    target.respond_to?(:preformatted?) && target.preformatted?
  end
  def preformatted_text(elem)
    str = elem.respond_to?(:inner_html) ? elem.inner_html : elem.to_s
    target_encoding(str.gsub(/(&nbsp;|\302\240)/, ' '))
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
    str = elem.respond_to?(:inner_html) ? elem.inner_html : elem.to_s
    target_encoding(str.gsub(/(&nbsp;|\302\240|\s)+/, ' ').strip)
  end
end
  end
end
