#!/usr/bin/env ruby
# State::Drugs::Fachinfo -- oddb -- 17.09.2003 -- rwaltert@ywesee.com

require 'state/drugs/global'
require 'view/drugs/fachinfo'

module ODDB
	module State
		module Drugs
class Fachinfo < State::Drugs::Global
	VIEW = View::Drugs::Fachinfo
	VOLATILE = true
end
class FachinfoPreview < State::Drugs::Global
	VIEW = View::Drugs::FachinfoPreview
	VOLATILE = true
end
class FachinfoPrint < State::Drugs::Global
	VIEW = View::Drugs::FachinfoPrint
	VOLATILE = true
end
		end
	end
end
