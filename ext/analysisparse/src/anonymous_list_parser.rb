#!/usr/bin/env ruby
# AnalyisParse -- AnonymousListParser -- 10.11.2005 -- hwyss@ywesee.com

require 'parser'

module ODDB
	module AnalysisParse
		class AnonymousListParser < Parser
			LINE_PTRN = /^([CNS]|N,\s*ex|TP)?\s*\d{4}\.\d{2,}\s*\d+\s*\w/
			grammar = <<-EOG
Grammar AnalysisList
	Tokens
		SPACE						= /\\s+/	[:Skip]
		ARROW						= /\\.*\\s*\\?/
		GROUP						=	/[0-9]{4}/
		POSITION				=	/[0-9]{2}/
		REVISION				= /^[CS]|N(,\\s*ex)?|TP/
		TAXPOINTS				=	/[0-9]+/
		WORD						=	/(\\S(?!\\.))+[^.]|\\w|(\\d\\.)/
		DOTS						=	/\\./
	Productions
		Line				->	REVISION? GROUP '.' POSITION 
										TAXPOINTS Description DOTS* 
										ARROW GROUP '.' POSITION 
										[: revision, group, _, position,
											taxpoints, description, _, 
											_, anonymousgroup , _, anonymouspos ]
		Description	->	WORD+ 
										[^: description ]
			EOG
			PARSER = Parse.generate_parser grammar
			def parse_line(src)
				src.gsub!(/\s+/,' ')
				super
			end
		end
	end
end
