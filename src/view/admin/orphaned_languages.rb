#!/usr/bin/env ruby
# encoding: utf-8
# View::Admin::OrphanedLanguages -- oddb -- 11.12.2003 -- rwaltert@ywesee.com

module ODDB
	module View
		module Admin
class OrphanedLanguagesList < HtmlGrid::List
	OMIT_HEADER = true
	COMPONENTS = {
		[0,0]	=>  :language,
		[2,0]	=>	:name,
		[3,0]	=>	:preview,
	}
	COMPONENT_CSS_MAP = {
		[3,0]		=>	'small',
	}
	SORT_DEFAULT = :language
	def language(model, session)
		@lookandfeel.lookup(model.language)	
	end
	def name(model, session)
		begin
			model.document.name
		rescue RuntimeError => e
			e.message
		end
	end
	def preview(model, session)
		link = HtmlGrid::PopupLink.new(:preview, model, session, self)
		args = {
			"language_select" => model.language,
		}
		if(@container.respond_to? :list_index)
			args.store("index", @container.list_index)
		end
		link.href = @lookandfeel.event_url(:preview, args)
		link
	end
end
module OrphanedLanguages
	class OrphanedLanguageFacade < SimpleDelegator
		attr_reader :language
		attr_reader :document
		def initialize(lang, document)
			@language = lang
			@document = document
			super(document)
		end
	end
	def languages(model, session)
		if(model.is_a?(Hash))
			listmodel = model.collect { |lang, document|	
				OrphanedLanguageFacade.new(lang, document)
			}
			OrphanedLanguagesList.new(listmodel, session, self)
		end
	end
end
		end
	end
end
