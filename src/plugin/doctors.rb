#!/usr/bin/env ruby
# Doctors -- oddb -- 21.09.2004 -- jlang@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'drb/drb'
require 'plugin/plugin'
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
						if(data.include?(:prax_address))
							store_address(doctor.pointer, :prax, data)
						end
						if(data.include?(:work_address))
							store_address(doctor.pointer, :work, data)
						end
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
			def store_address(doc_pointer, addr_type, hash)
				pointer = doc_pointer + [:address, addr_type]
				translate = if(addr_type == :prax)
					{
						:prax_city		=>	:city,
						:prax_fax			=>	:fax,
						:prax_fon			=>	:fon,
						:prax_address	=>	:lines,
						:prax_plz			=>	:plz,
					}
				else
					{
						:work_city		=>	:city,
						:work_fax			=>	:fax,
						:work_fon			=>	:fon,
						:work_address	=>	:lines,
						:work_plz			=>	:plz,
					}
				end
				addr_hash = {}
				hash.each { |key, value|
					if(new_key = translate[key])
						addr_hash.store(new_key, value)
					end
					}
				update_values = addr_hash
				@app.update(pointer.creator, update_values)
			end
			def store_doctor(doc_id, hash)
				doc = nil
				if(doc = @app.doctor_by_origin(:ch, doc_id))
				else
					@doctors_created += 1
					puts "doctors updated: #{@doctors_created}"
					pointer = Persistence::Pointer.new(:doctor)
					doc = @app.create(pointer)
				end
				extract = [
					:exam,
					:firstname,
					:language,
					:name,
					:praxis,
					:specialist,
					:title,
					:salutation,
				]
				doc_hash = {}
				hash.each { |key, value|
					if(extract.include?(key))
						to_store = hash.fetch(key)
						if(key == :praxis) 
							to_store = (to_store == 'Ja') ? true : false
						end
						doc_hash.store(key, to_store)
					end
				}
				doc_hash.store(:origin_db, :ch)
				doc_hash.store(:origin_id, doc_id)
				@app.update(doc.pointer, doc_hash)
				doc
			end
		end
	end
end
