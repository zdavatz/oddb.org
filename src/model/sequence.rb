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
		attr_accessor :registration, :dose, :atc_class, 
									:galenic_form, :patinfo, :pdf_patinfo
		attr_writer :composition_text
		alias :pointer_descr :seqnr
		def initialize(seqnr)
			@seqnr = sprintf('%02d', seqnr.to_i)
			@packages = {}
			@active_agents = []
		end
		def active_packages
			(active?) ? @packages.values : []
		end
		def active_package_count(generic_type=nil)
			if(active? && (generic_type.nil? \
				|| @registration.generic_type == generic_type))
				@packages.size
			else
				0
			end
		end
		def active?
			@registration.active?
		end
		def active_agent(substance)
			@active_agents.each { |active|
				if(active.same_as?(substance))
					return active
				end
			}
			nil
		end
		def checkout
			checkout_helper([@atc_class, @galenic_form], :remove_sequence)
			@packages.each_value { |pac| 
				pac.checkout 
				pac.odba_delete
			}
			@active_agents.each { |act| 
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
			active = active_agent(substance)
			@active_agents.delete(active)
		end
		def delete_package(ikscd)
			ikscd = sprintf('%03d', ikscd.to_i)
			@packages.delete(ikscd)
		end
		def each_package(&block)
			@packages.each_value(&block)
		end
		def generic_type
			@registration.generic_type
		end
		def iksnr
			@registration.iksnr
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
		def package(ikscd)
			@packages[sprintf('%03d', ikscd.to_i)]
		end
		def package_count
			@packages.length
		end
		def limitation_text_count
			@packages.values.select { |package|
				package.limitation_text
			}.size
		end
		def search_terms
			self.name.split(/\s+/).push(self.name).uniq.delete_if { |term| 
				term.empty? 
			}
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
			unless(@patinfo.nil?)
				@patinfo_oid = @patinfo.oid
			end
			@patinfo
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
			@atc_class && @name_base
		end
		def accepted!(app, reg_pointer)
			ptr = reg_pointer + [:sequence, @seqnr]
			hash = {
				:name_base				=>	@name_base,
				:name_descr				=>	@name_descr,
				:dose							=>	@dose,
				:atc_class				=>	(@atc_class.code if @atc_class), 
				:galenic_form			=>	(@galenic_form.pointer if @galenic_form),
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
	end
end
