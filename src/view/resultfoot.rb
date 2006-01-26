#!/usr/bin/env ruby
# View::ResultFoot -- oddb -- 20.03.2003 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'htmlgrid/link'
require 'view/external_links'

module ODDB
	module View
		class ExplainResult < HtmlGrid::Composite
			include ExternalLinks
			COMPONENTS = {
				[0,0]	=>	:explain_original,
				[0,1]	=>	:explain_generic,
				[0,2]	=>	:explain_complementary,
				[0,3]	=>	:explain_vaccine,
				[0,4]	=>	'explain_unknown',
				[0,7]	=>	:explain_cas,
				[1,0]	=>	'explain_li',
				[1,1]	=>	'explain_fi',
				[1,2]	=>	'explain_pi',
				[1,3]	=>	'explain_narc',
				[1,4]	=>	'explain_a',
				[1,5]	=>	'explain_h',
				[1,6]	=>	'explain_p',
				[1,7]	=>	'explain_pr',
				[2,0]	=>	'explain_efp',
				[2,1]	=>	'explain_pbp',
				[2,2]	=>	'explain_sl',
				#[2,3]	=>	'explain_hors_commerce',
				[2,3]	=>	'explain_slo',
				[2,4]	=>	'explain_slg',
				[2,5]	=>	'explain_fd',
				[2,6]	=>	'explain_g',
			}
			CSS_MAP = {	
				[0,4]	=>	'explain-unknown',
				[0,7]	=>	'explain-infos',
				[1,0,2,8]	=>	'explain-infos',
			}
			def init
				if(@lookandfeel.enabled?(:atupri_web, false))
					@components = {
						[0,0]	=>	:explain_original,
						[0,1]	=>	:explain_generic,
						[0,2]	=>	:explain_complementary,
						[0,3]	=>	:explain_vaccine,
						[0,4]	=>	'explain_unknown',
						[0,6]	=>	'explain_li',
						[0,7]	=>	'explain_fi',
						[0,8]	=>	'explain_pi',
						[0,9]	=>	'explain_narc',
						[1,1]	=>	'explain_a',
						[1,2]	=>	'explain_h',
						[1,3]	=>	'explain_p',
						[1,4]	=>	'explain_pr',
						[1,5]	=>	'explain_efp',
						[1,6]	=>	'explain_pbp',
						[1,7]	=>	'explain_sl',
						[1,8]	=>	'explain_slo',
						[1,9]	=>	'explain_slg',
					}
					@css_map = {
						[0,4]	=>	'explain-unknown',
						[0,5,1,5]	=>	'explain-infos',
						[1,0,1,10]	=>	'explain-infos',
					}
				end
				super
			end
			def explain_original(model, session=@session)
				explain_link(model, :original)
			end
			def explain_generic(model, session=@session)
				explain_link(model, :generic)
			end
			def explain_complementary(model, session=@session)
				explain_link(model, :complementary)
			end
			def explain_vaccine(model, session=@session)
				explain_link(model, :vaccine)
			end
			def explain_cas(model, session=@session)
				link = HtmlGrid::Link.new(:explain_cas,
					model, @session, self)
				link.href = "http://cas.org"
				link
			end
			def explain_narc(model, session=@session)
				create_link(:explain_narc, 
					'http://wiki.oddb.org/wiki.php?pagename=ODDB.Pi-Upload')
			end
			def explain_link(model, key)
				link = external_link(model, "explain_#{key}")
				link.href = @lookandfeel.lookup("explain_#{key}_url") 
				link.attributes['class'] = "explain-#{key}"
				link 
			end
		end
		module ResultFootBuilder
			def result_foot(model, session=@session)
				if(@lookandfeel.navigation.include?(:legal_note))
					View::ExplainResult.new(model, @session, self)
				else
					View::ResultFoot.new(model, @session, self)
				end
			end
		end
		class ResultFoot < HtmlGrid::Composite
			include ExternalLinks
			COLSPAN_MAP	= {
			}
			COMPONENTS = {
				[0,0]	=>	View::ExplainResult,
				[1,0]	=>	:legal_note,
			}
			COMPONENT_CSS_MAP = {
				[0,0]	=>	'explain-result',
				[1,0]	=>	'explain-result-r',
			}
			CSS_MAP = {
				[0,0]	=>	'explain-result',
				[1,0]	=>	'explain-result-r',
			}
			CSS_CLASS = 'composite'
			def legal_note(model, session=@session)
			  link = super(model)
				link.css_class = 'subheading'
			  link
		  end
		end
	end
end
