#!/usr/bin/env ruby
#View::Drugs::Narcotics  -- oddb -- 16.11.2005 -- spfenninger@ywesee.com


require 'view/alphaheader'
require 'view/resulttemplate'
require 'view/resultfoot'
require 'view/resultcolors'

module ODDB
	module View
		module Drugs
class NarcoticList < HtmlGrid::List
	include AlphaHeader
	COMPONENTS = {
		[0,0] => :casrn,
		[1,0] => :swissmedic_code,
		[2,0] => :substance,
		[3,0]	=> :category,
		[4,0] => :num_packages,
	}
	LEGACY_INTERFACE = false
	DEFAULT_CLASS = HtmlGrid::Value
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,4] => 'list',
		[4,0] 	=> 'list-r',
	}
	CSS_HEAD_MAP = {
		[0,0] => 'th',
		[1,0] => 'th',
		[2,0] => 'th',
		[3,0] => 'th',
		[4,0] => 'th-r',
	}
	SORT_HEADER = false
	SYMBOL_MAP = {
		:substance	=>	PointerLink,
		:casrn	=>	PointerLink,
	}
	def num_packages(model)
		model.packages.size
	end
end
class NarcoticsComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0] => :title_narcotics,
		[1,0] => SearchForm,
		[0,1] => NarcoticList,
		[0,2] => View::ResultFoot,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0] => 'result-found list',
	}
	COLSPAN_MAP = {
		[0,1] => 2,
		[0,2] => 2,
	}
	LEGACY_INTERFACE = false
	def title_narcotics(model)
		unless(model.empty?)
			@lookandfeel.lookup(:title_narcotics,
				@session.state.interval, @model.size)
		end
	end
end
class Narcotics < View::ResultTemplate
	CONTENT = View::Drugs::NarcoticsComposite
end
		end
	end
end
