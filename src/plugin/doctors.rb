#!/usr/bin/env ruby
# encoding: utf-8
# Doctors -- oddb -- 21.09.2004 -- jlang@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'drb/drb'
require 'plugin/plugin'
require 'model/address'
require 'util/oddbconfig'
require 'util/persistence'

module ODDB
	module Doctors
		class DoctorPlugin < Plugin
			RECIPIENTS = []
			PARSER = DRbObject.new(nil, DOCPARSE_URI)
			def initialize(*args)
				super
				@config = @app.config(:docparse, :ch)
				@doctors_created = 0
				@doctors_deleted = 0
			end
			def restore(doc_id)
				if(data = get_doctor_data(doc_id))
					store_doctor(doc_id, data)
				end
			end
			def update
				#range = 5000..99999
				empty_ids = (@config.empty_ids || [])
				step = 250
				5000.step(100000, step) { |base|
					range = base...(base+step)
					puts "Next-Step: #{range.first} - #{range.last}"
					$stdout.flush
				top_doc_id = 0
				(range.to_a - empty_ids).each { |doc_id| 
					if(data = get_doctor_data(doc_id))
						store_doctor(doc_id, data)
						top_doc_id = doc_id
					else
						# 1. delete doctor if exists
						delete_doctor(doc_id)
						# 2. record id, muss das naechste mal nicht geprueft werden.
						empty_ids.push(doc_id)
					end
				}
				empty_ids.delete_if { |id| id > top_doc_id }
				store_empty_ids(empty_ids)
				}
			end
			def delete_doctor(doc_id)
				if(doc = @app.doctor_by_origin(:ch, doc_id))
					@app.delete(doc.pointer)
					@doctors_deleted += 1
				end
			end
			def get_doctor_data(doc_id)
				retry_count = 3
				begin
					self::class::PARSER.doc_data_add_ean(doc_id)
				rescue Errno::EINTR, Errno::ECONNRESET => err
					puts "rescued #{err} -> #{retry_count} more tries"
					if(retry_count > 0)
						retry_count -= 1
						retry
					end
				end
			end
			def report
				report = "Doctors update \n\n"
				report << "Number of doctors: " << @app.doctors.size.to_s << "\n"
				report << "New doctors: " << @doctors_created.to_s << "\n"
				report << "Deleted doctors: " << @doctors_deleted.to_s << "\n"
				report
			end
			def merge_addresses(addrs)
				merged = []
				addrs.each { |addr|
					if(equal = merged.select { |other|
						addr[:lines] == other[:lines]
					}.first)
						merge_address(equal, addr, :fon)
						merge_address(equal, addr, :fax)
					else
						merge_address(addr, addr, :fax)
						merge_address(addr, addr, :fon)
						merged.push(addr)
					end
				}
				merged
			end
			def merge_address(target, source, sym)
				target[sym] = [target[sym], source[sym]].flatten
				target[sym].delete('')
				target[sym].uniq!
			end
			def prepare_addresses(hash)
				if(addrs = hash[:addresses])
					tmp_addrs = (addrs.is_a?(Array)) ? addrs : [addrs]
					merge_addresses(tmp_addrs).collect { |values|
						addr = Address.new
						values.each { |key, val| 
							meth = "#{key}="
							if(addr.respond_to?(meth))
								addr.send(meth, val)
							end
						}
						addr
					}
				else
					[]
				end
			end
			def store_doctor(doc_id, hash)
				pointer = nil
				if(doc = @app.doctor_by_origin(:ch, doc_id))
					pointer = doc.pointer
				else
					@doctors_created += 1
					ptr = Persistence::Pointer.new(:doctor)
					pointer = ptr.creator
				end
				extract = [
					:ean13,
					:exam,
					:email,
					:firstname,
					:language,
					:name,
					:praxis,
					:salutation,
					:specialities,
					:title,
				]
				doc_hash = {}
				extract.each { |key|
					if(value = hash[key])
						case key
						when :praxis
							value = (value == 'Ja')
						when :specialities 
							if(value.is_a?(String))
								value = [value]
							end	
						end
						doc_hash.store(key, value)
					end
					
				}
				doc_hash.store(:origin_db, :ch)
				doc_hash.store(:origin_id, doc_id)
				doc_hash.store(:addresses, prepare_addresses(hash))
				@app.update(pointer, doc_hash)
			end
			def store_empty_ids(ids)
				values = {
					:empty_ids	=> ids,
				}
				@app.update(@config.pointer, values, :fmh)
			end

			MEDDATA_SERVER = DRbObject.new(nil, MEDDATA_URI)
			def fix_doctors(ambiguous, docs)
				found = {}
				hypothesis = {}
				docs.each { |doc|
					criteria = {
						:name	=>	doc.name,
					}
					check = [doc.name, doc.firstname]
					if((addr = doc.praxis_address) \
						|| (addr = doc.addresses.first))
						criteria.store(:city, addr.city)
						check.push(addr.city)
					end
					eans = []
					MEDDATA_SERVER.session { |meddata|
						begin
							results = meddata.search(criteria).select { |res|
								check_with = res.values[0,check.size]
								check_with.at(1).gsub!(/\d/u, '')
								check_with.at(1).strip!
								check_with == check
							}
						rescue RuntimeError
							puts check.inspect, criteria.inspect
							hypothesis.store(doc, [ambiguous])
							next
						end
						eans = results.collect { |result|
							details = meddata.detail(result, {:ean13 => [1,0]})
							details[:ean13]
						}
					}
					if(eans.size == 1)
						found.store(doc, eans.first)
					else
						hypothesis.store(doc, eans)
					end
				}
				found.each_value { |ean|
					hypothesis.each { |doc, eans|
						eans.delete(ean)
					}
				}
				hypothesis.delete_if { |doc, eans| eans.empty? }
				sorted = hypothesis.sort_by { |doc, eans| eans.size }
				while(pair = sorted.shift)
					doc, eans = *pair
					if(eans.size > 1) ## ambiguous
						break
					elsif(eans.size == 0)
						next
					else
						if(sorted.any? { |pair| pair.at(1) == eans}) ## duplicate!
							sorted.delete_if { |pair| pair.at(1) == eans}
						else
							found.store(doc, eans.first)
						end
						sorted.each { |pair| pair.at(1).delete(eans.first) }
					end
					sorted = sorted.sort_by { |pair| pair.at(1).size }
				end
				if(found.values.size > found.values.uniq.size)
					## ignore ambiguous values
					eans = found.values
					while(ean = eans.shift)
						if(eans.include?(ean))
							found.delete_if { |doc, ean13| ean == ean13 }
							eans.delete(ean)
						end
					end
				end
				docs.each { |doc|
					doc.ean13 = found[doc]
					doc.odba_store
				}
=begin
				result = MEDDATA_SERVER.search().first
				matchs = []
				docs.each { |doc|
					if([doc.name, doc.firstname] == result.values[0,2])
						matchs.push(doc)
					else
						#doc.ean13 = nil
						#doc.odba_store
					end
				}
				locations = []
				if(matchs.size > 1)
					matchs.each { |doc|
						if(doc.addresses.any? { |addr|result.values.at(2) })
							locations.push(doc)
						else
							#doc.ean13 = nil
							#doc.odba_store
						end
					}
				end
				if(locations.size > 1)
					puts "still #{locations.size} duplicate eans:"
					puts locations.collect { |doc| [doc.name, doc.firstname].join(' ') }
					raise "thats enuff"
				end
=end
			end
			def fix_duplicate_eans
				ean_table = {}
				@app.doctors.each { |id, doc|
					if(ean = doc.ean13)
						(ean_table[ean] ||= []).push(doc)
					end
				}
				ean_table.each { |ean, docs|
					if(docs.size > 1)
						fix_doctors(ean, docs)
					end
				}
			end

		end
	end
end
