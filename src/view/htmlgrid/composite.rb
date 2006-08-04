#!/usr/bin/env ruby
# HtmlGrid::Composite -- oddb -- 17.02.2006 -- hwyss@ywesee.com

require 'htmlgrid/composite'

module HtmlGrid
	class Composite
		def Composite.event_link(name)
			define_method(name) { |*args|
				link = HtmlGrid::Link.new(name, args.first, @session, self)
				link.href = @lookandfeel._event_url(name)
				link
			}
		end
	end
end
