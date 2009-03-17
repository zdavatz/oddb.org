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
				@tables.at(1).each_row { |row|
          case(row.cdata(0))
          when /genehmigung/iu
            data[:iksnrs] = [row.cdata(1)].flatten.collect { |str|
              if(match = /(?:iks|oicm|swissmedic),?\s+(\d{5})\b/iu.match(str))
                match[1]
              elsif(match = /bag,?\s+(\d{3,5})\b/iu.match(str))
                sprintf("%05i", match[1])
              end
            }.compact
          when /schutzdauerbeginn/iu
            data.store(:protection_date, date(row.cdata(1)))
          when /l.{1,2}schdatum/iu
            data.store(:deletion_date, date(row.cdata(1)))
					when /anmeldedatum/iu
						data.store(:registration_date, date(row.cdata(1)))
					when /erteilungsdatum/iu
						data.store(:issue_date, date(row.cdata(1)))
					when /esz-nr/iu
						data.store(:certificate_number, row.cdata(1).strip)
					when /grundpatent-nr/iu
						data.store(:base_patent, row.cdata(1))
					when /maximale laufzeit/iu
						data.store(:expiry_date, date(row.cdata(1)))
					when /publikationsdatum/iu
						data.store(:publication_date, date(row.cdata(1)))
					when /schutzbeginn grundpatent/iu
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
				if(@table)
					@table.send_cdata(data)
				elsif(@link)
					@link.send_adata(data)
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
