#!/usr/bin/env ruby
# AtcChooserState  -- oddb -- 14.07.2003 -- maege@ywesee.com

require 'state/global_predefine'
require 'view/atcchooser'

module ODDB
	class AtcChooserState < GlobalState
		attr_reader :user_code
		DIRECT_EVENT = :atc_chooser
		VIEW = AtcChooserView
	end
end
