#!/usr/bin/env ruby
# State::Drugs::Package -- oddb -- 15.02.2005 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/drugs/package'

module ODDB
	module State
		module Drugs
class Package < State::Drugs::Global
	VIEW = View::Drugs::Package
end
		end
	end
end
