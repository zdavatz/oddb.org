#!/usr/bin/env ruby
# State::Admin::MergeIndication -- oddb -- 07.07.2003 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'view/admin/mergeindication'

module ODDB
	module State
		module Admin
class MergeIndication < State::Admin::Global
	VIEW = View::Admin::MergeIndication
end
		end
	end
end
