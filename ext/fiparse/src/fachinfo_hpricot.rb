#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::FiParse::FachinfoHpricot -- oddb.org -- 05.03.2013 -- yasaka@ywesee.com
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
    when '6950'
      @name = chapter
    when '3300', '7000'
      @composition = chapter
    when '7050'
      @galenic_form = chapter
    when '4000', '7100'
      @indications = chapter
    when '7200'
      @contra_indications = chapter
    when '4400', '7250'
      @restrictions = chapter
    when '3500', '7550'
      @effects = chapter
    when '4200', '7150'
      @usage = chapter
    when '3700', '7600'
      @kinetic = chapter
    when '4700', '7450'
      @unwanted_effects = chapter
    when '4800', '7300'
      @interactions = chapter
    when '7350'
      @pregnancy = chapter
    when '7400'
      @driving_ability = chapter
    when '5000', '7500'
      @overdose = chapter
    when '5200', '7700'
      @other_advice = chapter
    when '5998', '7750'
      @iksnrs = chapter
    when '6100', '8000'
      @date = chapter
    when '7650'
      @preclinic = chapter
    when '7850'
      @registration_owner = chapter
    when '5610', '7860'
      @fabrication = chapter
    when '7870'
      @delivery = chapter
    when '5595'
      @distribution = chapter
    when '7800', '9100'
      @packages = chapter
    when nil # special chapers without heading
      @galenic_form ||= chapter
    when '9200', '8500'
      # skip "Beschreibung" and unexpected 'AMZV'
    else
      raise "Unknown chapter-code #{code}, while parsing #{@name}"
    end
  end
  def to_textinfo
    fi = if (@amzv or (@format == :swissmedicinfo))
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
  private
  def detect_chapter(elem)
    return [nil, nil] unless /^section[0-9]*$/i.match(elem.attributes['id'].to_s)
    # TODO
    #   Update chapter detection if swissmedic repairs FI/PI format.
    #
    #   Currently, id attribute 'section*' is not fixed number.
    #   And Section order is also not fixed :(
    text = text(elem).sub(/^\s/, '')
    code =
    case text
    when /^Zusammensetzung(en)?|^Composition[s]?/                                                                                               ; '7000'
    when /^Galenische\s*Form(en)?\s*und\s*Wirkstoffmenge[n]?\s*pro\s*Einheit|^Forme[n]?\s*gal.nique[s]?\s*et\s*quantit.[s]?\s*de\s*/            ; '7050'
    when /^Indikation(en)?\s*\/\s*Anwendungsm.glichkeit(en)?|^Indications\s*\/\s*[pP]ossibilit.s\s*d.emploi/                                    ; '7100'
    when /^Dosierung\s*\/\s*Anwendung|^Posologie\s*\/\s*[mM]ode\s*d.emploi/                                                                     ; '7150'
    when /^Kontraindikation(en)?|^Contre\s*\-\s*[iI]ndication(s)?/                                                                              ; '7200'
    when /^Warnhinweise\s*und\s*[vV]orsichtsmassnahm(en)?|^Mises\s*en\s*garde\s*et\s*pr.cautions/                                               ; '7250'
    when /^Interaktion(en)\s*$|^Interaction(s)\s*$/                                                                                             ; '7300'
    when /^Schwangerschaft\s*[,\/]?\s*Stillzeit|^Grossesse\s*[,\/]?\s*[aA]llaitement/                                                           ; '7350'
    when /^Wirkungen\s*auf\s*die\sFahrt.chtigkeit\s*und\s*auf\s*Bedienen\s*von\sMashinen|^Effet\s*sur\s*l.aptitude\s*.\s*la\s*conduite\s*et\s*/ ; '7400'
    when /^Unerwünschte\s*Wirkung(en)?|^Effets\s*ind.sirables/                                                                                  ; '7450'
    when /^Überdosierung|^Surdosage/                                                                                                            ; '7500'
    when /^Eigenschaft(en)?\s*\/\s*Wirkung(en)?|^Propri.t.s\s*\/\s*[eE]ffets/                                                                   ; '7550'
    when /^Pharmakokinetik|^Pharmacocin.tique/                                                                                                  ; '7600'
    when /^Pr.klinische\s*Daten|Donn.es\s*pr.cliniques/                                                                                         ; '7650'
    when /^Sonstige\s*Hinweise|^Remarques\s*particuli.res/                                                                                      ; '7700'
    when /^Zulassungsnummer[n]?|^Num.ro\s*d.autorisation/                                                                                       ; '7750'
    when /^Packungen|^Pr.sentation[s]?/                                                                                                         ; '7800'
    when /^Zulassungsinhaberin(en)?|^Titulaire\s*de\s*l.autorisation/                                                                           ; '7850'
    when /^Herstellerin(en)?|^Fabricant/                                                                                                        ; '7860'
    when /^Stand\s*der\s*Information|^Mise\s*.\s*jour\s*de\s*l.information/                                                                     ; '8000'
    end
    [code, text]
  end
end
  end
end
