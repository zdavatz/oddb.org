#!/usr/bin/env ruby
# View::Migel::Subgroup -- oddb -- 05.10.2005 -- ffricker@ywesee.com

require 'view/privatetemplate'
require 'view/migel/result'
require 'view/pointervalue'
require 'model/migel/subgroup'
require 'view/dataformat'

module ODDB
	module View
		module Migel
class SubgroupComposite < HtmlGrid::Composite
	COMPONENTS = {}
end
class Subgroup < View::PrivateTemplate
	CONTENT = SubgroupComposite
	SNAPBACK_EVENT = :result	
end
		end
	end
end
