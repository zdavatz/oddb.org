#!/usr/bin/env ruby
# State::Analysis::Group -- oddb.org -- 05.07.2006 -- sfrischknecht@ywesee.com

require 'view/analysis/group'

module ODDB
	module State
		module Analysis
class Group < Global
	VIEW = View::Analysis::Group
	LIMITED = true
end
		end
	end
end
