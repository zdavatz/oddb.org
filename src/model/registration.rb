#!/usr/bin/env ruby
# Registration -- oddb -- 24.02.2003 -- hwyss@ywesee.com 

require 'date'
require 'util/persistence'
require 'model/sequence'

module ODDB
	class RegistrationCommon
		include Persistence
		attr_reader :iksnr, :sequences 
		attr_writer :generic_type, :complementary_type
		attr_accessor :registration_date, :export_flag, :company, 
			:revision_date, :indication, :expiration_date, :inactive_date,
			:market_date, :fachinfo, :source, :pdf_fachinfos,
			:index_therapeuticus
		alias :pointer_descr :iksnr
		SEQUENCE = Sequence
		def initialize(iksnr)
			@iksnr = iksnr
			@sequences = {}
		end
		def active?
			(@inactive_date.nil? || @inactive_date > Date.today) \
				&& (@market_date.nil? || @market_date <= Date.today)
		end
		def atc_classes
			@sequences.values.collect { |seq|
				seq.atc_class
			}.compact.uniq
		end
		def atcless_sequences
			@sequences.values.select { |seq|
				seq.atc_class.nil?
			}
		end
		def checkout
			checkout_helper([@company, @indication], :remove_registration)
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
		def create_sequence(seqnr)
			seq = self::class::SEQUENCE.new(seqnr)
			unless @sequences.include?(seq.seqnr)
				seq.registration = self
				@sequences.store(seq.seqnr, seq)
			end
		end
		def delete_sequence(seqnr)
			seqnr = sprintf('%02d', seqnr.to_i)
			if(seq = @sequences.delete(seqnr))
				@sequences.odba_isolated_store
				seq
			end
		end
		def each_package(&block)
			@sequences.each_value { |seq|
				seq.each_package(&block)
			}
		end
		def each_sequence(&block)
			@sequences.values.each(&block)
		end
		def generic_type
			@generic_type || if(@company)
				@company.generic_type
			end
		end
		def limitation_text_count
			@sequences.values.inject(0) { |inj, seq|			
				inj + seq.limitation_text_count
			}
		end
		def name_base
			if(seq = @sequences.values.first)
				seq.name_base
			end
		end
		def package(ikscd)
			@sequences.each_value { |seq|
				package = seq.package(ikscd)
				return package unless package.nil?
			}
			nil
		end
		def package_count
			@sequences.values.inject(0) { |inj, seq|
				inj + seq.package_count
			}
		end
		def search(query)
			@sequences.values.collect { |seq|
				seq.atc_class if seq.match(query)
			}.compact
		end
		def sequence(seqnr)
			@sequences[sprintf('%02d', seqnr.to_i)]
		end
		def substance_names
			@sequences.values.collect { |seq|
				seq.substance_names
			}.flatten.uniq
		end
		private
		def adjust_types(hash, app=nil)
			hash = hash.dup
			hash.each { |key, value|
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
						if(!value.is_a?(Date) && !value.nil?)
							hash.store(key, Date.parse(value.tr('.', '-')))
						end
					when :company
						hash[key] = if(company.is_a? String)
							app.company_by_name(value)
						else
							app.company(value)
						end
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
			@fachinfo_oid = (@fachinfo.nil?) ? nil : @fachinfo.oid
			@fachinfo
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
