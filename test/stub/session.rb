#!/usr/bin/env ruby
# Stub: Session -- oddb -- 22.10.2002 -- hwyss@ywesee.com 

require 'util/session'

module ODDB
	class Session < SBSM::Session
		attr_reader :state, :request
		attr_writer :lookandfeel
	end
end
