#!/usr/bin/env ruby
# BsvPlugin -- oddb -- 30.05.2003 -- hwyss@ywesee.com 

require 'plugin/plugin'
require 'util/persistence'
require 'parseexcel/parseexcel'

module ODDB
	class BsvPlugin < Plugin
		class PackageDiffer
			attr_reader :iksnr, :name
			COMMA = ','
			def PackageDiffer.header(wdth = 20)
				[
					"  Iksnr".ljust(8),
					"SL-Liste".ljust(wdth),
					"Swissmedic".ljust(wdth),
					"Übereinstimmend".ljust(wdth),
				].join
			end
			def initialize(reg, row)
				@iksnr = row[:iksnr]
				@name = row[:name]
				@bsv = []
				@smj = []
				reg.each_package { |pak|
					@smj << pak.ikscd
				}
				@both = []
			end
			def add_both(ikscd)
				@smj.delete(ikscd)
				add(@both, ikscd)
			end
			def add_bsv(ikscd)
				if(@smj.include?(ikscd))
					raise "ikscd: #{ikscd} has a database-counterpart!"
				else
					add(@bsv, ikscd)
				end
			end
			def add_smj(ikscd)
				add(@smj, ikscd)
			end
			def empty?
				@bsv.empty?
			end
			def to_s
				lines = [@name]
				all = [[@iksnr], @bsv.sort, @smj.sort, @both.sort] 
				all.collect { |coll| coll.size }.max.times { |idx|
					lines << all.collect { |coll| coll.at(idx).to_s.ljust(10) }.join
				}
				lines.join("\n")
			end
			private
			def add(coll, ikscd)
				(coll << ikscd) unless (coll + @both).include?(ikscd)
			end
		end
		def initialize(app)
			super
			@package_diffs = {}
			@unknown_packages = []
			@unknown_registrations = []
			@successful_updates = []
			@updated_packages = []
		end
		def report
			successful = @successful_updates.collect { |row| 
				report_format(row).join("\n")
			}
			registrations = @unknown_registrations.collect { |row| 
				report_format(row).join("\n")
			}
			packages = @unknown_packages.collect { |row| 
				report_format(row).join("\n")
			}
			package_diffs = @package_diffs.values.collect { |diff| 
				diff.to_s unless diff.empty?
			}.compact.sort
			[
				"Successful Updates:    #{@successful_updates.size.to_s.rjust(5)}", 
				"Unknown Registrations: #{@unknown_registrations.size.to_s.rjust(5)}",
				"Unknown Packages:      #{@unknown_packages.size.to_s.rjust(5)}",
				nil, nil, nil,
				"Successful Updates:    #{@successful_updates.size.to_s.rjust(5)}", 
				successful.join("\n\n"),
				nil, nil, nil,
				"Unknown Registrations: #{@unknown_registrations.size.to_s.rjust(5)}",
				registrations.join("\n\n"),
				nil, nil, nil,
				"Unknown Packages:      #{@unknown_packages.size.to_s.rjust(5)}",
				packages.join("\n\n"),
				nil, nil, nil,
				"Differences:",
				PackageDiffer.header,
				package_diffs.join("\n\n"),
				nil,
			].join("\n")
		end
		def update(month)
			@month = month
			server = 'www.galinfo.net'
			filename = "BSV_per_#{sprintf('%4d.%02d', @month.year, @month.month)}.01.xls"
			path = "/sl/#{filename}"
			update_from_url(server, path, filename)
		end
		def update_from_url(server, path, filename)
			target_path = target(filename)
			if(http_file(server, path, target_path))
				workbook = Spreadsheet::ParseExcel.parse(target_path)
				worksheet = workbook.worksheet(0)
				worksheet.each(1) { |row|
					iksnr = row.at(4).to_i.to_s
					ikscd = iksnr.slice!(-3..-1)
					hash = {
						:iksnr						=>	iksnr,
						:ikscd						=>	ikscd,
						:price_exfactory	=>	row.at(8).to_f,
						:price_public			=>	row.at(9).to_f,
						:limitation				=>	(row.at(10).to_s.downcase=='y'),
						:limitation_points=>	row.at(11).to_i,
						:introduction_date=>	row.at(6).date,
						:company					=>	row.at(0).to_s,
						:ikscat						=>	row.at(5).to_s,
						:name							=>	row.at(7).to_s,
					}
					if(row.at(1).to_s.downcase == 'y')
						hash.store(:generic_type, :generic)
					end
					begin 
						update_registration(hash)
					rescue StandardError => e
						puts e.class
						puts e.message
						puts e.backtrace
					end
				}
				purge_sl_entries
				true
			else
				false
			end
		end
		private
		def price_flag(old_efp, new_efp, old_pbp, new_pbp)
			if([old_efp, new_efp, old_pbp, new_pbp].compact.empty? \
				|| (old_efp && new_efp && (old_efp.to_f < new_efp.to_f)) \
				|| (old_pbp && new_pbp && (old_pbp.to_f < new_pbp.to_f)))
				:price_rise
			else
				:price_cut
			end
		end
		def purge_sl_entries
			@app.each_package { |pack| 
				unless(pack.sl_entry.nil? || @updated_packages.include?(pack))
					@app.delete(pack.sl_entry.pointer)
					@change_flags.store(pack.pointer, [:sl_entry_delete])
				end
			}
		end
		def report_format(row)
			[
				:name,
				:company,
				:iksnr,
				:ikscd,
				:ikscat,
				:generic_type,
				:price_exfactory,
				:price_public,
				:introduction_date,
				:limitation,
				:limitation_points,
			].collect { |key| 
				label = key.to_s.tr('_', '-').capitalize << ':'
				label.ljust(20) << row[key].to_s
			}
		end
		def target(filename)
			File.expand_path("xls/#{filename}", self::class::ARCHIVE_PATH)
		end
		def update_package(reg, row)
			differ = @package_diffs[row[:iksnr]] ||= PackageDiffer.new(reg, row)
			if(pack = reg.package(row[:ikscd]))
				differ.add_both(row[:ikscd])
				hash = {}
				if price = row[:price_exfactory]
					hash.store(:price_exfactory, price)
				end
				if price = row[:price_public]
					hash.store(:price_public, price)
				end

				# no prior sl_entry
				if(pack.sl_entry.nil?)
					@change_flags.store(pack.pointer, [:sl_entry])
				# prior sl_entry has different price
				elsif((changes = pack.diff(hash)) && !changes.empty?)
					old_efp = pack.price_exfactory
					new_efp = row[:price_exfactory]
					old_pbp = pack.price_public
					new_pbp = row[:price_public]
					flag = price_flag(old_efp, new_efp, old_pbp, new_pbp)
					@change_flags.store(pack.pointer, [flag])
				end
				@app.update(pack.pointer, hash)
				update_sl(pack.pointer, row)
				@successful_updates.push(row)
				@updated_packages.push(pack)
			else
				differ.add_bsv(row[:ikscd])
				@unknown_packages.push(row)
			end
		end
		def update_registration(row)
			reg_pointer = Persistence::Pointer.new([:registration, row[:iksnr]])
			if(registration = reg_pointer.resolve(@app))
				if(gtype = row[:generic_type])
					hash = {:generic_type => gtype}
					@app.update(reg_pointer, hash)
				end
				update_package(registration, row)
			else
				@unknown_registrations.push(row)
			end
		end
		def update_sl(pack_pointer, row)
			pointer = pack_pointer + :sl_entry
			hash = {
				:limitation					=>	row[:limitation],
				:limitation_points	=>	row[:limitation_points],
			}
			if(date = row[:introduction_date])
				hash.store(:introduction_date, date)
			end
			@app.update(pointer.creator, hash)
		end
	end
end
