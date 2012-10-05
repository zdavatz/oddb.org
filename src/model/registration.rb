#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Registration -- oddb.org -- 04.10.2012 -- yasaka@ywesee.com
# ODDB::Registration -- oddb.org -- 29.02.2012 -- mhatakeyama@ywesee.com 
# ODDB::Registration -- oddb.org -- 24.02.2003 -- hwyss@ywesee.com 

require 'date'
require 'util/persistence'
require 'model/sequence'
require 'model/patent'
require 'util/today'

module ODDB
	class RegistrationCommon
		include Persistence
    class << self
      include AccessorCheckMethod
    end
		attr_reader :iksnr, :sequences, :patent
		attr_writer :generic_type, :complementary_type
		attr_accessor :registration_date, :export_flag, :company, 
			:revision_date, :indication, :expiration_date, :inactive_date,
      :manual_inactive_date, :deactivate_fachinfo, :activate_fachinfo,
			:market_date, :fachinfo, :source, :ikscat, :renewal_flag, #:pdf_fachinfos,
      :renewal_flag_swissmedic,
      :index_therapeuticus, :comarketing_with, :vaccine, :ignore_patent,
      :parallel_import, :minifi, :product_group, :production_science,
      :ith_swissmedic, :keep_generic_type
    check_accessor_list = {
      :generic_type => "Symbol",
      :complementary_type => "Symbol",
      :registration_date => ["DateTime","Date"],
      :export_flag => ["FalseClass","NilClass","TrueClass"],
      :company => ["ODDB::Company"],
      :revision_date => "Date",
      :indication => "ODDB::Indication",
      :expiration_date => "Date",
      :inactive_date => "Date",
      :manual_inactive_date => "Date",
      :deactivate_fachinfo => "Date",
      :activate_fachinfo => "Date",
      :market_date => "Date",
      :fachinfo => "ODDB::Fachinfo",
      :source => "String",
      :ikscat => "String",
      :renewal_flag => ["NilClass","FalseClass","TrueClass"],
      :renewal_flag_swissmedic => ["NilClass","FalseClass","TrueClass"],
      :index_therapeuticus => "String",
      :comarketing_with => "ODDB::Registration",
      :vaccine => ["TrueClass","NilClass","FalseClass"],
      :ignore_patent => ["NilClass","TrueClass","FalseClass"],
      :parallel_import => ["NilClass","TrueClass","FalseClass"],
      :minifi => "ODDB::MiniFi",
      :product_group => "String",
      :production_science => "String",
      :ith_swissmedic => "String",
      :keep_generic_type => ["NilClass","TrueClass","FalseClass"],
    }
    define_check_class_methods check_accessor_list
		alias :pointer_descr :iksnr
		SEQUENCE = Sequence
		def initialize(iksnr)
			@iksnr = iksnr
			@sequences = {}
		end
		def active?(cutoff=@@two_years_ago)
			!inactive? \
				&& (!@expiration_date || @expiration_date > cutoff || @renewal_flag) \
				&& (!@market_date || @market_date <= @@today) 
		end
    def active_packages
      if active?
        @sequences.values.inject([]) do |memo, seq|
          memo.concat seq.active_packages
        end
      else
        []
      end
    end
		def active_package_count
			if(active?)
				@sequences.values.inject(0) { |inj, seq|
					inj + seq.active_package_count
				}
			else
				0
			end
		end
		def atc_classes
      if @sequences
        @sequences.values.collect { |seq|
          seq.atc_class if seq.respond_to?(:atc_class)
        }.compact.uniq
      end
		end
		def atcless_sequences
			@sequences.values.select { |seq|
				seq.atc_class.nil?
			}
		end
		def checkout
			checkout_helper([@company, @indication, @fachinfo], 
				:remove_registration)
			@sequences.each_value { |seq| 
				seq.checkout 
				seq.odba_delete
			}
			@sequences.odba_delete
		end
		def company_name
			@company.name if @company
		end
		def complementary_type
			@complementary_type || if(@company)
				@company.complementary_type
			end
		end
    def compositions
      @sequences.sort.inject([]) { |memo, (seqnr, seq)| 
        memo.concat seq.compositions
      }
    end 
		def create_patent
			@patent = Patent.new
		end
		def create_sequence(seqnr)
			seq = self::class::SEQUENCE.new(seqnr)
			unless @sequences.include?(seq.seqnr)
				seq.registration = self
				@sequences.store(seq.seqnr, seq)
			end
		end
		def delete_patent
			@patent = nil
		end
		def delete_sequence(seqnr)
			seqnr = sprintf('%02d', seqnr.to_i)
			if(seq = @sequences.delete(seqnr))
				@sequences.odba_isolated_store
				seq
			end
		end
		def each_package(&block)
      unless @sequences.is_a?(NilClass)
        @sequences.each_value { |seq|
          seq.each_package(&block)
        }
      end
		end
    def each_sequence(&block)
      unless @sequences.is_a?(NilClass)
        @sequences.values.each(&block)
      end
    end
		def expired?
			inactive? \
				|| (!@renewal_flag && @expiration_date && @expiration_date <= @@today)
		end
    def fachinfo_active?
      @fachinfo && (@deactivate_fachinfo.nil? || @deactivate_fachinfo > @@today) \
        && (@activate_fachinfo.nil? || @activate_fachinfo <= @@today)
    end
		def generic?
			self.generic_type == :generic
		end
		def generic_type # This is old value. Pleas use Package#sl_generic_type
			@generic_type || if(@company and @company.respond_to?(:generic_type))
				@company.generic_type
			end
		end
    def has_fachinfo?
      !@fachinfo.nil?
    end
    def ignore_patent?
      !!@ignore_patent
    end
    def inactive?
      (date = @manual_inactive_date || @inactive_date) && date <= @@today
    end
		def limitation_text_count
			@sequences.values.inject(0) { |inj, seq|			
				inj + seq.limitation_text_count
			}
		end
    def localized_name(lang)
      if(seq = @sequences.values.first)
        seq.localized_name(lang)
      end
    end
		def may_violate_patent?
			# we are making the assumption that no generic registration will be
			# created more than a year before the original's patent protection 
			# expires. Registrations where the @registration_date is not known can 
			# be considered old enough to fall out of consideration for 
			# patent violation
			!@ignore_patent && @registration_date \
				&& !@comarketing_with \
				&& (@generic_type != :original) \
				&& (@registration_date > @@one_year_ago)
		end
		def name_base
			if(@sequences.respond_to?(:values) and seq = @sequences.values.first)
				seq.name_base
			end
		end
		def original?
			self.generic_type == :original
		end
    def out_of_trade
			@sequences.all? { |key, seq|
        seq.out_of_trade
			}
    end
    def package(ikscd)
      if @sequences
        @sequences.each_value { |seq|
          if package = seq.package(ikscd)
            return package
          end
        }
      end
      nil
    end
		def package_count
			@sequences.values.inject(0) { |inj, seq|
				inj + seq.package_count
			}
		end
    def packages
      @sequences.values.inject([]) { |memo, seq|
        memo.concat(seq.packages.values)
      }
    end
		def patent_protected?
			@patent && @patent.protected?
			#@patented_until && (@patented_until >= @@today)
		end
    def public?(cutoff=@@two_years_ago)
      !@export_flag && active?(cutoff)
    end
		def public_package_count
			if(active?)
				@sequences.values.inject(0) { |inj, seq|
					inj + seq.public_package_count
				}
			else
				0
			end
		end
    def sequence(seqnr)
      if !seqnr.is_a?(SBSM::InvalidDataError) and
         @sequences.is_a?(Hash)
        @sequences[sprintf('%02d', seqnr.to_i)]
      end
    end
		def substance_names
			@sequences.values.collect { |seq|
				seq.substance_names
			}.flatten.uniq
		end
		private
		def adjust_types(hash, app=nil)
			hash = hash.dup
			hash.dup.each { |key, value|
				if(value.is_a?(Persistence::Pointer))
					hash[key] = value.resolve(app)
				else
					case(key)
					when :generic_type, :complementary_type
						if(value.is_a? String)
							hash[key] = value.intern
						end
					when :registration_date, :revision_date, 
						:expiration_date, :inactive_date, :market_date
						#key != for elements that can be nil
						if(value.is_a?(String))
							hash.store(key, Date.parse(value.tr('.', '-')))
						end
					when :company
						hash[key] = if(company.is_a? String)
							app.company_by_name(value)
						else
							app.company(value)
						end
          when :index_therapeuticus, :ith_swissmedic
            hash.store key, IndexTherapeuticus.normalize_code(value)
					end
				end
			}
			hash
		end
	end
	class Registration < RegistrationCommon
		ODBA_PREFETCH = true
		def company=(company)
			@company = replace_observer(@company, company)
		end
		def indication=(indication)
			@indication = replace_observer(@indication,indication)
		end
		def fachinfo=(fachinfo)
			@fachinfo = replace_observer(@fachinfo, fachinfo)
		end
    def minifi=(minifi)
			@minifi = replace_observer(@minifi, minifi)
    end
		def	replace_observer(target, value)
			if(target.respond_to?(:remove_registration))
				target.remove_registration(self)
			end
			if(value.respond_to?(:add_registration))
				value.add_registration(self)
			end
			target = value
		end	
	end
end
