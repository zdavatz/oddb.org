#!/usr/bin/env ruby
# GaldatDownloadState -- oddb -- 18.08.2003 -- maege@ywesee.com

require 'state/global_predefine'
require 'view/galdatdownload'

module ODDB
	class GaldatDownloadState < GlobalState
		VIEW = GaldatDownloadView
	end
end		
