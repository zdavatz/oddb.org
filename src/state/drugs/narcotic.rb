#!/usr/bin/env ruby
#State::Drugs::Narcotic -- oddb -- 08.11.2005 -- spfenninger@ywesee.com

require 'view/drugs/narcotic'

module ODDB
	module State
		module Drugs
class Narcotic < State::Global
	VIEW = View::Drugs::Narcotic
end
class NarcoticPlus < State::Global
	VIEW = View::Drugs::NarcoticPlus
end
		end
	end
end
