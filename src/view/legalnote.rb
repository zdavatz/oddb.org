#!/usr/bin/env ruby
# View::LegalNote -- oddb -- 01.09.2003 -- mhuggler@ywesee.com

require 'htmlgrid/composite'
require 'view/popuptemplate'

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
		class LegalNoteDoctorInfo < HtmlGrid::Composite
			COMPONENTS = {
				[0,0]	=>	'legal_note',
				[0,1] =>	'legal_note_doctors_text1',
				[0,2] =>	'lookandfeel_doctors_owner',
				[0,2,1] =>'legal_note_doctors_text2',
				[0,3] =>	'legal_note_doctors_text3',
				[0,4] =>	'legal_note_doctors_text4',
			}
			CSS_MAP = {
				[0,0]	=>	'th',
				[0,1]	=>	'list',
				[0,2]	=>	'list',
				[0,3]	=>	'list',
				[0,4]	=>	'list',
			}
		end
		class LegalNote < View::PopupTemplate
			HEAD = View::PopupLogoHead
			CONTENT = View::LegalNoteInfo
		end
		module Doctors
			class LegalNote < View::PopupTemplate
				HEAD = View::PopupLogoHead
				CONTENT = View::LegalNoteDoctorInfo
			end
		end
	end
end
