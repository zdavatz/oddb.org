#!/usr/bin/env ruby
# View::Analysis::Position -- oddb.org -- 23.06.2006 -- sfrischknecht@ywesee.com

require 'htmlgrid/urllink'
require 'view/additional_information'
require 'view/dataformat'
require 'view/pointervalue'
require 'view/privatetemplate'
require 'view/analysis/result'
require 'model/analysis/position'

module ODDB
	module View
		module Analysis
class PositionInnerComposite < HtmlGrid::Composite
	include View::AdditionalInformation
	include DataFormat
	SYMBOL_MAP = {
		:feedback_label	=>	HtmlGrid::LabelText,
	}
	COMPONENTS	= {
		[0,0]		=>	:code,
		[0,1]		=>	:description,
		[0,2]		=>	:limitation,
		[0,3]		=>	:anonymous,
		[0,4]		=>	:taxpoints,
		[0,5]		=>	:taxnote,	
#		[0,6]		=>	:feedback_label,
#		[1,6]		=>	:feedback,
		[0,6]		=>	:footnote,
	}
	CSS_CLASS = ''
	CSS_MAP = {
		[0,0,1,8]		=>	'list top',
		[1,0,1,8]		=>	'list',
	}
	CSS_STYLE_MAP = {
		[1,0,1,6]		=>	'max-width:250px',
	}
	LABELS = true
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	def anonymous(model, key = :anonymous)
			value = HtmlGrid::Value.new(key, model, @session, self)
			if(model.anonymous)
			value.value = [model.anonymousgroup.dup,
				model.anonymouspos].join('.')
			else value.value = @lookandfeel.lookup(:false)
			end
			value
	end
	def description(model, key = :description)
		value = HtmlGrid::Value.new(key, model, @session, self)
		value.value = model.description.gsub(/(\d{4})\.(\d{2})/) {
			group_code = $~[1]
			pos_code = $~[2]
			ptr = Persistence::Pointer.new([:analysis_group, group_code])
			ptr += [:position, pos_code]
			args = {:pointer => ptr}
			'<a class="list" href="' << @lookandfeel._event_url(:resolve, args) << '">' << $~[0] << '</a>'
		}
		value
	end
	def footnote(model, key = :footnote)
		value = HtmlGrid::Value.new(key, model, @session, self)
		if(model.footnote)
			value.value = model.footnote
		else value.value = @lookandfeel.lookup(:false)
		end
		value
	end
	def limitation(model, key = :limitation)
		value = HtmlGrid::Value.new(key, model, @session, self)
		if(model.limitation)
			value.value = model.limitation
		else value.value = @lookandfeel.lookup(:false)
		end
		value
	end
	def taxnote(model, key = :taxnote)
		value = HtmlGrid::Value.new(key, model, @session, self)
		if(model.taxnote)
			value.value = model.taxnote
		else value.value = @lookandfeel.lookup(:false)
		end
		value
	end
	def taxpoints(model, key = :taxpoints)
		value = HtmlGrid::Value.new(key, model, @session, self)
		effective_tax = (model.taxpoints.to_i * 0.9).to_s
		value.value = model.taxpoints.to_s << ', ' << model.taxpoints.to_s << ' * 0.9 = ' << effective_tax
		value
	end
end
class Permissions < HtmlGrid::List
	DEFAULT_HEAD_CLASS = 'subheading'
	CSS_MAP = {
		[0,0,2]	=>	'list',
	}
	COMPONENTS = {
		[0,0]	=>	:specialization,
		[1,0]	=>	:restriction,
	}
end
class PositionComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]		=>	'position_details',
		[0,1]		=>	PositionInnerComposite,
		[0,2]		=>	:permissions,
	}
	CSS_MAP	=	{
		[0,0]		=>	'th',
		[0,1]		=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	def permissions(model)
		Permissions.new(model.permissions, @session, self)
	end
end
class Position < View::PrivateTemplate
	CONTENT = PositionComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
