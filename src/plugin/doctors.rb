#!/usr/bin/env ruby
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
			RECIPIENTS = [
				'jlang@ywesee.com',
				'usenguel@ywesee.com',
			]
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
					ODBA.batch {
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
				@app.update(@config.pointer, values)
			end
		end
	end
end
