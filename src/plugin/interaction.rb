#!/usr/bin/env ruby
# Plugin -- oddb -- 23.02.2004 -- maege@ywesee.com

require 'plugin/plugin'
require 'plugin/flockhart'
require 'plugin/hayes'
require 'util/html_parser'
require 'model/text'
require 'util/levenshtein_distance'

module ODDB
	module Interaction 
		class AbstractLink
			attr_accessor :info, :href, :text
		end
		class Parser < HtmlParser
			def do_category(attrs)
				@formatter.end_category
			end
		end
		class Formatter < HtmlFormatter
			def end_category
				@writer.end_category
			end
			def push_tablerow(attributes)
				unless(@tablehandler.nil?)
					@tablehandler.next_row(attributes)
					@writer.start_tr(attributes)
				end
			end
		end
		class Cytochrome
			attr_accessor :substrates, :inhibitors, :inducers
			attr_reader :cyt_name
			def initialize(cyt_name)
				@cyt_name = cyt_name
				@substrates = []
				@inhibitors = []
				@inducers = []
				@interactions = {}
			end
			def add_connection(conn)
				case conn
				when ODDB::Interaction::SubstrateConnection
					@substrates.push(conn)
				when ODDB::Interaction::InhibitorConnection
					@inhibitors.push(conn)
				when ODDB::Interaction::InducerConnection
					@inducers.push(conn)
				end
			end
			def has_connection?(other)
				@inhibitors.each { |inhibitor|
					if(inhibitor.name == other.description('en'))
						@interaction.store(:inhibitor, inhibitor)
					end
				}
				@inducers.each { |inducers|
					if(inducers.name == other.description('en'))
						@interactions.store(:inducers, inducers)
					end
				}
				@interactions
			end
		end
		class Connection
			attr_reader :name
			attr_accessor :category, :links
			def initialize(name)
				@name = name
				@links = []
			end
			def add_link(abstractlink)
				@links.push(abstractlink)
			end
		end
		class SubstrateConnection < Connection
		end
		class InhibitorConnection < Connection
		end
		class InducerConnection < Connection
		end
		class InteractionPlugin < Plugin
			REFETCH_PAGES = false
			INTERACTION_TYPES = [
				:substrates, :inhibitors, :inducers,
			]
=begin
			ERROR_MESSAGES = {
			:no_flock_conn => "There's no matching Flockhart connection for:",
			:no_hayes_conn => "There's no matching Hayes connection for:",
			}
=end
			UPDATE_MESSAGES = {
				:cyp450_created			=>	"The following CyP450s have been created:",
				:substance_created	=>	"The following Substances have been created:",
				:inhibitors_created	=>	"The following inhibitor connections have been created:",
				:inhibitors_deleted	=>	"The following inhibitor connections have been deleted:",
				:inducers_created		=>	"The following inducer connections have been created:",
				:inducers_deleted		=>	"The following inducer connections have been deleted:",
				:substrates_created	=>	"The following substrate connections have been created:",
				:substrates_deleted	=>	"The following substrate connections have been updated:",
			}
			def initialize(app)
				@app = app
				@hayes = {}
				@flockhart = {}
				@updated_substances = {}
				@flock_conn_not_found = 0
				@hayes_conn_not_found = 0
=begin
				@merging_errors = {
					:no_flock_conn	=> [], 
					:no_hayes_conn => [],
				}
