#!/usr/bin/env ruby
# State::AllZones -- oddb -- 31.10.2005 -- hwyss@ywesee.com

module ODDB
	module State
		module AllZones
			def zone
				if(@previous.respond_to?(:zone))
					@previous.zone
				else
					super
				end
			end
			def zone_navigation
				if(@previous.respond_to?(:zone_navigation))
					@previous.zone_navigation
				else
					super
				end
			end
		end
	end
end
