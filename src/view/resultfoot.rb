#!/usr/bin/env ruby
# View::ResultFoot -- oddb -- 20.03.2003 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'htmlgrid/link'

module ODDB
	module View
		module LegalNoteLink
			def legal_note(model, session)
				legal_note = nil
			end
		end
		class ExplainResult < HtmlGrid::Composite
			COMPONENTS = {
				[0,0]	=>	:explain_original,
				[0,1]	=>	:explain_generic,
				[0,2]	=>	:explain_complementary,
				[0,3]	=>	'explain_unknown',
				[1,0]	=>	'explain_fd',
				[1,1]	=>	'explain_g',
				[1,2]	=>	'explain_a',
				[1,3]	=>	'explain_h',
				[1,4]	=>	'explain_p',
				[1,5]	=>	'explain_pr',
				[2,0]	=>	'explain_efb',
				[2,1]	=>	'explain_pbp',
				[2,2]	=>	'explain_sl',
				[2,3]	=>	'explain_fi',
				[2,4]	=>	'explain_pi',
				[2,5]	=>	'explain_li',
			}
			CSS_MAP = {	
				[0,3]	=>	'explain-unknown',
				[1,0,2,6]	=>	'explain-infos',
			}
			def explain_original(model, session)
				link = HtmlGrid::Link.new(:explain_original, model, session, self)
				link.href = @lookandfeel.lookup(:explain_original_url) 
				link.value = @lookandfeel.lookup(:explain_original)
				link.attributes['class'] = 'explain-original'
				link
			end
			def explain_generic(model, session)
				link = HtmlGrid::Link.new(:explain_generic, model, session, self)
				link.href = @lookandfeel.lookup(:explain_generic_url) 
				link.value = @lookandfeel.lookup(:explain_generic)
				link.attributes['class'] = 'explain-generic'
				link
			end
			def explain_complementary(model, session)
				link = HtmlGrid::Link.new(:explain_complementary, model, session, self)
				link.href = @lookandfeel.lookup(:explain_complementary_url) 
				link.value = @lookandfeel.lookup(:explain_complementary)
				link.attributes['class'] = 'explain-complementary'
				link
			end
		end
		class ResultFoot < HtmlGrid::Composite
			include LegalNoteLink
			COLSPAN_MAP	= {
				[0,0]	=> 2,
			}
			COMPONENTS = {
				[0,1]	=>	View::ExplainResult,
				[1,1]	=>	:legal_note,
			}
			COMPONENT_CSS_MAP = {
				[0,1]	=>	'explain-result',
				[1,1]	=>	'explain-result-r',
			}
			CSS_CLASS = 'composite'
			def legal_note(model, session)
			  link = HtmlGrid::Link.new(:legal_note, model, @session, self)
			  if(@lookandfeel.language == 'de')
					link.href = "http://wiki.oddb.org/wiki.php?pagename=ODDB.RechtlicherHinweis"
				elsif(@lookandfeel.language == 'fr')
					link.href = "http://wiki.oddb.org/wiki.php?pagename=ODDB.NoticeLegale"
				elsif(@lookandfeel.language == 'en')
					link.href = "http://wiki.oddb.org/wiki.php?pagename=ODDB.LegalDisclaimer"
	      end
				link.css_class = 'subheading'
			  link
		  end
		end
	end
end
