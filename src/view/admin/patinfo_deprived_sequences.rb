#!/usr/bin/env ruby
# View::Admin::PatinfoDeprivedSequences -- oddb -- 08.12.2003 -- rwaltert@ywesee.com

require 'view/drugs/privatetemplate'
require 'view/alphaheader'
#require 'view/export'
require 'htmlgrid/link'

module ODDB
	module View
		module Admin
class PatinfoDeprivedSequencesList < HtmlGrid::List
	BACKGROUND_SUFFIX = '-bg'
	COMPONENTS = {
		[0,0] => :nr,
		[1,0] => :name,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,2] => 'list'
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'th'
	SORT_DEFAULT = :name
	STRIPED_BG = true
	include View::AlphaHeader
	def nr(model, session)
		link = HtmlGrid::Link.new(:select_seq, model, session, self)
		hash = { 
			:pointer					=> model.pointer , 
		}
		link.href = @lookandfeel.event_url(:select_seq, hash)
		link.value = model.name_base
		link
	end
end
class ShadowPatternForm < View::Form
	EVENT = :shadow_pattern
	COMPONENTS = {
		[0,0]	=>	:pattern,	
		[0,0,1]	=>	:submit,
	}
	LABELS = false
	def pattern(model, session)
		HtmlGrid::InputText.new(:pattern, model, session, self)
	end
end
class PatinfoDeprivedSequencesComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	=>	View::Admin::ShadowPatternForm,
		[0,1]	=>	View::Admin::PatinfoDeprivedSequencesList,
	}
end
class PatinfoDeprivedSequences < View::Drugs::PrivateTemplate
	CONTENT = View::Admin::PatinfoDeprivedSequencesComposite
	SNAPBACK_EVENT = :incomplete_registrations
end
		end
	end
end
