#!/usr/bin/env ruby
# PopupTemplate -- oddb -- 21.08.2003 -- ywesee@ywesee.com

require 'view/publictemplate'

module ODDB
	class PopupTemplate < PublicTemplate
		HEAD = PopupLogoHead
		FOOT = nil
	end
end
