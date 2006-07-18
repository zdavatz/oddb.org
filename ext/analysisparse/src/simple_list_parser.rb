#!/usr/bin/env ruby
# AnalyisParse -- SimpleListParser -- 10.11.2005 -- hwyss@ywesee.com

require 'parser'

module ODDB
	module AnalysisParse
		class SimpleListParser < Parser
			grammar = <<-EOG
Grammar AnalysisList
	Tokens
		SPACE				= /\\s+/	[:Skip]
		GROUP				=	/[0-9]{4}/
		POSITION		=	/[0-9]{2}/
		REVISION		= /^[CS]|N(,\\s*ex)?|TP/
		TAXPOINTS		=	/[0-9]+/
		WORD				=	/\\S+/
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
