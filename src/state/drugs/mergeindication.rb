#!/usr/bin/env ruby
# State::Drugs::MergeIndication -- oddb -- 07.07.2003 -- hwyss@ywesee.com 

require 'state/drugs/global'
require 'view/drugs/mergeindication'

module ODDB
	module State
		module Drugs
class MergeIndication < State::Drugs::Global
	VIEW = View::Drugs::MergeIndication
end
		end
	end
end
