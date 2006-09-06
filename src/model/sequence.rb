#!/usr/bin/env ruby
# Sequence -- oddb -- 24.02.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'model/package'
require 'model/dose'
require 'model/activeagent'

module ODDB
	class SequenceCommon
		include Persistence
		attr_reader :seqnr, :name_base, :name_descr, :packages,
								:active_agents
		attr_accessor :registration, :dose, :atc_class, :export_flag,
									:galenic_form, :patinfo, :pdf_patinfo, :atc_request_time
		attr_writer :composition_text, :inactive_date
		alias :pointer_descr :seqnr
		def initialize(seqnr)
			@seqnr = sprintf('%02d', seqnr.to_i)
			@packages = {}
			@active_agents = []
		end
		def active_packages
			if(active?) 
				@packages.values.select { |pac| pac.active? }
			else
				[]
			end
		end
		def active_package_count(generic_type=nil)
			if(active? && (generic_type.nil? \
				|| @registration.generic_type == generic_type))
				@packages.values.inject(0) { |count, pack|
					if(pack.active?)
						count += 1
					end
					count
				}
			else
				0
			end
		end
		def active?
			(!@inactive_date || (@inactive_date > @@two_years_ago)) \
				&& @registration && @registration.active? && !violates_patent?
		end
		def active_agent(substance_or_oid, spag=nil)
			@active_agents.find { |active| active.same_as?(substance_or_oid, spag) }
		end
		def basename
			@name_base.to_s[/^.[^0-9]+/]
		end
		def checkout
			checkout_helper([@atc_class, @galenic_form, @patinfo], 
				:remove_sequence)
			@packages.each_value { |pac| 
				pac.checkout 
				pac.odba_delete
			}
			@active_agents.dup.each { |act| 
				act.checkout 
				act.odba_delete
			}
		end
		def company
			@registration.company
		end
		def company_name
			@registration.company_name
		end
		def comparables
			if(@atc_class)
				@atc_class.sequences.select { |seq|
					comparable?(seq)
				}
			else
				[]
			end
		end
		def comparable?(seq)
			seq != self \
				&& seq.active? \
				&& !seq.galenic_form.nil? \
				&& seq.galenic_form.equivalent_to?(@galenic_form) \
				&& (seq.active_agents.sort == @active_agents.sort)
		end
		def composition_text
			@composition_text || @active_agents.collect { |agent| 
				agent.to_s 
			}.join(', ')
		end
		def create_active_agent(substance_name)
			active = active_agent(substance_name)
			return active unless active.nil?
			active = self::class::ACTIVE_AGENT.new(substance_name)
			active.sequence = self
			@active_agents.push(active)
			active
		end
		def create_package(ikscd)
			ikscd = sprintf('%03d', ikscd.to_i)
			unless @packages.include?(ikscd)
				pkg = self::class::PACKAGE.new(ikscd)
				pkg.sequence = self
				@packages.store(ikscd, pkg) 
			end
		end
		def delete_active_agent(substance)
			if(active = active_agent(substance))
				@active_agents.delete(active)
				@active_agents.odba_isolated_store
				active
			end
		end
		def delete_package(ikscd)
			ikscd = sprintf('%03d', ikscd.to_i)
			if(pac = @packages.delete(ikscd))
				@packages.odba_isolated_store
				pac
			end
		end
		def each_package(&block)
			@packages.values.each(&block)
		end
		def expired?
			@registration.expired?
		end
		def fachinfo
			@registration.fachinfo
		end
		def generic_type
			@registration.generic_type
		end
		def has_patinfo?
			(!@patinfo.nil? || !@pdf_patinfo.nil?) && !company.disable_patinfo
		end
    def has_public_packages?
      @packages.any? { |key, pac|
        pac.public?
      }
    end
		def iksnr
			@registration.iksnr
		end
		def indication
			@registration.indication
		end
		def localized_name(language)
			self.name
		end
		def match(query)
			/#{query}/i.match(@name_base)
		end
		def name
			[@name_base, @name_descr].compact.join(', ')
		end
		alias :to_s :name
		def name=(name)
			self.name_base, self.name_descr = name.split(',', 2)
		end
		def name_base=(name_base)
			@name_base = nil_if_empty(name_base)
		end
		def name_descr=(name_descr)
			@name_descr = nil_if_empty(name_descr)
		end
    def out_of_trade
			@packages.all? { |key, pac|
        pac.out_of_trade
			}
    end
		def package(ikscd)
			@packages[sprintf('%03d', ikscd.to_i)]
		end
		def package_count
			@packages.length
		end
		def public_packages
			active_packages.select { |pac| pac.public? }
		end
		def public_package_count(generic_type=nil)
			if(active? && (generic_type.nil? \
				|| @registration.generic_type == generic_type))
        count = 0
				@packages.values.each { |pack|
					if(pack.public?)
						count += 1
					end
				}
        count
			else
				0
			end
		end
		def limitation_text
			@packages.each_value { |package|
				if(txt = package.limitation_text)
					return txt
				end
			}
			nil
		end
		def limitation_text_count
			@packages.values.select { |package|
				package.limitation_text
			}.size
		end
		def patent_protected?
			@registration.patent_protected? if(@registration)
		end
		def search_terms
			str = self.name
			ODDB.search_terms(str.split(/\s+/).push(str))
		end
		def seqnr=(seqnr)
			## FIXME: this is just a quick spaghetti-hack to get all data correct
			if(/^[0-9]{2}$/.match(seqnr) \
				&& @registration.sequence(seqnr).nil?)
				seqs = @registration.sequences
				seqs.delete(@seqnr)
				seqs.store(seqnr, self)
				seqs.odba_store
				@pointer = @registration.pointer + [:sequence, seqnr]
				self.odba_store
				@packages.each { |ikscd, package|
					ppointer = @pointer + [:package, ikscd]
					package.pointer = ppointer
					if(sl = package.sl_entry)
						sl.pointer = ppointer + [:sl_entry]
						sl.odba_store
					end
					package.feedbacks.each { |id, fb|
						fb.pointer = ppointer + [:feedback, id]
						fb.odba_store
					}
					package.odba_store
				}
				@active_agents.each { |agent|
					agent.pointer = @pointer + [:active_agent, agent.substance.to_s]
					agent.odba_store
				}
				@seqnr = seqnr
				odba_store
			end
		end
		def source
			@registration.source
		end
		def substances
			@active_agents.collect { |agent| 
				agent.substance
			}
		end
		def substance_names
			substances.collect { |subst| subst.to_s }
		end
		def violates_patent?
			@atc_class && @registration.may_violate_patent?	\
				&& @atc_class.sequences.any? { |seq| 
				seq.patent_protected? && seq.company != @registration.company
			}
		end
		private
		def adjust_types(values, app=nil)
			values = values.dup
			values.each { |key, value|
				if(value.is_a?(Persistence::Pointer))
					values[key] = value.resolve(app)
				else
					case(key)
					when :atc_class
						values[key] = if(atc = app.atc_class(value))
							atc
						else
							@atc_class
						end
					when :dose
						values[key] = if(value.is_a? Dose)
							value
						elsif(value.is_a?(Array))
							Dose.new(*value)
						end
					when :galenic_form
						values[key] = if(galform = app.galenic_form(value))
							galform
						else
							@galenic_form
						end
					when :inactive_date
						if(value.is_a?(String))
							hash.store(key, Date.parse(value.tr('.', '-')))
						end
					end 
				end
			}
			values
		end
	end
	class Sequence < SequenceCommon
		attr_accessor :patinfo_shadow
		ACTIVE_AGENT = ActiveAgent
		ODBA_PREFETCH = true
		PACKAGE = Package
		def atc_class=(atc_class)
			unless(atc_class.nil?)
				@atc_class = replace_observer(@atc_class, atc_class)
			end
		end
		def galenic_form=(galform)
			@galenic_form = replace_observer(@galenic_form, galform)
		end
		def patinfo=(patinfo)
			@patinfo = replace_observer(@patinfo, patinfo)
		end
		def	replace_observer(target, value)
			if(target.respond_to?(:remove_sequence))
				target.remove_sequence(self)
			end
			if(value.respond_to?(:add_sequence))
				value.add_sequence(self)
			end
			target = value
		end	
	end
	class IncompleteSequence < SequenceCommon
		ACTIVE_AGENT = IncompleteActiveAgent
		PACKAGE = IncompletePackage
		def acceptable?
			_acceptable? && !@active_agents.empty? \
			&& @packages.all? { |key, val|
				val.acceptable?
			}
		end
		def _acceptable?
			@atc_class && @name_base && @galenic_form
		end
		def accepted!(app, reg_pointer)
			reg = reg_pointer.resolve(app)
			seq = reg.sequence(@seqnr)
			galform = if(@galenic_form && ((@galenic_form.galenic_group.oid > 1) \
																			|| seq.nil? || seq.galenic_form.nil?))
									@galenic_form.pointer
								end
			ptr = reg_pointer + [:sequence, @seqnr]
			hash = {
				:name_base				=>	@name_base,
				:name_descr				=>	@name_descr,
				:dose							=>	@dose,
				:atc_class				=>	(@atc_class.code if @atc_class), 
				:galenic_form			=>	galform,
				:composition_text	=>	@composition_text,
			}.delete_if { |key, val| val.nil? }
			app.update(ptr.creator, hash)
			@packages.each_value { |pack|
				pack.accepted!(app, ptr)
			}
			@active_agents.each { |agent|
				agent.accepted!(app, ptr)
			} 
		end
		def fill_blanks(sequence)
			scalars = [	:name_base, :name_descr, :dose, :galenic_form, 
				:atc_class ].select { |key|
				if(self.send(key).to_s.empty?)
					self.send("#{key}=", sequence.send(key))
				end
			}
			sequence.packages.each { |ikscd, pac|
				npac = @packages.fetch(ikscd) { 
					npac = create_package(ikscd)
					npac.pointer = @pointer + [:package, ikscd]
					npac
				}
				npac.fill_blanks(pac)
			}
			sequence.active_agents.each { |agent|
				if(sub = agent.substance)
					name = sub.name
					nagent = create_active_agent(name)
					nagent.pointer = @pointer + [:active_agent, name]
					nagent.fill_blanks(agent)
				end
			}
			scalars
		end
	end
end
