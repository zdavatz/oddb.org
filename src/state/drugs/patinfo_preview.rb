#!/usr/bin/env ruby
# State::Drugs::PatinfoPreview -- oddb -- 21.11.2003 -- rwaltert@ywesee.com

require 'view/drugs/patinfo'

module ODDB
	module State
		module Drugs
class PatinfoPreview < State::Drugs::Global
	VOLATILE = true
	VIEW = View::Drugs::PatinfoPreview
end
		end
	end
end
