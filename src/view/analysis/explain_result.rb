#!/usr/bin/env ruby
#  View::Analysis::ExplainResult-- oddb.org -- 15.08.2006 -- sfrischknecht@ywesee.com

require 'htmlgrid/list'
require 'util/language'

module ODDB
	module View
		module Analysis
class ExplainAnalysisColumns < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]		=>	'explain_analysis_revision',
		[0,1]		=>	'explain_analysis_rev_C',
		[0,2]		=>	'explain_analysis_rev_N',
		[0,3]		=>	'explain_analysis_rev_Nex',
		[0,4]		=>	'explain_analysis_rev_TP',
		[0,6]		=>	'explain_analysis_labarea',
		[0,7]		=>	'explain_analysis_lab_C',
		[0,8]		=>	'explain_analysis_lab_G',
		[0,9]	=>	'explain_analysis_lab_H',
		[0,10]	=>	'explain_analysis_lab_I',
		[0,11]	=>	'explain_analysis_lab_M',
	}
end
class ExplainAnalysisTechnical1 < HtmlGrid::Composite
	def init
		if(@session.language == 'fr')
			@components = {
				[0,0]		=>	'analysis_description',
				[0,1]		=>	'explain_analysis_tech_AAS',
				[0,2]		=>	'explain_analysis_tech_Bi',
				[0,3]		=>	'explain_analysis_tech_GC',
				[0,4]		=>	'explain_analysis_tech_GC_MS',
				[0,5]		=>	'explain_analysis_tech_F',
				[0,6]		=>	'explain_analysis_tech_HPLC',
				[0,7]		=>	'explain_analysis_tech_HPLC_MS',
				[0,8]		=>	'explain_analysis_tech_IEP',
				[0,9]		=>	'explain_analysis_tech_IF',
				[0,10]	=>	'explain_analysis_tech_L',
				[0,11]	=>	'explain_analysis_tech_AL',
				[0,12]	=>	'explain_analysis_tech_ALT',
				[0,13]	=>	'explain_analysis_tech_SL',
			}
		else
			@components = {
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
	super
	end
end	
class ExplainAnalysisTechnical2 < HtmlGrid::Composite
	def init
		if(@session.language == 'fr')
			@components = {
				[0,1]		=>	'explain_analysis_tech_n',
				[0,2]		=>	'explain_analysis_tech_p',
				[0,3]		=>	'explain_analysis_tech_PCR',
				[0,4]		=>	'explain_analysis_tech_ql',
				[0,5]		=>	'explain_analysis_tech_qn',
				[0,6]		=>	'explain_analysis_tech_R',
				[0,7]		=>	'explain_analysis_tech_RAST',
				[0,8]		=>	'explain_analysis_tech_RIA',
				[0,9]		=>	'explain_analysis_tech_S',
				[0,10]	=>	'explain_analysis_tech_sq',
				[0,11]	=>	'explain_analysis_tech_ST',
				[0,12]	=>	'explain_analysis_tech_U',
				[0,13]	=>	'explain_analysis_tech_WB',
			}	
		else
			@components = {
				[0,1]		=>	'explain_analysis_tech_p',
				[0,2]		=>	'explain_analysis_tech_PCR',
				[0,3]		=>	'explain_analysis_tech_ql',
				[0,4]		=>	'explain_analysis_tech_qn',
				[0,5]		=>	'explain_analysis_tech_R',
				[0,6]		=>	'explain_analysis_tech_RAST',
				[0,7]		=>	'explain_analysis_tech_RIA',
				[0,8]		=>	'explain_analysis_tech_S',
				[0,9]		=>	'explain_analysis_tech_SL',
				[0,10]	=>	'explain_analysis_tech_sq',
				[0,11]	=>	'explain_analysis_tech_ST',
				[0,12]	=>	'explain_analysis_tech_U',
				[0,13]	=>	'explain_analysis_tech_WB',
			}
		end
	super
	end
end
class ExplainResult < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]		=>	ExplainAnalysisColumns,
		[1,0]		=>	ExplainAnalysisTechnical1,
		[2,0]		=>	ExplainAnalysisTechnical2,
	}
	CSS_MAP = {
		[0,0,3] => 'top',
	}
end
		end
	end
end
