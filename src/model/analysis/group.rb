#!/usr/bin/env ruby
#  -- oddb.org -- 12.06.2006 -- sfrischknecht@ywesee.com

require 'util/persistence'
require 'model/analysis/position'

module ODDB
	module Analysis
		class Group
			include Persistence
			attr_reader :groupcd, :positions
			alias :pointer_descr :groupcd
			def initialize(groupcd)
				@groupcd = groupcd
				@positions = {}
			end
			def create_position(poscd)
				position = Position.new(poscd)
				position.group = self
				@positions.store(poscd, position)
			end
			def position(poscd)
				@positions[poscd]
			end
		end
	end
end
