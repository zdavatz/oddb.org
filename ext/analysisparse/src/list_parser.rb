#!/usr/bin/env ruby
# AnalyisParse -- Parser -- 10.11.2005 -- hwyss@ywesee.com

require 'parser'

module ODDB
	module AnalysisParse
		class ListParser < Parser
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
		FINDING			= /\\b[pn](?=\\s)/
		GROUP				=	/[0-9]{4}/
		LABAREA			= /(#{permutations.join('|')}) *$/
		LIMITATION	= /[#{STOPCHARS}]\\s*Limitation:/
		POSITION		=	/^\\s*[0-9]{2,}/
		REVISION		= /[CS]|N(,\s*ex)?|TP/
		TAXPOINTS		=	/[0-9]+/
		WORD				=	/((\\d{1,2}\\.){2}\\d{4})|(\\d{4}\.\\d{2})|((?!\\b[pn]\\s)[^#{STOPCHARS}\\s\\t ]+)|([#{STOPCHARS}])/im
	Productions
		Line				->	REVISION? GROUP '.' POSITION '*'? 
										TAXPOINTS FINDING? Description
										Limitation? LABAREA
										Description? Limitation? NEWLINE
										[: revision, group, _, position,
											anonymous, taxpoints, finding,
											description, limitation, labarea,
											morelines, limitation2]
		Description	->	WORD+ 
										[^: description ]
		Limitation	->	LIMITATION Description
										[: _, description ]
			EOG
			PARSER = Parse.generate_parser grammar
		end
	end
end
