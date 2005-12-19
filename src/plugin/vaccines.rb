#!/usr/bin/env ruby
# VaccinePlugin -- oddb -- 22.03.2005 -- hwyss@ywesee.com

require 'drb'
require 'plugin/plugin'
require 'rockit/rockit'
require 'util/persistence'
require 'util/html_parser'
require 'util/oddbconfig'
require 'model/dose'
require 'parseexcel/parseexcel'

module ODDB
	class VaccineIndexWriter < NullWriter
		attr_reader :path
		def new_linkhandler(link)
			if(link)
				if((name = link.attribute('name')) && name == 'Impfstoff')
					@vaccine_section = true
				end
				if(@vaccine_section && (href = link.attribute('href')) \
					 && /\/files\/pdf\/B.*\.xls/.match(href))
					@path = href
					@vaccine_section = false
				end
			end
		end
	end
	class VaccinePlugin	< Plugin
		SWISSMEDIC_SERVER = 'www.swissmedic.ch'
		INDEX_PATH = '/de/fach/overall.asp?theme=0.00085.00003&theme_id=939'
		MEDDATA_SERVER = DRbObject.new(nil, MEDDATA_URI)
		DOSE_PATTERN = /(\d+(?:[,.]\d+)?)\s*((?:\/\d+)|[^\s\d]*)?/
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
				data = {
					:generic_type => :vaccine,
				}
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
			attr_writer :dose
			
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
					:dose	=>	self.dose,
				}
			end
			def dose
				@dose || if(match = DOSE_PATTERN.match(name.to_s))
					Dose.new(match[1], match[2])
				end
			end
			def ikscds
				@packages.keys
			end
			def dup
				dp = ParsedSequence.new
				dp.name = @name
				dp
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
			attr_accessor :ikscd, :size, :sizestring, :dose
			def data
				{ :size => @sizestring }
			end
		end
		def initialize(app)
			super
			@active = []
			@created = []
			@updated = []
			@deactivated = []
			@latest_path = File.join(ARCHIVE_PATH, 'xls', 'vaccines-latest.xls')
		end
		def update
			if(path = get_latest_file)
				update_registrations(registrations_from_xls(path))
				FileUtils.cp(path, @latest_path) 
			end
		end
		def extract_latest_filepath(html)
			writer = VaccineIndexWriter.new
			formatter = HtmlFormatter.new(writer)
			parser = HtmlParser.new(formatter)
			parser.feed(html)	
			writer.path
		end
		def get_latest_file
			if(index = http_body(SWISSMEDIC_SERVER, INDEX_PATH))
				path = extract_latest_filepath(index)
				if(download = http_body(SWISSMEDIC_SERVER, path))
					latest = ''
					if(File.exist?(@latest_path))
						latest = File.read(@latest_path)
					end
					if(download != latest)
						target = File.join(ARCHIVE_PATH, 'xls',
															 Date.today.strftime('vaccines-%Y.%m.%d.xls'))
						File.open(target, 'w') { |fh| fh.puts(download) }
						target
					end
				end
			end
		end
		def get_packages(reg)
			criteria = { :ean => "7680" + reg.iksnr }
			template = { :info => [0,1] }
			seqs = reg.sequences
			results = MEDDATA_SERVER.search(criteria, :refdata)
			if(results.size == 1 && seqs.size == 1)
				detail = MEDDATA_SERVER.detail(results.first, template)
				pack = parse_refdata_detail(detail[:info])
				seqs.first.packages.store(pack.ikscd, pack)
			else
				results.each { |result|
					detail = MEDDATA_SERVER.detail(result, template)
					pack = parse_refdata_detail(detail[:info])
					sequence = nil
					sequence = seqs.select { |seq|
						(sd = seq.dose) && (pd = pack.dose) \
							&& (pd == sd || (sd.unit.to_s.empty? && sd.qty == pd.qty))
					}.first
					sequence ||= seqs.select { |seq|
						seq.dose.nil?
					}.first
					if(sequence.nil?) 
						sequence = seqs.first.dup
						reg.sequences.push(sequence)
					end
					if(sequence.dose.nil?)
						sequence.dose = pack.dose
					end
					sequence.packages.store(pack.ikscd, pack)
				}
			end
		end
		def parse_refdata_detail(str)
			ean = str[0,13]
			name = str[13..-1]
			if(/^7680[0-9]{9}$/.match(ean))
				pack = ParsedPackage.new
				pack.ikscd = ean[-4..-2,]
				if(sstring = name.slice!(/(\d+(?:[.,]\d+)?)?\s+([^\d\s]*)$/))
					qty, unit = sstring.split(/\s+/, 2)
					if(qty.empty?)
						qty = 1
					end
					pack.sizestring = sstring
					pack.size = Dose.new(qty, unit)
				else
					pack.size = Dose.new(1)
				end
				if(dstring = name.slice!(DOSE_PATTERN))
					pack.dose = Dose.new(*dstring.split(/\s+/, 2))
				end
				pack
			end
		end
		def parse_worksheet(worksheet)
			registrations = {}
			worksheet.each { |row|
				if(row && (pair = parse_worksheet_row(row)))
					reg, seq = pair
					(registrations[reg.iksnr] ||= reg).sequences.push(seq)
				end
			}
			registrations
		end
		def parse_worksheet_row(row)
			row_at(row, 1)
			if((iksval = row_at(row, 1)) \
				 && /^[0-9]{3,5}(\.[0-9]+)?$/.match(iksval))
				reg = ParsedRegistration.new
				reg.iksnr = sprintf('%05i', iksval.to_i)
				reg.indication = row_at(row, 2)
				reg.ikscat = row_at(row, 3)
				reg.company = row_at(row, 9)
				seq = ParsedSequence.new
				seq.name = row_at(row, 0)
				[reg, seq]
			end
		end
		def registrations_from_xls(path)
			workbook = Spreadsheet::ParseExcel.parse(path)
			registrations = parse_worksheet(workbook.worksheet(0))
			registrations.each_value { |reg|
				get_packages(reg)
			}
		end
		def report
			fmt = "%-14s %3i"
			['@created', '@updated', '@deactivated'].collect { |var|
				sprintf(fmt, var[1..-1].capitalize << ':', instance_variable_get(var))
			}.join("\n")
		end
		def row_at(row, index)
			val = row.at(index).to_s
			val unless val.empty?
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
			iksnr = reg.iksnr
			registration = @app.registration(iksnr)
			@active.push(iksnr)
			reg.assign_seqnrs(registration)
			if(registration)
				@updated.push(iksnr)
				pointer = registration.pointer
				@app.update(pointer, data) unless(data.empty?)
			else
				@created.push(iksnr)
				pointer = Persistence::Pointer.new([:registration, reg.iksnr])
				registration = @app.update(pointer.creator, data)
			end
			reg.sequences.each { |seq| update_sequence(seq, pointer) }
			unless(reg.sequences.empty?)
				registration.each_sequence { |sequence|
					unless(reg.sequences.any? { |seq| 
						seq.seqnr == sequence.seqnr })
						@app.delete(sequence.pointer)
					end
				}
			end
			if(ikscat = reg.ikscat)
				registration.each_package { |pack|
					@app.update(pack.pointer, {:ikscat => ikscat})
				}
			end
		end
		def update_registrations(registrations)
			ODBA.transaction {
				registrations.each_value { |reg|
					update_registration(reg)
				}
				today = Date.today
				@app.registrations.each_value { |reg|
					if(reg.generic_type == :vaccine && !@active.include?(reg.iksnr))
						@deactivated.push(reg.iksnr)
						@app.update(reg.pointer, {:inactive_date => today})
					end
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
