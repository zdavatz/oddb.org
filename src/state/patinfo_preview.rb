#!/usr/bin/env ruby
# PatinfoPreviewState -- oddb -- 21.11.2003 -- rwaltert@ywesee.com

require 'view/patinfo'

module ODDB
	class PatinfoPreviewState < GlobalState
		VOLATILE = true
		VIEW = PatinfoPreview
	end
end

