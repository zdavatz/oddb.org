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
		class AbstractLink
			attr_accessor :info, :href, :text
		end
		class Cytochrome
			attr_accessor :substrates, :inhibitors, :inducers
			attr_reader :cyt_name
			def initialize(cyt_name)
				@cyt_name = cyt_name
				@substrates = []
				@inhibitors = []
				@inducers = []
			end
			def add_connection(conn)
				case conn
				when SubstrateConnection
					@substrates.push(conn)
				when InhibitorConnection
					@inhibitors.push(conn)
				when InducerConnection
					@inducers.push(conn)
				end
			end
		end
		class Connection
			attr_reader :name_base, :links
			attr_accessor :category
			def initialize(name_base)
				@name_base = name_base
				@links = []
				@cytochromes = []
			end
			def add_cytochrome(cyt)
				@cytochromes.push(cyt)
			end
			def add_link(abstractlink)
				@links.push(abstractlink)
			end
		end
		class SubstrateConnection < Connection
			def initialize(name_base)
				super
			end
		end
		class InhibitorConnection < Connection
			def initialize(name_base)
				super
			end
		end
		class InducerConnection < Connection
			def initialize(name_base)
				super
			end
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
			def initialize(app)
				@app = app
				@hayes = {}
				@flockhart = {}
				@merging_errors = {
					:no_flock_conn	=> [], 
					:no_hayes_conn => [],
				}
			end
			def flock_conn_name(flock_conn)
				name = flock_conn.name_base
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
									if(similar_name?(hayes_conn.name_base, flock_conn_name(flock_conn)))
										found_conn = true
										hayes_conn.category = flock_conn.category
										hayes_conn.links.concat(flock_conn.links)
										@flock_conn_arr.delete(flock_conn)
									end
								}
							end
							unless(found_conn)
								id = :no_flock_conn
								backtrace = "#{hayes_cyt_id} => #{hayes_conn.name_base}"
								@merging_errors[id].push(backtrace)
							end
						}
						if(@flock_conn_arr)
							@flock_conn_arr.each { |conn|
								id = :no_hayes_conn
								backtrace = "#{hayes_cyt_id} => #{conn.name_base}"
								@merging_errors[id].push(backtrace)
							}
						end
					}
				}
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
									if(table_conn.name_base.downcase==conn.name_base.downcase)
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
				@merging_errors.each { |key, value|
					errors.push(ERROR_MESSAGES[key])
					errors.push(value.uniq)
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
				] + errors
				lines.join("\n")
			end
			def similar_name?(astring, bstring)
				astring.downcase!
				bstring.downcase!
				if(astring.ld(bstring) == 0)
					true
				else
					false
				end
			end
			def update
				@hayes = parse_hayes(HayesPlugin.new(@app))
				@flockhart = parse_flockhart(FlockhartPlugin.new(@app, REFETCH_PAGES))
				merge_data(@hayes, @flockhart)
			end
		end
	end
end
