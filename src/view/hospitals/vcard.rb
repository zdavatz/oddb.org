#!/usr/bin/env ruby
# View::Hospitals::Vcard -- oddb -- 09.03.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require 'htmlgrid/component'
require 'view/vcard'

module ODDB
	module View
		module Hospitals
class VCard < View::VCard
	def init
		@content = [:name, :addresses]
	end
	def get_filename
		filename = @model.name.gsub(/\s/, '_').to_s + 
			"_" + @model.ean13.gsub(/\s/, '_').to_s + ".vcf"
	end
end
		end
	end
end

