#!/usr/bin/env ruby
# View::Drugs::PrivateTemplate -- oddb -- 06.04.2006 -- hwyss@ywesee.com

require 'view/privatetemplate'

module ODDB
	module View
		module Drugs
class PrivateTemplate < View::PrivateTemplate
	SEARCH_HEAD = View::SelectSearchForm
end
		end
	end
end
