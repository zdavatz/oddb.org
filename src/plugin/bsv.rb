#!/usr/bin/env ruby
# BsvPlugin -- oddb -- 30.05.2003 -- hwyss@ywesee.com 

require 'plugin/plugin'
require 'util/persistence'
require 'parseexcel/parseexcel'
require 'model/package'

module ODDB
	class BsvPlugin < Plugin
		BLOCKED_REGISTRATIONS = [
			'17719', '19075', '55645',
		]
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
						:company					=>	row.at(0).to_s,
						:ikscat						=>	row.at(5).to_s,
						:name							=>	row.at(7).to_s,
					}
					if(field = row.at(6))
						hash.store(:introduction_date, field.date)
					end
					if(row.at(1).to_s.downcase == 'y')
						hash.store(:generic_type, :generic)
					end
					begin 
						unless(BLOCKED_REGISTRATIONS.include?(hash[:iksnr]))
							update_registration(hash)
						end
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
				unless(pack.sl_entry.nil? || @updated_packages.include?(pack.odba_id) \
					|| BLOCKED_REGISTRATIONS.include?(pack.iksnr))
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
				@updated_packages.push(pack.odba_id)
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
	class BsvPlugin2 < Plugin
		class ParsedPackage
			include SizeParser
			attr_accessor :sl_dossier, :iksnr, :ikscd, :introduction_date, 
				:price_public, :price_exfactory, :pharmacode, :limitation,
				:limitation_points, :generic_type, :name, :company, :pointer
			def ikskey
				[@iksnr, @ikscd].join
			end
			def ikskey=(key)
				@iksnr = sprintf('%05i', key[0,5].to_i)
				@ikscd = sprintf('%03i', key[5,3].to_i)
			end
			def merge(other)
				if(other.is_a?(ParsedPackage))
					other.instance_variables.each { |name|
						unless(instance_variable_get(name))
							instance_variable_set(name, 
								other.instance_variable_get(name))
						end
					}
				else
					raise TypeError "can only merge with another package"
				end
			end
			def data
				data = {
					:pharmacode	=>	@pharmacode,
				}
				if(@price_public)
					data.store(:price_public, @price_public)
				end
				if(@price_exfactory)
					data.store(:price_exfactory, @price_exfactory)
				end
				data
			end
			def sl_data
				{
					:bsv_dossier => @sl_dossier,
					:introduction_date => @introduction_date,
					:limitation	=>	@limitation,
					:limitation_points	=>	@limitation_points,
				}
			end
		end
		class MutationParser
			attr_reader :src_additions, :src_deletions, :src_reductions,
				:src_augmentations, :src_limitations
			money = "[\\d\.]+"
			@@line = /Fr\.\s+([\d.]+)\s*\{([\s\d.]+)\}\s+\[(\d+)\]\s+([\d.]+),/
			@@modline = /(\d+)\s*(\d+)\s+([\d.]+)\s+([\d.]*)/
			def initialize(src)
				@src = src.gsub("\r", "")
				@src_additions = ''
				@src_deletions = ''
				@src_reductions = ''
				@src_augmentations = ''
				@src_limitations = ''
				@src_previous = ''
			end
			def each_addition(&block)
				@src_additions.each_line { |line|
					if(pack = parse_line(line))
						block.call(pack)
					end
				}
			end
			def each_deletion(&block)
				@src_deletions.each_line { |line|
					if(pack = parse_line(line))
						block.call(pack)
					end
				}
			end
			def each_reduction(&block)
				@src_reductions.each_line { |line|
					if(pack = parse_line(line))
						block.call(pack)
					end
				}
			end
			def each_augmentation(&block)
				@src_augmentations.each_line { |line|
					if(pack = parse_line(line))
						block.call(pack)
					end
				}
			end
			def identify_parts
				target = ''
				skip = 0
				@src.each_line { |line|
					if(skip > 0)
						skip -= 1
					else
						case line
						when /^I\. Neuzugang/
							target = @src_additions = ''
						when /^II\. Neu gestrichen/
							target = @src_deletions = ''
						when /^III\. Preissenkung/
							target = @src_reductions = ''
							skip = 5
						when /^IV\. Preismutation/
							target = @src_augmentations = ''
							skip = 1
						when /^V\. Aenderung der Limitation/
							target = @src_limitations = ''
						when /^VI\. Bisherige/
							target = @src_previous = ''
						when /^Therap\.Gruppe/, /^Präparate/
							## ignore this bit
							target = ''
						else
							target << line
						end
					end
				}
				@src_additions.strip!
				@src_deletions.strip!
				@src_reductions.strip!
				@src_augmentations.strip!
				@src_limitations.strip!
			end
			def parse_line(line)
				if(match = @@line.match(line))
					pack = ParsedPackage.new
					pack.sl_dossier = line[%r{\d+}]
					pack.price_public = match[1].to_f
					pack.price_exfactory = match[2].to_f
					pack.ikskey = match[3]
					date = match[4].split('.').reverse.collect { |str| str.to_i }
					pack.introduction_date = Date.new(*date)
					pack
				elsif(match = @@modline.match(line))
					pack = ParsedPackage.new
					pack.pharmacode = match[1]
					pack.sl_dossier = match[2]
					pack.price_public = match[3].to_f
					pack.price_exfactory = match[4].to_f
					pack
				end
			end
		end
		class PackageDiffer
			attr_reader :iksnr, :name
			COMMA = ','
			def initialize(reg, pac)
				@iksnr = pac.iksnr
				@name = pac.name
				@bsv = []
				@smj = []
				reg.each_package { |pak|
					@smj.push(pak.ikscd)
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
				wdth = 12
				header = [
					"Iksnr".ljust(wdth),
					"BAG".ljust(wdth),
					"Swissmedic".ljust(wdth),
					"Beide".ljust(wdth),
				].join
				all = [[@iksnr], @bsv.sort, @smj.sort, @both.sort] 
				all.collect { |coll| coll.size }.max.times { |idx|
					lines << all.collect { |coll| 
						coll.at(idx).to_s.ljust(wdth) 
					}.join
				}
				lines.join("\n")
			end
			private
			def add(coll, ikscd)
				(coll << ikscd) unless (coll + @both).include?(ikscd)
			end
		end
		GALINFO = 'www.galinfo.net'
		def initialize(app)
			super
			@ikstable = {}
			@package_diffs = {}
			@ptable = {}
			@successful_updates = []
			@guessed_packages = []
			@unknown_packages = []
			@unknown_registrations = []
		end
		def report
			successful = @successful_updates.collect { |pac| 
				report_format(pac).join("\n")
			}
			guessed = @guessed_packages.collect { |pac| 
				report_format(pac).join("\n")
			}
			registrations = @unknown_registrations.collect { |pac| 
				report_format(pac).join("\n")
			}
			packages = @unknown_packages.collect { |pac| 
				report_format(pac).join("\n")
			}
			package_diffs = @package_diffs.values.collect { |diff| 
				diff.to_s unless diff.empty?
			}.compact.sort
			[
				"Successful Updates:    #{@successful_updates.size.to_s.rjust(5)}", 
				"Guessed Packages:      #{@guessed_packages.size.to_s.rjust(5)}", 
				"Unknown Registrations: #{@unknown_registrations.size.to_s.rjust(5)}",
				"Unknown Packages:      #{@unknown_packages.size.to_s.rjust(5)}",
				nil, nil, nil,
				"Successful Updates:    #{@successful_updates.size.to_s.rjust(5)}", 
				successful.join("\n\n"),
				nil, nil, nil,
				"Guessed Packages:      #{@guessed_packages.size.to_s.rjust(5)}", 
				guessed.join("\n\n"),
				nil, nil, nil,
				"Unknown Registrations: #{@unknown_registrations.size.to_s.rjust(5)}",
				registrations.join("\n\n"),
				nil, nil, nil,
				"Unknown Packages:      #{@unknown_packages.size.to_s.rjust(5)}",
				packages.join("\n\n"),
				nil, nil, nil,
				"Differences:",
				package_diffs.join("\n\n"),
				nil,
			].join("\n")
		end
		def update(month)
			@month = month

			## download the Bulletin where we can extract exact changes
			## and the database-file where we can reference pharmacodes
			bl_file = download_bulletin(month)
			db_file = download_database(month)

			## make a pharmacode-lookup-table from the database-file
			load_database(db_file)

			## iterate over all changes in the bulletin, identify the 
			## corresponding package, apply the changes and record them 
			## in @change_flags
			parser = MutationParser.new(File.read(bl_file))
			parser.identify_parts
			parser.each_addition { |package|
				handle_addition(package)
			}
			parser.each_deletion { |package|
				handle_deletion(package)
			}
			parser.each_reduction { |package|
				handle_reduction(package)
			}
			parser.each_augmentation { |package|
				handle_augmentation(package)
			}

			## update prices from the database but do not store as mutation.
			@ikstable.each_value { |package| 
				handle_package(package)
			}

			## TODO: try to identify missing packages according to their 
			##       package-size and dose
			@ikstable.each_value { |package| 
				handle_unknown_package(package)
			}
			
			## compile a report that includes missing packages.
			## -> is being done on the fly
		rescue RuntimeError
			false
		end
		private
		def balance_package(package)
			if((package.iksnr.nil? \
				&& (pack = @ptable[package.pharmacode])) \
				|| (package.pharmacode.nil? \
				&& (pack = @ikstable[package.ikskey])))
				package.merge(pack)
			end
		end
		def bulletin(date)
			sprintf('PR%02d%02d01.txt', date.year % 100, date.month)
		end
		def database(date)
			sprintf('BSV_per_%4d.%02d.01.xls', date.year, date.month)
		end
		def delete_sl_entry(package, pac)
			@app.delete(package.pointer + [:sl_entry])
		end
		def download_bulletin(date)
			download(bulletin(date))
		end
		def download_database(date)
			download(database(date))
		end
		def download(name)
			path = '/' << name
			target = File.join(ARCHIVE_PATH, 'txt', path)
			http_file(GALINFO, path, target) \
				or raise "Could not download #{path} from #{GALINFO}"
			target
		end
		def handle_addition(package)
			if(pack = handle_package(package))
				update_sl_entry(pack, package)
				@change_flags.store(package.pointer, [:sl_entry])
			end
		end
		def handle_augmentation(package)
			if(pack = handle_package(package))
				update_sl_entry(pack, package)
				@change_flags.store(package.pointer, [:price_rise])
			end
		end
		def handle_deletion(package)
			if(pack = handle_package(package))
				delete_sl_entry(pack, package)
				@change_flags.store(package.pointer, [:sl_entry_delete])
			end
		end
		def handle_package(package)
			balance_package(package)
			if(reg = update_registration(package))
				if(pac = update_package(reg, package))
					## when we iterate over @ikstable later on, this package 
					## need not be handled again
					@ikstable.delete(package.ikskey)
					pac
				end
			else
				## when we iterate over @ikstable later on, this unknown
				## registration need not be handled again
				@ikstable.delete(package.ikskey)
				nil
			end
		end
		def handle_reduction(package)
			if(pack = handle_package(package))
				update_sl_entry(pack, package)
				@change_flags.store(package.pointer, [:price_cut])
			end
		end
		def handle_unknown_package(package)
			if(reg = @app.registration(package.iksnr))
				if(match = /(\d+\s+\w+)\s+(\d+\s+\w+)/.match(package.name))
					package.size = match[2]
					dose = Dose.new(match[2])
					## both dose and size must match for a valid guess
					candidates = reg.sequences.values.select { |seq|
						seq.dose == dose
					}.collect { |seq|
						seq.packages.values.select { |pac|
							pac.comparable_size == package.comparable_size
						}
					}.flatten
					if(candidates.size == 1)
						@unknown_packages.delete(package)
						@guessed_packages.push(package)
						package.ikscd = candidates.first.ikscd
						update_package(reg, package)
					end
				end
			end
		end
		def load_database(path)
			workbook = Spreadsheet::ParseExcel.parse(path)
			worksheet = workbook.worksheet(0)
			worksheet.each(1) { |row|
				pcode = row.at(2).to_i.to_s
				ikskey = row.at(4).to_i.to_s
				package = ParsedPackage.new
				package.company = row.at(0).to_s
				package.generic_type = (row.at(1).to_s.downcase == 'y')
				package.name = row.at(7).to_s
				exf = row.at(8).to_f
				package.price_exfactory = exf if(exf > 0)
				pub = row.at(9).to_f
				package.price_public = pub if(pub > 0)
				package.limitation = (row.at(10).to_s.downcase=='y')
				package.limitation_points = row.at(11).to_i
				unless(pcode == '0')
					package.pharmacode = pcode
					@ptable.store(pcode, package)
				end
				unless(ikskey == '0')
					package.ikskey = ikskey
					## ensure the correct ikskey-format by regetting it
					@ikstable.store(package.ikskey, package)
				end
			}
		end
		def report_format(package)
			[
				:name,
				:company,
				:iksnr,
				:ikscd,
				:generic_type,
				:price_exfactory,
				:price_public,
				:introduction_date,
				:limitation,
				:limitation_points,
			].collect { |key| 
				label = key.to_s.tr('_', '-').capitalize << ':'
				label.ljust(20) << package.send(key).to_s
			}
		end
		def update_package(reg, pac)
			differ = @package_diffs.fetch(pac.iksnr) {
				@package_diffs.store(pac.iksnr, PackageDiffer.new(reg, pac))
			}
			if(pack = reg.package(pac.ikscd))
				differ.add_both(pac.ikscd)
				pac.pointer = pack.pointer
				@app.update(pack.pointer, pac.data)
				@successful_updates.push(pac)
				pack
			else
				differ.add_bsv(pac.ikscd)
				@unknown_packages.push(pac)
				nil
			end
		end
		def update_registration(package)
			ptr = Persistence::Pointer.new([:registration, package.iksnr])
			if(registration = ptr.resolve(@app))
				if(package.generic_type)
					@app.update(ptr, {:generic_type => :generic})
				end
				registration
			else
				@unknown_registrations.push(package)
				nil
			end
		end
		def update_sl_entry(package, pac)
			sl_ptr = package.pointer + [:sl_entry]
			@app.update(sl_ptr.creator, pac.sl_data)
		end
	end
end
