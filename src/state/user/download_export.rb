#!/usr/bin/env ruby
# State::User::DownloadExport -- oddb -- 20.09.2004 -- mhuggler@ywesee.com

require 'state/user/global'
require 'view/user/download_export'

module ODDB
	module State
		module User
class DownloadExport < State::User::Global
	VIEW = View::User::DownloadExport
	DIRECT_EVENT = :download_export
end
		end
	end
end
