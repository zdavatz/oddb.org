#!/usr/bin/env ruby
# -- oddb -- 07.02.2005 -- jlang@ywesee.com

$: << File.expand_path('../../src', File.dirname(__FILE__))

require 'plugin/plugin'
require 'util/oddbconfig'
require 'util/persistence'
require 'drb'
require 'ext/meddata/src/meddata'
require 'ext/meddata/src/ean_factory'
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
				puts "current EAN: #{current}"
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
					@meddata_server.search(criteria) { |result|
						values = hospital_details(result)
						update_hospital(values)
					}
				rescue MedData::OverflowError
					current = factory.clarify
				end
			end
		end
		def hospital_details(result)
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
			}
			data = @meddata_server.detail(result.session, result.ctl, template)
			#hash
		end
		def update_hospital(values)
			ean13 = values.delete(:ean13)
			if(hospital = @app.hospital(ean13))
				pointer = hospital.pointer
			else
				ptr = Persistence::Pointer.new([:hospital, ean13])
				pointer = ptr.creator
			end
			@app.update(pointer, values)
		end
	end
end
