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
			attr_reader :packages, :active_agents
			@@dose_pattern = /\d+([,.]\d+)?\s*(%|ml)?/
			def initialize
				@packages = {}
				@active_agents = []
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
		class ParsedActiveAgent
			attr_accessor :substance, :dose, :unit
			def data
				{
					:substance	=>	@substance,
					:dose				=>	[@dose, @unit],
				}
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
			update_registrations(registrations_from_xls(path))
		end
		def parse_worksheet(worksheet)
			registrations = {}
			reg = nil
			seq_name = nil
			substance = nil
			subs_str = ''
			ikscd = nil
			packages = nil
			sequence = nil
			offset = 0
			worksheet.each { |row|
				if(row)
					## is this an xls with ean13?
					if(match = /[0-9]{13}/.match(row.at(3).to_s))
						ikscd = match[0][9,3]
						package = ParsedPackage.new
						package.size = row.at(2).to_s
						package.ikscd = ikscd
					end
					iksval = row.at(1).to_i
					if(iksval > 0)
						iksnr = sprintf('%05i', iksval)
						## new sequence
						sequence = ParsedSequence.new
						seq_name = sequence.name = row.at(0).to_s
						reg = (registrations[iksnr] ||= ParsedRegistration.new)
						reg.iksnr = iksnr
						unless(package)
							reg.company = row.at(2).to_s
						end
						offset = reg.sequences.size
						reg.sequences.push(sequence)
					end
					dose_str = row.at(6).to_s.strip
					subs_str << ' ' << row.at(4).to_s
					subs_str.strip!
					dose_str.split('/').each_with_index { |dose, idx|
						if(dose.to_f > 0)
							sequence = reg.sequences[idx + offset] or begin
								sequence = ParsedSequence.new
								sequence.name = seq_name
								reg.sequences[idx + offset] = sequence
							end
							active_agent = ParsedActiveAgent.new
							active_agent.substance = subs_str
							active_agent.dose = dose
							active_agent.unit = row.at(7).to_s
							sequence.active_agents.push(active_agent)
						end
					}
					if(package)
						sequence.packages.store(ikscd, package)
						package, ikscd = nil
					end
					if(!dose_str.empty?)
						## reset substance
						subs_str = ''
						substance = nil
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
		def registrations_from_xls(path)
			workbook = Spreadsheet::ParseExcel.parse(path)
			parse_worksheet(workbook.worksheet(0))
		end
		def update_active_agent(agent, seq_pointer)
			update_substance(agent.substance)
			pointer = seq_pointer + [:active_agent, agent.substance]
			active_agent = @app.resolve(pointer)
			if(active_agent.nil?)
				active_agent = @app.create(pointer)
			end
			@app.update(active_agent.pointer, agent.data)
		end
		def update_company(data)
			if((name = data.delete(:company)) && !name.empty?)
				company = @app.company_by_name(name)
				if(company.nil?)
					pointer = Persistence::Pointer.new(:company)
					company = @app.update(pointer.creator, {:name => name})
				end
				data.store(:company, company.pointer)
			end
		end
		def update_indication(data)
			if((text = data.delete(:indication)) && !text.empty?)
				indication = @app.indication_by_text(text)
				if(indication.nil?)
					pointer = Persistence::Pointer.new(:indication)
					indication = @app.update(pointer.creator, { 'de' => text})
				end
				data.store(:indication, indication.pointer)
			end
		end
		def update_package(pack, seq_pointer)
			pointer = seq_pointer + [:package, pack.ikscd]
			@app.update(pointer.creator, pack.data)
		end
		def update_registration(reg)
			data = reg.data
			update_company(data)
			update_indication(data)
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
			seq.active_agents.each { |act| 
				update_active_agent(act, pointer) }
			## remove old packages
			unless(seq.packages.empty?)
				sequence.each_package { |package|
					unless(seq.packages.include?(package.ikscd))
						@app.delete(package.pointer)
					end
				}
			end
		end
		def update_substance(substance_name)
			@app.substance(substance_name) or begin
				pointer = Persistence::Pointer.new(:substance)
				@app.update(pointer.creator, {'de' => substance_name})
			end
		end
	end
end
