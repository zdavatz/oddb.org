#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::FiParse::FachinfoHpricot -- oddb.org -- 27.02.2013 -- yasaka@ywesee.com
# ODDB::FiParse::FachinfoHpricot -- oddb.org -- 30.01.2012 -- mhatakeyama@ywesee.com
# ODDB::FiParse::FachinfoHpricot -- oddb.org -- 17.08.2006 -- hwyss@ywesee.com

require 'model/fachinfo'
require 'textinfo_hpricot'

module ODDB
  module FiParse
class FachinfoHpricot < TextinfoHpricot
  attr_reader :amzv, :name, :composition, :galenic_form, :indications, :effects, :indications,
              :usage, :kinetic, :restrictions, :unwanted_effects, :interactions,
              :overdose, :other_advice, :iksnrs, :date, :pregnancy, :driving_ability,
              :contra_indications, :packages
  def identify_chapter(code, chapter)
    case code
    when '6900'
      @amzv = chapter
    when '6950', 'section1'
      @name = chapter
    when '3300', '7000', 'section2'
      @composition = chapter
    when '7050', 'section3'
      @galenic_form = chapter
    when '4000', '7100', 'section4'
      @indications = chapter
    when '7200', 'section6'
      @contra_indications = chapter
    when '4400', '7250', 'section7'
      @restrictions = chapter
    when '3500', '7550', 'section13'
      @effects = chapter
    when '4200', '7150', 'section5'
      @usage = chapter
    when '3700', '7600', 'section14'
      @kinetic = chapter
    when '4700', '7450', 'section11'
      @unwanted_effects = chapter
    when '4800', '7300', 'section8'
      @interactions = chapter
    when '7350', 'section9'
      @pregnancy = chapter
    when '7400', 'section10'
      @driving_ability = chapter
    when '5000', '7500', 'section12'
      @overdose = chapter
    when '5200', '7700', 'section16'
      @other_advice = chapter
    when '5998', '7750', 'section17'
      @iksnrs = chapter
    when '6100', '8000', 'section20'
      @date = chapter
    when '7650', 'section15'
      @preclinic = chapter
    when '7850', 'section19'
      @registration_owner = chapter
    when '5610', '7860'
      @fabrication = chapter
    when '7870'
      @delivery = chapter
    when '5595'
      @distribution = chapter
    when '7800', '9100', 'section18'
      @packages = chapter
    when nil # special chapers without heading
      @galenic_form ||= chapter
    when '9200'
      # skip "Beschreibung"
    else
      raise "Unknown chapter-code #{code}, while parsing #{@name}"
    end
  end
  def to_textinfo
    fi = if(@amzv)
      fi = FachinfoDocument2001.new
      fi.amzv               = @amzv
      fi.contra_indications = @contra_indications
      fi.pregnancy          = @pregnancy
      fi.registration_owner = @registration_owner
      fi.driving_ability    = @driving_ability
      fi.preclinic          = @preclinic
      fi
    else
      fi = FachinfoDocument.new
      fi
    end
    fi.name             = @name
    fi.galenic_form     = @galenic_form
    fi.effects          = @effects
    fi.kinetic          = @kinetic
    fi.indications      = @indications
    fi.usage            = @usage
    fi.restrictions     = @restrictions
    fi.unwanted_effects = @unwanted_effects
    fi.interactions     = @interactions
    fi.overdose         = @overdose
    fi.other_advice     = @other_advice
    fi.composition      = @composition
    fi.packages         = @packages
    fi.reference        = @reference
    fi.delivery         = @delivery
    fi.distribution     = @distribution
    fi.fabrication      = @fabrication
    fi.iksnrs           = @iksnrs
    fi.date             = @date
    fi
  end
end
  end
end
