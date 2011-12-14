#!/usr/bin/env ruby
# encoding: utf-8
# View::Admin::SlEntry -- oddb -- 22.04.2003 -- benfay@ywesee.com

require 'view/drugs/privatetemplate'
require 'view/form'
require 'htmlgrid/inputdate'
require 'htmlgrid/select'
require 'htmlgrid/errormessage'

module ODDB
	module View
		module Admin
class SlEntryInnerComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:introduction_date,
		[0,1]	=>	:limitation,
		[1,1]	=>	:limitation_points,
	}
	CSS_MAP = {
		[0,0,4,2]	=>	'list',
	}
	LABELS = true
	SYMBOL_MAP = {
		:introduction_date => HtmlGrid::DateValue, 
	} 
end
class SlEntryForm < View::Form
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]	  =>	:introduction_date,
		[0,1]	  =>	:limitation,
		[1,1]	  =>	:limitation_points,
		[1,2,0]	=>	:submit,
		[1,2,1] =>	:delete_item,
	}
	COMPONENT_CSS_MAP = {
		[1,0]	=>	'standard',
	}
	CSS_MAP = {
		[0,0,4,3]	=>	'list',
	}
	LABELS = true
	SYMBOL_MAP = {
		:introduction_date => HtmlGrid::InputDate, 
		:limitation => HtmlGrid::Select,
	} 
	def init
		super
		error_message()
	end
	def limitation_points(model, session)
		input = HtmlGrid::InputText.new(:limitation_points, model, session, self)
		input.set_attribute('class', 'small' )
		input.label = false
		input
	end
end
class SlEntryComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:package_name,
		[0,1]	=>	View::Admin::SlEntryInnerComposite,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
	}
	def package_name(model, session)
		package = model.parent(session.app)
		[
			package.name_base, 
			package.size, 
			@lookandfeel.lookup(:sl_entry),
		].compact.join('&nbsp;-&nbsp;')
	end
end
class RootSlEntryComposite < View::Admin::SlEntryComposite
	COMPONENTS = {
		[0,0]	=>	:package_name,
		[0,1]	=>	View::Admin::SlEntryForm,
	}
end
class SlEntry < View::Drugs::PrivateTemplate
	CONTENT = View::Admin::SlEntryComposite
	SNAPBACK_EVENT = :result
end
class RootSlEntry < View::Admin::SlEntry
	CONTENT = View::Admin::RootSlEntryComposite
end
		end
	end
end
