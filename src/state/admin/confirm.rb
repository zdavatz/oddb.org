#!/usr/bin/env ruby
# State::Admin::Confirm -- ODDB -- 26.01.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/admin/confirm'

module ODDB
	module State
		module Admin
class Confirm < State::Admin::Global
	VIEW = View::Admin::Confirm
end
		end
	end
end
