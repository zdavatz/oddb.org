#!/usr/bin/env ruby
# State::Drugs::LimitationText -- oddb -- 14.11.2003 -- maege@ywesee.com

require 'state/drugs/global'
require 'view/drugs/limitationtext'

module ODDB
	module State
		module Drugs
class LimitationText < State::Drugs::Global
	VIEW = View::Drugs::LimitationText
end
		end
	end
end
