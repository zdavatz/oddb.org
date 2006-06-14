#!/usr/bin/env ruby
#  -- oddb.org -- 12.06.2006 -- sfrischknecht@ywesee.com

module ODDB
	module Analysis
		class Position
			include Persistence
			attr_accessor :taxpoints, :limitation, 
				:description, :anonymous, :footnote,
				:anonymousgroup, :anonymouspos, :lab_areas,
				:taxnumber, :taxnote, :revision, :finding,
				:poscd, :group
			def initialize(poscd)
				@positions = {}
				@poscd = poscd
			end
			def search_terms
				ODDB.search_terms(@description.split(' '))
			end
		end
	end
end
