#!/usr/bin/env ruby
# PassThruState -- ODDB -- 21.10.2003 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/passthru'

module ODDB
	class PassThruState < GlobalState
		VIEW = PassThruView
		VOLATILE = true
	end
end
