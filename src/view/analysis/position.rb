#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Analysis::Position -- oddb.org -- 10.01.2012 -- mhatakeyama@ywesee.com
# ODDB::View::Analysis::Position -- oddb.org -- 23.06.2006 -- sfrischknecht@ywesee.com

require 'htmlgrid/urllink'
require 'view/additional_information'
require 'view/dataformat'
require 'view/pointervalue'
require 'view/privatetemplate'
require 'view/analysis/result'
require 'view/resultfoot'
require 'model/analysis/position'
require 'view/analysis/explain_result'

module ODDB
	module View
		module Analysis
class AdditionalInfoComposite < HtmlGrid::Composite
	include View::AdditionalInformation
	CSS_CLASS = ''
	COMPONENTS = {
		[0,0]	=>	'dacapo_title',
	}	
	CSS_MAP = {
		[0,0,2]	=>	'subheading',
	}
	COLSPAN_MAP = {
		[0,0]	=> 2,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	LABELS = true
	def init
		counter = 1
		if(@model.info_description)
			components.update([0, counter]	=>	:info_description)
			counter += 1
		end
		if(@model.info_interpretation)
			components.update([0, counter]	=>	:info_interpretation)
			counter += 1
		end
		if(@model.info_indication)
			components.update([0, counter]	=>	:info_indication)
			counter += 1
		end
		if(@model.info_significance)
			components.update([0, counter]	=>	:info_significance)
			counter += 1
		end
		if(ext = @model.info_ext_material)
			components.update([0, counter]	=>	:info_ext_material)
			counter += 1
		end
		if(@model.info_ext_condition)
			components.update([0, counter]	=>	:info_ext_condition)
			counter += 1
		end
		if(@model.info_storage_condition)
			components.update([0, counter]	=>	:info_storage_condition)
			counter += 1
		end
		if(@model.info_storage_time)
			components.update([0, counter]	=>	:info_storage_time)
			counter += 1
		end
		css_map.update([0,1,1,counter -1]	=>	'list top')
		css_map.update([1,1,1,counter -1]	=>	'list')
		super
	end
	def info_ext_material(model)
				value = HtmlGrid::Value.new(model.info_ext_material, model, @session, self)
			if(/info@dacapo.ch/u.match(model.info_ext_material))
				value.value = $` + '<a href="mailto:info@dacapo.ch">' + $& + '</a>' + $'
			else
				value.value = model.info_ext_material
			end
			value
	end
end
class PositionInnerComposite < HtmlGrid::Composite
	include View::AdditionalInformation
	include DataFormat
	SYMBOL_MAP = {
		:feedback_label	=>	HtmlGrid::LabelText,
	}
	COMPONENTS	= {
		[0,0]		=>	:code,
		[0,1]		=>	:chapter,
		[0,2]		=>	:analysis_revision,
		[0,3,0]	=>	:description,
		[1,3,0]	=>	"nbsp",
		[1,3,1]	=>	:google_search,
		[0,4]		=>	:taxpoints,
		[0,5]		=>	:lab_areas,
		[0,6]		=>	:limitation_text,
		[0,7]		=>	:taxnote,	
	}
	CSS_CLASS = ''
	CSS_MAP = {
		[0,0,1,10]		=>	'list top',
		[1,0,1,10]		=>	'list',
	}
	LABELS = true
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
	def description(model, key = :description)
		value = HtmlGrid::Value.new(key, model, @session, self)
		if(model && (str = model.send(@session.language)))
			value.value = str.gsub(/(\d{4})\.(\d{2})/u) {
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
	def taxpoints(model, key = :taxpoints)
		value = HtmlGrid::Value.new(key, model, @session, self)
		effective_tax = sprintf("%1.2f", (model.taxpoints.to_i * 0.9).to_s)
		
		value.value = model.taxpoints.to_s + ' (' + model.taxpoints.to_s + ' x 0.90 CHF = ' + effective_tax  + ' CHF)'
		value
	end
end
class Permissions < HtmlGrid::List
	DEFAULT_HEAD_CLASS = 'subheading'
	SORT_HEADER =	false
	CSS_MAP = {
		[0,0,2]	=>	'list',
	}
	COMPONENTS = {
		[0,0]	=>	:specialization,
		[1,0]	=>	:restriction,
	}
end
class PositionComposite < HtmlGrid::Composite
	include ResultFootBuilder
	CSS_CLASS = 'composite'
	EXPLAIN_RESULT = View::Analysis::ExplainResult
	COMPONENTS = {
		[0,0]		=>	'position_details',
		[0,1]		=>	PositionInnerComposite,
		[0,2]		=>	:result_foot,
	}
	CSS_MAP	=	{
		[0,0]		=>	'th',
		[0,1]		=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LEGACY_INTERFACE = false
end

class PointerSteps < ODDB::View::PointerSteps
  def pointer_descr(model, session=@session)
    event = :analysis
    link = PointerLink.new(:pointer_descr, model, @session, self)
    link.href = @lookandfeel._event_url(event, {:group => model.groupcd})
    link
  end
end

class Position < View::PrivateTemplate
	CONTENT = PositionComposite
	SNAPBACK_EVENT = :result
  def backtracking(model, session=@session)
    ODDB::View::Analysis::PointerSteps.new(model, @session, self)
  end
end
		end
	end
end
