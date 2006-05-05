#!/usr/bin/env ruby
# Patent -- oddb.org -- 05.05.2006 -- hwyss@ywesee.com

require 'util/persistence'

module ODDB
	class Patent
		include Persistence
		attr_accessor :srid, :base_patent, :base_patent_date, :base_patent_srid,
			:certificate_number, :expiry_date, :iksnr, :issue_date, :protection_date,
			:publication_date, :registration_date
		def pointer_descr
			:patent
		end
		def protected?
			@expiry_date && @expiry_date >= @@today
		end
	end
end
