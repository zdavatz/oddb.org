#!/usr/bin/env ruby
# Validator -- oddb -- 18.11.2002 -- hwyss@ywesee.com 

require 'sbsm/validator'
require 'model/ean13'

module ODDB
	class Validator < SBSM::Validator
		alias :set_pass_1 :pass
		alias :set_pass_2 :pass
		alias :unique_email :email
		BOOLEAN = [
			:cl_status, 
		]
		DATES = [
			:inactive_date,
			:introduction_date,
			:registration_date,
			:revision_date,
			:market_date,
			:expiration_date,
			:sponsor_until,
		]
		ENUMS = {
			:cl_status		=>	['false', 'true'],
			:fi_status		=>	['false', 'true'],
			:generic_type =>	[nil, 'generic', 'original' ],
			:limitation		=>	['true', 'false'],
			:pi_status		=>	['false', 'true'],
		}	
		EVENTS = [
			:accept,
			:add_to_interaction_basket,
			:assign,
			:assign_patinfo,
			:assign_deprived_sequence,
			:atc_chooser,
			:back,
			:calculate_interaction,
			:choice,
			:companylist,
			:company,
			:compare,
			:ddd, 
			:delete,
			:delete_orphaned_fachinfo,
			:delete_orphaned_patinfo,
			:download,
			:download_export,
			:galdat_download,
			:generic_definition,
			:help,
			:legal_note,
			:login,
			:login_form,
			:logout,
			:galenic_groups,
			:home,
			:incomplete_registrations,
			:indications,
			:interaction_basket,
			:interaction_home,
			:limitation_text,
			:mailinglist,
			:merge,
			:new_active_agent,
			:new_company,
			:new_galenic_form,
			:new_galenic_group,
			:new_indication,
			:new_item, 
			:new_package,
			:new_registration,
			:new_sequence,
			:orphaned_fachinfos,
			:orphaned_patinfos,
			:patinfo_deprived_sequences,
			:passthru,
			:paypal_thanks,
			:plugin,
			:powerlink,
			:preview,
			:print,
			:recent_registrations,
			:resolve,
			:result,
			:shadow,
			:shadow_pattern,
			:search,
			:search_interaction,
			:search_registrations,
			:search_sequences,
			:select_seq,
			:set_pass,
			:sponsor,
			:substance_result,
			:substances,
			:update,
			:update_bsv,
			:update_incomplete,
			:sort,
			:ywesee_contact,
		]
		FILES = [
			:logo_file,
			:fachinfo_upload,
		]
		NUMERIC = [
			:limitation_points,
			:price_exfactory,
			:price_public,
			:index,
			:meaning_index,
		]
		STRINGS = [
			:address,
			:address_email,
			:atc_descr,
			:bsv_url,
			:business_area,
			:chapter,
			:en,
			:descr,
			:language_select,
			:location,
			:company_form,
			:company_name,
			:comparable_size,
			:contact,
			:contact_email,
			:de,
			:destination,
			:fax,
			:fr,
			:galenic_form,
			:indication,
			:language_select,
			:location,
			:lt,
			:name,
			:name_base,
			:name_descr,
			:pattern,
			:phone,
			:plz,
			:powerlink,
			:range,
			:size,
			:sortvalue,
			:subscribe,
			:substance,
			:unsubscribe,
			:url,
		]
		def code(value)
			pattern = /^[A-Z]([0-9]{2}([A-Z]([A-Z]([0-9]{2})?)?)?)?$/i
			if(valid = pattern.match(value.capitalize))
				valid[0].upcase
			else
				raise SBSM::InvalidDataError.new(:e_invalid_atc_class, :atc_class, value)
			end
		end
		def dose(value)
			return nil if value.empty?
			if(valid = /(\d+(?:[.,]\d+)?)\s*(.*)/.match(value))
				qty = valid[1].gsub(',', '.')
				[qty.to_f, valid[2].to_s]
			else
				raise SBSM::InvalidDataError.new(:e_invalid_dose, :dose, value)
			end
		end
		def filename(value)
			if(value == File.basename(value))
				value
			end
		end
		def ean13(value)
			return '' if value.empty?
			ODDB::Ean13.new(value)
		end
		def galenic_group(value)
			pointer(value)
		end
		def ikscat(value)
			return '' if value.empty?
			if(valid = /[ABCDE]|Sp/.match(value.capitalize))
				valid[0]
			else
				raise SBSM::InvalidDataError.new(:e_invalid_ikscat, :ikscat, value)
			end
		end
		def ikscd(value)
			swissmedic_id(:ikscd, value, 1..3, 3)
		end
		def iksnr(value)
			swissmedic_id(:iksnr, value, 4..5)
		end
		def search_query(value)
			result = validate_string(value)
			if(result.length > 2)
				result
			else
				raise SBSM::InvalidDataError.new(:e_search_query_short, :search_query, value)
			end
		end
		def seqnr(value)
			swissmedic_id(:seqnr, value, 1..2, 2)
		end
		def swissmedic_id(key, value, range, pad=false)
			return value if value.empty?
			valid = /^\d+$/.match(value)
			if(valid && range.include?(valid[0].length))
				if(pad)
					sprintf("%0#{pad}d", valid[0].to_i)
				else
					valid[0]
				end
			else
				raise SBSM::InvalidDataError.new("e_invalid_#{key}", key, value)
			end
		end
		def page(value)
			validate_numeric(:page, value).to_i - 1
		end
		def pointer(value)
			begin
				Persistence::Pointer.parse(value)
			rescue StandardError, ParseException
				raise SBSM::InvalidDataError.new("e_invalid_pointer", :pointer, value)
			end
		end
		alias :pointers :pointer
		alias :patinfo_pointer :pointer
	end
end
