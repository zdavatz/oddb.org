#!/usr/bin/env ruby
# VaccinePlugin -- oddb -- 22.03.2005 -- hwyss@ywesee.com

require 'plugin/plugin'
require 'rockit/rockit'
require 'util/persistence'
require 'parseexcel/parseexcel'

module ODDB
	class VaccinePlugin	< Plugin
		class ParsedRegistration
			attr_accessor :iksnr, :indication, :company, :ikscat
			attr_reader :sequences
			def initialize
				@sequences = []
			end
			def assign_seqnrs(reg = nil)
				offset = 1
				if(reg)
					@sequences.each { |seq|
						seq.assign_seqnr_by_ikscd(reg)
					}
					offset = @sequences.collect { |seq| 
						seq.seqnr.to_i 
					}.max.next
				end
				@sequences.select { |seq| seq.seqnr.nil? }.sort_by { |seq|
					seq.ikscds.sort
				}.each_with_index { |seq, idx|
					seq.seqnr = sprintf("%02d", idx + offset)
				}
			end
			def data
				data = {}
				if(@indication)
					data.store(:indication, @indication)
				end
				if(@company)
					data.store(:company, @company)
				end
				if(@ikscat)
					data.store(:ikscat, @ikscat)
				end
				data
			end
		end
		class ParsedSequence
			attr_accessor :name, :seqnr
			attr_reader :packages
			@@dose_pattern = /\d+([,.]\d+)?\s*(%|ml)?/
			def initialize
				@packages = {}
			end
			def assign_seqnr_by_ikscd(registration)
				@packages.each_key { |ikscd|
					if(pack = registration.package(ikscd))
						return @seqnr = pack.sequence.seqnr
					end
				}
			end
			def data
				{
					:name	=>	@name,
				}
			end
			def dose
				@name.to_s[@@dose_pattern]
			end
			def ikscds
				@packages.keys
			end
		end
		class ParsedPackage
			attr_accessor :ikscd, :size
			def data
				{ :size => @size }
			end
		end
		def parse_from_smj(txt)
			registrations = {}
			txt.each_line { |line|
				if(pair = parse_smj_line(line))
					reg, seq = pair
					(registrations[reg.iksnr] ||= reg).sequences.push(seq)
				end
			}
			update_registrations(registrations)
		end
		def parse_from_xls(path)
			workbook = Spreadsheet::ParseExcel.parse(path)
			registrations = parse_worksheet(workbook.worksheet(0))
			update_registrations(registrations)
		end
		def parse_worksheet(worksheet)
			registrations = {}
			sequence = nil
			worksheet.each { |row|
				if(row)
					if(match = /[0-9]{5}/.match(row.at(1).to_s))
						iksnr = match[0]
						## new sequence
						sequence = ParsedSequence.new
						sequence.name = row.at(0).to_s
						reg = (registrations[iksnr] ||= ParsedRegistration.new)
						reg.iksnr = iksnr
						reg.sequences.push(sequence)
					end
					if(match = /[0-9]{13}/.match(row.at(3).to_s))
						ikscd = match[0][9,3]
						package = ParsedPackage.new
						package.size = row.at(2).to_s
						package.ikscd = ikscd
						sequence.packages.store(ikscd, package)
					end
				end
			}
			registrations
		end
		def parse_smj_line(line)
			if(nrpos = line.index(/[0-9]{5}/))
				registration = ParsedRegistration.new
				sequence = ParsedSequence.new
				catpos = line.index(/\b[A-D]\b/, nrpos)
				flagpos = line.rindex(/\bx\b/) || catpos.next
				sequence.name = line[0...nrpos].strip
				registration.iksnr = line[nrpos, 5]
				registration.indication = line[(nrpos + 5)...catpos].strip
				registration.ikscat = line[catpos, 1]
				registration.company = line[flagpos.next..-1].strip
				[registration, sequence]
			end
		end
		def update_package(pack, seq_pointer)
			pointer = seq_pointer + [:package, pack.ikscd]
			@app.update(pointer.creator, pack.data)
		end
		def update_registration(reg)
			data = reg.data
			pointer = nil
			registration = @app.registration(reg.iksnr)
			reg.assign_seqnrs(registration)
			if(registration)
				pointer = registration.pointer
				@app.update(pointer, data) unless(data.empty?)
			else
				pointer = Persistence::Pointer.new([:registration, reg.iksnr])
				@app.update(pointer.creator, data)
			end
			reg.sequences.each { |seq| update_sequence(seq, pointer) }
			if(registration)
				registration.each_sequence { |sequence|
					unless(reg.sequences.any? { |seq| 
						seq.seqnr == sequence.seqnr })
						@app.delete(sequence.pointer)
					end
				}
			end
		end
		def update_registrations(registrations)
			ODBA.transaction {
				registrations.each_value { |reg|
					update_registration(reg)
				}
			}
		end
		def update_sequence(seq, reg_pointer)
			pointer = reg_pointer + [:sequence, seq.seqnr]
			sequence = @app.update(pointer.creator, seq.data)
			seq.packages.each_value { |pack| update_package(pack, pointer) }
			sequence.each_package { |package|
				unless(seq.packages.include?(package.ikscd))
					@app.delete(package.pointer)
				end
			}
		end
	end
end
