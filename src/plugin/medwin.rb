#!/usr/bin/env ruby
# MedwinPlugin -- oddb -- 06.10.2003 -- mhuggler@ywesee.com

require 'util/oddbconfig'
require 'plugin/plugin'
require 'util/persistence'
require 'util/html_parser'
require 'util/http'
require 'model/text'
require 'model/address'
require 'drb'

module ODDB
	class MedwinPlugin < Plugin
		HTTP_SERVER = 'www.medwin.ch'
		def initialize(app)
			super
			@checked = 0
			@temp_count = 0
			@found = 0
			@updated = []
			@errors = {}
		end
	end
	class MedwinCompanyPlugin < MedwinPlugin
		#HTTP_PATH = '/frmSearchPartner.aspx?lang=de' 
		HTTP_PATH = '/refdata_wa_medwin/frmSearchPartner.aspx?lang=de' 
		MEDDATA_SERVER = DRbObject.new(nil, MEDDATA_URI)
		def initialize(app)
			super
			@medwin_template = {
				:ean13		=>	[1,0],
				:address	=>	[1,4],
				:plz			=>	[1,5],
				:location	=>	[2,5],
				:phone		=>	[1,6],
				:fax			=>	[2,6],
			}
		end
		def report
			lines = [
				"Checked #{@checked} Companies",
				"Compared #{@found} Medwin Entries",
				"Updated  #{@updated.size} Companies:",
			] + @updated.sort
			lines.push("Errors:")
			@errors.each { |key, value|
				lines.push(key + " => " + value)
			}
			lines.join("\n")
		end
		def update
			@checked = @app.companies.size
			@app.companies.each_value { |comp| 
				update_company(comp)
			}
		end
		def update_company(comp)
			criteria = {
				:ean =>  comp.ean13 
			}
			results = MEDDATA_SERVER.search(criteria)
			if(results.size == 1)
				result = results.first
				details = MEDDATA_SERVER.detail(result, @medwin_template)
				update_company_data(comp, details)
			end
			#comp_name = comp.name.gsub(/\W/," ").split(" ")
		end
		def update_company_data(comp, data)
			unless(comp.listed? || comp.has_user?)
				addr = Address2.new
				addr.address = data[:address]
				addr.location = [data[:plz], data[:location]].compact.join(' ')
				if(fon = data[:phone])
					addr.fon = [fon]
				end
				if(fax = data[:fax])
					addr.fax = [fax]
				end
				update = {
					:ean13	=>	data[:ean13],
					:addresses => [addr],
				}
				@updated.push(comp.name)
				@app.update(comp.pointer, update)
			end
		end
	end
	class MedwinPackagePlugin < MedwinPlugin
		#HTTP_PATH = '/frmSearchPartner.aspx?lang=de' 
		HTTP_PATH = '/refdata_wa_medwin/frmSearchPartner.aspx?lang=de' 
		MEDDATA_SERVER = DRbObject.new(nil, MEDDATA_URI)
		def initialize(app)
			super
			@medwin_template = {
				:pharmacode	=>	[3,2],
			}	
		end
		def report
			lines = [
				"Checked #{@checked} Packages",
				"Tried #{@found} Medwin Entries",
				"Updated  #{@updated.size} Packages",
			]
			lines.push("Errors:")
			@errors.each { |key, value|
				lines.push(key + " => " + value)
			}
			lines.join("\n")
		end
		def update
			@app.each_sequence { |seq| 
				if(seq.active?)
					seq.each_package { |pack|
					@checked += 1
					if(!pack.pharmacode)
						@found += 1
						update_package(pack)
					end
					}
				end
			}
		end
		def update_package(pack)
			criteria = {
				:ean =>  pack.barcode.to_s,
			}
			results = MEDDATA_SERVER.search(criteria)
			if(results.size == 1)
				result = results.first
				details = MEDDATA_SERVER.detail(result, @medwin_template)
				update_package_data(pack, details)
			end
		end
		def update_package_data(pack, data)
			unless(data.empty?)
				@updated.push(pack.barcode)
				@app.update(pack.pointer, data)
			end
		end
	end
end
