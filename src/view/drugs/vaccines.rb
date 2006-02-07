#!/usr/bin/env ruby
# View::Drugs::Vaccines -- oddb -- 06.02.2006 -- hwyss@ywesee.com

module ODDB
	module View
		module Drugs
class ExplainVaccines < View::ExplainResult
	COMPONENTS = {
		[0,0]	=>	:explain_vaccine,
		[1,0]	=>	'explain_fd',
		[2,0]	=>	'explain_g',
	}
	CSS_MAP = {
		[1,0,2]	=> 'explain-infos',
	}
end
class VaccinesComposite < HtmlGrid::Composite
	include ResultFootBuilder
	EXPLAIN_RESULT = View::Drugs::ExplainVaccines
	COMPONENTS = {
		[0,0]	=> :title_vaccines,
		[1,0]	=>	SearchForm,
		[0,1]	=> View::Drugs::SequenceList,
		[0,2]	=> :result_foot,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'result-found list',
	}
	COLSPAN_MAP	= {
		[0,1]	=> 2,
		[0,2]	=> 2,
	}
	LEGACY_INTERFACE = false
	def title_vaccines(model)
		unless(model.empty?)
			@lookandfeel.lookup(:title_vaccines, 
				@session.state.interval, model.size)
		end
	end
end
class Vaccines < View::ResultTemplate
	CONTENT = View::Drugs::VaccinesComposite
end
		end
	end
end
