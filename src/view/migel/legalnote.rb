#!/usr/bin/env ruby
#  -- oddb -- 04.10.2005 -- ffricker@ywesee.com

require 'htmlgrid/composite'
require 'view/popoptemplate'

module ODDB
	module View
		class LegalNoteInfo < HtmlGrid::Composite
			COMPONENTS = {
				[0,0]	=>	'legal_note',
				[0,1] =>	'legal_note_text1',
				[0,2] =>	'lookandfeel_owner',
				[0,2,1] =>'legal_note_text2',
				[0,3] =>	'legal_note_text3',
			}
			CSS_MAP = {
				[0,0]	=>	'th',
				[0,1]	=>	'list',
				[0,2]	=>	'list',
				[0,3]	=>	'list',
			}
		end
		class LegalNote < View::PopupTemplate
			HEAD = View::PopupLogoHead
			CONTENT = View::LegalNoteInfo
		end
	end
end
