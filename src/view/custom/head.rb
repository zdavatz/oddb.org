#!/usr/bin/env ruby
# View::CustomHead -- oddb -- 21.12.2005 -- hwyss@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/image'
require 'htmlgrid/div'
require 'view/language_chooser'

module ODDB
	module View
		module Custom
class OekkHead < HtmlGrid::Composite
	CSS_CLASS = 'oekk-head'
	COMPONENTS = {
		[0,0,0]	=>	:oekk_department,
		[0,0,1]	=>	:oekk_title,
		[0,0,2]	=>	:language_chooser,
		[1,0]		=>	:oekk_logo,

	}
	CSS_MAP = {
		[0,0]	=>	'oekk-head',
	}
	LEGACY_INTERFACE = false
	def language_chooser(model)
		LanguageChooser.new(@lookandfeel.languages, @session, self)
	end
	def oekk_department(model)
		div = HtmlGrid::Div.new(model, @session, self)
		div.value = @lookandfeel.lookup(:oekk_department)
		div.css_class = 'oekk-department'
		div
	end
	def oekk_logo(model)
    link = HtmlGrid::Link.new(:oekk_logo, model, @session, self)
		img = HtmlGrid::Image.new(:oekk_logo, model, @session, self)
		img.set_attribute('src', 
			'http://www.oekk.ch/_img/img_oekk_logo_oddb.gif')
		link.value = img
    link.href = 'http://www.oekk.ch'
    link
	end
	def oekk_title(model)
		div = HtmlGrid::Div.new(model, @session, self)
		div.value = @lookandfeel.lookup(:oekk_title)
		div.css_class = 'oekk-title'
		div
	end
end
module HeadMethods
	def just_medical(model, session=@session)
		div = HtmlGrid::Div.new(model, @session, self)
		div.css_class = 'just-medical'
		div.value = @lookandfeel.lookup(:all_drugs_pricecomparison)
		div
	end
	def oekk_head(model, session=@session)
		OekkHead.new(model, @session, self)
	end
end
module Head
	include HeadMethods
	def head(model, session=@session)
		if(@lookandfeel.enabled?(:just_medical_structure, false))
			just_medical(model)
		elsif(@lookandfeel.enabled?(:oekk_structure, false))
			oekk_head(model)
		else
			self::class::HEAD.new(model, session, self)
		end
	end
end
		end
	end
end
