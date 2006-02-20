#!/usr/bin/env ruby
# Validator -- oddb -- 18.11.2002 -- hwyss@ywesee.com 

require 'sbsm/validator'
require 'model/ean13'
require 'cgi'

module ODDB
	class Validator < SBSM::Validator
		alias :set_pass_2 :pass
		alias :unique_email :email
		alias :notify_sender :email
		alias :notify_recipient :email
		alias :receiver_email :email
		BOOLEAN = [
			:cl_status,  :download, :experience, :recommend, :impression,
			:invoice_htmlinfos, :helps, :show_email, :export_flag,
			:disable_autoinvoice, :refdata_override, :lppv,
		]
		DATES = [
			:inactive_date,
			:index_invoice_date,
			:introduction_date,
			:lookandfeel_invoice_date,
			:registration_date,
			:revision_date,
			:market_date,
			:expiration_date,
			:pref_invoice_date,
			:sponsor_until,
		]
		ENUMS = {
			:address_type	=>	[nil, 'at_work', 'at_praxis',
				'at_private'],
			:business_area=>	[nil, 'ba_hospital', 'ba_pharma', 'ba_insurance',
				'ba_doctor', 'ba_health', 'ba_info' ],
			:canton				=>	[nil, 'AG', 'AI', 'AR', 'BE',
				'BL', 'BS', 'FR', 'GE', 'GL', 'GR', 'JU', 'LU',
				'NE', 'NW', 'OW', 'SG', 'SH', 'SO', 'SZ', 'TG',
				'TI', 'UR', 'VD', 'VS', 'ZG', 'ZH'],
			:cl_status		=>	['false', 'true'],
			:complementary_type =>	[nil, 'anthroposophy', 'homeopathy', 
				'phytotherapy', ],
			:compression	=>	[ 'compr_zip', 'compr_gz' ],
			:currency			=>  ['CHF', 'EUR', 'USD'],
			:deductible		=>	[nil, 'deductible_g', 'deductible_o'],
			:search_type	=>	['st_oddb', 'st_sequence', 
				'st_substance', 'st_company', 'st_indication',],
			:fi_status		=>	['false', 'true'],
			:generic_type =>	[nil, 'generic', 'original', 'complementary',
				'vaccine' ],
			:limitation		=>	['true', 'false'],
			:payment_method => ['pm_invoice', 'pm_paypal'],
			:patinfo			=>	['delete', 'keep'],
			:salutation		=>	['salutation_m', 'salutation_f'],
		}	
		EVENTS = [
			:accept,
			:add_to_interaction_basket,
			:addresses,
			:ajax,
			:assign,
			:assign_deprived_sequence,
			:assign_patinfo,
			:atc_chooser,
			:atc_request,
			:authenticate,
			:address_send,
			:back,
			:calculate_offer,
			:checkout,
			:choice,
			:clear_interaction_basket,
			:company,
			:companylist,
			:compare,
			:ddd,
			:delete,
			:delete_connection_key,
			:delete_orphaned_fachinfo,
			:delete_orphaned_patinfo,
			:doctorlist,
			:download,
			:download_credit,
			:download_export,
			:effective_substances,
			:export_csv,
			:fachinfos,
			:feedbacks,
			:fipi_offer_input,
			:galenic_groups,
			:generic_definition,
			:help,
			:home,
			:home_admin,
			:home_companies,
			:home_doctors,
			:home_drugs,
			:home_hospitals,
			:home_migel,
			:home_interactions,
			:home_substances,
			:home_user,
			:hospitallist,
			:incomplete_registrations,
			:indications,
			:interaction_basket,
			:legal_note,
			:limitation_text,
			:limitation_texts,
			:login,
			:login_form,
			:logout,
			:mailinglist,
			:merge,
			:migel_alphabetical,
			:narcotics,
			:new_active_agent,
			:new_company,
			:new_galenic_form,
			:new_galenic_group,
			:new_indication,
			:new_item,
			:new_package,
			:new_registration,
			:new_sequence,
			:new_substance,
			:notify,
			:notify_send,
			:orphaned_fachinfos,
			:orphaned_patinfos,
			:passthru,
			:password_lost,
			:password_request,
			:password_reset,
			:patinfo_deprived_sequences,
			:patinfos,
			:patinfo_stats,
			:patinfo_stats_company,
			:paypal_ipn,
			:paypal_return,
			:paypal_thanks,
			:plugin,
			:powerlink,
			:preview,
			:print,
			:proceed_download,
			:proceed_payment,
			:proceed_poweruser,
			:recent_registrations,
			:release,
			:resolve,
			:result,
			:search,
			:search_registrations,
			:search_sequences,
			:select_seq,
			:sequences,
			:set_pass,
			:shadow,
			:shadow_pattern,
			:show,
			:show_interaction,
			:sort,
			:sponsor,
			:sponsorlink,
			:substances,
			:suggest_address,
			:suggest_choose,
			:switch,
			:update,
			:update_bsv,
			:update_incomplete,
			:vaccines,
			:vcard,
			:wait,
			:ywesee_contact,
		]
		FILES = [
			:logo_file,
			:logo_fr,
			:fachinfo_upload,
			:patinfo_upload,
		]
		NUMERIC = [
			:change_flags,
			:days,
			:fi_quantity,
			:index,
			:invoice,
			:index_package_price,
			:index_price,
			:item_number,
			:limitation_points,
			:lookandfeel_price,
			:lookandfeel_member_count,
			:lookandfeel_member_price,
			:meaning_index,
			:month,
			:months,
			:patinfo_price,
			:pi_quantity,
			:price_exfactory,
			:price_public,
			:year,
		]
		STRINGS = [
			:additional_lines,
			:address,
			:address_email,
			:atc_descr,
			:bsv_url,
			:business_unit,
			:challenge,
			:chapter,
			:chemical_substance,
			:city,
			:company_form,
			:company_name,
			:comparable_size,
			:connection_key,
			:contact,
			:contact_email,
			:de,
			:descr,
			:destination,
			:effective_form,
			:en,
			:equivalent_substance,
			:fax,
			:fi_update,
			:fon,
			:fr,
			:galenic_form,
			:heading,
			:html_chapter,
			:indication,
			:language_select,
			:location,
			:lt,
			:name,
			:name_base,
			:name_descr,
			:name_first,
			:notify_message,
			:pattern,
			:payment_status,
			:phone, ## needed for download-registration!!
			:pi_update,
			:plz,
			:powerlink,
			:range,
			:register_update,
			:regulatory_email,
			:size,
			:sortvalue,
			:spagyric_dose,
			:spagyric_type,
			:subscribe,
			:substance,
			:substance_form,
			:synonym_list,
			:title,
			:token,
			:txn_id,
			:unsubscribe,
			:url,
		]
		ZONES = [:admin, :doctors, :interactions, :drugs, :migel, :user, 
			:hospitals, :substances, :companies]
		def code(value)
			pattern = /^[A-Z]([0-9]{2}([A-Z]([A-Z]([0-9]{2})?)?)?)?$/i
			if(valid = pattern.match(value.capitalize))
				valid[0].upcase
			elsif(value.empty?)
				nil
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
		alias :pretty_dose :dose
		alias :chemical_dose :dose
		alias :equivalent_dose :dose
		def filename(value)
			if(value == File.basename(value))
				value
			end
		end
		def ean13(value)
			return '' if value.empty?
			ODDB::Ean13.new(value)
		end
		def email_suggestion(value)
			unless(value.empty?)
				email(value)
			end
		end
		alias :invoice_email :email_suggestion
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
		def message(value)
			validate_string(value).to_s[0,500]
		end
		def search_query(value)
			result = validate_string(value).gsub(/[*%]/, '')
			if(result.length > 2)
				result
			else
				raise SBSM::InvalidDataError.new(:e_search_query_short, :search_query, value)
			end
		end
		def set_pass_1(value)
			if(value.to_s.size < 4)
				raise SBSM::InvalidDataError.new("e_missing_password", 
					:set_pass_1, value)
			end
			pass(value)
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
				if(value[-1] != ?.)
					value << "."
					retry
				end
				raise SBSM::InvalidDataError.new("e_invalid_pointer", :pointer, value)
			end
		end
		def zone(value)
			if(value.to_s.empty?)
				raise SBSM::InvalidDataError.new("e_invalid_zone", :zone, value)
			end
			zone = value.to_sym
			if(self::class::ZONES.include?(zone))
				zone
			else
				raise SBSM::InvalidDataError.new("e_invalid_zone", :zone, value)
			end
		end
		alias :pointers :pointer
		alias :patinfo_pointer :pointer
	end
end
