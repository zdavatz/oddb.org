#!/usr/bin/env ruby
# View::PopupTemplate -- oddb -- 21.08.2003 -- ywesee@ywesee.com

require 'view/publictemplate'

module ODDB
	module View
		class PopupTemplate < View::PublicTemplate
			HEAD = View::PopupLogoHead
			FOOT = nil
		end
	end
end
