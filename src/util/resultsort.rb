#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::ResultSort -- oddb.org -- 28.02.2012 -- mhatakeyama@ywesee.com
# ODDB::ResultSort -- oddb.org -- 10.09.2003 -- mhuggler@ywesee.com

module ODDB
	module ResultStateSort
		def sort
			get_sortby!
      if @model
        @model.each { |atc| 
          atc.packages.sort! { |a, b| compare_entries(a, b) }
          atc.packages.reverse! if(@sort_reverse)
        }
      end
			self
		end
	end
	module ResultSort
		def sort_result(packages, session)
			begin
				packages.sort_by { |package|
					priorize_desitin = false
					package_from_desitin = (package.company and /desitin/i.match(package.company.to_s) != nil)
					priorize_desitin = true if package_from_desitin and session and session.lookandfeel.enabled?(:evidentia, false)
					priorize_desitin = true if package_from_desitin and session and
																			session.user and not session.user.is_a?(ODDB::UnknownUser) and
																			/@desitin/i.match(session.user.name.to_s)
					name_to_use = (priorize_desitin  && generic_type_weight(package) == 5)? ' '+package.name_base.to_s : package.name_base.to_s
					name_to_use = name_to_use.gsub(/\d.*/, '')
					[
						package.expired? ? 1 : -1,
						generic_type_weight(package),
						name_to_use,
						package.galenic_forms.collect { |gf| galform_str(gf, session) },
						dose_value(package.dose),
						package.comparable_size,
					]
				}
			rescue StandardError => e
				puts e.class
				puts e.message
				puts e.backtrace
				packages
			end
		end
		def dose_value(dose)
			dose || Dose.new(0)
		end
		def package_count
			@packages.size
		end
		def galform_str(galform, session)
			if(galform.odba_instance.nil?)
				''
      elsif galform.respond_to?(session.language.to_sym)
				galform.send(session.language)
      else
        ''
			end
		end
		def generic_type_weight(package)
			type = package.generic_type
			type = package.sl_generic_type.to_sym if package and package.generic_type and package.sl_generic_type and package.generic_type.to_sym == :unknown
			case type ? type.to_sym : nil
			when :original
				0
			when :generic
				5
			when :comarketing
				10
			when :complementary
				15
			else
				20
			end
			# the following was madly inefficient!
=begin
			types = session.valid_values(:generic_type)
			index = types.index(package.generic_type.to_s).to_i
			10 - (index*2)
=end
		end
	end
end
