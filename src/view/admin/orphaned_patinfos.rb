#!/usr/bin/env ruby
# View::Admin::Orphaned_patinfos -- oddb -- 20.11.2003 -- rwaltert@ywesee.com

require 'view/publictemplate'
#require 'view/export'
require 'view/alphaheader'
require 'htmlgrid/link'

module ODDB
	module View
		module Admin
class OrphanedPatinfosList < HtmlGrid::List
	BACKGROUND_SUFFIX = '-bg'
	COMPONENTS = {
		[0,0]	=>	:key,
		[1,0]	=> :names,
		[2,0]	=> :reason,
	}	
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,3]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'th'
	SORT_DEFAULT = :names
	STRIPED_BG = true
	SYMBOL_MAP = {
		:key		=>	PointerLink,
	}
	include View::AlphaHeader
end
class OrphanedPatinfos < View::PrivateTemplate
	CONTENT = View::Admin::OrphanedPatinfosList
	SNAPBACK_EVENT = :incomplete_registrations
end
		end
	end
end
