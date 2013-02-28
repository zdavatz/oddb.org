#!/usr/bin/env ruby
# FiParse::PatinfoHpricot -- oddb -- 28.02.2013 -- yasaka@ywesee.com
# FiParse::PatinfoHpricot -- oddb -- 17.08.2006 -- hwyss@ywesee.com

require 'model/patinfo'
require 'textinfo_hpricot'

module ODDB
  module FiParse
class PatinfoHpricot < TextinfoHpricot
  attr_reader :amendments, :amzv, :composition, :contra_indications,
    :date, :distribution, :effects, :iksnrs, :fabrication, :galenic_form,
    :general_advice, :packages, :precautions, :pregnancy,
    :unwanted_effects, :usage
  def identify_chapter(code, chapter)
    case code
    when '7600', 'section1'
      @amzv = chapter
    when 'section2'
      @name = chapter
    when '2000', '7620', 'section3'
      @effects = chapter
    when '2500', '7640'
      @amendments = chapter
    when '3000', '7625', '7660', '7680', 'section4'
      @contra_indications = chapter
    when '3500', '7700', 'section5'
      @precautions = chapter
    when '4000', '7720', 'section6'
      @pregnancy = chapter
    when '4500', '7740', 'section7'
      @usage = chapter
    when '5000', '7760', 'section8'
      @unwanted_effects = chapter
    when '5500', '7780', 'section9'
      @general_advice = chapter
    when '6000', '7840', 'section10'
      @composition = chapter
    when '7860', 'section11'
      @iksnrs = chapter
    when '6500', '7880', 'section12'
      @packages = chapter
    when '7000', '7900'
      @distribution = chapter
    when '7920'
      @fabrication = chapter
    when '7930'
      @delivery = chapter
    when '7520', '7940', '7950', 'section14'
      if(@date) # we are overwriting an existing @date
        chapter.sections = @date.sections
      end
      @date = chapter
    when nil # special chapers without heading
      case chapter.to_s
      when /^\d{5}/u
        @iksnrs = chapter
      when /\b\d{4}\b/u
        @date = chapter
      end
    else
      raise "Unknown chapter-code #{code}, while parsing #{@name}"
    end
  end
  def to_textinfo
    pat = if(@amzv)
      pat        = PatinfoDocument2001.new
      pat.amzv   = @amzv
      pat.iksnrs = @iksnrs
      pat
    else
      pat = PatinfoDocument.new
      pat
    end
    pat.name               = @name
    pat.company            = @company
    pat.galenic_form       = @galenic_form
    pat.effects            = @effects
    pat.amendments         = @amendments
    pat.contra_indications = @contra_indications
    pat.precautions        = @precautions
    pat.pregnancy          = @pregnancy
    pat.usage              = @usage
    pat.unwanted_effects   = @unwanted_effects
    pat.general_advice     = @general_advice
    #pat.other_advice      = @other_advice ## not identified yet.
    pat.composition        = @composition
    pat.packages           = @packages
    pat.distribution       = @distribution
    pat.fabrication        = @fabrication
    pat.date               = @date
    pat
  end
end
  end
end
