#!/usr/bin/env ruby
# PatinfoHtmlWriter -- oddb -- 24.10.2003 -- rwaltert@ywesee.com
require 'writer'
require 'model/patinfo'

module ODDB
	module FiParse
		class PatinfoHtmlWriter < Writer
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
				pat.purpose = @pupose
				pat.contra_indications = @contra_indications
				pat.precautions = @precautions
				pat.pregnancy = @pregnancy
				pat.usage	= @usage
				pat.unwanted_effects = @unwanted_effects
				pat.general_advice	= @general_advice
				pat.other_advice = @other_advice
				pat.composition	= @composition
				pat.packages = @packages
				pat.distribution = @distribution
				pat.date = @date
				pat
			end
			def new_font(font_tuple)
				#puts "new_font #{(font_tuple || []).join('-')}"
				if(@chapter_flag)
					@chapter_flag = nil
					if(@chapter == @switch)
					# switch between old and new (2001) FI-Schema
						set_templates(@chapter)
					end
					# sometimes there will be empty <B><I> tags.
					# these do not count as real chapter headings
					# exception to the rule: the galenic_form chapter
					# may appear without heading, albeit only in the
					# older Fachinfo-Structure
					if(@chapter.heading.empty? \
					&& ((@chapter != @galenic_form) || @amzv))
						@templates.unshift(@chapters.pop)
						@chapter = @chapters.last
						@section = @chapter.next_section
					end
				end
				#	puts @chapter
				case font_tuple
				when ['h1',0,1,0]
					set_target(@name)
				when [nil,1,1,nil]
					if(@chapter && (@chapter == @composition) \
						&& @chapter.match(/\(Swissmedic\)/i))
						@chapter = next_chapter
						@chapter_flag = true
						para = @section.paragraphs.last
						@chapter.heading << para.text
						para.clear!
						@composition.clean!
					elsif(@chapter && (@chapter == @distribution) \
						&& @chapter.match(/(Packungsbeilage)|(Cette notice d'emballage)/i))
						@chapter = next_chapter
						para = @section.paragraphs.last
						@chapter.heading << para.text
						para.clear!
						@distribution.clean!
					end
					if(@chapter && @chapter.sections.empty?)
						@section = @chapter.next_section
						set_target(@section.subheading)
					else
						@chapter_flag = true
						@chapter = next_chapter
						@section = @chapter.next_section
						set_target(@chapter.heading)
					end
					if(@chapter == @date && !@date_dummy.nil?)
						para = @section.next_paragraph
						para << @date_dummy.heading
					end
				when [nil,1,nil,nil]
					if(@target.is_a?(Text::Paragraph) \
						&& !@target.empty?)
						@format = @target.set_format(:italic)
					elsif(@chapter)
						@section = @chapter.next_section
						set_target(@section.subheading)
					end
				else
					# Reset format
					unless(@format.nil?)
						@target.set_format if(@target.respond_to?(:set_format))
						@format = nil
					else
						# When the content of a section is on the same line
						# as its subheading
						target = if(@section)
							@section.next_paragraph
						end
						set_target(target)
					end
				end
			end
			def set_templates(chapter)
				if(@amzv.nil?)
					case chapter.heading
					when /9\.11\.2001/
						@amzv = chapter
						@templates = named_chapters [
							:effects, :switch,
						]
					when /Eigenschaften/i, /Allgemeine Angaben/i, /Propri.t.s/i, /Informations compl.mentaires/i
						@effects = chapter
						@templates = named_chapters [ :switch ]
					when /Verwendungszweck/i, /Emploi th.rapeutique/i
						@purpose = chapter
						@templates = named_chapters [ :switch ]
					when /Erg.{1,2}nzungen/, /Compl.ment d'information/i
						@amendments = chapter
						@templates = named_chapters [ :switch ]
					when /Kontraindikationen/, /Anwendungseinschr.{1,2}kungen/i, /Limitations d'emploi/i, /Contre-indications/i
						@contra_indications = chapter
						@templates = named_chapters [ :switch ]
					when /Vorsichts?massnahmen/, /Pr.cautions/i
						@precautions = chapter
						@templates = named_chapters [ :switch ]
					when /Schwangerschaft/, /Grossesse/i
						@pregnancy = chapter
						@templates = named_chapters [ :switch ]
					when /Dosierung/, /Posologie/i
						@usage = chapter
						@templates = named_chapters [ :switch ]
					when /Unerw.{1,2}nschte/i, /ind.sirables/i
						@unwanted_effects = chapter
						@templates = named_chapters  [ :switch ]
					when /Hinweise/i, /particuli.res/i
						@general_advice = chapter
						@templates = named_chapters [ :switch ]
					when /Weitere Angaben/i,/Aufbewahrungsvorschriften/i, /Informations suppl.mentaires/i, /Conservation/i
						@other_advice = chapter
						@templates = named_chapters [ :switch ]
					when /Composition/i, /Zusammensetzung/i
						@composition = chapter
						@templates = named_chapters [ :switch ]
					when /Verkaufsart/i, /Pr.sentation/i, /Mode d(e vente|'emploi)/i, /Packungen/i
						@packages = chapter
						@templates = named_chapters [
						  :distribution, :date
						]
					when /Zulassungsinhaberin/i, /Distributeur/i, /Vertriebsfirma/i
						@distribution = chapter
						@templates = named_chapters [ :date ]
					end
				else
					case chapter.heading
					when /beachtet/i, /tenir compte/i
						@amendments = chapter
						@templates = named_chapters [ 
							 :switch
						]
					when /nicht( oder nur mit Vorsicht)? angewendet/i,
							/pas .tre utilis./i
						@contra_indications = chapter
						@templates = named_chapters [ 
						  :switch
						]
					when /Vorsicht/i, /précautions/i
						@precautions = chapter
						@templates = named_chapters [
						 :switch
						]
					when /Schwangerschaft/i, /Grossesse/i
						@pregnancy = chapter
						@templates = named_chapters [
							:switch
						]
					when /Wie verwende/i, /Comment utiliser/i
						@usage = chapter
						@templates = named_chapters [
							:unwanted_effects, :general_advice,
							:composition,
							:switch
						]
					when /\(Swissmedic\)/i
						@iksnrs = chapter
						@templates = named_chapters [
							:switch
						]
					when /Packungen/i, /obtenez-vous/i, /emballages/i
						@packages = chapter
						@templates = named_chapters [
							:switch
						]
					when /Zulassungsinhaberin/i,/Distributeur/i, /Titulaire de l'autorisation/i
						@distribution = chapter
						@templates = named_chapters [
							:date_dummy, :date
						]
					end	
				end
			end
		end
	end
end
