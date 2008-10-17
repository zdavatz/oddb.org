#!/usr/bin/env ruby
# VaccinePlugin -- oddb -- 22.03.2005 -- hwyss@ywesee.com

require 'drb'
require 'plugin/plugin'
require 'rockit/rockit'
require 'util/persistence'
require 'util/html_parser'
require 'util/oddbconfig'
require 'model/dose'

module ODDB
	class VaccineIndexWriter < NullWriter
		attr_reader :path
    def send_flowing_data(data)
      if(/Excel/i.match data)
        @path ||= @candidate
      end
      super
    end
		def new_linkhandler(link)
      if(link && (href = link.attribute('href')) \
				 && /.*\.xls$/.match(href))
        @candidate = href
			end
		end
	end
	class VaccinePlugin	< Plugin
    Spreadsheet.client_encoding = ENCODING
		SWISSMEDIC_SERVER = 'www.swissmedic.ch'
		INDEX_PATH = '/html/content/Impfstoffe-d.html'
		MEDDATA_SERVER = DRbObject.new(nil, MEDDATA_URI)
		DOSE_PATTERN  = /(\d+(?:[,.]\d+)?)\s*((?:\/\d+)|[^\s\d]*)?/
		ENDMULTI_PATTERN = /\d+\s*Stk$/
		MULTI_PATTERN = /(\d+\s+)\b(Fl|Fertigspr)\b/
		XLS_PATH = '/files/pdf/B3.1.35-d.xls'
		SIZE_PATTERN  = /(?:(?:(\d+(?:[.,]\d+)?)\s*x\s*)?(\d+(?:[.,]\d+)?))?\s*([^\d\s]*)$/
		class ParsedRegistration
			attr_accessor :iksnr, :indication, :company, :ikscat, :out_of_trade, 
        :expiration_date
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
          :vaccine => true, 
        }
        [:indication, :company, :ikscat, :expiration_date].each { |key|
          if(val = self.send(key))
            data.store(key, val)
          end
        }
				data
			end
		end
		class ParsedSequence
			attr_accessor :name, :seqnr, :atc_class
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
				data = {
					:name	=>	@name,
					:dose	=>	self.dose,
				}
        if(@atc_class)
          data.store(:atc_class, @atc_class)
        end
        data
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
        dp.atc_class = @atc_class
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
		def update(manual_download=nil)
			if(path = (manual_download || get_latest_file))
				update_registrations(registrations_from_xls(path))
				FileUtils.cp(path, @latest_path) 
        @app.rebuild_atc_chooser
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
			if((index = http_body(SWISSMEDIC_SERVER, INDEX_PATH)) \
				 && (path = extract_latest_filepath(index)) \
				 && (download = http_body(SWISSMEDIC_SERVER, path)))
=begin
			if(download = http_body(SWISSMEDIC_SERVER, XLS_PATH))
