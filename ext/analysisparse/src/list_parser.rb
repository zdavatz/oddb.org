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
		SPACE				= /[\\n\\s\\t ]/u [:Skip]
		NEWLINE			= /\\n/u
		FINDING			= /\\b[pn](?=\\s)/u
		GROUP				=	/[0-9]{4}/u
		LABAREA			= /(#{permutations.join('|')}) *$/u
		LIMITATION	= /[#{STOPCHARS}]\\s*[Ll]imitation:/u
		POSITION		=	/^\\s*[0-9]{2,}/u
		REVISION		= /[CS]|N(,\s*ex)?|TP/u
		TAXPOINTS		=	/[0-9]+/u
		WORD				=	/((\\d{1,2}\\.){2}\\d{4})|(\\d{4}\.\\d{2})|((?!\\b[pn]\\s|\\s*Limitation:|\\s*limitation:)[^#{STOPCHARS}\\s\\t ]+)|([#{STOPCHARS}])/imu
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
