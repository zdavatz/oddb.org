#!/usr/bin/env ruby
# View::DataDeclaration -- ODDB -- 29.04.2005 -- hwyss@ywesee.com

module ODDB
	module View
		module DataDeclaration
def data_declaration(model, session=@session)
	link = HtmlGrid::Link.new(:data_declaration, model, session, self)
	link.href = 'http://wiki.oddb.org/wiki.php?pagename=Swissmedic.Datendeklaration'
	link.css_class = 'th'
	link
end
		end
	end
end