=end
				latest = ''
				if(File.exist?(@latest_path))
					latest = File.read(@latest_path)
				end
        if(download[-1] != ?\n)
          download << "\n"
        end
				if(download != latest)
					target = File.join(ARCHIVE_PATH, 'xls',
														 @@today.strftime('vaccines-%Y.%m.%d.xls'))
					File.open(target, 'w') { |fh| fh.puts(download) }
					target
				end
			end
		end
		def get_packages(reg, active=nil)
			criteria = { :ean => "7680" + reg.iksnr }
			template = { :info => [0,1] }
			seqs = reg.sequences
			MEDDATA_SERVER.session(:refdata) { |session|
				results = session.search(criteria)
				if(results.size == 1 && seqs.size == 1)
					result = results.first
					detail = session.detail(result, template)
					pack = parse_refdata_detail(detail[:info])
					seqs.first.packages.store(pack.ikscd, pack)
				else
					results.each { |result|
						detail = session.detail(result, template)
						pack = parse_refdata_detail(detail[:info])
						sequence = nil
						activeseq = nil
						if(active && (activepac = active.package(pack.ikscd)) \
							&& (activeseq = activepac.sequence))
							sequence = seqs.find { |seq|
								seq.seqnr == activeseq.seqnr
							}
						end
						sequence ||= seqs.find { |seq|
							(sd = seq.dose) && (pd = pack.dose) \
								&& (pd == sd || (sd.unit.to_s.empty? && sd.qty == pd.qty))
						}
						## assign a new sequence since none could be identified
						sequence ||= seqs.find { |seq|
							seq.packages.empty? || seq.dose.nil?
						}
						if(sequence.nil?) 
							sequence = seqs.first.dup
							reg.sequences.push(sequence)
						end
						if(activeseq && sequence.seqnr.nil?)
							sequence.seqnr = activeseq.seqnr
						end
						if(sequence.dose.nil?)
							sequence.dose = pack.dose
						end
						sequence.packages.store(pack.ikscd, pack)
					}
				end
			}
		end
		def parse_refdata_detail(str)
			ean = str[0,13]
			name = str[13..-1]
			if(/^7680[0-9]{9}$/.match(ean))
				pack = ParsedPackage.new
				pack.ikscd = ean[-4..-2,]
				mult, desc = nil
				if(mstring = name.slice!(ENDMULTI_PATTERN))
					mult, desc = mstring.split(/\s+/, 2)
					name.strip!
				end
				if(sstring = name.slice!(SIZE_PATTERN))
					qty = $2.to_i
					if($1)
						qty *= $1.to_i
					end
					unit = $3
					if(qty == 0)
						qty = 1
					end
					if(mstring = name.slice!(MULTI_PATTERN))
						mult ||= mstring.split(/\s+/, 2).first
					end
					if(mult)
						sstring = mult + ' x ' + sstring
						qty = qty.to_i * mult.to_i
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
					reg, seqs = pair
					(registrations[reg.iksnr] ||= reg).sequences.concat(seqs)
				end
			}
			registrations
		end
		def parse_worksheet_row(row)
			if((iksval = row_at(row, 1)) \
				 && /^[0-9]{3,5}(\.[0-9]+)?$/.match(iksval.to_s))
				reg = ParsedRegistration.new
				reg.iksnr = sprintf('%05i', iksval.to_i)
				reg.indication = row_at(row, 2)
				reg.ikscat = row_at(row, 3)
        ## missing as of 02/2008
        #reg.out_of_trade = row_at(row, 9) == 'x'
				reg.company = row_at(row, 9)
        if((date = row_at(row, 10)) && date.is_a?(Date))
          reg.expiration_date = date
        end
				seq = ParsedSequence.new
        if(atc = row_at(row, 11))
          seq.atc_class = atc.gsub(/[^A-Z0-9]/, '')
        end
        seqs = [seq]
        name = row_at(row, 0)
        if(match = /^(.*?)(\d+)\/(\d+)$/.match(name))
				  seq2 = seq.dup
          seq.name = match[1] + match[2]
          seq2.name = match[1] + match[3]
          seqs = [seq, seq2]
        else
          seq.name = name
        end
				[reg, seqs]
			end
		end
		def registrations_from_xls(path)
			workbook = Spreadsheet.open(path)
			registrations = parse_worksheet(workbook.worksheet(0))
			registrations.each_value { |reg|
				get_packages(reg, @app.registration(reg.iksnr))
			}
		end
		def report
			fmt = "%-14s %3i"
			['@created', '@updated', '@deactivated'].collect { |var|
				sprintf(fmt, var[1..-1].capitalize << ':', instance_variable_get(var).size)
			}.join("\n")
		end
		def row_at(row, index)
      row[index]
		end
    def update_atc_class(seq)
      if((code = seq.atc_class) \
         && !(atc = @app.atc_class(code)))
        begin
          atc = @app.create(Persistence::Pointer.new([:atc_class, code]))
        end while((code = atc.parent_code) && !@app.atc_class(code))
      end
    end
		def update_company(data)
			if((name = data.delete(:company)) && !name.empty?)
				company = @app.company_by_name(name)
				if(company.nil?)
					pointer = Persistence::Pointer.new(:company)
					company = @app.update(pointer.creator, {:name => name}, :swissmedic)
				end
				data.store(:company, company.pointer)
			end
		end
		def update_indication(data)
			if((text = data.delete(:indication)) && !text.empty?)
				indication = @app.indication_by_text(text)
				if(indication.nil?)
					pointer = Persistence::Pointer.new(:indication)
					indication = @app.update(pointer.creator, { 'de' => text}, :swissmedic)
				end
				data.store(:indication, indication.pointer)
			end
		end
		def update_package(pack, seq_pointer)
			pointer = seq_pointer + [:package, pack.ikscd]
      registration = seq_pointer.parent.resolve(@app)
      ## prevent the creation of duplicate ean-codes: if the package exists in 
      #  another sequence, it's probably been edited manually - use it.
      if(existing = registration.package(pack.ikscd))
        pointer = existing.pointer
      else
        pointer = pointer.creator
      end
			package = @app.update(pointer, {}, :swissmedic)
      ptr = if(part = package.parts.first)
              part.pointer
            else
              (package.pointer + :part).creator
            end
			@app.update(ptr, pack.data, :swissmedic)
      package
		end
		def update_registration(reg)
			data = reg.data
      data.store(:inactive_date, nil)
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
				@app.update(pointer, data, :swissmedic) unless(data.empty?)
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
					@app.update(pack.pointer, {:ikscat => ikscat}, :swissmedic)
				}
			end
		end
		def update_registrations(registrations)
      registrations.each_value { |reg|
        update_registration(reg)
      }
      @app.registrations.each_value { |reg|
        if(reg.vaccine && !@active.include?(reg.iksnr))
          @deactivated.push(reg.iksnr)
          @app.update(reg.pointer, {:inactive_date => @@today}, :swissmedic)
        end
      } unless @active.empty?
		end
		def update_sequence(seq, reg_pointer)
			pointer = reg_pointer + [:sequence, seq.seqnr]
      update_atc_class(seq)
			sequence = @app.update(pointer.creator, seq.data, :swissmedic)
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
				@app.update(pointer.creator, {'de' => substance_name}, :swissmedic)
			end
		end
	end
end
