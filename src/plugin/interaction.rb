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
			ERROR_MESSAGES = {
			:no_flock_conn => "Keine passende Flockhart Connection gefunden:",
			:no_hayes_conn => "Keine passende Hayes Connection gefunden:",
			}
			UPDATE_MESSAGES = {
				:cyp450_created			=>	"Folgende Cytochrome wurden erstellt:",
				:substance_created	=>	"Folgende Substanzen wurden erstellt:",
				:inhibitors_updated	=>	"Folgende Inhibitoren wurden aktualisiert:",
				:inhibitors_deleted	=>	"Folgende Inhibitoren wurden geloescht:",
				:inducers_updated		=>	"Folgende Induktoren wurden aktualisiert:",
				:inducers_deleted		=>	"Folgende Induktoren wurden geloescht:",
				:substrates_updated	=>	"Folgende Substrate wurden aktualisiert:",
				:substrates_deleted	=>	"Folgende Substrate wurden geloescht:",
			}
			def initialize(app)
				@app = app
				@hayes = {}
				@flockhart = {}
				@updated_substances = {}
				@merging_errors = {
					:no_flock_conn	=> [], 
					:no_hayes_conn => [],
				}
				@update_reports = {
					:cyp450_created			=>	[],
					:substance_created	=>	[],
					:inhibitors_updated	=>	[],
					:inhibitors_deleted	=>	[],
					:inducers_updated		=>	[],
					:inducers_deleted		=>	[],
					:substrates_updated	=>	[],
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
								id = :no_flock_conn
								backtrace = "#{hayes_cyt_id} => #{hayes_conn.name}"
								@merging_errors[id].push(backtrace)
							end
						}
						if(@flock_conn_arr)
							@flock_conn_arr.each { |conn|
								id = :no_hayes_conn
								backtrace = "#{hayes_cyt_id} => #{conn.name}"
								@merging_errors[id].push(backtrace)
							}
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
				errors = []
				updates = []
				@update_reports.each { |key, value|
					unless(value == [])
						updates.push(UPDATE_MESSAGES[key])
						updates.push(value.uniq)
					end
				}
				@merging_errors.each { |key, value|
					unless(value == [])
						errors.push(ERROR_MESSAGES[key])
						errors.push(value.uniq)
					end
				}
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
				] + updates + errors
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
			def update_cyp450_connections(cyt_id, cyt, cyp450, connection)
				cyp450_connections = cyp450.send(connection).keys.dup
				cyt.send(connection).each { |conn|
					conn_pointer = [ 
						'cyp450' + connection.to_s, 
						conn.name	
					]
					pointer = cyp450.pointer + conn_pointer
					args = {
						:substance	=>	conn.name,
						:links			=>	conn.links,
						:category		=>	conn.category,
					}
					@app.update(pointer.creator, args)
					if(cyp450_connections.include?(conn.name))
						cyp450_connections.delete(conn.name)
						info = "#{cyp450.cyp_id} =>	#{conn.name}" 
						symbol = (connection.to_s + '_updated').intern
						update_report(symbol, info)
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
			def update_oddb(cytochrome_hsh)
				puts "updating oddb ..."
				cytochrome_hsh.each { |cyt_id, cyt|
					update_oddb_substances(cyt)
					cyp450 = update_oddb_cyp450(cyt_id, cyt)
					update_cyp450_connections(cyt_id, cyt, cyp450, :inhibitors)
					update_cyp450_connections(cyt_id, cyt, cyp450, :inducers)
					update_oddb_substrates(cyt_id, cyt)
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
			def update_oddb_substances(cyt)
				puts "updating oddb substances..."
				(cyt.substrates + cyt.inhibitors + cyt.inducers).each { |connection|
					if(subs = @app.substance_by_conn_name(connection.name))
						unless(@updated_substances.keys.include?(subs.en))
							values = {
								:connections	=> subs.substrate_connections.dup,
								:pointer			=> subs.pointer,
							}
							@updated_substances.store(subs.en, values)
						end
					else
						pointer = Persistence::Pointer.new(:substance)
						descr = {
							'en'	=>	connection.name,
						}
						substance = @app.update(pointer.creator, descr)
						unless(@updated_substances.keys.include?(substance.en))
							values = {
								:connections	=> substance.substrate_connections.dup,
								:pointer			=> substance.pointer,
							}
							@updated_substances.store(substance.en, values)
						end
						info = substance.en
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
							if(substance.en == substrate.name)
								substrate_connections = @updated_substances[substance.en][:connections]
								pointer = substance.pointer + ['cyp450substrate', cyt_id]
								@app.update(pointer.creator, args)
								if(substrate_connections.keys.include?(cyt_id))
									substrate_connections.delete(cyt_id)
									info = "#{substrate.name} => #{cyt_id}"
									update_report(:substrates_updated, info)
								end
								throw :found
							end
						}	
					end
				}
				@updated_substances.each { |desc_en, substance|
					substance[:connections].each { |cyt_id, conn|
						pointer = substance[:pointer] + ['cyp450substrate', cyt_id]
						@app.delete(pointer)
						info = "#{desc_en} => #{cyt_id}"
						update_report(:substrates_deleted, info)	
					}
				}
			end
			def update_report(id, info)
				@update_reports[id].push(info)
			end
		end
	end
end
