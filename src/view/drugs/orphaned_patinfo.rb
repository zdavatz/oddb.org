#!/usr/bin/env ruby
# View::Druges::Orphaned Patinfo -- oddb -- 20.11.2003 -- rwaltert@ywesee.com

require 'view/publictemplate'
require 'view/drugs/orphaned_languages'
#require 'view/export'
require 'htmlgrid/link'
require 'htmlgrid/list'
require 'htmlgrid/form'

module ODDB
	module View
		module Drugs
class OrphanedPatinfoForm < View::Form
	COMPONENTS = {
		[0,0] => :delete_orphaned_patinfo,
		[0,0,1]=>:submit
	}
	EVENT = :delete_orphaned_patinfo
	FORM_METHOD = 'POST'
end
module OrphanedPatinfoLanguages
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
				View::Drugs::OrphanedLanguageFacade.new(lang, document)
			}
			View::Drugs::OrphanedLanguagesList.new(listmodel, session, self)
		end
	end
end
class OrphanedPatinfoListInnerComposite < HtmlGrid::Composite
	include View::Drugs::OrphanedLanguages
	CSS_CLASS = 'component'
	COMPONENTS = {
		[0,0]	=> :languages,
		[1,0] => :meaning_index,
	}
	COMPONENT_CSS_MAP = {
		[0,0]	=>	'list',
		[1,0]	=>	'list-small',
	}
	def meaning_index(model, session)
		link = HtmlGrid::Link.new(:choice, model, session, self)
		hash = { 
			:meaning_index	=> @container.list_index , 
			:state_id				=> @session.state.id,
		}
		link.href = @lookandfeel.event_url(:choice, hash)
		link
	end
	def list_index
		@container.list_index
	end
end
class OrphanedPatinfoList < HtmlGrid::List
	attr_reader :list_index
	CSS_CLASS = 'composite'
	STRIPED_BG = true
	OMIT_HEADER = true
	BACKGROUND_SUFFIX = '-bg'
	COMPONENTS = {
		[0,0]	=> View::Drugs::OrphanedPatinfoListInnerComposite,
	}
	CSS_MAP = {
		[0,0]	=>	'list',
	}
	SORT_DEFAULT = nil
end
class OrphanedPatinfoComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0] => :key,
		[0,1]	=> :reason,
		[0,2]	=> :meanings,
		[0,3] => View::Drugs::OrphanedPatinfoForm,	
		
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,1]	=>	'subheading',
	}
	CSS_CLASS = 'composite'
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'th'
	def reason(model, session)
		@lookandfeel.lookup(model.reason)
	end
	def meanings(model, session)
		View::Drugs::OrphanedPatinfoList.new(model.meanings, session, self)
	end
end
class OrphanedPatinfo < View::PrivateTemplate
	CONTENT = View::Drugs::OrphanedPatinfoComposite
	SNAPBACK_EVENT = :orphaned_patinfos
end
		end
	end
end
