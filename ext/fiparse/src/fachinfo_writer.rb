#!/usr/bin/env ruby
# FachinfoWriter -- oddb -- 20.10.2003 -- rwaltert@ywesee.com

require 'model/fachinfo'
require 'writer'

module ODDB
	module FiParse
		module FachinfoWriterMethods
			def to_fachinfo
				fi = if(@amzv)
					fi = FachinfoDocument2001.new
					fi.amzv = @amzv
					fi.contra_indications = @contra_indications
					fi.pregnancy = @pregnancy
					fi.driving_ability = @driving_ability
					fi.preclinic = @preclinic
					fi.registration_owner = @registration_owner
					fi
				else
					fi = FachinfoDocument.new
					fi.delivery = @delivery
					fi.distribution = @distribution
					fi.fabrication = @fabrication
					fi.reference = @reference
					fi
				end
				fi.name = @name.gsub(/\?/u, '')
				fi.galenic_form = @galenic_form
				fi.composition = @composition
				fi.effects = @effects 
				fi.kinetic = @kinetic
				fi.indications = @indications
				fi.usage = @usage

				fi.restrictions = @restrictions
				fi.unwanted_effects = @unwanted_effects
				fi.interactions = @interactions
				fi.overdose = @overdose
				fi.other_advice = @other_advice
				fi.iksnrs = @iksnrs
        fi.packages = @packages
				fi.date = @date
				fi
			end
			private
			def set_templates(chapter)
				if(@amzv.nil?)
					case chapter.heading
					when /9\.11\.2001/u, /AMZV/u, /OEM.d/u
						@amzv = chapter
						@templates = named_chapters [
							:composition, :galenic_form, :indications,
							:usage, :contra_indications, :restrictions,
							:interactions, :pregnancy, :driving_ability,
              :unwanted_effects, :overdose, :effects, :switch,
						]
          when /Galenische\s*Form/iu, /Forme\s*gal.nique/iu
            ## this is an amzv-FI without Declaration, switch to amzv-mode.
            @galenic_form = chapter
            named_chapter(:amzv)
						@templates = named_chapters [
              :indications, :usage, :contra_indications, :restrictions,
              :interactions, :pregnancy, :driving_ability, :unwanted_effects,
              :overdose, :effects, :switch,
						]
					when /Zusammensetzung/u, /Composition/u, /Principes\s*actifs/u
						@composition = chapter
						@templates = named_chapters [
							:switch,
						]
					when /Eigenschaften/u, /Propri.t.s/u
						@effects = chapter
						@templates = named_chapters [
							:switch,
						]
					when /Weitere Angaben/iu, /Informations suppl.mentaires/iu
						@reference = chapter
						@templates = named_chapters [
							:switch,
						]
					when /Pharmakokinetik?/iu, /Pharmacocin.tique?/iu
						@kinetic = chapter
						@templates = named_chapters [
							:switch,
						]
					when /Indikationen/u, /Indications/u
						@indications = chapter
						@templates = named_chapters [
							:usage, :restrictions, 
							:unwanted_effects, :switch,
						]
					when /Interaktionen/u, /Interactions/u
						@interactions = chapter
						@templates = named_chapters [
							:switch,
						]
					when /berdosierung/u, /Surdosage/u
						@overdose = chapter
						@templates = named_chapters [
							:switch,
						]
					when /Sonstige/u, /Remarques/u
						@other_advice = chapter
						@templates = named_chapters [
							:switch
						]
					when /Auslieferung/u, /R.partiteur/u
						@delivery = chapter
						@templates = named_chapters [
							:switch,
						]
					when /Vertrieb/u, /Distributeur/u
						@distribution = chapter
						@templates = named_chapters [
							:switch,
						]
					when /Hersteller/u, /Fabricant/u
						@fabrication = chapter
						@templates = named_chapters [
							:switch,
						]
					when /IKS-Nummern?/iu, /Num.ros? OICM/iu,
            /Zulassungs(vermerk|nummer)/u, /Estampille|Num.ro\s+d.autorisation/u,
            /^\d{5}\s/u
						@iksnrs = chapter
						@templates = named_chapters [
							:date, :rest,
						]
					when /Stand\s+der\s+Information/iu, /Mise\s+.\s+jour/iu
						@date = chapter
						@templates = named_chapters [
							:rest,
						]
					end
				else
					case chapter.heading
          when /Pharmakokinetik?/iu, /Pharmacocin.tique?/iu
            @kinetic = chapter
						@templates = named_chapters [
              :switch,
            ]
          when /Pr.klinische Daten/iu, /(R.sultat|Donn.e?)s? pr.-?cliniques?/iu
            @preclinic = chapter
						@templates = named_chapters [
              :switch,
            ]
					when /Sonstige/u, /(Autres\s*)?Remarques/iu
						@other_advice = chapter
						@templates = named_chapters [
							:switch
						]
					when /Weitere Angaben/u, /Informations supp/u
						@templates = named_chapters [
              :switch,
						]
					when /Zulassungs(vermerk|nummer)/u, 
            /Estampille|Num.ro\s+d.autorisation/u, /Autorisation/, /^\d{5}\s/u
						@iksnrs = @switch
						@templates = named_chapters [
							:switch,
						]
					when /Packungen/u, /Pr.sentation/u, /Conditionnement/u, /Darreichungsform/u
						@packages = chapter
						@templates = named_chapters [
							:registration_owner, :switch
						]
					when /(Registration|Zulassung)sinhaber/u, /Titulaire/u
						@registration_owner = @switch
						@templates = named_chapters [
							:switch,
						]
					when /Hersteller/u, /Fabricant/u
						@fabrication = chapter
						@templates = named_chapters [
							:switch,
						]
					when /Stand der Information/u, /Mise? . jour de l.information/u,
            /Informationsstand/u
						@date = chapter
						@templates = named_chapters [
							:switch#, :rest,
						]
					end
				end
			end
		end
		class FachinfoWriter < Writer
			include FachinfoWriterMethods
		end
	end
end
