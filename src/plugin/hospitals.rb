#!/usr/bin/env ruby
# HospitalPlugin -- oddb -- 07.02.2005 -- jlang@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'plugin/plugin'
require 'util/oddbconfig'
require 'util/persistence'
require 'drb'
require 'ext/meddata/src/meddata'
require 'ext/meddata/src/ean_factory'
require 'model/address'
require 'plugin/hospitals'

module ODDB
	module MedData
		class OverflowError < RuntimeError; end
	end
	class HospitalPlugin < Plugin
		attr_writer :meddata_server
		def initialize(app)
			super
			@meddata_server = DRbObject.new(nil, MEDDATA_URI)
		end
		def update(current='7601001', last = '7601004')
			factory =  MedData::EanFactory.new(current)
			while(current < last)
				current = factory.next
				puts current
				criteria = { 
					:name				=> '',
					:country		=> 'CH',
					:plz				=> '',
					:city				=> '',
					:state			=> '',
					:functions	=> '10',
					:ean				=> current,
				}
				begin
					@meddata_server.session { |meddata|
						meddata.search(criteria) { |result|
							values = hospital_details(meddata, result)
							update_hospital(values)
						}
					}
				rescue MedData::OverflowError
					current = factory.clarify
					retry
				rescue
					puts $!.backtrace
					raise
				end
			end
		end
		def hospital_details(meddata, result)
			template = {
				:ean13					=>	[1,0],
				:name						=>	[1,2],
				:business_unit	=>	[1,3],
				:address				=>	[1,4],
				:plz						=>	[1,5],
				:location				=>	[2,5],
				:phone					=>	[1,6],
				:fax						=>	[2,6],
				:canton					=>	[3,5],
				:narcotics			=>	[1,10],
			}
			meddata.detail(result, template)
		end
		def update_hospital(values)
			ean13 = values.delete(:ean13)
			if(hospital = @app.hospital(ean13))
				pointer = hospital.pointer
			else
				ptr = Persistence::Pointer.new([:hospital, ean13])
				pointer = ptr.creator
			end
			addr = Address2.new
			addr.address = values.delete(:address)
			addr.location = [values.delete(:plz), 
				values.delete(:location)].compact.join(' ')
			addr.canton	 = values.delete(:canton)
			addr.fon = [values.delete(:phone)]
			addr.fax = [values.delete(:fax)]
			addr.additional_lines = [values[:business_unit]]
			values.store(:addresses, [addr])
			@app.update(pointer, values, :refdata)
		end
	end
end
