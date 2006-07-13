#!/usr/bin/env ruby
# View::Analysis::Result -- oddb.org -- 14.06.2006 -- sfrischknecht@ywesee.com

require 'htmlgrid/list'
require 'model/analysis/position'
require 'view/additional_information'
require 'view/pointervalue'
require 'view/privatetemplate'
require 'view/resultfoot'

module ODDB
	module View
		module Analysis
class List < HtmlGrid::List
	include View::AdditionalInformation
	COMPONENTS = {
		[0,0]	=> :code,
		[1,0]	=> :lab_areas,
		[2,0]	=> :list_title,
		[3,0]	=> :analysis_description,
		[4,0]	=> :taxpoints,
		[5,0]	=> :analysis_revision,
#		[6,0]	=> :feedback,
		[6,0]	=> :google_search,
#		[7,0]	=> :notify,
	}
	CSS_CLASS = 'composite'
	CSS_HEAD_MAP = {
		[0,0]	=>	'th',
		[1,0]	=>	'th',
		[2,0]	=>	'th',
		[3,0]	=>	'th',
		[4,0]	=>	'th',
		[5,0]	=>	'th',
	}
	CSS_MAP = {
		[0,0,6]	=>	'list',
		[6,0,1]	=>	'list-r',
	}
	LEGACY_INTERFACE = false
	SORT_DEFAULT = :code
	def analysis_description(model)
		link = PointerLink.new(:to_s, model, @session, self)
		text = model.description.gsub("\n", ' ')
		if(text.size > 60)
			if(match = /^([\S]*block)/.match(text))
				text = match[1]
			elsif(match = /^(Blutgase)/.match(text))
				text = match[1]
			else
				text = text[0..60]
				text = text[0..text.rindex(" ")] << '...'
			end
		end
		link.value = text
		link
	end
end
class ResultList < View::Analysis::List
end
class ExplainAnalysisColumns < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]		=>	'explain_analysis_revision',
		[0,1]		=>	'explain_analysis_rev_C',
		[0,2]		=>	'explain_analysis_rev_N',
		[0,3]		=>	'explain_analysis_rev_Nex',
		[0,4]		=>	'explain_analysis_rev_S',
		[0,5]		=>	'explain_analysis_rev_TP',
		[0,7]		=>	'explain_analysis_labarea',
		[0,8]		=>	'explain_analysis_lab_C',
		[0,9]		=>	'explain_analysis_lab_G',
		[0,10]	=>	'explain_analysis_lab_H',
		[0,11]	=>	'explain_analysis_lab_I',
		[0,12]	=>	'explain_analysis_lab_M',
	}
end
class ExplainAnalysisTechnical1 < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]		=>	'analysis_description',
		[0,1]		=>	'explain_analysis_tech_AAS',
		[0,2]		=>	'explain_analysis_tech_AL',
		[0,3]		=>	'explain_analysis_tech_ALT',
		[0,4]		=>	'explain_analysis_tech_Bi',
		[0,5]		=>	'explain_analysis_tech_F',
		[0,6]		=>	'explain_analysis_tech_GC',
		[0,7]		=>	'explain_analysis_tech_GC_MS',
		[0,8]		=>	'explain_analysis_tech_HPLC',
		[0,9]		=>	'explain_analysis_tech_HPLC_MS',
		[0,10]	=>	'explain_analysis_tech_IEP',
		[0,11]	=>	'explain_analysis_tech_IF',
		[0,12]	=>	'explain_analysis_tech_L',
		[0,13]	=>	'explain_analysis_tech_n',
	}	
end
class ExplainAnalysisTechnical2 < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	'explain_analysis_tech_p',
		[0,1]	=>	'explain_analysis_tech_PCR',
		[0,2]	=>	'explain_analysis_tech_ql',
		[0,3]	=>	'explain_analysis_tech_qn',
		[0,4]	=>	'explain_analysis_tech_R',
		[0,5]	=>	'explain_analysis_tech_RAST',
		[0,6]	=>	'explain_analysis_tech_RIA',
		[0,7]	=>	'explain_analysis_tech_S',
		[0,8]	=>	'explain_analysis_tech_SL',
		[0,9]	=>	'explain_analysis_tech_sq',
		[0,10]	=>	'explain_analysis_tech_ST',
		[0,11]	=>	'explain_analysis_tech_U',
		[0,12]	=>	'explain_analysis_tech_WB',
	}
end
class ExplainResult < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]		=>	ExplainAnalysisColumns,
		[1,0]		=>	ExplainAnalysisTechnical1,
		[2,0]		=>	ExplainAnalysisTechnical2,
	}
end
class ResultComposite < HtmlGrid::Composite
	include ResultFootBuilder	
	EXPLAIN_RESULT = View::Analysis::ExplainResult
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	=>	ResultList,
		[0,1]	=>	:result_foot,
	}
end
class Result < View::PrivateTemplate
	CONTENT = ResultComposite
	SNAPBACK_EVENT = :result
end
class EmptyResultForm < HtmlGrid::Form
	COMPONENTS = {
		[0,0]		=>	:search_query,
		[0,0,1]	=>	:submit,
		[0,1]		=>	:title_none_found,
		[0,2]		=>	'e_empty_result',
	}
	CSS_MAP	=	{
		[0,0]			=>	'search',
		[0,1]			=>	'th',
		[0,2,1,1]	=>	'result-atc',
	}
	CSS_CLASS = 'composite'
	EVENT = :search
	FORM_METHOD = 'GET'
	SYMBOL_MAP = {
		:search_query	=>	View::SearchBar
	}
	def title_none_found(model, session)
		query = session.persistent_user_input(:search_query)
		@lookandfeel.lookup(:title_none_found, query)
	end
end
class EmptyResult < View::ResultTemplate
	CONTENT = EmptyResultForm
end
		end
	end
end
