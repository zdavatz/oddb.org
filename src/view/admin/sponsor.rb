#!/usr/bin/env ruby
# View::Admin::Sponsor -- oddb -- 29.07.2003 -- maege@ywesee.com

require 'htmlgrid/inputdate'
require 'htmlgrid/inputfile'
require 'htmlgrid/errormessage'
require 'htmlgrid/image'
require 'view/publictemplate'
require 'view/form'
require 'view/sponsorlogo'

module ODDB
	module View
		module Admin
class SponsorForm < View::Form
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]		=>	:company_name,
		[0,1]		=>	:sponsor_until,
		[0,2]		=>	:logo_file,
		[1,3]		=>	:submit,
	} 
	COMPONENT_CSS_MAP = {
		[0,0,2,2]	=>	'standard',
	}
	CSS_MAP =	{
		[0,0,2,4]	=>	'list',
	}
	LABELS = true
	SYMBOL_MAP = {
		:sponsor_until	=>	HtmlGrid::InputDate,
		:logo_file			=>	HtmlGrid::InputFile,
	}
	TAG_METHOD = :multipart_form
	def init
		super
		error_message()
	end
end
class SponsorInnerComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	View::Admin::SponsorForm,
		[1,0]	=>	View::SponsorLogo,
	}
end
class SponsorComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	'sponsor',
		[0,1]	=>	View::Admin::SponsorInnerComposite,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
	}
end
class Sponsor < View::PublicTemplate
	CONTENT = View::Admin::SponsorComposite
end
		end
	end
end
