#!/usr/bin/env ruby
# CyP450 -- oddb -- 04.05.2004 -- maege@ywesee.com

require 'util/persistence'
require 'model/cyp450connection'

module ODDB
	class CyP450
		attr_reader :cyp_id
		attr_accessor :inhibitors, :inducers
		include Persistence
		def initialize(cyp_id)
			@cyp_id = cyp_id
			@inhibitors = {}
			@inducers = {}
		end
		def has_connection?(other)
			(@inhibitors + @inducers).any? { |connection| 
					
			}
			@inhibitors.each { |inhibitor|
				if(inhibitor.name == other.description('en'))
					@interaction.store(:inhibitor, inhibitor)
				end
			}
			@inducers.each { |inducers|
				if(inducers.name == other.description('en'))
					@interactions.store(:inducer, inducers)
				end
			}
			@interactions
		end
		def create_cyp450inducer(substance_name)
			#puts 'creating inducer...'
			conn = ODDB::CyP450InhibitorConnection.new(substance_name)
			@inducers.store(substance_name, conn)
		end
		def create_cyp450inhibitor(substance_name)
			#puts 'creating inhibitor...'
			conn = ODDB::CyP450InhibitorConnection.new(substance_name)
			@inhibitors.store(conn.substance_name, conn)
		end
		def cyp450inducer(substance_name)
			@inducers[substance_name]
		end
		def cyp450inhibitor(substance_name)
			@inhibitors[substance_name]
		end
		def delete_cyp450inducer(substance_name)
			@inducers.delete(substance_name)
		end
		def delete_cyp450inhibitor(substance_name)
			@inhibitors.delete(substance_name)
		end
	end
end
