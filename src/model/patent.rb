#!/usr/bin/env ruby
# Patent -- oddb.org -- 05.05.2006 -- hwyss@ywesee.com

require 'util/persistence'
require 'util/today'

module ODDB
	class Patent
		include Persistence
    attr_accessor :base_patent, :base_patent_date, :certificate_number,
      :expiry_date, :iksnr, :issue_date, :protection_date,
      :publication_date, :registration_date, :deletion_date
		def pointer_descr
			:patent
		end
		def protected?
			!@deletion_date && @expiry_date && @expiry_date >= @@today
		end
	end
end
