#!/usr/bin/env ruby
# View::Drugs::Fachinfo -- oddb -- 17.09.2003 -- rwaltert@ywesee.com

require 'view/drugs/privatetemplate'
require 'view/chapter'
require 'view/printtemplate'
require 'view/additional_information'
require 'view/changelog'

module ODDB
	module View
		module Drugs
class Fachinfo2001; end
class FiChapterChooserLink < HtmlGrid::Link
	def init
		@document = @model.send(@session.language)
		if(@document.respond_to?(:amzv))
			@value = @lookandfeel.lookup("fi_#{@name.to_s}_amzv")
		end
		@value ||= @lookandfeel.lookup("fi_" << @name.to_s)
		@attributes['title'] = if(@document.respond_to?(@name) \
			&& (chapter = @document.send(@name)))
			title = chapter.heading
			if(title.empty? && (section = chapter.sections.first))
				section.subheading
			else
				title
			end
		else
			@lookandfeel.lookup(@name)
		end
		args = [
			:chapter, @name,
			:pointer, @model.pointer,
		]
		unless(@session.user_input(:chapter) == @name.to_s)
			if(@model.pointer.skeleton == [:create])
				self.href = @lookandfeel.event_url(:self, {:chapter => @name})
			else
				self.href = @lookandfeel._event_url(:resolve, args)
			end
		end
	end
end
class FiChapterChooser < HtmlGrid::Composite
	include View::AdditionalInformation
	include View::Print
	XWIDTH = 8
	COLSPAN_MAP = {
		[2,0]	=>	XWIDTH - 3,
	}
	COMPONENTS = {
		[0,0]	=>	:full_text,
		[1,0]	=>	:ddd,
		#[2,0]	=>	:print,
	}
	COMPONENT_CSS_MAP = {
		[0,0,2]	=>	'chapter-tab',
		[2,0]		=>	'chapter-tab bold',
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,2]	=>	'chapter-tab',
		[2,0]		=>	'chapter-tab bold',
		[XWIDTH-1,0]		=>	'chapter-tab bold',
	}
	def init
		xwidth = self::class::XWIDTH
		unless(@model.pointer.skeleton == [:create])
			if(@session.state.allowed?)
				components.store([2,0], :print_edit)
				components.store([xwidth-1,0], :changelog)
			else
				components.store([2,0], :print)
			end
		end
		document = @model.send(@session.language)
		names = display_names(document)
		xx = 0
		yy = 0
		xoffset = xwidth
		pos = [0,0]
		names.each { |name|
			next if(name == :amzv)
			if((xx % xwidth) == 0)
				yy += 1
				xoffset -= xwidth
			end
			pos = [xx + xoffset, yy]
			components.store(pos, name)
			css_map.store(pos, 'chapter-tab')
			component_css_map.store(pos, 'chapter-tab')
			symbol_map.store(name, View::Drugs::FiChapterChooserLink)
			xx += 1
		}
		colspan_map.store(pos, xwidth - pos.at(0))
		super
	end
	def changelog(model, session)
		View::Drugs::FiChapterChooserLink.new(:changelog, 
			model, session, self)
	end
	def ddd(model, session)
		if(atc = model.atc_class)			
			View::Drugs::FiChapterChooserLink.new(:ddd, 
				model, session, self)
		end
	end
	def display_names(document)
		document.chapter_names
	end
	def full_text(model, session)
		if(@model.pointer.skeleton == [:create])
			@lookandfeel.lookup(:fachinfo_all)
		else
			link = HtmlGrid::Link.new(:fachinfo_all, model, session, self)
			link.set_attribute('title', @lookandfeel.lookup(:fachinfo_all_title))
			unless(@session.user_input(:chapter).nil?)
				link.href = @lookandfeel._event_url(:resolve, {:pointer => model.pointer})
			end
			link
		end
	end
end
class FachinfoInnerComposite < HtmlGrid::DivComposite
	COMPONENTS = {}
	DEFAULT_CLASS = View::Chapter
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
		[0,1] =>	View::Drugs::FachinfoInnerComposite,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0] => 'th',
		[1,0]	=> 'th right',
	}	
	DEFAULT_CLASS = HtmlGrid::Value
	def fachinfo_name(model, session)
		@lookandfeel.lookup(:fachinfo_name, model.name)
	end
