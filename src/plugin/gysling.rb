#!/usr/bin/env ruby
# GyslingPlugin -- oddb -- 13.09.2004 -- mhuggler@ywesee.com

require 'plugin/interaction'
require 'csvparser'
require 'model/text'

module ODDB
	module Interaction
		class GyslingWriter
			GYSLING2HAYES = {
				"3A4/5/7"	=>	["3A4", "3A5-7"],
				"2C8/9"	=>	["2C8", "2C9"],
			}
			def initialize(line_arrays)
				@line_arrays = line_arrays
				@cytochromes = {}
			end
			def extract_data
				data_hsh = {}
				key = nil
				cyp_map = {}
				@line_arrays.each { |arr|
					if(arr.first.match(/Substrate/))
						key = 'substrate'	
					elsif(arr.first.match(/CYP-Hemmer/))
						key = 'inhibitor'
					elsif(arr.first.match(/CYP-Induktoren/))
						key = 'inducer'
					elsif(arr.first.match(/Wirkstoffe/))
						arr.each_with_index { |cyp, idx|
							unless(idx==0)
								if(GYSLING2HAYES.has_key?(cyp))
									cyp_map.store(idx, GYSLING2HAYES[cyp])
								else
									cyp_map.store(idx, [cyp])
								end
							end
						}
						create_cytochromes(cyp_map)
					else
						conn = create_connection(key, arr.first)
						arr.each_with_index { |col, idx|
							if(col.match(/1/))
								cyp_map[idx].each { |cyp_id|
									@cytochromes[cyp_id].add_connection(conn)
								}
							end	
						}
					end
				}
				@cytochromes
			end
			def create_cytochromes(cyp_map)
				cyp_map.values.each { |arr|
					arr.each { |cytochrome|	
						unless(@cytochromes.has_key?(cytochrome))
							@cytochromes.store(cytochrome, ODDB::Interaction::Cytochrome.new(cytochrome))
						end
					}
				}
			end
			def create_connection(key, name)
				case key
				when 'substrate'
					new_class = ODDB::Interaction::SubstrateConnection
				when 'inhibitor'
					new_class = ODDB::Interaction::InhibitorConnection
				when 'inducer'
					new_class = ODDB::Interaction::InducerConnection
				end
				new_class.new(name, 'de')
			end
		end
		class GyslingPlugin < Plugin
			FILE_PATH = File.expand_path('../../data/html/interaction/gysling', File.dirname(__FILE__))
			FILE = 'gysling.csv'
			def initialize(app)
				@app = app
			end
			def parse_csv
				file = [ FILE_PATH, FILE ].join("/")
				csv = CSVParser.new_with_file(file)
				line_arrays = CSVParser.parse(csv.string)
				writer = GyslingWriter.new(line_arrays)
				writer.extract_data	
			end
		end
	end
end
