#!/usr/bin/env ruby
# encoding: utf-8
# View::Admin::PatinfoPreview -- oddb -- 07.12.2004 -- hwyss@ywesee.com

require 'view/popuptemplate'
require 'view/drugs/patinfo'

module ODDB
	module View
		module Admin
class PatinfoPreviewComposite < View::Drugs::PatinfoComposite
	COLSPAN_MAP = {
		[0,1]	=> 2,
	}
	COMPONENTS = {
		[0,0]	=>	:patinfo_name,
		[1,0]	=>	:company,
		[0,1] =>	:document,
	}
	CSS_MAP = {
		[0,0] => 'th',
		[1,0]	=> 'th right',
	}	
	def document(model, session)
		document_composite(model, session)
	end
	def patinfo_name(model, session)
		@lookandfeel.lookup(:patinfo_name, model.name)
	end
end
class PatinfoPreview < View::PopupTemplate
	CONTENT = View::Admin::PatinfoPreviewComposite
end	
		end
	end
end
