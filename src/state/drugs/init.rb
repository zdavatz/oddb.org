#!/usr/bin/env ruby
# State::Drugs::Init -- oddb -- 22.10.2002 -- hwyss@ywesee.com 

require 'state/drugs/global'
#require 'state/admin/root'
#require 'state/admin/companyuser'
require 'view/drugs/search'
#require 'view/admin/login'

module ODDB
	module State
		module Drugs
class Init < State::Drugs::Global
	VIEW = View::Drugs::Search
	DIRECT_EVENT = :home
end
		end
	end
end
