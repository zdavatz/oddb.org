#!/usr/bin/env ruby
# GenericGroup -- oddb -- 28.02.2003 -- hwyss@ywesee.com 

require 'util/persistence'

module ODDB
	class GenericGroup
		include Persistence
		def initialize
			@packages = []
		end
		def add_package(package)
			@packages.push(package)
			@packages.odba_isolated_store
			@packages.last
		end
		def remove_package(package)
			@packages.delete_if { |pack| pack==package }
		end
	end
end

