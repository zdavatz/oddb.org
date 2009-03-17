#!/usr/bin/env ruby
# AnalyisParse -- SimpleListParser -- 10.11.2005 -- hwyss@ywesee.com

require 'parser'

module ODDB
	module AnalysisParse
		class SimpleListParser < Parser
			grammar = <<-EOG
Grammar AnalysisList
	Tokens
		SPACE				= /\\s+/u [:Skip]
		GROUP				=	/[0-9]{4}/u
		POSITION		=	/[0-9]{2}/u
		REVISION		= /^[CS]|N(,\\s*ex)?|TP/u
		TAXPOINTS		=	/[0-9]+/u
		WORD				=	/\\S+/u
	Productions
		Line				->	REVISION? GROUP '.' POSITION 
										TAXPOINTS Description
										[: revision, group, _, position,
											taxpoints, description ]
		Description	->	WORD+ 
										[^: description ]
			EOG
			PARSER = Parse.generate_parser grammar
		end
	end
end
