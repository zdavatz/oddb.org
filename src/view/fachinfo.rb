#!/usr/bin/env ruby
# FachinfoView -- oddb -- 17.09.2003 -- rwaltert@ywesee.com

require 'view/popuptemplate'
require 'view/chapter'
require 'view/printtemplate'

module ODDB
	class Fachinfo2001; end
	class FiChapterChooserLink < HtmlGrid::Link
		def init
			@document = @model.send(@session.language)
			if(@document.respond_to?(:amzv))
				@value = @lookandfeel.lookup("fi_#{@name.to_s}_amzv")
			end
			@value ||= @lookandfeel.lookup("fi_" << @name.to_s)
			@attributes['title'] = if(@document.respond_to? @name)
				chapter = @document.send(@name)
				title = chapter.heading
				if(title.empty? && (section = chapter.sections.first))
					section.subheading
				else
					title
				end
			else
				@lookandfeel.lookup(@name)
			end
			args = {
				:chapter => @name,
				:pointer => @model.pointer,
			}
			unless(@session.user_input(:chapter) == @name.to_s)
				self.href = @lookandfeel.event_url(:resolve, args)
			end
		end
	end
	class FiChapterChooser < HtmlGrid::Composite
		include AdditionalInformation
		include Print
		XWIDTH = 8
		COLSPAN_MAP = {
			[2,0]	=>	XWIDTH - 2,
		}
		COMPONENTS = {
			[0,0]	=>	:full_text,
			[1,0]	=>	:ddd,
			[2,0]	=>	:print,
		}
		COMPONENT_CSS_MAP = {
			[0,0,1]	=>	'chapter-tab',
			[2,0]		=>	'chapter-tab-b',
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0,2]	=>	'chapter-tab'
		}
		def init
			xwidth = self::class::XWIDTH
			document = @model.send(@session.language)
			names = document.chapter_names
			xx = 0
			yy = 0
			xoffset = xwidth
			pos = [0,0]
			names.each { |name|
				next if(name == :amzv)
				if((chapter = document.send(name)) )#&& !chapter.heading.empty?)
					if((xx % xwidth) == 0)
						yy += 1
						xoffset -= xwidth
					end
					pos = [xx + xoffset, yy]
					components.store(pos, name)
					css_map.store(pos, 'chapter-tab')
					component_css_map.store(pos, 'chapter-tab')
					symbol_map.store(name, FiChapterChooserLink)
					xx += 1
				end
			}
			colspan_map.store(pos, xwidth - pos.at(0))
			super
		end
		def full_text(model, session)
			link = HtmlGrid::Link.new(:fachinfo_all, model, session, self)
			link.set_attribute('title', @lookandfeel.lookup(:fachinfo_all_title))
			unless(@session.user_input(:chapter).nil?)
				link.href = @lookandfeel.event_url(:resolve, {:pointer => model.pointer})
			end
			link
		end
		def ddd(model, session)
			if(atc = model.atc_class)			
				FiChapterChooserLink.new(:ddd, model, session, self)
=begin
				link = HtmlGrid::Link.new(:ddd, atc, session, self)
				link.href = @lookandfeel.event_url(:ddd, {'pointer'=>atc.pointer})
				#link.set_attribute('class', 'result-infos-bg')
				link.set_attribute('title', @lookandfeel.lookup(:ddd_title))
				link
=end
			end
		end
	end
	class FachinfoInnerComposite < HtmlGrid::Composite
		COMPONENTS = {}
		DEFAULT_CLASS = ChapterView
		def init
			@model.chapter_names.each_with_index { |name, idx|
				components.store([0,idx], name)
			}
			super
		end
	end
=begin
	class Fachinfo2001InnerComposite < FachinfoInnerComposite
		CHAPTERS = [
			:amzv,
			:composition,
			:galenic_form,
			:indications,
			:usage,
			:contra_indications,
			:restrictions,
			:interactions,
			:pregnancy,
			:driving_ability,
			:unwanted_effects,
			:overdose,
			:effects,
			:kinetic,
			:preclinic,
			:other_advice,
			:iksnrs,
			:registration_owner,
			:date,
		]
	end
=end
	class FachinfoPreviewComposite < HtmlGrid::Composite
		COLSPAN_MAP = {
			[0,1]	=> 2,
		}
		COMPONENTS = {
			[0,0]	=>	:fachinfo_name,
			[1,0]	=>	:company,
			[0,1] =>	FachinfoInnerComposite,
		}
		CSS_CLASS = 'composite'
		CSS_MAP = {
			[0,0] => 'th',
			[1,0]	=> 'th-r',
		}	
		DEFAULT_CLASS = HtmlGrid::Value
		def document(model, session)
=begin
			klass = case model
			when FachinfoDocument2001
				Fachinfo2001InnerComposite
			else
				FachinfoInnerComposite
			end
			klass.new(model, session, self)
=end
			FachinfoInnerComposite.new(model, session, self)
		end
		def fachinfo_name(model, session)
			@lookandfeel.lookup(:fachinfo_name, model.name)
		end
	end
	class FachinfoPrintComposite < FachinfoPreviewComposite
		include PrintComposite
		INNER_COMPOSITE = FachinfoInnerComposite
		PRINT_TYPE = :print_type_fachinfo
	end
	class FachinfoComposite < FachinfoPreviewComposite
		COMPONENTS = {
			[0,0]	=>	:fachinfo_name,
			[1,0]	=>	:company_name,
			[0,1]	=>	FiChapterChooser,
			[0,2] =>	:document,
		}
		COLSPAN_MAP = {
			[0,1]	=>	2,
			[0,2]	=>	2,
		}
		CSS_MAP = {
			[0,0] => 'th',
			[1,0]	=> 'th-r',
			[0,2]	=> 'list',
		}	
		def document(model, session)
			document = model.send(session.language)
			chapter = @session.user_input(:chapter)
			if(chapter == 'ddd')
				DDDTree.new(model.atc_class, session, self)
			elsif(chapter)
				ChapterView.new(chapter, document, session, self)
			else
				#super(document, session)
				FachinfoInnerComposite.new(document, session, self)
			end
		end
		def fachinfo_name(model, session)
			model = model.send(@session.language)
			super(model, session)
		end
	end
	class FachinfoView < PopupTemplate
		CONTENT = FachinfoComposite
	end
	class FachinfoPreview < PopupTemplate
		CONTENT = FachinfoPreviewComposite
	end
	class FachinfoPrintView < PrintTemplate
		CONTENT = FachinfoPrintComposite
	end
end
