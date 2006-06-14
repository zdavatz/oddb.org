#!/usr/bin/env ruby
# AnalyisParse -- BlockListParser -- 10.11.2005 -- hwyss@ywesee.com

require 'parser'

module ODDB
	module AnalysisParse
		class BlockListParser < Parser
			LINE_PTRN = /^\s*([CNS]|N,\s*ex|TP)?\s*\d{4}\.\d{2,}\s+\d/
			labareas = %w{C G H I M}
			permutations = []
			while(la = labareas.shift)
				str = "(" << la
				labareas.each { |other| str << other << '?' }
				str << ")"
				permutations << str
			end
			grammar = <<-EOG
Grammar AnalysisList
	Tokens
		SPACE				= /[\\n\\s\\t ]/	[:Skip]
		NEWLINE			= /\\n/
		GROUP				=	/[0-9]{4}/
		LABAREA			= /(#{permutations.join('|')}) *$/
		POSITION		=	/[0-9]{2,}/
		REVISION		= /^[CS]|N(,\s*ex)?|TP/
		TAXPOINTS		=	/[0-9]+/
		WORD				=	/((\\d{1,2}\\.){2}\\d{4})|(\\d{4}\.\\d{2})|([^#{STOPCHARS}\\s\\t ]+)|([#{STOPCHARS}])/im
	Productions
		Line				->	REVISION? GROUP '.' POSITION
										TAXPOINTS Description LABAREA
										Description? NEWLINE
										[: revision, group, _, position,
											taxpoints, description, 
											labarea, morelines, _ ]
		Description	->	WORD+ 
										[^: description ]
			EOG
			PARSER = Parse.generate_parser grammar
		end
	end
end
