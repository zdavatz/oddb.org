#!/usr/bin/env ruby
# InteractionSearchView -- oddb -- 26.05.2004 -- maege@ywesee.com

require 'view/interaction_centeredsearchform'

module ODDB
	class InteractionSearchView < SearchView
		CONTENT = InteractionCenteredSearchComposite
	end
end
