#!/usr/bin/env ruby
# StubOddbDatExport -- oddb -- 20.08.2003 -- ywesee@ywesee.com


$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'plugin/oddbdat_export'

module ODDB
	class OddbDatExport
		class Table
			#	remove_const :DOCUMENT_ROOT
			#remove_const :DIRPATH
			DOCUMENT_ROOT = File.expand_path("../../test", 
				File.dirname(__FILE__))
			DIRPATH = "/data/downloads"
		end
		class Line
			FILENAME = 's01x'
			LENGTH = 4
			def structure
				{
					1		=> 'nodata',	
					3		=> 'moredata',	
				}
			end
		end
	end
end
