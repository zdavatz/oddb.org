#!/usr/bin/env ruby
# State::Doctors::LegalNote -- oddb -- 01.09.2003 -- mhuggler@ywesee.com

require 'state/global_predefine'
require 'view/legalnote'

module ODDB
	module State
		module Doctors
class LegalNote < State::Doctors::Global
	VIEW = View::Doctors::LegalNote
	VOLATILE = true
end
		end
	end
end

