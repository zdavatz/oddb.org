#!/usr/bin/env ruby
# View::Admin::IncompleteRegistrations -- oddb -- 19.06.2003 -- hwyss@ywesee.com 

require 'view/drugs/privatetemplate'
require 'view/pointervalue'
require 'view/form'
require	'htmlgrid/errormessage'
require	'htmlgrid/infomessage'
require 'htmlgrid/inputtext'
require 'htmlgrid/list'
require 'htmlgrid/span'

module ODDB
	module View
		module Admin
class BsvForm < View::Form
	include HtmlGrid::ErrorMessage
	include HtmlGrid::InfoMessage
	COMPONENTS = {
		[0,0]	=>	:bsv_url,
		[2,0]	=>	:submit,
	}
	CSS_MAP = {
		[0,0,3]	=>	"list",
	}
	EVENT = :update_bsv
	LABELS = true
	SYMBOL_MAP = {
		:bsv_url	=>	HtmlGrid::InputText,
	}
	def init
		super
		error_message()
		info_message()
	end
end
class InnerIncompleteRegList < HtmlGrid::List
	BACKGROUND_SUFFIX = ' bg'
	COMPONENTS = {
		[0,0]	=>	:oid,
		[1,0]	=>	:iksnr,
		[2,0]	=>	:sequence_names,
	}	
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,3]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'th'
	STRIPED_BG = true
	SYMBOL_MAP = {
		:oid		=>	View::PointerLink,
	}
	def sequence_names(model, session)
		model.sequence_names.join("<br>")
	end
end
class IncompleteRegList < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	View::Admin::InnerIncompleteRegList,
		[0,1]	=>	:orphaned_patinfos,
		[0,2] =>  :patinfo_deprived_sequences,
		[0,3] =>  :orphaned_fachinfos,
	}	
	COLSPAN_MAP	= {
		[0,0]	=> 2,
	}
	CSS_CLASS = 'composite'
=begin
	def bsv_url_label(model, session)
		span = HtmlGrid::Span.new(model, session, self)
		span.value = @lookandfeel.lookup(:bsv_url_label)
		#span.set_attribute('style','font-weight: bold;')
		span.set_attribute('class','label')
		span
	end
=end
	def orphaned_fachinfos(model, session)
		link = HtmlGrid::Link.new(:orphaned_fachinfos, model, session, self)
		link.href = @lookandfeel._event_url(:orphaned_fachinfos)
		link.set_attribute('class', 'list')
		count = session.app.orphaned_fachinfos.size
		link.value = @lookandfeel.lookup(:orphaned_fachinfos, count)
		link
	end
	def orphaned_patinfos(model, session)
		link = HtmlGrid::Link.new(:orphaned_patinfos, model, session, self)
		link.href = @lookandfeel._event_url(:orphaned_patinfos)
		link.set_attribute('class', 'list')
		count = session.app.orphaned_patinfos.size
		link.value = @lookandfeel.lookup(:orphaned_patinfos, count)
		link
	end
	def patinfo_deprived_sequences(model,session)
		link = HtmlGrid::Link.new(:patinfo_deprived_sequences, 
			model, session, self)
		link.href = @lookandfeel._event_url(:patinfo_deprived_sequences)
		link.set_attribute('class','list')
	#	count = anazahl sequenzen ohne patinfo
		link.value = @lookandfeel.lookup(:patinfo_deprived_sequences)
		link
	end
	def release(model, session)
		if(@model.empty? \
			&& @session.allowed?('create', 'org.oddb.task.background'))
			button = HtmlGrid::Button.new(:release, 
				model, session, self)
			url = @lookandfeel.event_url(:release)
			button.set_attribute('onclick', "window.location.href='#{url}'")
			button
		end
	end
end
class IncompleteRegistrations < View::Drugs::PrivateTemplate
	CONTENT = View::Admin::IncompleteRegList
	SNAPBACK_EVENT = :incomplete_registrations
end
		end
	end
end
