#!/usr/bin/env ruby
# Logger -- ODDB -- 08.03.2004 -- hwyss@ywesee.com

module ODDB
	module Failsafe
		def failsafe(klass=StandardError, failval=:error, &block)
			begin
				"failsafe: #{klass}, calling block"
				block.call
			rescue klass => e
				puts "failsafe rescued #{e.class} < #{klass}"
				puts e.message
				puts e.backtrace
				$stdout.flush
				(failval == :error) ? e : failval
			end
		end
	end
end
