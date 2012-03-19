#!/usr/bin/env ruby
# index.rbx -- oddb.org -- 19.03.2012 -- yasaka@ywesee.com
# index.rbx -- oddb.org -- 21.02.2012 -- mhatakeyama@ywesee.com
# index.rbx -- oddb.org -- hwyss@ywesee.com

# When SBSM is updated, the SBSM lib path should also be updated
require '/usr/local/lib/ruby/gems/1.9.1/gems/sbsm-1.1.5/lib/sbsm/request'
require 'util/oddbconfig'

DRb.start_service('druby://localhost:0')

begin
  request = SBSM::Request.new(ODDB::SERVER_URI)
  if request.is_crawler?
    request = SBSM::Request.new(ODDB::SERVER_URI_FOR_CRAWLER)
  end
  request.process
rescue Exception => e
	$stderr << "ODDB-Client-Error: " << e.message << "\n"
	$stderr << e.class << "\n"
	$stderr << e.backtrace.join("\n") << "\n"
end
