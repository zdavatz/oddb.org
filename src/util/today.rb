#!/usr/bin/env ruby
# @@today -- oddb.org -- 11.07.2007 -- hwyss@ywesee.com

class Object
	unless(defined?(@@date_arithmetic_optimization))
		@@date_arithmetic_optimization = Thread.new {
			loop {
				@@today = Date.today
				@@one_year_ago = @@today << 12
				@@two_years_ago = @@today << 24
				tomorrow = Time.local(@@today.year, @@today.month, @@today.day)
				sleep([tomorrow - Time.now, 3600].max)
			}	
		}
		def today
			@@today
		end
	end
end

