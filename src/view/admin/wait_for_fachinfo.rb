#!/usr/bin/env ruby
# View::Admin::WaitForFachinfo -- oddb -- 18.11.2004 -- mwalder@ywesee.com  rwaltert@ywesee.com

require 'view/popuptemplate'
require 'view/pointervalue'
require 'htmlgrid/list'

module ODDB
	module View
		module Admin
class StatusBar < HtmlGrid::Composite
	COMPONENTS = {}
	CSS_CLASS = 'wait'
	CSS_MAP = { 
		[0,0]	=>	'wait',
		[1,0]	=>	'wait',
		[2,0]	=>	'wait',
		[3,0]	=>	'wait',
		[4,0]	=>	'wait',
	}
	def init
		css_map.store([@session.state.wait_counter, 0], "wait bg-red")
		super
		@grid.set_attribute('cellspacing', '20')
	end
end
class WaitForFachinfoComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0] => 'please_wait',
		[0,1] => View::Admin::StatusBar,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,1,1,1]	=>	'subheading',
	}
end
class WaitForFachinfo < View::PopupTemplate
	CONTENT = View::Admin::WaitForFachinfoComposite
	def http_headers
		hsh = super
		link = @lookandfeel.event_url(:wait)
		hsh.store("Refresh", "5; url=#{link}")
		hsh
	end
end
		end
	end
end
