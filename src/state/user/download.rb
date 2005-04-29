#!/usr/bin/env ruby
# State::User::Download -- ODDB -- 29.10.2003 -- hwyss@ywesee.com

require 'state/user/global'
require 'view/user/download'
require 'view/user/auth_info'
require 'view/drugs/csv_result'

module ODDB
	module State
		module User
class Download < State::User::Global
	VOLATILE = true
	VIEW = View::User::Download
	def init
		query = @model.data[:search_query]
		stype = @model.data[:search_type]
		# if the file is a bespoke export, query and stype should be set
		if(query && stype)
			@model = _search_drugs(query, stype)
			@model.session = @session
			@default_view = View::Drugs::CsvResult
		end
	end
end
		end
	end
end
