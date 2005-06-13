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
				#puts "name " << fi.name
				fi.galenic_form = @galenic_form
				#puts "galenic " << fi.galenic_form.heading
				fi.composition = @composition
				#puts "composite " << fi.composition.heading
				fi.effects = @effects 
				#puts "effects " << fi.effects.heading
				fi.kinetic = @kinetic
				#		puts "kinetic " << fi.kinetic.heading
				fi.indications = @indications
				#	puts "indications " << fi.indications.heading
				fi.usage = @usage
				#		puts "indications " << fi.indications.heading

				fi.restrictions = @restrictions
				#	puts "indications " << fi.indications.heading
				fi.unwanted_effects = @unwanted_effects
				#	puts "indications " << fi.indications.heading
				fi.interactions = @interactions
				#		puts "indications " << fi.indications.heading
				fi.overdose = @overdose
				#puts "overdose " << fi.overdose.heading
				fi.other_advice = @other_advice
				#	puts "other advice " << fi.other_advice.heading
				fi.iksnrs = @iksnrs
				#	puts "iksnrs " << fi.iksnrs.heading
				fi.date = @date
				fi
			end
			private
			def set_templates(chapter)
				if(@amzv.nil?)
					#puts "********"
					#puts chapter.heading
					case chapter.heading
					when /9\.11\.2001/
						@amzv = chapter
						@templates = named_chapters [
							:composition, :galenic_form, :indications,
							:usage, :contra_indications, :restrictions,
							:interactions, :pregnancy, :driving_ability,
							:unwanted_effects, :overdose, :effects,
							:kinetic, :preclinic, :other_advice, :switch,
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
					when /IKS-Nummern?/i, /Num.ros? OICM/i
						@iksnrs = chapter
						@templates = named_chapters [
							:date, :rest,
						]
					when ''
					end
				else
					case chapter.heading
					when /Weitere Angaben/, /Informations supp/
						@templates = named_chapters [
							:iksnrs, :registration_owner, :date, :rest,
						]
					when /Packungen/, /Pr.sentation/
						@packages = chapter
						@templates = named_chapters [
							:registration_owner, :date, :rest,
						]
					when /(Registration|Zulassung)sinhaber/, /Titulaire/
						@registration_owner = @switch
						@templates = named_chapters [
							:switch,
						]
					when /Stand der Information/, /Mise? . jour de l.information/
						@date = chapter
						@templates = named_chapters [
							:rest,
						]
					when /Zulassungsvermerk/, /Estampille/
						@iksnrs = @switch
						@templates = named_chapters [
							:switch,
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
