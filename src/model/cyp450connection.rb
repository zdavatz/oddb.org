#!/usr/bin/env ruby
# CyP450Connection -- oddb -- 04.05.2004 -- maege@ywesee.com

require 'util/persistence'

module ODDB
	class AbstractLink
		attr_accessor :info, :href, :text
	end
	class CyP450Connection 
		attr_accessor :category, :links, :substance
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
		def adjust_types(values, app)
			if(conn_name = values[:substance])
				substance = app.substance(conn_name)
				values.store(:substance, substance)
			end
			values
		end
	end
	class CyP450SubstrateConnection < CyP450Connection
		attr_accessor :cyp450
		attr_reader :cyp_id
		def initialize(cyp_id)
			super()
			@cyp_id = cyp_id
		end
		def interactions_with(substance)
			if(@cyp450)
				@cyp450.interactions_with(substance)
			else
				[]
			end
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
	end
	class CyP450InhibitorConnection < CyP450InteractionConnection
	end
	class CyP450InducerConnection < CyP450InteractionConnection
	end
end
