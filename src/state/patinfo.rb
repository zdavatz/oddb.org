#!/usr/bin/env ruby
# PatinfoState  -- oddb -- 11.11.2003 -- rwaltert@ywesee.com

require 'state/global_predefine'
require 'view/patinfo'


module ODDB
	class PatinfoState < GlobalState
		VIEW = PatinfoView
		VOLATILE = true
	end
	class PatinfoPrintState < GlobalState
		VIEW = PatinfoPrintView
		VOLATILE = true
	end
end
