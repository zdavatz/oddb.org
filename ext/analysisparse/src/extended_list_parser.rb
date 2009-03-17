#!/usr/bin/env ruby
# AnalyisParse -- ExtendedListParser -- 10.11.2005 -- hwyss@ywesee.com

require 'parser'

module ODDB	
	module AnalysisParse
		class ExtendedListParser < Parser
			FOOTNOTE_TYPE = :restriction
			LINE_PTRN  = /^\s*([CNS]|N,\s*ex|TP)?\s*\d{4}\.\d{2,}\s*[\d\*]/u
			STOPCHARS2 = ';.('
			grammar = <<-EOG
Grammar AnalysisList
	Tokens
		SPACE				= /[\\n\\s\\t ]/u [:Skip]
		NEWLINE			= /\\n/u
		FOOTNOTE		=	/\\d/u
		GROUP				=	/[0-9]{4}/u
		LIMITATION	= /Limitation:/u
		NOTE				=	/^\\(\\d+\\)\\s*/u
		POSITION		=	/[0-9]{2,}/u
		REVISION		= /^[CS]|N(,\s*ex)?|TP/u
		TAXPOINTS		=	/[0-9]+/u
		TAXNUMBER	  = /\\(\\d+\\)/u
		WORD				=	/((\\d{1,2}\\.){2}\\d{4})|(\\d\\.\\d\\.\\d)|(\\(\\w+\\):)|(z\\.B\\.)|(\\d\\.\\d)|(\\d{4}\\.\\d{2})|([#{STOPCHARS2}]+)|((?!Limitation)[^#{STOPCHARS2}\\s]+)/imu
	Productions
		Line				->	REVISION? GROUP '.' POSITION FOOTNOTE? '*'?
										TAXPOINTS TAXNUMBER? Description
										Limitation? Taxnote?
										NEWLINE
										[: revision, group, _, position,
										restriction, anonymous, taxpoints,
										taxnumber, description, limitation,
											taxnote, _ ]
		Description	->	/[A-ZöäüÉéèà:,]+/iu WORD*
		Limitation	->	LIMITATION Description
										[: _, description ]
		Taxnote			->	NOTE Description
										[: _, description ]
			EOG
			PARSER = Parse.generate_parser grammar
		end
	end
end
