#!/usr/bin/env ruby
# -- oddb -- 14.11.2002 -- andy@jetnet.ch

$: << File.expand_path('../src', File.dirname(__FILE__))

require 'util/pdf_parser'

File.open(ARGV[1], "w") { |file|
	ODDB::PdfParser.scan(File.readlines(ARGV[0]).join) { |deflated|
		inflated = ODDB::PdfParser.inflate(deflated)
		index = 0
		while(inflated && index && index = inflated.index('(', index))
			p index
			if(inflated[index-1] != ?\\)
				startpoint = index + 1
				begin
					index = inflated.index(')', index+1)
				end while(index && inflated[index-1] == ?\\)
				if index
					file << inflated[startpoint...index]
					if(etindex = inflated.index('ET', index) && tindex = inflated.index('(', index))
						file << "\n\n\n" if(etindex < tindex)
					end
				end
			end 
		end
	}
} 
