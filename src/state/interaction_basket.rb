#!/usr/bin/env ruby
# InteractionBasketState -- oddb -- 07.06.2004 -- maege@ywesee.com

require	'state/global_predefine'
require	'view/interaction_basket'

module ODDB
	class InteractionBasketState < GlobalState
		VIEW = InteractionBasketView
	end
	class EmptyInteractionBasketState < GlobalState
		VIEW = InteractionBasketView
	end
end
