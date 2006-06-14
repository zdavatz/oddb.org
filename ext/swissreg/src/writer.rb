#!/usr/bin/env ruby
# Swissreg::Writer -- oddb.org -- 03.05.2006 -- hwyss@ywesee.com

require 'date'
require 'util/html_parser'

module ODDB
	module Swissreg
		class DetailWriter < NullWriter
			attr_reader :tables
			def initialize(*args)
				super
				@tables = []
			end
			def date(str)
				Date.new(*(str.split('.').reverse.collect { |num| num.to_i }))
			end
			def extract_data
				data = {}
				@tables.at(0).each_row { |row|
					cdata = row.cdata(1)
					if(cdata.is_a?(Array))
						case(cdata.at(0))
						when /registrierung/i
							if(match = /(?:iks|oicm)\s+(\d{5})\b/i.match(cdata.at(1)))
								data.store(:iksnr, 	match[1])
							elsif(match = /bag\s+(\d{3,5})\b/i.match(cdata.at(1)))
								data.store(:iksnr, 	sprintf("%05i", match[1]))
							end
						when /schutzdauerbeginn/i
							data.store(:protection_date, date(cdata.at(1)))
						when /esz gel.scht am/i
							data.store(:deletion_date, date(cdata.at(1)))
						end
					end
				}
				@tables.at(1).each_row { |row|
					case(row.cdata(0))
					when /anmeldedatum/i
						data.store(:registration_date, date(row.cdata(1)))
					when /erteilungsdatum/i
						data.store(:issue_date, date(row.cdata(1)))
					when /esz-nr/i
						data.store(:certificate_number, row.cdata(1).strip)
					when /grund-patent nr/i
						link = row.children(1).first
						data.store(:base_patent, link.value)
						href = link.attribute('href')
						if(match = /regid=(\d+)/.match(href))
							data.store(:base_patent_srid, match[1])
						end
					when /g.ltigkeitsdauer max\. bis/i
						data.store(:expiry_date, date(row.cdata(1)))
					when /publikationsdatum/i
						data.store(:publication_date, date(row.cdata(1)))
					when /schutzbeginn des grund-patentes/i
						data.store(:base_patent_date, date(row.cdata(1)))
					end
				}
				data
			end
			def new_linkhandler(link)
				if(link)
					@link = link
				elsif(@link && @table)
					@table.add_child(@link)
					@link = nil
				end
			end
			def new_tablehandler(table)
				if(table)
					@tables.push(table)
					@table = table
				else
					@table = nil
				end
			end
			def send_flowing_data(data)
				if(@link)
					@link.send_adata(data)
				elsif(@table)
					@table.send_cdata(data)
				else
				end
			end
			def send_line_break
				if(@table)
					@table.next_line
				end
			end
		end
	end
end
