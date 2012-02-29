#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Sequence -- oddb.org -- 29.02.2012 -- mhatakeyama@ywesee.com 
# ODDB::Sequence -- oddb.org -- 24.02.2003 -- hwyss@ywesee.com 

require 'util/persistence'
require 'model/package'
require 'model/dose'
require 'model/composition'

module ODDB
  module Migel
    class Item
      # This is necessary because maybe some old migel item object remain somewhere in the cache
    end
  end
	class SequenceCommon
		include Persistence
    class << self
      include AccessorCheckMethod
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
    check_accessor_list = {
      :registration => "ODDB::Registration",
      :atc_class => "ODDB::AtcClass",
      :export_flag => ["NilClass","FalseClass","TrueClass"],
      :patinfo => "ODDB::Patinfo",
      :pdf_patinfo => "String",
      :atc_request_time => "Time",
      :deactivate_patinfo => ["NilClass","Date"],
      :sequence_date => ["NilClass", "Date"],
      :activate_patinfo => ["NilClass","Date"],
      :composition_text => "String",
      :dose => ["NilClass","ODDB::Dose"],
      #:inactive_date => "Date",
    }
    define_check_class_methods check_accessor_list
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
			if(active? && (generic_type.nil? || @registration.generic_type == generic_type))
        if @packages.is_a?(Hash)
          @packages.values.inject(0) { |count, pack|
            if(pack.active?)
              count += 1
            end
            count
          }
        end
			else
				0
			end
		end
    ## active_patinfo is used for invoicing. Returns path to a pdf file, iff it
    #  is displayed online.
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
      nb = @name_base.to_s[/^.[^0-9]+/u]
      nb.force_encoding('utf-8') if nb
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
      @compositions.collect { |comp| 
        comp.galenic_form if comp.respond_to?(:galenic_form)
      }.compact.uniq
    end
    def has_patinfo?
      (!@patinfo.nil? || !@pdf_patinfo.nil?) && patinfo_active? \
        && !company.disable_patinfo
    end
    def has_public_packages?
      if @packages.is_a?(Hash)
        @packages.any? { |key, pac|
          pac.public?
        }
      end
    end
		def indication
			@indication || @registration.indication if @registration
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
		def name
      @name_base.force_encoding('utf-8') if @name_base
      @name_descr.force_encoding('utf-8') if @name_descr
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
      unless ikscd.is_a?(SBSM::InvalidDataError)
        if @packages.is_a?(Hash)
          @packages[sprintf('%03d', ikscd.to_i)]
        end
      end
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
			if(public? and @packages.is_a?(Hash)) 
				@packages.values.select { |pac| pac.public? }
			else
				[]
			end
		end
		def public_package_count(generic_type=nil)
			if(public? && (generic_type.nil? \
				|| @registration.generic_type == generic_type))
        count = 0
        if @packages.is_a?(Hash)
          @packages.values.each { |pack|
            if(pack.public?)
              count += 1
            end
          }
        end
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
			#str = self.name.force_encoding('utf-8')
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
			values.dup.each { |key, value|
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
      super(atc_class)
			unless(atc_class.nil?)
				@atc_class = replace_observer(@atc_class, atc_class)
			end
		end
		def patinfo=(patinfo)
      super(patinfo)
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
      @composition_text.force_encoding('utf-8') if @composition_text
    end
	end
end
