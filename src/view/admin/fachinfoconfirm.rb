#!/usr/bin/env ruby
# View::Admin::FachinfoConfirm -- oddb -- 26.09.2003 -- rwaltert@ywesee.com

require 'view/drugs/privatetemplate'
require 'htmlgrid/select'
require 'htmlgrid/errormessage'

module ODDB
	module View
		module Admin
class FachinfoConfirmForm < View::FormList
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]	=>	:preview,
		[1,0]	=>	:name,
		[2,0] =>	:iksnrs,
		[3,0]	=>	:language,
	}
	COMPONENT_CSS_MAP = {
		[0,0]		=>	'list-small',
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]		=>	'list-small',
		[1,0,3]	=>	'list',
	}
	DEFAULT_HEAD_CLASS = 'subheading'
	EVENT = :update
	LOOKANDFEEL_MAP = {
		:name	=>	:fachinfo_title,
	}
	SORT_HEADER = false
	def init
		super
		error_message()
	end
	def compose_footer(matrix)
		@grid.add(back(), *matrix)
		unless(@session.error?)
			super
		end
		@grid.set_colspan(*matrix)
	end
	def iksnrs (model, session)
		@session.state.iksnrs(model).join(",&nbsp;")
	end
	def language(model, session)
		@lookandfeel.lookup(@session.state.language)
	end
	def preview(model, session)
		link = HtmlGrid::PopupLink.new(:preview, model, session, self)
		link.href = @lookandfeel.event_url(:preview, \
			{"index" => @list_index})
		link
	end
end
class FachinfoConfirmComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	"fachinfo_confirm",
		[0,1]	=>	View::Admin::FachinfoConfirmForm,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	"th",
	}
end
class FachinfoConfirm < View::Drugs::PrivateTemplate
	CONTENT = View::Admin::FachinfoConfirmComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
