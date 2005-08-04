#!/usr/bin/env ruby
# State::Drugs::Patinfo -- oddb -- 11.11.2003 -- rwaltert@ywesee.com

require 'state/drugs/global'
require 'view/drugs/patinfo'


module ODDB
	module State
		module Drugs
class Patinfo < State::Drugs::Global
	VIEW = View::Drugs::Patinfo
	VOLATILE = true
	LIMITED = true
end
class PatinfoPrint < State::Drugs::Global
	VIEW = View::Drugs::PatinfoPrint
	VOLATILE = true
	LIMITED = true
end
		end
	end
end
