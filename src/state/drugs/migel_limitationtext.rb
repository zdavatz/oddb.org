#!/usr/bin/env ruby
#  -- oddb -- 30.09.2005 -- ffricker@ywesee.com

require 'state/drugs/global'
require 'view/drugs/limitationtext'

module ODDB
	module State
		module Drugs
class MigelLimitationText < State::Drugs::Global
	VIEW = View::Drugs::MigelLimitationText
	LIMITED = true
end
		end
	end
end
