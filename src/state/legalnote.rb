#!/usr/bin/env ruby
# State::LegalNote -- oddb -- 01.09.2003 -- maege@ywesee.com

require 'state/global_predefine'
require 'view/legalnote'

module ODDB
	module State
		class LegalNote < State::Global
			VIEW = View::LegalNote
			VOLATILE = true
		end
	end
end
