#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Substances::SelectSubstance -- oddb.org -- 22.06.2011 -- mhatakeyama@ywesee.com
# ODDB::View::Substances::SelectSubstance -- oddb.org -- 30.09.2004 -- hwyss@ywesee.com

require 'htmlgrid/formlist'
require 'view/privatetemplate'

module ODDB
	module View
		module Substances
class TargetList < HtmlGrid::FormList
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0,0]	=>	:pointer,
		[0,0,1]	=>	:name,
		[1,0]	  =>	:lt,
		[2,0]	  =>	:de,
		[3,0]	  =>	:fr,
		[4,0]	  =>	:en,
	}
	CSS_MAP = {
		[0,0,5]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'subheading'
	EMPTY_LIST = true
	EVENT = :merge
	OMIT_HEADER = true
	SYMBOL_MAP = {
		:pointer =>	HtmlGrid::InputRadio
	}
end
class SelectSubstanceComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0,0]	=>	:source_name,
		[0,0,1]	=>	'merge_with',
		[0,1]	=>	:targets,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
	}
	LEGACY_INTERFACE = false
	def source_name(model)
		model.source.name
	end
	def targets(model)
		TargetList.new(model.targets, @session, self)
	end
end
class SelectSubstance < View::PrivateTemplate
	CONTENT = ODDB::View::Substances::SelectSubstanceComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
