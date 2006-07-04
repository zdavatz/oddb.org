#!/usr/bin/env ruby
# Analysis::Position -- oddb.org -- 12.06.2006 -- sfrischknecht@ywesee.com

require 'util/searchterms'
require 'model/analysis/permission'

module ODDB
	module Analysis
		class Position
			include Persistence
			ODBA_SERIALIZABLE = ['@permissions']
			attr_accessor :taxpoints, :limitation, :list_title,
				:description, :anonymous, :footnote,
				:anonymousgroup, :anonymouspos, :lab_areas,
				:taxnumber, :taxnote, :analysis_revision, :finding,
				:poscd, :group, :taxpoint_type, :permissions
			def initialize(poscd)
				@positions = {}
				@poscd = poscd
				@permissions = []
			end
			def code
				[groupcd, @poscd].join('.')
			end
			def groupcd
				@group.groupcd
			end
			def search_terms
				ODDB.search_terms(@description.split(' '))
			end
		end
	end
end
