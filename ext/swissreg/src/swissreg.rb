#!/usr/bin/env ruby
# Swissreg -- oddb.org -- 04.05.2006 -- hwyss@ywesee.com

require 'session'

module ODDB
	module Swissreg
		def Swissreg.search(substance)
			session = Session.new
			session.get_result_list(substance).collect { |url|
				res = {}
				retries = 2
				begin
					sleep(1)
					res = session.get_detail(url)
				rescue 
					if(retries > 0)
						retries -= 1
						retry
					else
						raise
					end
				end
				res
			}
		end
		def Swissreg.detail(path)
			session = Session.new
			session.get_detail(path)
		end
	end
end
