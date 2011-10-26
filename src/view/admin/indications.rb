#!/usr/bin/env ruby
# View::Admin::Indications -- oddb -- 03.07.2003 -- hwyss@ywesee.com 

require 'view/drugs/privatetemplate'
require 'view/descriptionlist'
require 'view/pointervalue'
require 'view/pointervalue'
require 'view/alphaheader'

module ODDB
	module View
		module Admin
class IndicationList < View::DescriptionList
	CSS_MAP = {
		[0,0]	=>	'list',
	}
	DEFAULT_HEAD_CLASS = nil
	EVENT = :new_indication
	SYMBOL_MAP = {
		:description	=>	View::PointerLink,
	}
  def description(model, session)
    link = View::PointerLink.new(:description, model, session)
    link.href = @lookandfeel._event_url(:indication, {:oid => model.oid})
    link
  end
	include View::AlphaHeader
end
class Indications < View::Drugs::PrivateTemplate
	CONTENT = View::Admin::IndicationList
	SNAPBACK_EVENT = :indications
end
		end
	end
end
