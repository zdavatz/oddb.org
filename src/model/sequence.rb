#!/usr/bin/env ruby
# Sequence -- oddb -- 24.02.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'model/package'
require 'model/dose'
require 'model/composition'

module ODDB
	class SequenceCommon
		include Persistence
    class << self
      def registration_data(*names)
        names.each { |name|
          define_method(name) {
            @registration && @registration.send(name)
          }
        }
      end
    end
		attr_reader :seqnr, :name_base, :name_descr, :packages,
								:compositions, :longevity
    attr_accessor :registration, :atc_class, :export_flag,
                  :patinfo, :pdf_patinfo, :atc_request_time,
                  :deactivate_patinfo, :sequence_date, :activate_patinfo
		attr_writer :composition_text, :dose, :inactive_date
		alias :pointer_descr :seqnr
    registration_data :company, :company_name, :complementary_type, :expired?,
      :fachinfo, :fachinfo_active?, :generic_type, :has_fachinfo?, :iksnr,
      :minifi, :patent_protected?, :source
		def initialize(seqnr)
			@seqnr = sprintf('%02d', seqnr.to_i)
			@packages = {}
			@compositions = []
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
    def active_patinfo
      active? && patinfo_active? && @pdf_patinfo
    end
		def active?
			(!@inactive_date || (@inactive_date > @@two_years_ago)) \
				&& @registration && @registration.active? && !violates_patent?
		end
    def active_agents
      @compositions.inject([]) { |acts, comp|
        acts.concat comp.active_agents
      }
    end
		def basename
			@name_base.to_s[/^.[^0-9]+/u]
		end
		def checkout
			checkout_helper([@atc_class, @patinfo], :remove_sequence)
			@packages.each_value { |pac| 
				pac.checkout 
				pac.odba_delete
			}
      @packages.odba_delete
			@compositions.dup.each { |comp| 
				comp.checkout 
				comp.odba_delete
			}
      @compositions.odba_delete
		end
		def comparables(factor = 1.0)
			if(@atc_class)
        comps = factored_compositions(factor)
				@atc_class.sequences.select { |seq|
					comparable?(seq, factor, comps)
				}
			else
				[]
			end
		end
		def comparable?(seq, factor = 1.0, comps = nil)
      comps ||= factored_compositions(factor)
			seq != self \
				&& seq.active? \
        && seq.compositions.sort == comps
		end
    def composition(oid)
      @compositions.find { |comp| comp.oid == oid }
    end
    def create_composition
      comp = Composition.new
      comp.sequence = self
      @compositions.push comp
      comp
    end
		def create_package(ikscd)
			ikscd = sprintf('%03d', ikscd.to_i)
			unless @packages.include?(ikscd)
				pkg = self::class::PACKAGE.new(ikscd)
				pkg.sequence = self
				@packages.store(ikscd, pkg) 
			end
		end
    def delete_composition(oid)
      @compositions.delete_if { |comp| comp.oid == oid }
    end
		def delete_package(ikscd)
			ikscd = sprintf('%03d', ikscd.to_i)
			if(pac = @packages.delete(ikscd))
				@packages.odba_isolated_store
				pac
			end
		end
    def dose # simulate the legacy attribute_reader for dose
      doses.inject { |a,b| a + b }
    rescue
    end
		def doses
			@compositions.inject([]) { |doses, comp|
				doses.concat comp.doses
			}
		end
		def each_package(&block)
			@packages.values.each(&block)
		end
    def factored_compositions(factor=1.0)
      comps = @compositions.sort
      if factor != 1.0
        comps = comps.collect do |comp| comp * factor end
      end
      comps
    end
    def fix_pointers
      @pointer = @registration.pointer + [:sequence, @seqnr]
      @packages.each_value { |package|
        package.fix_pointers
      }
      @compositions.each { |comp|
        comp.fix_pointers
      }
      odba_store
    end
    def galenic_group
      groups = galenic_groups
      groups.first if groups.size == 1
    end
    def galenic_groups
      @compositions.collect { |comp| comp.galenic_group }.compact.uniq
    end
    def galenic_forms
      @compositions.collect { |comp| comp.galenic_form }.compact.uniq
    end
    def has_patinfo?
      (!@patinfo.nil? || !@pdf_patinfo.nil?) && patinfo_active? \
        && !company.disable_patinfo
    end
    def has_public_packages?
      @packages.any? { |key, pac|
        pac.public?
      }
    end
		def indication
			@indication || @registration.indication
		end
    def indication=(indication)
      @indication = replace_observer(@indication,indication)
    end
		def localized_name(language)
			self.name
		end
		def match(query)
			/#{query}/iu.match(@name_base)
		end
    def _migrate_to_compositions(app)
      unless @compositions
        @compositions = []
        ptr = @pointer + :composition
        comp = create_composition
        comp.pointer = ptr
        comp.init app
        comp.instance_variable_set '@active_agents', @active_agents
        remove_instance_variable '@active_agents' if @active_agents
        comp.galenic_form = @galenic_form
        remove_instance_variable '@galenic_form' if @galenic_form
        comp.fix_pointers
        @compositions.odba_store
        @packages.each_value { |pac| pac._migrate_to_parts(app) }
        odba_store
      end
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
    def patinfo_active?
      (@deactivate_patinfo.nil? || @deactivate_patinfo > @@today) \
        && (@activate_patinfo.nil? || @activate_patinfo <= @@today)
    end
    def public?
      !@export_flag && @registration.public? && active?
    end
		def public_packages
			if(public?) 
				@packages.values.select { |pac| pac.public? }
			else
				[]
			end
		end
		def public_package_count(generic_type=nil)
			if(public? && (generic_type.nil? \
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
    def longevity=(days)
      days = days.to_i
      @longevity = (days > 1) ? days : nil
    end
    def route_of_administration
      roas = @compositions.collect { |comp| 
        comp.route_of_administration 
      }.compact.uniq
      roas.first if(roas.size == 1)
    end
		def search_terms
			str = self.name
			ODDB.search_terms(str.split(/\s+/u).push(str))
		end
		def seqnr=(seqnr)
			## FIXME: this is just a quick spaghetti-hack to get all data correct
			if(/^[0-9]{2}$/u.match(seqnr) \
				&& @registration.sequence(seqnr).nil?)
				seqs = @registration.sequences
				seqs.delete(@seqnr)
				seqs.store(seqnr, self)
				seqs.odba_store
				@seqnr = seqnr
        fix_pointers
			end
		end
		def substances
			@compositions.inject([]) { |subs, comp| 
				subs.concat comp.substances
			}.uniq
		end
		def substance_names
			substances.collect { |subst| subst.to_s }
		end
		def violates_patent?
			@atc_class && @registration.may_violate_patent?	\
				&& @atc_class.sequences.any? { |seq| 
				seq.patent_protected? && seq.company != @registration.company \
          && _violates_patent?(seq)
			}
		end
    def _violates_patent?(seq)
      other = seq.active_agents
      agents = active_agents
      other.size == agents.size or return false
      other = other.sort 
      agents = agents.sort
      other.each_with_index { |oth, idx|
        agt = agents.at(idx)
        oth.substance == agt.substance or return false
        oth.chemical_substance == agt.chemical_substance or return false
      }
      true
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
					when :inactive_date, :sequence_date
						if(value.is_a?(String))
							values.store(key, Date.parse(value.tr('.', '-')))
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
    def composition_text
      @composition_text || @packages.collect { |cd, pac|
        (src = pac.swissmedic_source) && src[:composition] 
      }.compact.first
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
			@atc_class && @name_base
		end
		def accepted!(app, reg_pointer)
			reg = reg_pointer.resolve(app)
			seq = reg.sequence(@seqnr)
			ptr = reg_pointer + [:sequence, @seqnr]
			hash = {
				:name_base				=>	@name_base,
				:name_descr				=>	@name_descr,
				:dose							=>	@dose,
				:atc_class				=>	(@atc_class.code if @atc_class), 
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
			scalars = [	:name_base, :name_descr, :dose,
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
