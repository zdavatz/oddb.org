#!/usr/bin/env ruby
# encoding: utf-8
# State::Hospitals::Init -- oddb -- 15.02.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require 'state/global_predefine'
require 'view/hospitals/search'

module ODDB
	module State
		module Hospitals
class Init < State::Hospitals::Global
	VIEW = View::Hospitals::Search
	DIRECT_EVENT = :home_hospitals	
end
		end
	end
end
