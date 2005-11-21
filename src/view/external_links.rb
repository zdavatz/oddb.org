#!/usr/bin/env ruby
# View::ExternalLinks -- oddb -- 21.11.2005 -- hwyss@ywesee.com

module ODDB
	module View
		module ExternalLinks
			def external_link(model, key)
				klass = if(@lookandfeel.enabled?(:just_medical_structure,
																				 false))
					HtmlGrid::PopupLink
				else
					HtmlGrid::Link
				end
				klass.new(key, model, @session, self)
			end
			def faq_link(model, session=@session)
				wiki_link(model, :faq_link, :faq_pagename)
			end
			def help_link(model, session=@session)
				wiki_link(model, :help_link, :help_pagename)
			end
			def wiki_link(model, key, namekey)
				link = external_link(model, key)
				name = @lookandfeel.lookup(namekey)
				link.href = "http://wiki.oddb.org/wiki.php?pagename=#{name}"
				link
			end
			## meddrugs_update, data_declaration and legal_note: 
			## extrawurst for just-medical
			def data_declaration(model, session=@session)
				wiki_link(model, :data_declaration, :datadeclaration_pagename)
			end
			def legal_note(model, session=@session)
				wiki_link(model, :legal_note, :legal_note_pagename)
			end
			def meddrugs_update(model, session=@session)
				link = NavigationLink.new(:meddrugs_update, 
					model, @session, self)
				link.href = "http://www.just-medical.com/lastdrugs.cfm"
				link.set_attribute('target', '_top')
				link
			end
		end
	end
end
