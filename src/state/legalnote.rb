#!/usr/bin/env ruby
# LegalNoteState -- oddb -- 01.09.2003 -- maege@ywesee.com

require 'state/global_predefine'
require 'view/legalnote'

module ODDB
	class LegalNoteState < GlobalState
		VIEW = LegalNoteView
		VOLATILE = true
	end
end
