#!/usr/bin/env ruby
# -- oddb -- 09.12.2004 -- jlang@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))
$: << File.dirname(__FILE__)

require 'util/http'
require 'util/html_parser'

module ODDB
	module MedData
class Formatter < HtmlFormatter
	def push_tablecell(attributes)
		unless(@tablehandler.nil?)
			@tablehandler.next_cell(attributes, true)
		end
	end
end
class ResultWriter < NullWriter
	DG_PATTERNS = {
		:partner => /DgMedwinPartner/,
		:product => /DgMedrefProduct/,
		:refdata => /DgMedrefProduct/,
	}
	def initialize(search_type=:partner)
		@dg_pattern = DG_PATTERNS[search_type]
		@tablehandlers = []
		@linkhandlers = []
	end
	def extract_data
		data = {}
		@tablehandlers.each { |handler|
			unless(handler.nil?)
				if(handler.attributes.any? { |key, val|
					@dg_pattern.match(val)
				})
					handler.each_row { |row|
					unless(row.children(0).empty?)
						arr = row.children(0).first.attributes['href'].split("$")
						data.store(arr[1], [row.cdata(1), row.cdata(2), row.cdata(3)])
					end
					}
				end
			end
		}
		data
	end
	def new_linkhandler(handler)
		unless(@current_tablehandler.nil?)
			@current_tablehandler.add_child(handler)
		end
	end
	def new_tablehandler(handler)
		@current_tablehandler = handler
		@tablehandlers.push(handler)
	end
	def send_flowing_data(data) 
		unless(@current_tablehandler.nil?)
			@current_tablehandler.send_cdata(data)
		end
	end
end
class DetailWriter < NullWriter
	def initialize
		@tablehandlers = []
	end
	def extract_data(template)
		data = {}
		@tablehandlers.each { |handler|
			unless(handler.nil?)
				id = handler.attributes.first[1]
				if(id.match(/tblFind/) || id.match(/Table2/))
					data = handler.extract_cdata(template)
				end
			end
		}
		data
	end
	def new_tablehandler(handler)
		@current_tablehandler = handler
		@tablehandlers.push(handler)
	end
	def send_flowing_data(data) 
		unless(@current_tablehandler.nil?)
			@current_tablehandler.send_cdata(data)
		end
	end
end
	end
end
