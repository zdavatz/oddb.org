#!/usr/bin/env ruby
# encoding: utf-8
# View::User::YweseeContact -- oddb -- 04.08.2003 -- mhuggler@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/form'
require 'htmlgrid/urllink'
require 'view/publictemplate'

module ODDB
	module View
		module User
class YweseeContactForm < HtmlGrid::Form
	COMPONENTS = {
		[0,0]	=>	'ywesee_contact_text',
		[0,1]	=>	'ywesee_contact_name',
		[0,2]	=>	:ywesee_contact_email,
	}
	CSS_MAP = {
		[0,0]	=>	'list',
		[0,1]	=>	'list',
		[0,2]	=>	'list',
	}
	def ywesee_contact_email(model, session)
		link = HtmlGrid::Link.new(:ywesee_contact_email, model, session, self)
		link.href = @lookandfeel.lookup(:ywesee_contact_href)
		link.attributes['class'] = 'list'
		link
	end
end
class YweseeContactComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	'ywesee_contact',
		[0,1]	=>	View::User::YweseeContactForm,
	}
	CSS_CLASS	=	'composite'
	CSS_MAP	= {
		[0,0]	=>	'th',
	}
end
class YweseeContact < View::PublicTemplate
	CONTENT = View::User::YweseeContactComposite
end
		end
	end
end
