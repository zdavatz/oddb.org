#!/usr/bin/env ruby
# index.rbx -- oddb -- hwyss@ywesee.com

require 'sbsm/request'
require 'util/oddbconfig'

DRb.start_service()
begin
	SBSM::Request.new(ODDB::SERVER_URI).process
rescue Exception => e
	$stderr << "ODDB-Client-Error: " << e.message << "\n"
	$stderr << e.class << "\n"
	$stderr << e.backtrace.join("\n") << "\n"
end
