#!/usr/bin/env ruby
# State::Admin::PatinfoPreview -- oddb -- 21.11.2003 -- rwaltert@ywesee.com

require 'view/admin/patinfopreview'

module ODDB
	module State
		module Admin
class PatinfoPreview < State::Admin::Global
	VOLATILE = true
	VIEW = View::Admin::PatinfoPreview
end
		end
	end
end
