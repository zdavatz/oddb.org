#!/usr/bin/env ruby
# encoding: utf-8
# Plugin -- oddb -- 23.02.2004 -- mhuggler@ywesee.com

require 'plugin/plugin'
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
						@interactions.store(:inhibitor, inhibitor)
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
			attr_reader :name, :lang
			attr_accessor :category, :links, :auc_factor
			def initialize(name, lang)
				@name = name
				@lang = lang
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
			REFETCH_PAGES = true
			CONNECTION_TYPES = [
				:substrates, :inhibitors, :inducers,
			]
=begin
			ERROR_MESSAGES = {
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
				:substrates_deleted	=>	"The following substrate connections have been deleted:",
			}
			def initialize(app)
				@app = app
				@hayes = {}
				@updated_substances = {}
				@hayes_conn_not_found = 0
=begin
				@merging_errors = {
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
			def format_connection_key(key)
				Substance.format_connection_key(key)
			end
			def parse_hayes(plugin)
				if(REFETCH_PAGES)
					plugin.fetch_pages
				end
				substr_hsh = plugin.parse_substrate_table
				inter_hsh = plugin.parse_interaction_table
				substr_hsh.each { |cyt_id, cyt|
					CONNECTION_TYPES.each { |type|
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
			def report
				updates = []
				@update_reports.each { |key, value|
					unless(value == [])
						updates.push(UPDATE_MESSAGES[key])
						updates.push(value.uniq)
					end
				}
				hayes_cyts = []
				@hayes.each { |key, value|
					hayes_cyts.push(key)
				}
				lines = [
					"found hayes cytochromes: #{@hayes.size}",
				] + [
					hayes_cyts.sort.join(", ")
				]+ updates
				lines.join("\n")
			end
			def similar_name?(astring, bstring)
				(sub = @app.substance(astring)) && sub.same_as?(bstring)
			end
			def update
				@hayes = parse_hayes(HayesPlugin.new(@app))
				update_oddb(@hayes)
			end
			def update_oddb(cytochrome_hsh)
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
				@updated_substances.each { |substance, connections|
					connections.each { |cyt_id, conn|
						pointer = substance.pointer + ['cyp450substrate', cyt_id]
						@app.delete(pointer)
						info = "#{substance} => #{cyt_id}"
						update_report(:substrates_deleted, info)	
					}
				}
			end
			def update_oddb_cyp450(cyt_id, cyt)
				unless(cyp450 = @app.cyp450(cyt_id))
					pointer = Persistence::Pointer.new(['cyp450', cyt_id])
					cyp450 = @app.create(pointer)
					update_report(:cyp450_created, cyp450.cyp_id.to_s)
				end
				cyp450
			end
			def update_oddb_cyp450_connections(cyt_id, cyt, cyp450, connection)
				cyp450_connections = cyp450.send(connection).keys
				cyt.send(connection).each { |conn|
					subs = @app.substance_by_connection_key(conn.name) \
						|| @app.substance(conn.name)
					connection_key = subs.primary_connection_key
					conn_pointer = [ 
						'cyp450' + connection.to_s[0..-2], 
						connection_key,	
					]
					pointer = cyp450.pointer + conn_pointer
					args = {
						:substance	=>	connection_key,
						:links			=>	conn.links,
						:category		=>	conn.category,
            :auc_factor =>  conn.auc_factor,
					}
					if(cyp450.send(connection).keys.include?(connection_key))
						@app.update(pointer, args)
					else
						@app.update(pointer.creator, args)
						info = "#{cyp450.cyp_id} =>	#{connection_key}" 
						symbol = (connection.to_s + '_created').intern
						update_report(symbol, info)
					end
					if(cyp450_connections.include?(connection_key))
						cyp450_connections.delete(connection_key)
					end
				}
				cyp450_connections.each { |connection_key|
					conn_pointer = [ 
						'cyp450' + connection.to_s[0..-2], 
						connection_key,
					]
					pointer = cyp450.pointer + conn_pointer 
					@app.delete(pointer)
					info = "#{cyp450.cyp_id} => #{connection_key}"
					symbol = (connection.to_s + '_deleted').intern
					update_report(symbol, info)
				}
			end
			def update_oddb_create_substance(connection)
				pointer = Persistence::Pointer.new(:substance)
				args = {
					connection.lang	=>	connection.name,
				}
				substance = @app.update(pointer.creator, args)
				@updated_substances.store(substance, {})
				update_report(:substance_created, substance.name)
			end
			def update_oddb_substances(cyt)
				(cyt.substrates + cyt.inhibitors + cyt.inducers).each { |connection|
					connection_key = format_connection_key(connection.name)
					if(subs = @app.substance_by_connection_key(connection_key))
						@updated_substances[subs] ||= subs.substrate_connections.dup
					else
						update_oddb_create_substance(connection)	
					end
				}
			end
			def update_oddb_substrates(cyt_id, cyt)
				cyt.substrates.each { |substrate|
					args = {
						:links		=>	substrate.links,
						:category	=>	substrate.category,
						:cyp450		=>	cyt_id,
					}
					substance = @app.substance_by_connection_key(substrate.name) \
						|| @app.substance(substrate.name)
					connection_key = substance.primary_connection_key
					pointer = substance.pointer + [:cyp450substrate, cyt_id]
					if(substance.cyp450substrate(cyt_id))
						@app.update(pointer, args)
					else
						@app.update(pointer.creator, args)
						info = "#{substrate.name} => #{cyt_id}"
						update_report(:substrates_created, info)
					end
					# ensure that update_oddb_tidy_up does not delete us again
					if(connections = @updated_substances[substance])
						connections.delete(cyt_id)
					end
				}
			end
			def update_report(id, info)
				@update_reports[id].push(info)
			end
		end
	end
end
