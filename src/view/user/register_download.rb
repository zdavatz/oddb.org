#!/usr/bin/env ruby
# View::User::RegisterDownload -- oddb -- 20.09.2004 -- maege@ywesee.com

require 'htmlgrid/form'
require 'htmlgrid/errormessage'
require 'view/publictemplate'
require 'view/logohead'

module ODDB
	module View
		module User
class RegisterDownloadForm < HtmlGrid::Form
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,1]	=>	:email,
		[1,2]	=>	:submit,
	}
	CSS_CLASS = 'component'
	EVENT = :download
	LABELS = true
	CSS_MAP = {
		[0,0,2,2]	=>	'list',
		[1,2]	=> 'button',
	}
	SYMBOL_MAP = {
		:email	=>	HtmlGrid::InputText,
	}
	def init
		super
		error_message
	end
	def hidden_fields(context)
		super <<
		context.hidden('filename', @session.user_input(:filename))
	end
end
class RegisterDownloadComposite < HtmlGrid::Composite 
	COMPONENTS = {
		[0,0]	=>	"register_download",
		[0,2]	=>	"register_download_descr",
		[0,3]	=>	View::User::RegisterDownloadForm,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
	}
end
class RegisterDownload < View::PublicTemplate
	CONTENT = View::User::RegisterDownloadComposite
end
		end
	end
end
