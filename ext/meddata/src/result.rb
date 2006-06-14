#!/usr/bin/env ruby
# MedData::Result -- oddb -- 21.12.2004 -- jlang@ywesee.com

module ODDB
	module MedData
		class Result
			attr_reader :values, :ctl
			def initialize(values, ctl)
				@values = values
				@ctl = ctl
			end
		end
	end
end
