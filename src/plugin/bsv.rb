#!/usr/bin/env ruby
# BsvPlugin2 -- oddb -- 30.05.2003 -- hwyss@ywesee.com 

require 'plugin/plugin'
require 'util/persistence'
require 'parseexcel/parseexcel'
require 'model/package'
require 'util/oddbconfig'

module ODDB
	class BsvPlugin2 < Plugin
		MEDDATA_SERVER = DRbObject.new(nil, MEDDATA_URI)
		MEDDATA_SLEEP = 0.2
		class ParsedPackage
			include SizeParser
			attr_accessor :sl_dossier, :iksnr, :ikscd, :introduction_date, 
				:price_public, :price_exfactory, :pharmacode, :limitation,
				:limitation_points, :generic_type, :name, :company, :pointer,
				:guessed_ikscd, :medwin_ikskey, :sl_ikskey, :deductible
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
					:deductible				=>	@deductible,
					:generic_type	    =>  @generic_type,
					:pharmacode				=>	@pharmacode,
					:sl_generic_type	=>  @generic_type,
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
				data = {
					:bsv_dossier => @sl_dossier,
					:limitation	=>	@limitation,
					:limitation_points	=>	@limitation_points,
				}
				if(@introduction_date.is_a?(Date))
					data.store(:introduction_date, @introduction_date)
				end
				data
			end
		end
		class MutationParser
			attr_reader :src_additions, :src_deletions, :src_reductions,
			:src_augmentations, :src_limitations
			@@line = /Fr\.\s+([\d.]+)\s*\{([\s\d.]+)\}\s+\[(\d+)\]\s+([\d.]+),/
			@@brokenline = /\s+\[(\d+)\]\s+([\d.]+),/
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
				number = '[IVX]+[a-z]?\.'
				target = ''
				skip = 0
				@src.each_line { |line|
					if(skip > 0)
						skip -= 1
					else
						case line
						when /^#{number} Neuzugang/
							target = @src_additions = ''
						when /^#{number} Neu gestrichen/
							target = @src_deletions = ''
						when /^#{number} Preissenkung/
							target = @src_reductions = ''
							skip = 5
						when /^#{number} Preismutation/
							target = @src_augmentations = ''
							skip = 1
						when /^#{number} Preiskorrektur/
							target = @src_corrections = ''
						when /^#{number} Aenderung der Limitation/, 
							/^#{number} Limitations.nderung/
							target = @src_limitations = ''
						when /^#{number} Streichung der Limitation/
							target = @src_limitation_deletions = ''
						when /^#{number} Bisherige/
							target = @src_previous = ''
						when /^Therap\.Gruppe/, /^Präparate/, /^#{number} Namens.nderung/
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
				elsif(match = @@brokenline.match(line))
					pack = ParsedPackage.new
					pack.ikskey = match[1]
					date = match[2].split('.').reverse.collect { |str| str.to_i }
					pack.introduction_date = Date.new(*date)
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
				wdth = 12
				header = [
				"Iksnr".ljust(wdth),
				"BAG".ljust(wdth),
				"Swissmedic".ljust(wdth),
				"Beide".ljust(wdth),
				].join
				lines = [@name, header]
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
		GALINFO = 'bsv.e-mediat.net'
		def initialize(app)
			super
			@ikstable = {}
			@package_diffs = {}
			@ptable = {}
			@successful_updates = []
			@guessed_packages = []
			@unknown_packages = []
			@unknown_registrations = []
			@parse_errors = []
			@medwin_sl_diffs = []
			@medwin_out_of_sale = []
		end
		def log_info
			info = super
			parts = [
				['text/plain', 'todo.txt', report_todo],
				['text/plain', 'bsv_out_of_sale.txt', report_out_of_sale],
				['text/plain', 'medwin_bsv_differences.txt', 
					report_medwin_diffs],
			]
			info.store(:parts, parts)
			info
		end
		def report
			[
				format_header("Successful Updates:", @successful_updates.size),
				format_header("Guessed Packages:", @guessed_packages.size),
				format_header("Unknown Registrations:", 
					@unknown_registrations.size),
				format_header("Unknown Packages:", @unknown_packages.size),
				format_header("Parse Errors:", @parse_errors.size),
				#format_header("Differences:", @package_diffs.size),
				format_header("Medwin-Differences:", @medwin_sl_diffs.size),
				format_header("Ausser Handel (laut Medwin):", 
					@medwin_out_of_sale.size),
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
				if(pack = handle_package(package))
					update_sl_entry(pack, package)
				end
			}

			## TODO: try to identify missing packages according to their 
			##       package-size and dose
			@ikstable.each_value { |package| 
				handle_unknown_package(package)
			}

			## compile a report that includes missing packages.
			## -> is being done on the fly
		rescue RuntimeError
			## return nil if any of the downloads fail.
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
		def deductible_originals(workbook)
			map = {}
			deductibles = workbook.worksheet(2)
			deductibles.each(1) { |row|
				pcode = row.at(2).to_i
				if(pcode > 0)
					map.store(pcode.to_s, true)
				end
				iksnr = row.at(4).to_i
				if(iksnr > 0)
					map.store(sprintf("%05i", iksnr), true)
				end
			}
			map
		end
		def delete_sl_entry(package, pac)
			@app.delete(package.pointer + [:sl_entry])
		end
		def download_bulletin(date)
			download('www.galinfo.net', '/', bulletin(date), 'txt')
		end
		def download_database(date)
			download('bsv.e-mediat.net', '/sl', database(date), 'xls')
		end
		def download(host, path, name, archive)
      dpath = File.join(path, name)
			target = File.join(ARCHIVE_PATH, archive, name)
			http_file(GALINFO, dpath, target) \
				or raise "Could not download #{dpath} from #{host}"
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
				candidates = []
				puts package.name
				puts package.ikscd
				if(match = /(\d+)\s+(\w+)(.*?)((\d,)?\d+\s+\w+)$/.match(package.name))
					package.size = match[3]
					dose = Dose.new(match[1], match[2])
					## both dose and size must match for a valid guess
					candidates = reg.sequences.values.select { |seq|
						seq.dose == dose
					}.collect { |seq|
						seq.packages.values.select { |pac|
							pac.comparable_size == package.comparable_size
						}
					}.flatten
				end
				if(candidates.empty? && package.ikscd == '000')
					min = reg.sequences.values.inject([]) { |inj, seq|
						seq.packages.each_value { |pac|
							inj.push(pac.comparable_size)
						}
						inj
					}.compact.sort.first
					candidates = reg.sequences.values.inject([]) { |inj, seq| 
						seq.packages.each_value { |pac|
							if(pac.comparable_size == min)
								inj.push(pac)
							end
						}
						inj
					}
				end
				if(candidates.size == 1)
					@unknown_packages.delete(package)
					@guessed_packages.push(package)
					pack = candidates.first
					package.guessed_ikscd = pack.ikscd
					update_package(reg, package)
					update_sl_entry(pack, package)
				end
			end
		rescue ParseException, AmbigousParseException => err
			@parse_errors.push([err.class.to_s, package.name, match[2]])
		end
		def format_header(name, size)
			sprintf("%-30s%5i", name, size)
		end
		def load_database(path)
			known_pcodes = {}
			@app.each_package { |pac|
				if(pcode = pac.pharmacode)
					known_pcodes.store(pcode, pac.ikskey)
				end
			}
			workbook = Spreadsheet::ParseExcel.parse(path)
			do_map = deductible_originals(workbook)
			worksheet = workbook.worksheet(0)
			worksheet.each(1) { |row|
				pcode = row.at(2).to_i.to_s
				sl_iks = row.at(4).to_i.to_s
				package = ParsedPackage.new
				if(cell = row.at(0))
					package.company = cell.to_s(ENCODING)
				end
				if(cell = row.at(1))
					str = cell.to_s(ENCODING)
					if(/g/i.match(str))
						package.generic_type = :generic
					elsif(/o/i.match(str))
						package.generic_type = :original
					else
						package.generic_type = :unknown
					end
				end
				if(cell = row.at(6))
					package.introduction_date = cell.date
				end
				if(cell = row.at(7))
					package.name = cell.to_s(ENCODING)
				end
				exf = row.at(8).to_f
				package.price_exfactory = exf if(exf > 0)
				pub = row.at(9).to_f
				package.price_public = pub if(pub > 0)
				if(cell = row.at(10))
					package.limitation = (cell.to_s(ENCODING).downcase=='y')
				end
				package.limitation_points = row.at(11).to_i
				if(do_map.has_key?(pcode) || do_map.has_key?(sl_iks))
					package.deductible = :deductible_o
				else
					package.deductible = :deductible_g
				end
				medwin_iks = nil
				unless(pcode == '0')
					package.pharmacode = pcode
					@ptable.store(pcode, package)
					medwin_iks = known_pcodes[pcode] || load_ikskey(pcode)
					#sleep(MEDDATA_SLEEP)
				end
				package.ikskey = (medwin_iks || sl_iks)
				if(!(medwin_iks.nil? || medwin_iks == sl_iks))
					package.medwin_ikskey = medwin_iks
					package.sl_ikskey = sl_iks
					@medwin_sl_diffs.push(package)
				end
				## ensure the correct ikskey-format by regetting it
				ikskey = package.ikskey
				unless(ikskey.to_i == 0)
					@ikstable.store(ikskey, package)
				end
			}
		end
		def load_ikskey(pcode)
			tries = 3
			ikskey = nil
			begin
				MEDDATA_SERVER.session(:product) { |meddata|
					results = meddata.search({:pharmacode => pcode})
					if(results.size == 1)
						data = meddata.detail(results.first, {:ean13 => [1,2]})
						if(ean13 = data[:ean13])
							ikskey = ean13[4,8]
						end
					end
				}
				ikskey
			rescue Errno::ECONNRESET
				if(tries > 0)
					tries -= 1
					sleep(3 - tries)
					retry
				else
					raise
				end
			end
		end
		def report_format(package)
			[
				:name,
				:company,
				:iksnr,
				:ikscd,
				:pharmacode,
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
		def report_medwin_diffs
			fmt = <<-EOS
Pharmacode: %s
%s
Medwin Swissmedic-Nr:  %5s %3s 
BSV-XLS Swissmedic-Nr: %5s %3s
			EOS
			medwin_sl_diffs = @medwin_sl_diffs.collect { |package|
				mw = package.medwin_ikskey.to_s
				sl = package.sl_ikskey.to_s
				sprintf(fmt, package.pharmacode, package.name, 
					mw[0,5], mw[5,3], sl[0,5], sl[5,3])
			}.sort
			[
				format_header("Medwin-Differences:", @medwin_sl_diffs.size),
				medwin_sl_diffs.join("\n"),
			].join("\n")
		end
		def report_out_of_sale
			medwin_out_of_sale = @medwin_out_of_sale.collect { |pac| 
				report_format(pac).join("\n")
			}.sort
			[
				format_header("Ausser Handel (laut Refdata):", @medwin_out_of_sale.size),
				medwin_out_of_sale.join("\n\n"),
			].join("\n")
		end
		def report_todo
			guessed = @guessed_packages.collect { |pac| 
				report_format(pac).join("\n")
			}.sort
			registrations = @unknown_registrations.collect { |pac| 
				report_format(pac).join("\n")
			}.sort
			packages = @unknown_packages.collect { |pac| 
				report_format(pac).join("\n")
			}.sort
			parse_errors = @parse_errors.collect { |triplet|
				sprintf("%-15s '%20s' '%s'", *triplet)
			}.sort
			[
				format_header("Guessed Packages:", @guessed_packages.size),
				guessed.join("\n\n"),
				nil, nil, nil,
				format_header("Unknown Registrations:", 
					@unknown_registrations.size),
				registrations.join("\n\n"),
				nil, nil, nil,
				format_header("Unknown Packages:", @unknown_packages.size),
				packages.join("\n\n"),
				nil, nil, nil,
				format_header("Parse Errors:", @parse_errors.size),
				parse_errors.join("\n"),
			].join("\n")
		end
		def update_package(reg, pac)
			differ = @package_diffs.fetch(pac.iksnr) {
				@package_diffs.store(pac.iksnr, PackageDiffer.new(reg, pac))
			}
			pack = nil
			if(pack = reg.package(pac.ikscd))
				differ.add_both(pac.ikscd)
			else
				pack = reg.package(pac.guessed_ikscd)
				differ.add_bsv(pac.ikscd)
			end
			if(pack)
				pac.pointer = pack.pointer
				@app.update(pack.pointer, pac.data, :sl)
				@successful_updates.push(pac)
			else
				@unknown_packages.push(pac)
			end
			if(pac.pharmacode.nil? || (pack && pack.out_of_trade))
				@medwin_out_of_sale.push(pac)
			end
			pack
		end
		def update_registration(package)
			ptr = Persistence::Pointer.new([:registration, package.iksnr])
			if(registration = ptr.resolve(@app))
				@app.update(ptr, { :generic_type => package.generic_type })
			else
				@unknown_registrations.push(package)
				nil
			end
		end
		def update_sl_entry(package, pac)
			sl_ptr = package.pointer + [:sl_entry]
			@app.update(sl_ptr.creator, pac.sl_data, :sl)
		end
	end
end