end
class FachinfoPrintInnerComposite < FachinfoInnerComposite
	DEFAULT_CLASS = View::PrintChapter
end
class FachinfoPrintComposite < HtmlGrid::DivComposite #View::Drugs::FachinfoPreviewComposite
	include PrintComposite
	INNER_COMPOSITE = View::Drugs::FachinfoInnerComposite
	PRINT_TYPE = :print_type_fachinfo
	CSS_MAP = {
		0	=> 'print-type',
		1	=> 'print big',
		2	=> 'list right',
	}
end
class FachinfoComposite < View::Drugs::FachinfoPreviewComposite
	CHOOSER_CLASS = View::Drugs::FiChapterChooser
	COMPONENTS = {
		[0,0]	=>	:fachinfo_name,
		[1,0]	=>	:company_name,
		[0,1]	=>	:chapter_chooser,
		[0,2] =>	:document,
	}
	COLSPAN_MAP = {
		[0,1]	=>	2,
		[0,2]	=>	2,
	}
	CSS_MAP = {
		[0,0] => 'th',
		[1,0]	=> 'th right',
		[0,2]	=> 'list',
	}	
	def chapter_chooser(model, session)
		if(klass = self.class.const_get(:CHOOSER_CLASS))
			klass.new(model, session, self)
		end
	end
	def chapter_view(chapter, document)
		View::Chapter.new(chapter, document, @session, self)
	end
	def document(model, session)
		document = model.send(session.language)
		chapter = @session.user_input(:chapter)
		if(chapter == 'ddd')
			View::Drugs::DDDTree.new(model.atc_class, session, self)
		elsif(chapter == 'changelog')
		  View::ChangeLog.new(model.change_log, session, self)
		elsif(chapter != nil)
			chapter_view(chapter, document)
		else
			View::Drugs::FachinfoInnerComposite.new(document, session, self)
		end
	end
	def fachinfo_name(model, session)
		model = model.send(@session.language)
		super(model, session)
	end
end
class Fachinfo < PrivateTemplate
	CONTENT = View::Drugs::FachinfoComposite
	SNAPBACK_EVENT = :result
end
class FachinfoPreview < PrivateTemplate
	CONTENT = View::Drugs::FachinfoPreviewComposite
end
class FachinfoPrint < View::PrintTemplate
	CONTENT = View::Drugs::FachinfoPrintComposite
end
class CompanyFachinfoPrintComposite < FachinfoPrintComposite
	INNER_COMPOSITE = View::Drugs::FachinfoPrintInnerComposite
end
class CompanyFachinfoPrint < FachinfoPrint
	CONTENT = View::Drugs::CompanyFachinfoPrintComposite
end
class EditFiChapterChooser < FiChapterChooser
	def display_names(document)
		document.chapters
	end
end
class RootFachinfoComposite < View::Drugs::FachinfoComposite
	CHOOSER_CLASS = EditFiChapterChooser
	def init
		unless(@model.company.invoiceable?)
			components.update({
				[0,2], :invoiceability,
				[0,3], :document,
			})
			css_map.store([0,3], 'list')
		end
		super
	end
	def chapter_view(chapter, document)
		if(@model.company.invoiceable?)
			View::EditChapterForm.new(chapter, document, @session, self)
		elsif(@model.pointer.skeleton == [:create])
			# don't show anything
		else
			super
		end
	end
	def invoiceability(model, session=@session)
		PointerLink.new(:e_fi_not_invoiceable, model.company, @session, self)
	end
end
class RootFachinfo < PrivateTemplate
	CONTENT = View::Drugs::RootFachinfoComposite
	SNAPBACK_EVENT = :result
	DOJO_REQUIRE = [ 'dojo.widget.Editor2', 'ywesee.widget.SymbolPalette' ]
  JAVASCRIPTS = ['dojo/Editor']
	DOJO_PARSE_WIDGETS = true
end
		end
	end
end
