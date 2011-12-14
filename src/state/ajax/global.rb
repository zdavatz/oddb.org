#!/usr/bin/env ruby
# encoding: utf-8
# State::Ajax::Global -- oddb -- 17.03.2006 -- hwyss@ywesee.com

module ODDB
	module State
		module Ajax
class Global < SBSM::State
	VOLATILE = true
	def limited?
		false
	end
end
		end
	end
end
