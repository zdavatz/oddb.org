#!/usr/bin/env ruby
# SwissmedicJournalPlugin -- oddb -- 19.02.2003 -- hwyss@ywesee.com 

require 'date'
require 'plugin/plugin'
require 'swissmedicjournal/control'
require 'util/persistence'
require 'model/address'
require 'cgi'
require 'mechanize'

module ODDB
	class SwissmedicJournalPlugin < Plugin
		RECIPIENTS = [
			'matthijs.ouwerkerk@just-medical.com',
		]
    FLAGS = {
      :new							=>	'Neues Produkt',
      :productname			=>	'Namensänderung', 
      :address					=>	'Adresse',
      :ikscat						=>	'Abgabekategorie',
      :composition			=>	'Zusammensetzung', 
      :indication				=>	'Indikation',
      :sequence					=>	'Handelsform', 
      :expirydate				=>	'Ablaufdatum der Zulassung',
      :comment					=>	'Bemerkungen',
      :delete						=>	'Das Produkt wurde gelöscht',
    }
		def initialize(app)
			super
      @indications = []
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
								dose = [
									pseq.most_precise_dose,
									pseq.most_precise_unit,
								]
								values = {
									:dose				=>	dose,
								}
								if(name_base = pseq.name_base)
									values.store(:name_base, name_base)
                end
								@app.update(seq.pointer, values, :swissmedic)
							end
							if((comp = pseq.composition) \
								&& flags.include?(:composition))
								succ = update_active_agents(comp, seq.pointer)
							end
							if(flags.include?(:packages))
								succ = update_packages(pseq, seq, [])
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
    def mail_notifications
      salutations = {}
      flags = {}
      if((grp = @app.log_group(:swissmedic_journal)) && (log = grp.latest))
        all_flags = log.change_flags
        companies = all_flags.inject({}) { |memo, (pointer, flgs)|
          if((reg = pointer.resolve(@app)) && (cmp = reg.company) \
             && (email = cmp.swissmedic_email))
            salutations.store(email, cmp.swissmedic_salutation)
            flags.store(pointer, flgs)
            (memo[email] ||= []).push(reg)
          end
          memo
        }
        month = log.date
        date = month.strftime("%m/%Y")
        companies.each { |email, registrations|
          report = sprintf(<<-EOS, salutations[email], date)
%s

Bei den folgenden Produkten wurden Änderungen gemäss Swissmedic-Journal %s vorgenommen:
          EOS
          registrations.sort_by { |reg| reg.name_base.to_s }.each { |reg|
            report << sprintf("%s: %s\n%s\n\n", reg.iksnr,
                              resolve_link(reg.pointer), 
                              format_flags(flags[reg.pointer]))
          }
          mail = Log.new(month)
          mail.report = report
          mail.recipients = [email]
          mail.notify("Swissmedic-Journal")
        }
      end
    end
		def report
			atcless = @app.atcless_sequences.collect { |sequence|
				resolve_link(sequence.pointer)	
			}.sort
			lines = [
				"ODDB::SwissmedicJournalPlugin - Report #{@month}",
				"Updated Indications: #{@indications.size}",
				"Total Sequences without ATC-Class: #{atcless.size}",
				atcless,
			]
			lines.flatten.join("\n")
		end
		def update(month)
      filename = month.strftime('%m_%Y.pdf')
      target = File.join(ARCHIVE_PATH, 'pdf', filename)
      source = "http://www.swissmedic.ch/files/pdf/#{filename}"
      unless File.exist?(target)
        agent = WWW::Mechanize.new
        page = agent.get source
        page.save target
      end
      update_indications(target)
    rescue WWW::Mechanize::ResponseCodeError
		end
    def update_indications(path)
      @indications, news = DRbObject.new(nil, FIPARSE_URI).extract_indications(path)
      @indications.delete_if { |iksnr, text|
        if registration = @app.registration(iksnr)
          indication = update_indication(text)
          @app.update(registration.pointer, 
                      {:indication => indication.pointer}, :swissmedic)
          false
        else
          true
        end
      }
      log = @app.log_group(:swissmedic).latest
      news.each { |iksnr|
        pointer = Persistence::Pointer.new([:registration, iksnr])
        (log.change_flags[pointer] ||= []).push :indication
      }
      @app.update(log.pointer, {:change_flags => log.change_flags}, :swissmedic)
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
					:lt
				end
				hash = {
					language	=>	smj_seq.most_precise_galform
				}
				@app.update(galform_pointer.creator, hash, :swissmedic)
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
    def format_flags(flags)
      flags.delete(:revision)
      flags.collect { |flag|
        "- %s\n" % FLAGS.fetch(flag, "Unbekannt (#{flag})")
      }.compact.join
    end
		def prune_packages(smj_seq, sequence)
			packages = smj_seq.packages || []
			ikscds = packages.collect { |package| package.ikscd }
			sequence.packages.dup.each { |ikscd, package| 
				unless ikscds.include?(ikscd)
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
					prune_packages(smj_seq, sequence) unless(smj_reg.incomplete?)
				else
					@app.delete(sequence.pointer) 
				end
			}
		end
		def resolve_link(pointer)
			model = pointer.resolve(@app)
			super(model)
		end
		def smj_incomplete?(smj_reg)
			smj_reg.incomplete? || ((date = smj_reg.valid_until) && date.year < 2000)
				#&& smj_reg.iksnr.nil?
		end
		def update_active_agent(agent, seq_pointer, liberation)
			unless(agent.substance.nil?)
				# FIXME: agent.special and agent.spagyric should not be part of the
				#        substance-name. They are atm, because some products include
				#        more than one spagyric version of a substance and the pointer
				#        cannot handle that yet.
				#substance = [agent.substance, 
				#	agent.special, agent.spagyric].compact.join(' ')
				substance = agent.substance
				unless(@app.substance(substance))
					pointer = Persistence::Pointer.new([:substance, substance])
					@app.create(pointer)
				end
				pointer = seq_pointer + [:active_agent, substance]
				values = {
					:spagyric_dose => agent.spagyric,	
					:spagyric_type => agent.special,	
				}
        dkey = :dose
        if(liberation)
          values.store(:dose, liberation.split(/\s+/, 2))
          dkey = :chemical_dose
        end
				if(agent.dose)
					values.store(dkey, [agent.dose.qty, agent.dose.unit])
				end
				values.update(extract_agent(agent, :chemical))
				values.update(extract_agent(agent, :equivalent))
				@app.update(pointer.creator, values, :swissmedic)
			end
		end
		def update_active_agents(smj_composition, seq_pointer)
			agents = smj_composition.active_agents
			unless(agents.empty?)
        liberation = smj_composition.liberation if(agents.size == 1)
				created = agents.collect { |agent|
					update_active_agent(agent, seq_pointer, liberation)
				}
				seq = seq_pointer.resolve(@app)
				(seq.active_agents - created).each { |agent|
					@app.delete(agent.pointer)
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
			@app.update(pointer, hash, :swissmedic)
		end
		def update_indication(indication_name)
			indication = @app.indication_by_text(indication_name)
			if(indication.nil?)
				indication_pointer = Persistence::Pointer.new(:indication)
				indication_hash = {
					:la	=>	indication_name,
				}
				indication = @app.update(indication_pointer.creator, indication_hash, :swissmedic)
			end
			indication
		end
		def update_packages(smj_sequence, sequence, reg_flags=[])
      if(smj_packages = smj_sequence.packages)
        smj_packages.each { |package|
          pointer = sequence.pointer + [:package, package.ikscd]
          hash = {
            ## TODO: fix this, in case fix_from_source is ever used again
            #:size		=>	package.package_size,
            :descr  =>  nil, # delete the description, if not confirmed
          }
          if(ikscat = package.ikscat || sequence.registration.ikscat)
            hash.store(:ikscat, ikscat)
          end
          if(descr = package.description)
            hash.store(:descr, descr)
          end
          if(comform_name = smj_sequence.most_precise_comform)
            comform = CommercialForm.find_by_name(comform_name)
            if(comform.nil?)
              comform_ptr = Persistence::Pointer.new(:commercial_form)
              comform = @app.update(comform_ptr.creator, 
                                    {:de => comform_name})
            end
            hash.store(:commercial_form, comform.pointer)
          end
          if(reg_flags.include?(:new))
            hash.store(:refdata_override, true)
          end
          @app.update(pointer.creator, hash, :swissmedic)
        }
      end
		end
		def update_registration(smj_reg, pointer=nil)
			flags = smj_reg.flags
			if((iksnr = smj_reg.iksnr) && @app.registration(iksnr))
				flags.delete(:new)	
			end
			date_key = if(flags.include?(:new))
				:registration_date	
			else
				:revision_date
			end
			hash = {
				date_key			=>	smj_reg.last_update,
				:export_flag	=>	!!smj_reg.exportvalue,
				:source				=>	smj_reg.src,
				:index_therapeuticus => smj_reg.indexth,
				:ikscat				=>	smj_reg.ikscat,
        :renewal_flag =>  false,
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
			registration = @app.update(pointer.creator, hash, :swissmedic)
			if(!smj_incomplete?(smj_reg))
				prune_sequences(smj_reg, registration)
			end.push(registration.pointer)
			update_sequences(smj_reg, registration, flags)
			registration
		end
		def update_sequence(smj_seq, parent_pointer, reg_flags=[])
			pointer = parent_pointer + [:sequence, smj_seq.seqnr]
			hash = {}
			if(name_base = smj_seq.name_base)
        hash.store(:name_base,	name_base)
      end
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
			sequence = @app.update(pointer.creator, hash, :swissmedic)
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
					@app.update(sequence.pointer, hash, :swissmedic)
				end
			end
      update_packages(smj_seq, sequence, reg_flags)
		end
		def update_sequences(smj_reg, registration, reg_flags=[])
			smj_reg.products.each_value { |seq| 
				update_sequence(seq, registration.pointer, reg_flags)	
			}
		end
	end
end
