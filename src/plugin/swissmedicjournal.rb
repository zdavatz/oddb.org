#!/usr/bin/env ruby
# SwissmedicJournalPlugin -- oddb -- 19.02.2003 -- hwyss@ywesee.com 

require 'date'
require 'plugin/plugin'
require 'swissmedicjournal/control'
require 'util/persistence'
require 'model/address'
require 'cgi'

module ODDB
	class SwissmedicJournalPlugin < Plugin
		RECIPIENTS = [
			'matthijs.ouwerkerk@just-medical.com',
		]
		attr_reader :incomplete_pointers
		def initialize(app)
			super
			@ctrl = SwissmedicJournal::Control.new(ARCHIVE_PATH)
			@registration_pointers = []
			@incomplete_pointers = []
			@deactivated_pointers = []
			@incomplete_deactivations = []
			@pruned_sequences = 0
			@pruned_packages = 0
		end
		def fix_from_source(reg, *flags)
			if(src = reg.source)
				src.gsub!(/-\n/, '')
				preg = SwissmedicJournal::ActiveRegistration.new(src, :human)
				succ = false
				if(flags.include?(:all))
					preg.parse
					ptr = nil
					if(reg.is_a?(IncompleteRegistration))
						ptr = reg.pointer
					end
					update_registration(preg, ptr)
				else
					preg.parse.each { |seqnum, pseq|
						if(seq = reg.sequence(seqnum))
							if((ndose = pseq.name_dose) || !flags.include?(:dose_only))
								name_base = [
									pseq.name_base, 
									ndose, 
									pseq.name_descr,
								].compact.join(' ')
								dose = [
									pseq.most_precise_dose,
									pseq.most_precise_unit,
								]
								values = {
									:name_base	=>	name_base,
									:dose				=>	dose,
								}
								@app.update(seq.pointer, values)
							end
							if((comp = pseq.composition) \
								&& flags.include?(:composition))
								succ = update_active_agents(comp, seq.pointer)
							end
							if((pacs = pseq.packages) \
								&& flags.include?(:packages))
								succ = update_packages(pacs, seq)
							end
						end
					}
				end
				if(succ)
					reg.odba_store
				end
			end
		rescue Exception => exc
			puts exc.class
			puts exc.message
			puts exc.backtrace
			$stdout.flush
		end
		def log_info
			hash = super
			hash.store(:pointers, @incomplete_pointers)
			hash
		end
		def reconsider_deletions(month)
			name = month.strftime('%m_%Y.txt')
			path = File.join(ARCHIVE_PATH, 'txt', name)
			document = SwissmedicJournal::Document.new(File.read(path))
			document.each { |part|
				if(part.is_a?(SwissmedicJournal::InactiveRegistration))
					part.parse
					deactivate_registration(part)
				end
			}
			@incomplete_deactivations
		end
		def report
			reg_pointers = @registration_pointers.collect { |pointer|
				resolve_link(pointer)
			}.sort
			inc_pointers = @incomplete_pointers.collect { |pointer|
				resolve_link(pointer)
			}.sort
			atcless = @app.atcless_sequences.collect { |sequence|
				resolve_link(sequence.pointer)	
			}.sort

			deactivated = @deactivated_pointers.collect { |pointer|
				resolve_link(pointer)
			}.sort
			lines = [
				"ODDB::SwissmedicJournalPlugin - Report #{@month}",
				"Updated Registrations: #{reg_pointers.size}",
				"Incomplete Registrations: #{inc_pointers.size}",
				"Deactivated Registrations: #{deactivated.size}",
				"Incomplete Deactivations: #{@incomplete_deactivations.size}",
				"Pruned Sequences: #{@pruned_sequences}",
				"Pruned Packages: #{@pruned_packages}",
				"Total Sequences without ATC-Class: #{atcless.size}",
				nil, 
				"Updated Registrations: #{reg_pointers.size}",
				reg_pointers,
				"Incomplete Registrations: #{inc_pointers.size}",
				inc_pointers,
				"Deactivated Registrations: #{deactivated.size}",
				deactivated,
				"Incomplete Deactivations: #{@incomplete_deactivations.size}",
				@incomplete_deactivations,
				"Total Sequences without ATC-Class: #{atcless.size}",
				atcless,
			] #+ @ctrl.report.to_a
			lines.flatten.join("\n")
		end
		def update(month)
			@month = month
			regs = @ctrl.registrations(month)
			unless(regs.nil?)
				regs.each { |reg|
					case reg
					when SwissmedicJournal::ActiveRegistration
						update_registration(reg) if(reg.patient_type == :human)
					when SwissmedicJournal::InactiveRegistration
						deactivate_registration(reg)
					end
				}
				true
			else
				false
			end
		end
		private
		def accept_galenic_form?(pointer, smj_seq)
			galform = @app.galenic_form(smj_seq.most_precise_galform)
			seq = pointer.resolve(@app)
			result = !((seq && seq.galenic_form && !galform) \
				|| (seq && seq.galenic_form \
				&& (smj_seq.most_precise_galform != smj_seq.galform_name)))
			if(result && !galform)
				galform_pointer = Persistence::Pointer.new([:galenic_group, 1],[:galenic_form])
				language = if (smj_seq.most_precise_galform == smj_seq.galform_name)
					:de
				else
					:la
				end
				hash = {
					language	=>	smj_seq.most_precise_galform
				}
				@app.update(galform_pointer.creator, hash)
			end
			result
		end
		def extract_agent(agent, key)
			values = {}
			extract = agent.send(key)
			if(extract && extract.substance && !extract.substance.empty?)
				values.store([key, 'substance'].join('_').intern, extract.substance)
				if(@app.substance(extract.substance).nil?)
					pointer = Persistence::Pointer.new([:substance, extract.substance])
					@app.create(pointer)
				end
				if(dose = extract.dose)
					values.store([key, 'dose'].join('_').intern,[extract.dose.qty, extract.dose.unit])
				end
			end
			values
		end
		def deactivate_registration(smj_reg)
			unless(smj_reg.incomplete?)
				pointer = Persistence::Pointer.new([:registration, smj_reg.iksnr])
				date = smj_reg.date || Date.today
				@deactivated_pointers.push(pointer)
				@change_flags.store(pointer, smj_reg.flags)
				@app.update(pointer, {:inactive_date => date})
			else
				@incomplete_deactivations.push(smj_reg.src)
			end
		end
		def prune_packages(smj_seq, sequence)
			ikscds = smj_seq.packages.collect { |package| package.ikscd }
			sequence.packages.dup.each { |ikscd, package| 
				unless ikscds.include?(ikscd)
					@pruned_packages += 1
					pointer = sequence.pointer + [:package, ikscd]
					@app.delete(pointer) 
				end
			}
		end
		def prune_sequences(smj_reg, registration)
			seqnrs = smj_reg.products.keys
			registration.sequences.dup.each { |seqnr, sequence|
				if(seqnrs.include?(seqnr))
					smj_seq = smj_reg.products[seqnr]
					prune_packages(smj_seq, sequence) if smj_seq.packages
				else
					@pruned_sequences += 1
					@app.delete(sequence.pointer) 
				end
			}
		end
		def resolve_link(pointer)
			model = pointer.resolve(@app)
			str = if(model.respond_to?(:name_base)) 
				(model.name_base.to_s + ': ').ljust(50) 
			else
				''
			end
			str << 'http://www.oddb.org/de/gcc/resolve/pointer/' << CGI.escape(pointer.to_s) << ' '
		rescue Exception
			"Error creating Link for #{pointer.inspect}"
		end
		def smj_incomplete?(smj_reg)
			smj_reg.incomplete? #&& smj_reg.iksnr.nil?
		end
		def update_active_agent(agent, seq_pointer)
			unless(agent.substance.nil?)
				substance = [agent.substance, 
					agent.special, agent.spagyric].compact.join(' ')
				unless(@app.substance(substance))
					pointer = Persistence::Pointer.new([:substance, substance])
					@app.create(pointer)
				end
				pointer = seq_pointer + [:active_agent, substance]
				values = {
					:spagyric_dose => agent.spagyric,	
					:spagyric_type => agent.special,	
				}
				if(agent.dose)
					values.store(:dose, [agent.dose.qty, agent.dose.unit])
				end
				values.update(extract_agent(agent, :chemical))
				values.update(extract_agent(agent, :equivalent))
				@app.update(pointer.creator, values)
			end
		end
		def update_active_agents(smj_composition, seq_pointer)
			agents = smj_composition.active_agents
			unless(agents.empty?)
				seq = seq_pointer.resolve(@app)
				seq.active_agents.dup.each { |agent|
					@app.delete(agent.pointer)
				}
				# remove stragglers
				seq.active_agents.dup.each { |agent|
					puts "straggler: #{agent.pointer}"
					if(sub = agent.substance)
						sub.remove_sequence(seq)
						agent.odba_delete
						sub.sequences.delete_if { |sseq| sseq.odba_instance.nil? }
						sub.sequences.odba_store
					end
				}
				agents.each { |agent|
					update_active_agent(agent, seq_pointer)
				}
			end
		end
		def update_company(smj_company)
			pointer = if(company = @app.company_by_name(smj_company.name))
				company.pointer
			else
				Persistence::Pointer.new([:company]).creator
			end
			addr = Address2.new
			addr.address = smj_company.address
			addr.location = [smj_company.plz, smj_company.location].join(' ')
			hash = {
				:name				=>	smj_company.name,
				:addresses	=>	[addr],
			}
			@app.update(pointer, hash)
		end
		def update_indication(indication_name)
			indication = @app.indication_by_text(indication_name)
			if(indication.nil?)
				indication_pointer = Persistence::Pointer.new(:indication)
				indication_hash = {
					:la	=>	indication_name,
				}
				indication = @app.update(indication_pointer.creator, indication_hash)
			end
			indication
		end
		def update_packages(smj_packages, sequence)
			smj_packages.each { |package|
				pointer = sequence.pointer + [:package, package.ikscd]
				hash = {
					:ikscat	=>	package.ikscat,
					:size		=>	package.package_size,
				}
				if(descr = package.description)
					hash.store(:descr, descr)
				end
				@app.update(pointer.creator, hash)
			}
		end
		def update_registration(smj_reg, pointer=nil)
			date_key = if (smj_reg.flags == [:new])
				:registration_date	
			else
				:revision_date
			end
			hash = {
				date_key			=>	smj_reg.last_update,
				:export_flag	=>	smj_reg.exportvalue,
				:source				=>	smj_reg.src,
				:index_therapeuticus => smj_reg.indexth,
			}
			if(indication_name = smj_reg.indication)
				indication = update_indication(indication_name)
				hash.store(:indication, indication.pointer)
			end
			if(expiration = smj_reg.valid_until)
				hash.store(:expiration_date, expiration)
			end
			if(smj_company = smj_reg.company)
				company = update_company(smj_company)
				hash.store(:company, company.pointer)
			end
			args = if(smj_incomplete?(smj_reg) || pointer) 
				hash.store(:errors, smj_reg.errors)
				hash.store(:iksnr, smj_reg.iksnr)
				:incomplete_registration
			else
				[:registration, smj_reg.iksnr]
			end
			pointer ||= Persistence::Pointer.new(args)
			registration = @app.update(pointer.creator, hash)
			if(smj_incomplete?(smj_reg))
				@incomplete_pointers
			else
				prune_sequences(smj_reg, registration)
				@change_flags.store(registration.pointer, smj_reg.flags)
				@registration_pointers
			end.push(registration.pointer)
			update_sequences(smj_reg, registration)
			registration
		end
		def update_sequence(smj_seq, parent_pointer)
			pointer = parent_pointer + [:sequence, smj_seq.seqnr]
			hash = {}
			name_base = [
				smj_seq.name_base, 
				smj_seq.name_dose, 
				smj_seq.name_descr,
			].compact.join(' ')
			hash.store(:name_base,	name_base) unless name_base.empty?
			if(galform = smj_seq.galform_name)
				hash.store(:name_descr, galform)
			end
			if((galform = smj_seq.most_precise_galform) \
				&& accept_galenic_form?(pointer, smj_seq))
				hash.store(:galenic_form, galform)
			end
			dose = [
				smj_seq.most_precise_dose,
				smj_seq.most_precise_unit,
			]#.compact.join(' ').strip
			hash.store(:dose, dose) unless dose.compact.empty?
			sequence = @app.update(pointer.creator, hash)
			if(composition = smj_seq.composition)
				update_active_agents(composition, pointer)
			end
			if(sequence.atc_class.nil?)
				code = nil
				atcs = sequence.registration.sequences.values.collect { |other| other.atc_class }.compact
				if(atc = atcs.first)
					code = atc.code
				elsif(sequence.active_agents.size == 1) 
					key = sequence.active_agents.first.substance.to_s
					if(atc = @app.unique_atc_class(key))
						code = atc.code
					end
				end
				if(code)
					hash = {
						:atc_class => code,
					}	
					@app.update(sequence.pointer, hash)
				end
			end
			if(packages = smj_seq.packages)
				update_packages(packages, sequence)
			end
		end
		def update_sequences(smj_reg, registration)
			smj_reg.products.each_value { |seq| 
				update_sequence(seq, registration.pointer)	
			}
		end
	end
end
