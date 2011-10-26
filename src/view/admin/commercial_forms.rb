#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::CommercialForms -- oddb.org -- 26.10.2011 -- mhatakeyama@ywesee.com
# ODDB::View::Admin::CommercialForms -- oddb.org -- 23.11.2006 -- hwyss@ywesee.com

require 'view/privatetemplate'
require 'view/descriptionlist'
require 'view/pointervalue'

module ODDB
  module View
    module Admin
class CommercialFormsList < View::DescriptionList
	COMPONENTS = {
		[0,0]	=>	:oid,
		[1,0]	=>	:description,
		[2,0]	=>	:package_count,
	}
	CSS_MAP = {
		[0,0,2]	=>	'list',
		[2,0]	  =>	'right list',
	}
	DEFAULT_HEAD_CLASS = 'th'
	EVENT = :new_commercial_form
  SYMBOL_MAP = {
    :oid => View::PointerLink,
  }
  def oid(model, session)
    link = View::PointerLink.new(:oid, model, session)
    link.href = @lookandfeel._event_url(:commercial_form, {:oid => model.oid})
    link
  end
end
class CommercialForms < PrivateTemplate
  CONTENT = CommercialFormsList
	SNAPBACK_EVENT = :commercial_forms
end
    end
  end
end
