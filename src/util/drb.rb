#!/usr/bin/env ruby
# DRb -- oddb -- hwyss@ywesee.com

require 'drb/invokemethod'

module DRb
	class DRbServer
		module InvokeMethod18Mixin
			alias :_old_perform_with_block :perform_with_block
			def perform_with_block
				begin
					_old_perform_with_block
				rescue LocalJumpError => e
					puts "Error in DRb::DRbServer::InvokeMethod18Mixin#perform_with_block"
					puts e.class
					puts e.message
					puts e.backtrace
				end
			end
		end
	end
end
