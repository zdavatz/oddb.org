#!/usr/bin/env ruby
# GenericGroup -- oddb -- 28.02.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'model/package_observer'

module ODDB
	class GenericGroup
		include Persistence
    include PackageObserver
	end
end
