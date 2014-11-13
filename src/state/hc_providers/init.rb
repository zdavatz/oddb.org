#!/usr/bin/env ruby
# encoding: utf-8
# State::HC_providers::Init -- oddb -- 15.02.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require 'state/global_predefine'
require 'view/hc_providers/search'

module ODDB
	module State
		module HC_providers
class Init < State::HC_providers::Global
	VIEW = View::HC_providers::Search
	DIRECT_EVENT = :home_hc_providers	
end
		end
	end
end
