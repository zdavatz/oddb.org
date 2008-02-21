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
				fi.name = @name
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
					when /9\.11\.2001/, /AMZV/
						@amzv = chapter
						@templates = named_chapters [
							:composition, :galenic_form, :indications,
							:usage, :contra_indications, :restrictions,
							:interactions, :pregnancy, :driving_ability,
							:unwanted_effects, :overdose, :effects,
							:kinetic, :preclinic, :switch,
						]
          when /Galenische\s*Form/i, /Forme\s*gal.nique/i
            ## this is an amzv-FI without Declaration, switch to amzv-mode.
            @galenic_form = chapter
            named_chapter(:amzv)
						@templates = named_chapters [
              :indications, :usage, :contra_indications, :restrictions,
              :interactions, :pregnancy, :driving_ability, :unwanted_effects,
              :overdose, :effects, :kinetic, :preclinic, :switch,
						]
					when /Zusammensetzung/, /Composition/
						@composition = chapter
						@templates = named_chapters [
							:switch,
						]
					when /Eigenschaften/, /Propri.t.s/
						@effects = chapter
						@templates = named_chapters [
							:switch,
						]
					when /Weitere Angaben/i, /Informations suppl.mentaires/i
						@reference = chapter
						@templates = named_chapters [
							:switch,
						]
					when /Pharmakokinetik/, /Pharmacocin.tique/
						@kinetic = chapter
						@templates = named_chapters [
							:switch,
						]
					when /Indikationen/, /Indications/
						@indications = chapter
						@templates = named_chapters [
							:usage, :restrictions, 
							:unwanted_effects, :switch,
						]
					when /Interaktionen/, /Interactions/
						@interactions = chapter
						@templates = named_chapters [
							:switch,
						]
					when /berdosierung/, /Surdosage/
						@overdose = chapter
						@templates = named_chapters [
							:switch,
						]
					when /Sonstige/, /Remarques/
						@other_advice = chapter
						@templates = named_chapters [
							:switch
						]
					when /Auslieferung/, /R.partiteur/
						@delivery = chapter
						@templates = named_chapters [
							:switch,
						]
					when /Vertrieb/, /Distributeur/
						@distribution = chapter
						@templates = named_chapters [
							:switch,
						]
					when /Hersteller/, /Fabricant/
						@fabrication = chapter
						@templates = named_chapters [
							:switch,
						]
					when /IKS-Nummern?/i, /Num.ros? OICM/i, 
            /Zulassungs(vermerk|nummer)/, /Estampille|Num.ro\s+d.autorisation/
						@iksnrs = chapter
						@templates = named_chapters [
							:date, :rest,
						]
					when /Stand\s+der\s+Information/i, /Mise\s+.\s+jour/i
						@date = chapter
						@templates = named_chapters [
							:rest,
						]
					end
				else
					case chapter.heading
					when /Sonstige/, /(Autres\s*)?Remarques/i
						@other_advice = chapter
						@templates = named_chapters [
							:switch
						]
					when /Weitere Angaben/, /Informations supp/
						@templates = named_chapters [
              :switch,
						]
					when /Zulassungs(vermerk|nummer)/, 
            /Estampille|Num.ro\s+d.autorisation/, /Autorisation/
						@iksnrs = @switch
						@templates = named_chapters [
							:switch,
						]
					when /Packungen/, /Pr.sentation/, /Conditionnement/
						@packages = chapter
						@templates = named_chapters [
							:registration_owner, :switch
						]
					when /(Registration|Zulassung)sinhaber/, /Titulaire/
						@registration_owner = @switch
						@templates = named_chapters [
							:switch,
						]
					when /Hersteller/, /Fabricant/
						@fabrication = chapter
						@templates = named_chapters [
							:switch,
						]
					when /Stand der Information/, /Mise? . jour de l.information/
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
