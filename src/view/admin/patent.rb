#!/usr/bin/env ruby
# View::Admin::Patent -- oddb.org -- 05.05.2006 -- hwyss@ywesee.com

require 'view/privatetemplate'
require 'view/form'
require 'htmlgrid/errormessage'
require 'htmlgrid/inputdate'

module ODDB
	module View
		module Admin
module PatentMethods
	def base_patent_link(model, session=@session)
		if(pn = model.base_patent)
			link = HtmlGrid::Link.new(:base_patent_detail, model, @session, self)
			link.href = @lookandfeel.lookup(:swissreg_patent_url, pn)
			link
		end
	end
	def patent_link(model, session=@session)
		if(cn = model.certificate_number)
			link = HtmlGrid::Link.new(:patent_detail, model, @session, self)
			link.href = @lookandfeel.lookup(:swissreg_url, cn)
			link
		end
	end
end
class PatentInnerComposite < HtmlGrid::Composite
	include PatentMethods
	COMPONENTS = {
		[0,0]	=>	:certificate_number,
		[2,0]	=>	:base_patent,
		[1,1]	=>	:patent_link,
		[3,1]	=>	:base_patent_link,
		[2,2]	=>	:base_patent_date,
		[0,2]	=>	:registration_date,
		[0,3]	=>	:publication_date,
		[0,4]	=>	:issue_date,
		[2,4]	=>	:protection_date,
		[0,5]	=>	:deletion_date,
	}
	CSS_MAP = {
		[0,0,4,6]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LABELS = true
	LEGACY_INTERFACE = false
	SYMBOL_MAP = {
		:base_patent_date		=>	HtmlGrid::DateValue,
		:deletion_date			=>	HtmlGrid::DateValue,
		:registration_date	=>	HtmlGrid::DateValue,
		:publication_date		=>	HtmlGrid::DateValue,
		:issue_date					=>	HtmlGrid::DateValue,
		:protection_date		=>	HtmlGrid::DateValue,
	}
end
class PatentForm < HtmlGrid::Form
	include PatentMethods
	COMPONENTS = {
		[0,0]	=>	:certificate_number,
		[2,0]	=>	:base_patent,
		[1,1]	=>	:patent_link,
		[3,1]	=>	:base_patent_link,
		[2,2]	=>	:base_patent_date,
		[0,2]	=>	:registration_date,
		[0,3]	=>	:publication_date,
		[0,4]	=>	:issue_date,
		[2,4]	=>	:protection_date,
		[0,5]	=>	:expiry_date,
		[2,5]	=>	:deletion_date,
		[1,6]	=>	:submit,
	}
	CSS_MAP = {
		[0,0,4,7]	=>	'list',
	}
	EVENT = :update
	LABELS = true
	LEGACY_INTERFACE = false
	SYMBOL_MAP = {
		:base_patent_date		=>	HtmlGrid::InputDate,
		:deletion_date			=>	HtmlGrid::InputDate,
		:expiry_date	  		=>	HtmlGrid::InputDate,
		:registration_date	=>	HtmlGrid::InputDate,
		:publication_date		=>	HtmlGrid::InputDate,
		:issue_date					=>	HtmlGrid::InputDate,
		:protection_date		=>	HtmlGrid::InputDate,
	}
end
class ReadonlyPatentComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:registration_name,
		[0,1]	=>	PatentInnerComposite,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
	}
	CSS_CLASS = 'composite'
	LEGACY_INTERFACE = false
	def registration_name(model, session=@session)
		registration = model.parent(@session.app)
		[
			registration.name_base, 
			@lookandfeel.lookup(:patent),
		].compact.join('&nbsp;-&nbsp;')
	end
end
class PatentComposite < ReadonlyPatentComposite
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]	=>	:registration_name,
		[0,1]	=>	PatentForm,
	}
	def init
		super
		error_message(1)
	end
end
class ReadonlyPatent < PrivateTemplate
	CONTENT = ReadonlyPatentComposite
	SNAPBACK_EVENT = :result
end
class Patent < ReadonlyPatent
	CONTENT = PatentComposite
end
		end
	end
end
