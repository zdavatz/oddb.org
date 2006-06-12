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
      if(ean = comp.ean13)
        criteria = {
          :ean =>  comp.ean13 
        }
        MEDDATA_SERVER.session(:partner) { |meddata|
          results = meddata.search(criteria)
          if(results.size == 1)
            result = results.first
            details = meddata.detail(result, @medwin_template)
            update_company_data(comp, details)
          end
        }
      end
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
				@app.update(comp.pointer, update, :refdata)
			end
		end
	end
	class MedwinPackagePlugin < MedwinPlugin
		MEDDATA_SERVER = DRbObject.new(nil, MEDDATA_URI)
		def initialize(app)
			super
			@medwin_template = {
				:pharmacode	=>	[3,2],
			}	
			@nonmatching_template = {
				:ean13			=>	[1,2],
				:pharmacode	=>	[3,2],
			}
			@probable_errors_oddb = []
			@probable_errors_medwin = []
		end
		def report
			lines = [
				"Checked #{@checked} Packages",
				"Tried #{@found} Medwin Entries",
				"Updated  #{@updated.size} Packages",
				"Probable Errors in ODDB: #{@probable_errors_oddb.size}",
				"Probable Errors in Medwin: #{@probable_errors_medwin.size}",
				nil,
				"Probable Errors in ODDB: #{@probable_errors_oddb.size}",
			]
			@probable_errors_oddb.each { |pack|
				lines.push("http://www.oddb.org/de/gcc/resolve/pointer/#{pack.pointer}")
			}
			lines.push nil
			lines.push "Probable Errors in Medwin: #{@probable_errors_medwin.size}"
			@probable_errors_medwin.each { |pack|
				lines.push("http://www.oddb.org/de/gcc/resolve/pointer/#{pack.pointer}")
			}
			lines.push nil
			lines.push("Errors:")
			@errors.each { |key, value|
				lines.push(key + " => " + value)
			}
			lines.join("\n")
		end
		def update
			MEDDATA_SERVER.session(:product) { |meddata|
				@app.each_sequence { |seq| 
					if(seq.active?)
						seq.each_package { |pack|
							@checked += 1
							if(!pack.pharmacode && !pack.out_of_trade)
								@found += 1
								update_package(meddata, pack)
							end
						}
					end
				}
			}
		end
		def update_trade_status
			MEDDATA_SERVER.session(:refdata) { |meddata|
				@app.each_sequence { |seq|
					if(seq.active?)
						seq.each_package { |pack|
							@checked += 1
							update_package_trade_status(meddata, pack)
							sleep(0.1)
						}
					end
				}
			}
		end
		def update_package(meddata, pack)
			criteria = {
				:ean =>  pack.barcode.to_s,
			}
			template = @medwin_template
			results = meddata.search(criteria)
			if(results.empty? && pack.registration.package_count == 1)
				criteria = {
					:ean => pack.barcode.to_s[0,9]
				}
				template = @nonmatching_template
				results = meddata.search(criteria)
			end
			if(results.size == 1)
				result = results.first
				details = meddata.detail(result, template)
				if(ean13 = details.delete(:ean13))
					 details.store(:medwin_ikscd, ean13[9,3])
					 if(ean13 > pack.barcode.to_s)
						 @probable_errors_oddb.push(pack)
					 else
						 @probable_errors_medwin.push(pack)
					 end
				end
				update_package_data(pack, details)
			end
		end
		def update_package_trade_status(meddata, pack)
			criteria = {
				:ean =>  pack.barcode.to_s,
			}
			results = meddata.search(criteria)
			if(results.empty? && pack.registration.package_count == 1)
				criteria = {
					:ean => pack.barcode.to_s[0,9]
				}
				results = meddata.search(criteria)
			end
			if(results.size == 0 && !pack.out_of_trade)
				update_package_data(pack, {:out_of_trade => true})
			elsif(results.size == 1 && pack.out_of_trade)
				data = {:out_of_trade => false, :refdata_override => false}
				update_package_data(pack, data)
			else
				sleep(0.05)
			end
		end
		def update_package_data(pack, data)
			unless(data.empty?)
				@updated.push(pack.barcode)
				@app.update(pack.pointer, data, :refdata)
			end
		end
	end
end
