#!/usr/bin/env ruby
# View::Drugs::Fachinfos -- oddb -- 17.11.2005 -- hwyss@ywesee.com

require 'view/additional_information'
require 'view/alphaheader'
require 'view/pointersteps'
require 'view/resultcolors'
require 'view/resulttemplate'
require 'htmlgrid/list'

module ODDB
	module View
		module Drugs
class FachinfoList < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=> :fachinfo,
		[1,0]	=> :name,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'small result',
		[1,0]	=>	'result-big',
	}
	SORT_DEFAULT = false
	SORT_HEADER = false
	LEGACY_INTERFACE = false
	include View::AlphaHeader
	include View::AdditionalInformation
	include View::ResultColors
	def fachinfo(model)
		_fachinfo(model)
	end
	def name(model)
		link = HtmlGrid::Link.new(:name_base, model, @session, self)
		link.value = model.send(@session.language).name
		args = {
			'search_query'	=>	model.name_base,
		}
		link.href = @lookandfeel._event_url(:search, args)
		link.css_class = 'result-big' << resolve_suffix(model)
		link
	end
end
class FachinfosComposite < HtmlGrid::Composite
	include Snapback
	COMPONENTS = {
		[0,0]	=>	View::PointerSteps,
		[0,1]	=> :title_fachinfos,
		[1,1]	=>	SearchForm,
		[0,2]	=> View::Drugs::FachinfoList,
		[0,3]	=> View::ResultFoot,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,1]	=>	'result-found list',
	}
	COLSPAN_MAP	= {
		[0,0]	=> 2,
		[0,2]	=> 2,
		[0,3]	=> 2,
	}
	LEGACY_INTERFACE = false
	SNAPBACK_EVENT = :fachinfos
	def title_fachinfos(model)
		unless(model.empty?)
			@lookandfeel.lookup(:title_fachinfos, 
				@session.state.interval, @model.size, @session.fachinfo_count)
		end
	end
end
class Fachinfos < ResultTemplate
	CONTENT = View::Drugs::FachinfosComposite
end
		end
	end
end
