#!/usr/bin/env ruby
# ResultFoot -- oddb -- 20.03.2003 -- hwyss@ywesee.com 

require 'htmlgrid/composite'

module ODDB
	class ExplainResult < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]	=>	'explain_original',
			[0,1]	=>	'explain_generic',
			[0,2]	=>	'explain_unknown',
			[1,0]	=>	'explain_fi',
			[1,1]	=>	'explain_pi',
			[1,2]	=>	'explain_efb',
			[2,0]	=>	'explain_li',
			[2,1]	=>	'explain_sl',
			[2,2]	=>	'explain_pbp',
		}
		CSS_MAP = {
			[0,0]	=>	'explain-original',
			[0,1]	=>	'explain-generic',
			[0,2]	=>	'explain-unknown',
			[1,0]	=>	'explain-infos',
			[1,1]	=>	'explain-infos',
			[1,2]	=>	'explain-infos',
			[2,0]	=>	'explain-infos',
			[2,1]	=>	'explain-infos',
			[2,2]	=>	'explain-infos',
		}
	end
	class LegalNote < HtmlGrid::Composite
		COMPONENTS = {
			[0,0]	=>	:legal_note,
		}
		CSS_MAP = {
			[0,0]	=>	'legal-note',
		}
		CSS_CLASS = "legal-note"
		def legal_note(model, session)
			link = HtmlGrid::PopupLink.new(:legal_note, model, session, self)
			link.href = @lookandfeel.event_url(:legal_note)
			link.value = @lookandfeel.lookup(:legal_note) 
			link.set_attribute('class', 'legal-note')
			link
		end
	end
	class ResultFoot < HtmlGrid::Composite
		COLSPAN_MAP	= {
			[0,0]	=> 2,
			[0,1]	=> 2,
		}
		COMPONENTS = {
			[0,0]	=>	LegalNote,
			[0,1]	=>	ExplainResult,
		}
		COMPONENT_CSS_MAP = {
		[0,0]	=>	'legal-note',
		[0,1]	=>	'explain-result',
		}
		CSS_CLASS = 'composite'
	end
end
