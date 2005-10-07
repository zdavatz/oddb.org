#!/usr/bin/env ruby
# View::Migel::Group -- oddb -- 05.10.2005 -- ffricker@ywesee.com


module ODDB
	module View
		module Migel
class GroupComposite < HtmlGrid::Composite
	COMPONENTS = {}
end
class Group < View::PrivateTemplate
	CONTENT = GroupComposite
	SNAPBACK_EVENT = :result	
end
		end
	end
end

