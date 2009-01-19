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
			ean = comp.ean13.to_s
      eanc = { :ean =>  ean }
      namec = { :name =>  comp.name.to_s }
			criteria = ean.empty? ? namec : eanc
			MEDDATA_SERVER.session(:partner) { |meddata|
				results = meddata.search(criteria)
        if(results.empty? && criteria.include?(:ean))
          results = meddata.search(namec)
        end
				if(results.size == 1)
					result = results.first
					details = meddata.detail(result, @medwin_template)
					update_company_data(comp, details)
				end
				nil # return nil across DRb
			}
		rescue MedData::OverflowError
		end
		def update_company_data(comp, data)
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
      update.delete_if { |key, val| 
        (orig = comp.data_origin(key)) && orig != :refdata 
      }
      @updated.push(comp.name)
      @app.update(comp.pointer, update, :refdata)
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
        @header,
				"Checked #{@checked} Packages",
				"Tried #{@found} Medwin Entries",
				"Updated  #{@updated.size} Packages",
				"Probable Errors in ODDB: #{@probable_errors_oddb.size}",
				"Probable Errors in Medwin: #{@probable_errors_medwin.size}",
				nil,
        <<-EOS
Probable Errors in ODDB: #{@probable_errors_oddb.size}
In den folgenden Fällen ist die Swissmedic-Packungsnummer von ODDB.org ziemlich
sicher falsch, weil Sie tiefer ist als diejenige von Medwin.ch
        EOS
			]
			@probable_errors_oddb.each { |pack|
				lines.push("http://www.oddb.org/de/gcc/resolve/pointer/#{pack.pointer}")
			}
			lines.push nil
			lines.push <<-EOS
Probable Errors in Medwin: #{@probable_errors_medwin.size}
In den folgenden Fällen ist die Swissmedic-Packungsnummer von Medwin.ch
ziemlich sicher falsch, weil Sie tiefer ist als diejenige von ODDB.org.
      EOS
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
      @header = <<-EOS
Alle Packungen wurden überprüft (checked).
Packungen, welche im Handel sind, wurden bei MedWin abgefragt (tried).
Als Update (updated) gekennzeichnet wurden diejenigen, bei denen der Pharmacode
von MedWin anders war als in der ODDB (inkl. diese, wo die ODDB noch keinen
Pharmacode hatte)

      EOS
      MEDDATA_SERVER.session(:product) { |meddata|
        @app.each_package { |pack|
          @checked += 1
          unless pack.out_of_trade
            @found += 1
            update_package(meddata, pack)
          end
        }
        nil # return nil across DRb
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
					nil # don't return the packages across DRb
				}
				nil # return nil across DRb
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
        unless pack.pharmacode == details[:pharmacode].to_i.to_s
          update_package_data(pack, details)
        end
			end
		end
		def update_package_trade_status(refdata, pack)
			criteria = {
				:ean =>  pack.barcode.to_s,
			}
			results = refdata.search(criteria)
      if results.empty? && (pcode = pack.pharmacode) && !pcode.strip.empty?
        ## there's no pharmacode in RefData, so we need to escape to MedData here
        MEDDATA_SERVER.session(:product) { |meddata|
          results = meddata.search(:pharmacode => pcode)
        }
      end
			if(results.empty? && pack.registration.package_count == 1)
				criteria = {
					:ean => pack.barcode.to_s[0,9]
				}
				results = refdata.search(criteria)
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
