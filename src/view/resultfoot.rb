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
				[0,2]	=>	:explain_comarketing,
				[0,3]	=>	:explain_complementary,
				[0,4]	=>	:explain_vaccine,
				[0,5]	=>	'explain_unknown',
				[0,6]	=>	'explain_expired',
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
				[2,2]	=>	:explain_deductible,
				[2,3]	=>	'explain_sl',
				[2,4]	=>	'explain_slg',
				[2,5]	=>	'explain_fd',
				[2,6]	=>	:explain_lppv,
				[2,7]	=>	'explain_g',
			}
			CSS_MAP = {}
			CSS_KEYMAP = {
				'explain_unknown'	=>	'explain-unknown',
				'explain_expired'	=>	'explain-unknown expired',
				:explain_cas			=>	'explain-infos',
				'explain_li'			=>	'explain-infos',
				'explain_fi'			=>	'explain-infos',
				'explain_pi'			=>	'explain-infos',
				'explain_narc'		=>	'explain-infos',
			}
			def init
				@components = @lookandfeel.explain_result_components
				width = 1
				height = 1
				@components.each { |key, val| 
					if(klass = CSS_KEYMAP[val])
						css_map.store(key, klass)
					end
					x, y, = key
					width = [x, width].max
					height = [y.next, height].max
				}
				@css_map.store([1, 0, width, height], 'explain-infos')
				super
			end
			def explain_comarketing(model, session=@session)
				explain_link(model, :comarketing)
			end
			def explain_deductible(model, session=@session)
				explain_link(model, :deductible)
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
			def explain_lppv(model, session=@session)
				link = HtmlGrid::Link.new(:explain_lppv, model, @session, self)
				link.href = @lookandfeel.lookup(:lppv_url)
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
			EXPLAIN_RESULT = ExplainResult
			def result_foot(model, session=@session)
				if(@lookandfeel.navigation.include?(:legal_note))
					self.class::EXPLAIN_RESULT.new(model, @session, self)
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
				[0,0]	=>	:explain_result,
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
			def explain_result(model, session=@session)
				klass = nil
				if(defined?(@container.class::EXPLAIN_RESULT))
					klass = @container.class::EXPLAIN_RESULT
				end
				klass ||= View::ExplainResult
				klass.new(model, @session, self)
			end
			def legal_note(model, session=@session)
				link = super(model)
				link.css_class = 'subheading'
				link
			end
		end
	end
end
