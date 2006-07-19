#!/usr/bin/env ruby
# AnalyisParse -- AppendixListParser -- 10.11.2005 -- hwyss@ywesee.com

require 'parser'

module ODDB
	module AnalysisParse
		class AppendixListParser < Parser
			grammar = <<-EOG
Grammar AnalysisList
	Tokens
		SPACE				= /[\\n\\s\\t ]/	[:Skip]
		NEWLINE			= /\\n/
		GROUP				=	/[0-9]{4}/
		LIMITATION	= /Limitation:/
		POSITION		=	/[0-9]{2,}/
		REVISION		= /^[CS]|N(,\\s*ex)?|TP/
		TAXPOINTS		=	/[0-9]+/
		WORD				=	/((\\d{1,2}\\.){2}\\d{4})|(\\d{4}\\.\\d{2})|([#{STOPCHARS}])|((?!Limitation)[^#{STOPCHARS}\\s]+)/im
	Productions
		Line				->	REVISION? GROUP '.' POSITION '*'? 
										TAXPOINTS Description Limitation?
										NEWLINE
										[: revision, group, _, position,
											anonymous, taxpoints,
											description, limitation, _ ]
		Description	->	WORD+ 
										[^: description ]
		Limitation	->	LIMITATION Description
										[: _, description ]
			EOG
			PARSER = Parse.generate_parser grammar
		end
	end
end
