#!/usr/bin/env ruby
# MedData::Result -- oddb -- 21.12.2004 -- jlang@ywesee.com

module ODDB
	module MedData
		class Result
			attr_reader :session, :values, :ctl
			def initialize(session, values, ctl)
				@session = session
				@values = values
				@ctl = ctl
			end
		end
	end
end
