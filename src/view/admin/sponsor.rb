#!/usr/bin/env ruby
# View::Admin::Sponsor -- oddb -- 29.07.2003 -- mhuggler@ywesee.com

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
    [0,2]   =>  :emails,
		[0,3]		=>	:url_de,
		[0,4]		=>	:url_fr,
		[0,5]		=>	:logo_file,
		[0,6]		=>	:logo_fr,
		[1,7]		=>	:submit,
	} 
	COMPONENT_CSS_MAP = {
		[0,0,2,5]	=>	'standard',
	}
	CSS_MAP =	{
		[0,0,2,8]	=>	'list',
	}
	LABELS = true
  LEGACY_INTERFACE = false
	SYMBOL_MAP = {
		:sponsor_until	=>	HtmlGrid::InputDate,
		:logo_file			=>	HtmlGrid::InputFile,
		:logo_fr				=>	HtmlGrid::InputFile,
	}
	TAG_METHOD = :multipart_form
	def init
		super
		error_message()
	end
  def emails(model)
    input = HtmlGrid::InputText.new(:emails, model, @session, self)
    if emails = model.emails
      input.value = emails.join(', ')
    end
    input
  end
  def url(lang, model)
    input = HtmlGrid::InputText.new("urls[#{lang}]", model, @session, self)
    input.value = model.url(lang)
    input
  end
  def url_de(model)
    url :de, model
  end
  def url_fr(model)
    url :fr, model
  end
end
class SponsorInnerComposite < HtmlGrid::Composite
	CSS_MAP = {
		[1,0]	=>	'list logo',
	}
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
