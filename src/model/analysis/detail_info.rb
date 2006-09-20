#!/usr/bin/env ruby
#  Analysis::Detail_Info-- oddb.org -- 07.09.2006 -- sfrischknecht@ywesee.com


module ODDB
	module Analysis
		class DetailInfo
			include Persistence
			attr_accessor :info_description, :info_interpretation, 
				:info_indication, :info_significance, 
				:info_ext_material, :info_ext_condition,
				:info_storage_condition, :info_storage_time,
				:lab_key
			def initialize(lab_key)
				@lab_key = lab_key
			end
			def to_s
				[@info_description, @info_interpretation, 
				@info_indication, @info_significance, 
				@info_ext_material, @info_ext_condition,
				@info_storage_condition, @info_storage_time].compact.join(' ')
			end
		end
	end
end
