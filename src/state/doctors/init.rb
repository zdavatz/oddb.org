#!/usr/bin/env ruby
# encoding: utf-8
# State::Doctors::Init -- oddb -- 17.09.2004 -- jlang@ywesee.com

require 'state/global_predefine'
require 'view/doctors/search'

module ODDB
	module State
		module Doctors
class Init < State::Doctors::Global
	VIEW = View::Doctors::Search
	DIRECT_EVENT = :home_doctors	
end
		end
	end
end
