#!/usr/bin/env ruby
# View::Drugs::Patinfo -- oddb -- 11.11.2003 -- rwaltert@ywesee.com

require 'view/popuptemplate'
require 'view/chapter'
require 'view/printtemplate'

module ODDB
	module View
		module Drugs
class Patinfo2001;end
class PatinfoInnerComposite < HtmlGrid::Composite
	CHAPTERS = [
		:galenic_form,
		:effects,
		:pupose,
		:amendments,
		:contra_indications,
		:precautions,
		:pregnancy,
		:usage,
		:unwanted_effects,
		:general_advice,
		:other_advice,
		:composition,
		:packages,
		:distribution,
		:date
	]
	COMPONENTS = {}
	DEFAULT_CLASS = View::Chapter
	def init
		yy = 0
		self::class::CHAPTERS.each { |name|
			if(@model.respond_to?(name) && \
				(chapter = @model.send(name)) && !chapter.empty?)
				components.store([0,yy], name)
				yy += 1
			end
		}
		super
	end
end
class Patinfo2001InnerComposite < View::Drugs::PatinfoInnerComposite
	CHAPTERS = [
		:amzv,
		:galenic_form,
		:effects,
		:amendments,
		:contra_indications,
		:precautions,
		:pregnancy,
		:usage,
		:unwanted_effects,
		:general_advice,
		:composition,
		:iksnrs,
		:packages,
		:distribution,
		:date
	]
end
class PatinfoPreviewComposite < HtmlGrid::Composite
	COLSPAN_MAP = {
		[0,1]	=> 2,
	}
	COMPONENTS = {
		[0,0]	=>	:patinfo_name,
		[1,0]	=>	:company,
		[0,1] =>	:document,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0] => 'th',
		[1,0]	=> 'th-r',
	}	
	DEFAULT_CLASS = HtmlGrid::Value
	def document(model, session)
		klass = case model
		when ODDB::PatinfoDocument2001
			View::Drugs::Patinfo2001InnerComposite
		else
			View::Drugs::PatinfoInnerComposite
		end
		klass.new(model, session, self)
	end
	def patinfo_name(model, session)
		@lookandfeel.lookup(:patinfo_name, model.name)
	end
end
class PatinfoComposite < View::Drugs::PatinfoPreviewComposite
	include View::Print
	COLSPAN_MAP = {
		[0,2]	=> 2,
	}
	COMPONENTS = {
		[0,0]	=>	:patinfo_name,
		[1,0]	=>	:company_name,
		[0,1]	=>	:print,
		[0,2] =>	:document,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0] => 'th',
		[1,0]	=> 'th-r',
		[0,2]	=> 'list',
	}	
	COMPONENT_CSS_MAP = {
		[0,1]	=> 'list-b',
	}
=begin
	def company(model, session)
		if(seq = model.sequences.first)
			seq.registration.company_name
		end
	end
=end
	def document(model, session)
		document = model.send(session.language)
		super(document, session)
	end
	def patinfo_name(model, session)
		document = model.send(@session.language)
		@lookandfeel.lookup(:patinfo_name, document.name)
	end
end
class PatinfoPrintComposite < View::Drugs::PatinfoComposite
	include View::PrintComposite
	INNER_COMPOSITE = View::Drugs::PatinfoInnerComposite
	PRINT_TYPE = :print_type_patinfo
end
class Patinfo < View::PopupTemplate
	CONTENT = View::Drugs::PatinfoComposite
end
class PatinfoPreview < View::PopupTemplate
	CONTENT = View::Drugs::PatinfoPreviewComposite
end	
class PatinfoPrint < View::PrintTemplate
	CONTENT = View::Drugs::PatinfoPrintComposite
end
		end
	end
end
