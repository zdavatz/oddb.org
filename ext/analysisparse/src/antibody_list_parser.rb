#!/usr/bin/env ruby
# AnalyisParse -- AntibodyListParser -- 10.11.2005 -- hwyss@ywesee.com

require 'parser'

module ODDB
	module AnalysisParse
		class AntibodyListParser < Parser
			LINE_PTRN = /^([CNS]|N,\s*ex|TP)?\s*Auto/mu
			grammar = <<-EOG
Grammar AnalysisList
	Tokens
		SPACE				= /[\\n\\s\\t ]/u [:Skip]
		NEWLINE			= /\\n/u
		REVISION		= /^[CS]|N(,\s*ex)?|TP/u
		WORD				=	/(\\d{4}\.\\d{2})|\\d{4}\\.\\d{2}|Auto.*|\\?\\s*kapitel\\s*\\d*,\\s*pos\\.\\s*/imu
	Productions
		Line				->	REVISION? Description
										
										[: revision, description ]
		Description	->	WORD+ 
										[^: description ]
			EOG
			PARSER = Parse.generate_parser grammar
			def parse_line(src)
				ast = PARSER.parse(src)
				desc = ''
				data = {
					:description	=> desc,
				}
				extract_text(ast.description, desc)
				if(node = ast.revision)
					data.store(:revision, node.value)
				end
				data
			end
		end
	end
end
