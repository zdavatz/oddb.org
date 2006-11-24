#!/usr/bin/env ruby
# View::Admin::CommercialForms -- oddb.org -- 23.11.2006 -- hwyss@ywesee.com

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
	}
	DEFAULT_HEAD_CLASS = 'th'
	EVENT = :new_commercial_form
  SYMBOL_MAP = {
    :oid => View::PointerLink,
  }
end
class CommercialForms < PrivateTemplate
  CONTENT = CommercialFormsList
	SNAPBACK_EVENT = :commercial_forms
end
    end
  end
end
