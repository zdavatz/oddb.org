#!/usr/bin/env ruby
# State::User::OddbDatDownload -- oddb -- 18.08.2003 -- maege@ywesee.com

require 'state/user/global'
require 'view/user/oddbdatdownload'

module ODDB
	module State
		module User
class OddbDatDownload < State::User::Global
	VIEW = View::User::OddbDatDownload
	DIRECT_EVENT = :oddbdat_download
end
		end
	end
end		
