#!/usr/bin/env ruby
# CyP450Connection -- oddb -- 04.05.2004 -- maege@ywesee.com

require 'util/persistence'

module ODDB
	class AbstractLink
		attr_accessor :info, :href, :text
	end
	class CyP450Connection 
		attr_accessor :category, :links
		include Persistence
		def initialize
			super
			@links = []
		end
		def init(app=nil)
			unless(@pointer.last_step.size > 1)
				@pointer.append(@oid) 
			end
			@pointer
		end
	end
	class CyP450SubstrateConnection < CyP450Connection
		attr_reader :cyp_id
		def initialize(cyp_id)
			super()
			@cyp_id = cyp_id
		end
		def has_interaction_with?(other)
			@cytochromes.each { |cytochrome|
				cytochrome.has_connection?(other)
			}
		end
		def adjust_types(values, app)
			if(cyp_id = values[:cyp450])
				values.store(:cyp450, app.cyp450(cyp_id))
			end
			values
		end
	end
	class CyP450InteractionConnection < CyP450Connection
		attr_reader :substance_name
		def initialize(substance_name)
			super()
			@substance_name = substance_name
		end
		def adjust_types(values, app)
			if(conn_name = values[:substance])
				substance = app.substance_by_conn_name(conn_name)
				values.store(:substance, substance)
			end
			values
		end
	end
	class CyP450InhibitorConnection < CyP450InteractionConnection
	end
	class CyP450InducerConnection < CyP450InteractionConnection
	end
end
