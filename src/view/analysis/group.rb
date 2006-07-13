#!/usr/bin/env ruby
# View::Analysis::Group -- oddb.org -- 05.07.2006 -- sfrischknecht@ywesee.com

require 'view/privatetemplate'
require 'view/pointervalue'
require 'view/analysis/result'
require 'model/analysis/group'

module ODDB
	module View
		module Analysis
class	PositionList < HtmlGrid::List
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	=> :poscd,
		[1,0]	=> :description
	}
	CSS_MAP = {
		[0,0,2]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	OMIT_HEADER = true
	SORT_DEFAULT = :poscd
	SYMBOL_MAP = {
		:description	=>	PointerLink,
	}
	LOOKANDFEEL_MAP = {
		:poscd	=>	:analysis_positions,
	}
end
class GroupHeader < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS =	{
		[0,0]			=>	:analysis_positions,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	LABELS = true
	def analysis_positions(model)
		[@lookandfeel.lookup(:analysis_positions), model.groupcd].join(' ')
	end
end
class GroupComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]		=>	GroupHeader,
		[0,1]		=>	:positionlist,
	}
	CSS_MAP	=	{
		[0,0]		=>	'th',
	}
	LABELS = true
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	def positionlist(model)
		pos = model.positions.values
		if(!pos.empty?)
			PositionList.new(pos, @session, self)
		end
	end
end
class Group < View::PrivateTemplate
	CONTENT = GroupComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
