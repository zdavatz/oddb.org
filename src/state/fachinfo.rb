#!/usr/bin/env ruby
# FachinfoState -- oddb -- 17.09.2003 -- rwaltert@ywesee.com

require 'state/global_predefine'
require 'view/fachinfo'

module ODDB
	class FachinfoState < GlobalState
		VIEW = FachinfoView
		VOLATILE = true
	end
	class FachinfoPreviewState < GlobalState
		VIEW = FachinfoPreview
		VOLATILE = true
	end
	class FachinfoPrintState < GlobalState
		VIEW = FachinfoPrintView
		VOLATILE = true
	end
end
