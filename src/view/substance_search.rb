#!/usr/bin/env ruby
# SubstanceSearchView -- oddb -- 23.08.2004 -- maege@ywesee.com

require 'view/substance_centeredsearchform'

module ODDB
	class SubstanceSearchView < SearchView
		CONTENT = SubstanceCenteredSearchComposite
	end
end
