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
		def interactions_with(substance)
			connections = []
			@inhibitors.each { |connection_key, connection| 
				if((substance.connection_key == connection_key) || substance.same_as?(connection_key))
					connections.push(connection)
				end
			}
			@inducers.each { |connection_key, connection| 
				if((substance.connection_key == connection_key) || substance.same_as?(connection_key))
					connections.push(connection)
				end
			}
			connections
		end
		def create_cyp450inducer(substance_name)
			conn = ODDB::CyP450InducerConnection.new(substance_name)
			#puts "create_inducer"
			@inducers.store(substance_name, conn)
		end
		def create_cyp450inhibitor(substance_name)
			conn = ODDB::CyP450InhibitorConnection.new(substance_name)
			#puts "create_inhibitor"
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
