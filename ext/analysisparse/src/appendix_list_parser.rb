#!/usr/bin/env ruby
# AnalyisParse -- AppendixListParser -- 10.11.2005 -- hwyss@ywesee.com

require 'parser'

module ODDB
	module AnalysisParse
		class AppendixListParser < Parser
			grammar = <<-EOG
Grammar AnalysisList
	Tokens
		SPACE				= /[\\n\\s\\t ]/u [:Skip]
		NEWLINE			= /\\n/u
		GROUP				=	/[0-9]{4}/u
		LIMITATION	= /Limitation:/u
		POSITION		=	/[0-9]{2,}/u
		REVISION		= /^[CS]|N(,\\s*ex)?|TP/u
		TAXPOINTS		=	/[0-9]+/u
		WORD				=	/((\\d{1,2}\\.){2}\\d{4})|(\\d{4}\\.\\d{2})|([#{STOPCHARS}])|((?!Limitation)[^#{STOPCHARS}\\s]+)/imu
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
