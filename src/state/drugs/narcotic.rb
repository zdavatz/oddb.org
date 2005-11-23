#!/usr/bin/env ruby
#State::Drugs::Narcotic -- oddb -- 08.11.2005 -- spfenninger@ywesee.com

require 'view/drugs/narcotic'

module ODDB
	module State
		module Drugs
class Narcotic < State::Global
	VIEW = View::Drugs::Narcotic
	LIMITED = true
end
		end
	end
end
