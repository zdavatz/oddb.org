#!/usr/bin/env ruby
# State::Companies::Company -- oddb -- 11.02.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require 'state/global_predefine'
require 'view/hospitals/hospital'
require 'model/hospital'

module ODDB
	module State
		module Hospitals
class Hospital < State::Hospitals::Global
	VIEW = View::Hospitals::Hospital
	LIMITED = true
end
		end
	end
end
