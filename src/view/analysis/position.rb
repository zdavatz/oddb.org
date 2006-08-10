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
		[0,1]		=>	:anonymous,
		[0,2]		=>	:analysis_revision,
		[0,3]		=>	:description,
		[0,4]		=>	:taxpoints,
		[0,5]		=>	:lab_areas,
		[0,6]		=>	:limitation_text,
		[0,7]		=>	:finding,
		[0,8]		=>	:taxnote,	
#		[0,7]		=>	:feedback_label,
#		[1,7]		=>	:feedback,
		[0,9]		=>	:footnote,
	}
	CSS_CLASS = ''
	CSS_MAP = {
		[0,0,1,10]		=>	'list top',
		[1,0,1,10]		=>	'list',
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
			value.value = [model.anonymousgroup.dup, model.anonymouspos].join('.')
			end
=begin
			if(model.anonymous)
			value.value = [model.anonymousgroup.dup,
				model.anonymouspos].join('.')
			else value.value = @lookandfeel.lookup(:false)
			end
=end
			value
	end
	def description(model, key = :description)
		value = HtmlGrid::Value.new(key, model, @session, self)
		if(model && (str = model.send(@session.language)))
			value.value = str.gsub(/(\d{4})\.(\d{2})/) {
				group_code = $~[1]
				pos_code = $~[2]
				ptr = Persistence::Pointer.new([:analysis_group, group_code])
				ptr += [:position, pos_code]
				args = {:pointer => ptr}
				'<a class="list" href="' << @lookandfeel._event_url(:resolve, args) << '">' << $~[0] << '</a>'
			}
		end
		value
	end
	def limitation_text(model)
		description(model.limitation_text, :limitation)
	end
	def taxnote(model)
		description(model.taxnote, :taxnote)
	end
	def footnote(model)
		description(model.footnote, :footnote)
	end
	def taxpoints(model, key = :taxpoints)
		value = HtmlGrid::Value.new(key, model, @session, self)
		effective_tax = sprintf("%1.2f", (model.taxpoints.to_i * 0.9).to_s)
		
		value.value = model.taxpoints.to_s << ' (' << model.taxpoints.to_s << ' x 0.90 CHF = ' << effective_tax  << ' CHF)'
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
		Permissions.new(model.permissions.send(@session.language), @session, self)
	end
end
class Position < View::PrivateTemplate
	CONTENT = PositionComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
