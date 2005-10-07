#!/usr/bin/env ruby
#  -- oddb -- 04.10.2005 -- ffricker@ywesee.com

require 'state/global_predefine'
require 'view/legalnote'

module ODDB
	module State
		module Migel
class LegalNote < State::Migel::Global
	VIEW = View::LegalNote
	VOLATILE = true
end
		end
	end
end