=end
				@update_reports = {
					:cyp450_created			=>	[],
					:substance_created	=>	[],
					:inhibitors_created	=>	[],
					:inhibitors_deleted	=>	[],
					:inducers_created		=>	[],
					:inducers_deleted		=>	[],
					:substrates_created	=>	[],
					:substrates_deleted	=>	[],
				}
			end
			def flock_conn_name(flock_conn)
				name = flock_conn.name
				case name 
				when /=/
					name.split("=").first
				when /in part/
					name.split(" ").first
				else
					name
				end
			end
			def merge_data(hayes, flockhart)
				puts 'merging ...'
				hayes.each { |hayes_cyt_id, hayes_cyt|
					INTERACTION_TYPES.each { |type|
						hayes_conn_arr = hayes_cyt.send(type)
						hayes_conn_arr.each { |hayes_conn|
							found_conn = false
							if(flockhart.has_key?(hayes_cyt_id))
								@flock_conn_arr = flockhart[hayes_cyt_id].send(type)
								@flock_conn_arr.each { |flock_conn|
									if(similar_name?(hayes_conn.name, flock_conn_name(flock_conn)))
										found_conn = true
										hayes_conn.category = flock_conn.category
										hayes_conn.links.concat(flock_conn.links)
										@flock_conn_arr.delete(flock_conn)
									end
								}
							end
							unless(found_conn)
								@flock_conn_not_found += 1
							end
						}
						if(@flock_conn_arr)
							@hayes_conn_not_found += @flock_conn_arr.size
						end
					}
				}
				hayes
			end
			def parse_hayes(plugin)
				puts 'parsing hayes...'
				if(REFETCH_PAGES)
					plugin.fetch_pages
				end
				substr_hsh = plugin.parse_substrate_table
				inter_hsh = plugin.parse_interaction_table
				substr_hsh.each { |cyt_id, cyt|
					INTERACTION_TYPES.each { |type|
						unless(type==:substrates)
							if(inter_hsh.has_key?(cyt_id))
								inter_hsh[cyt_id].send(type).each { |conn|
									cyt.add_connection(conn)
								}
							end
						end
					}
				}
				substr_hsh
			end
			def parse_flockhart(plugin)
				puts 'parsing flockhart ...'
				table_hsh = plugin.parse_table 
				cytochromes = plugin.parse_detail_pages 
				cytochromes.each { |cyt_id, cyt|
					INTERACTION_TYPES.each { |type|
						cyt.send(type).each { |conn|
							if(conn_arr = table_hsh[cyt_id].send(type))
								conn_arr.each { |table_conn|
									if(table_conn.name.downcase==conn.name.downcase)
										conn.category = table_conn.category
									end
								}
							end
						}
					}
				}
				cytochromes	
			end
			def report
				puts 'reporting ...'
				#errors = []
				updates = []
				@update_reports.each { |key, value|
					unless(value == [])
						updates.push(UPDATE_MESSAGES[key])
						updates.push(value.uniq)
					end
				}
=begin
				@merging_errors.each { |key, value|
					unless(value == [])
						errors.push(ERROR_MESSAGES[key])
						errors.push(value.uniq)
					end
				}
