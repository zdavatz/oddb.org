#!/usr/bin/env ruby
# DownloadState -- ODDB -- 29.10.2003 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/download'

module ODDB
	class DownloadState < GlobalState
		VIEW = DownloadView
		VOLATILE = true
	end
end
