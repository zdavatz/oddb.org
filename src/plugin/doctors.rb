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
				@doctors_created = 0
				@doctors_deleted = 0
				@empty_id = []
				super
			end
			def update
				range = 14480..14500
				range.each { |doc_id| 
					puts "getting doctor data(#{doc_id})"
					if(data = get_doctor_data(doc_id))
						puts "###################### doctor: #{doc_id}"
						doctor = store_doctor(doc_id, data)
=begin
						if(data.include?(:prax_address))
							store_address(doctor.pointer, :praxis, data)
						end
						if(data.include?(:work_address))
							store_address(doctor.pointer, :work, data)
						end
=end
					else
						# 1. delete doctor if exists
						# 2. record id, muss das naechste mal nicht geprueft werden.
						delete_doctor(doc_id)
					end
				}
			end
			def delete_doctor(doc_id)
				  @app.doctors.each { |key, value| 
					if(key == doc_id) 
						@app.doctors.delete(key)
						@doctors_deleted += 1
						puts "doctors_deleted: #{@doctors_deleted}"
					end
				}
				@empty_id.push(doc_id)
				puts "added to empty_id: " << @empty_id.size.to_s
			end
			def get_doctor_data(doc_id)
				self::class::PARSER.emh_data(doc_id)
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
					:abilities,
					:exam,
					:email,
					:firstname,
					:language,
					:name,
					:praxis,
					:salutation,
					:skills,
					:specialities,
					:title,
				]
				doc_hash = {}
				extract.each { |key|
					if(value = hash[key])
						case key
						when :praxis
							value = (value == 'Ja')
						when :specialities ,:abilities ,:skills
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
		end
	end
end