=end
				hayes_cyts = []
				@hayes.each { |key, value|
					hayes_cyts.push(key)
				}
				flockhart_cyts = []
				@flockhart.each { |key, value|
					flockhart_cyts.push(key)
				}
				lines = [
					"found hayes cytochromes: #{@hayes.size}",
				] + [
					hayes_cyts.sort.join(", ")
				] + [
					"found flock cytochromes: #{@flockhart.size}",
				] + [
					flockhart_cyts.sort.join(", ")
				] + [
					"There are no matching hayes connections for #{@hayes_conn_not_found} flockhart connections"
				] + [
					"There are no matching flockhart connections for #{@flock_conn_not_found} hayes connections"
				]+ updates # + errors
				lines.join("\n")
			end
			def similar_name?(astring, bstring)
				if(astring.downcase.ld(bstring.downcase) == 0)
					true
				else
					false
				end
			end
			def update
				@hayes = parse_hayes(HayesPlugin.new(@app))
				@flockhart = parse_flockhart(FlockhartPlugin.new(@app, REFETCH_PAGES))
				update_oddb(merge_data(@hayes, @flockhart))
			end
			def update_oddb(cytochrome_hsh)
				puts "updating oddb ..."
				cytochrome_hsh.each { |cyt_id, cyt|
					update_oddb_substances(cyt)
					cyp450 = update_oddb_cyp450(cyt_id, cyt)
					update_oddb_cyp450_connections(cyt_id, cyt, cyp450, :inhibitors)
					update_oddb_cyp450_connections(cyt_id, cyt, cyp450, :inducers)
					update_oddb_substrates(cyt_id, cyt)
				}
				update_oddb_tidy_up
			end
			def update_oddb_tidy_up
				puts "tidying up..."
				@updated_substances.each { |desc_en, substance|
					substance[:connections].each { |cyt_id, conn|
						puts "deleting #{desc_en} => #{cyt_id}"
						pointer = substance[:pointer] + ['cyp450substrate', cyt_id]
						@app.delete(pointer)
						info = "#{desc_en} => #{cyt_id}"
						update_report(:substrates_deleted, info)	
					}
				}
			end
			def update_oddb_cyp450(cyt_id, cyt)
				puts "updating cyp450 ..."
				unless(cyp450 = @app.cyp450(cyt_id))
					pointer = Persistence::Pointer.new(['cyp450', cyt_id])
					cyp450 = @app.create(pointer)
					info = "#{cyp450.cyp_id}"
					update_report(:cyp450_created, info)
				end
				cyp450
			end
			def update_oddb_cyp450_connections(cyt_id, cyt, cyp450, connection)
				cyp450_connections = cyp450.send(connection).keys.dup
				cyt.send(connection).each { |conn|
					conn_pointer = [ 
						'cyp450' + connection.to_s[0..-2], 
						conn.name	
					]
					pointer = cyp450.pointer + conn_pointer
					args = {
						:substance	=>	conn.name,
						:links			=>	conn.links,
						:category		=>	conn.category,
					}
					if(cyp450.send(connection).keys.include?(conn.name))
						@app.update(pointer, args)
					else
						@app.update(pointer.creator, args)
						info = "#{cyp450.cyp_id} =>	#{conn.name}" 
						symbol = (connection.to_s + '_created').intern
						update_report(symbol, info)
					end
					if(cyp450_connections.include?(conn.name))
						cyp450_connections.delete(conn.name)
					end
				}
				cyp450_connections.each { |substance_name|
					conn_pointer = [ 
						'cyp450' + connection.to_s, 
						substance_name
					]
					pointer = cyp450.pointer + conn_pointer 
					@app.delete(pointer)
					info = "#{cyp450.cyp_id} => #{substance_name}"
					symbol = (connection.to_s + '_deleted').intern
					update_report(symbol, info)
				}
			end
			def update_oddb_substances(cyt)
				puts "updating oddb substances..."
				(cyt.substrates + cyt.inhibitors + cyt.inducers).each { |connection|
					if(subs = @app.substance_by_connection_key(connection.name))
						unless(@updated_substances.keys.include?(subs.connection_key))
							values = {
								:connections		=> subs.substrate_connections.dup,
								:pointer				=> subs.pointer,
							}
							#@app.update(subs.pointer, values)
							@updated_substances.store(subs.connection_key, values)
						end
					else
						pointer = Persistence::Pointer.new(:substance)
						descr = {
							'en'						=>	connection.name,
							:connection_key	=>	connection.name,
						}
						substance = @app.update(pointer.creator, descr)
						unless(@updated_substances.keys.include?(substance.connection_key))
							values = {
								:connections	=> substance.substrate_connections.dup,
								:pointer			=> substance.pointer,
								}
							@updated_substances.store(substance.connection_key, values)
						end
						info = substance.connection_key
						update_report(:substance_created, info)
					end
				}
			end
			def update_oddb_substrates(cyt_id, cyt)
				puts "updating oddb substrates..."
				cyt.substrates.each { |substrate|
					args = {
						:links		=>	substrate.links,
						:category	=>	substrate.category,
						:cyp450		=>	cyt_id,
					}
					catch :found do
						@app.substances.each { |substance|
							if(substance.connection_key == substrate.name)
								pointer = substance.pointer + ['cyp450substrate', cyt_id]
								if(substance.substrate_connections.keys.include?(cyt_id))
									@app.update(pointer, args)
								else
									@app.update(pointer.creator, args)
									info = "#{substrate.name} => #{cyt_id}"
									update_report(:substrates_created, info)
								end
								@updated_substances[substrate.name][:connections].delete(cyt_id)
								throw :found
							end
						}	
					end
				}
			end
			def update_report(id, info)
				@update_reports[id].push(info)
			end
		end
	end
end
