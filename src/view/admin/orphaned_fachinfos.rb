#!/usr/bin/env ruby
# View::Admin::OrphanedFachinfos -- oddb -- 11.12.2003 -- rwaltert@ywesee.com

require 'view/publictemplate'
#require 'view/export'
require 'view/alphaheader'
require 'htmlgrid/link'

module ODDB
	module View
		module Admin
class OrphanedFachinfosList < HtmlGrid::List
	BACKGROUND_SUFFIX = '-bg'
	COMPONENTS = {
		[0,0]	=>	:key,
		[1,0]	=>  :name,
	}	
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,2]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'th'
	SORT_DEFAULT = :name
	STRIPED_BG = true
	SYMBOL_MAP = {
		:key		=>	View::PointerLink,
	}
	include View::AlphaHeader
end
class OrphanedFachinfos < View::PrivateTemplate
	CONTENT = View::Admin::OrphanedFachinfosList
	SNAPBACK_EVENT = :incomplete_registrations
end
		end
	end
end
