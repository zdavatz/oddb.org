#!/usr/bin/env ruby
# Validator -- oddb -- 18.11.2002 -- hwyss@ywesee.com 

require 'sbsm/validator'
require 'model/ean13'
require 'cgi'

module ODDB
	class Validator < SBSM::Validator
		alias :partner :flavor
		alias :set_pass_2 :pass
		alias :invoice_email :email
		alias :unique_email :email
		alias :notify_sender :email
		alias :receiver_email :email
		alias :competition_email :email
		alias :swissmedic_email :email
		BOOLEAN = [
      :cl_status, :deductible_display, :disable, :disable_ddd_price,
      :disable_invoice_fachinfo, :disable_invoice_patinfo,
      :disable_patinfo, :download, :experience, :export_flag, :helps,
      :ignore_patent, :impression, :invoice_htmlinfos, :limit_invoice_duration, :lppv,
      :parallel_import, :preview_with_market_date, :recommend,
      :refdata_override, :remember_me, :renewal_flag,
      :show_email, :vaccine, :yus_groups, :yus_privileges,
      :force_new_ydim_debitor,
    ]
		DATES = [
			:base_patent_date, 
      :deactivate_patinfo,
			:deletion_date,
			:expiration_date,
			:expiry_date,
			:inactive_date,
			:introduction_date,
			:invoice_date_fachinfo,
			:invoice_date_index,
			:invoice_date_lookandfeel,
			:invoice_date_patinfo,
			:issue_date,
			:market_date,
			:patented_until,
			:protection_date,
			:publication_date,
			:registration_date,
			:revision_date,
      :sequence_date,
			:sponsor_until,
      :valid_until,
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
      :channel      =>  ['fachinfo.rss', 'feedback.rss', 'minifi.rss', 
                         'price_cut.rss', 'price_rise.rss', 'sl_introduction.rss'],
			:cl_status		=>	['false', 'true'],
			:complementary_type =>	[nil, 'complementary', 'anthroposophy',
				'homeopathy', 'phytotherapy', ],
			:compression	=>	[ 'compr_zip', 'compr_gz' ],
			:currency			=>  ['CHF', 'EUR', 'USD'],
			:deductible		=>	[nil, 'deductible_g', 'deductible_o'],
			:deductible_m	=>	[nil, 'deductible_g', 'deductible_o'],
			:search_type	=>	['st_oddb', 'st_sequence', 
        'st_substance', 'st_company', 'st_indication', 'st_interaction',
        'st_unwanted_effect', 'st_registration', 'st_pharmacode' ],
			:fi_status		=>	['false', 'true'],
			:generic_type =>	[nil, 'generic', 'original'], 
				# 'comarketing', 'complementary', 'vaccine' ],
			:limitation		=>	['true', 'false'],
			:payment_method => ['pm_invoice', 'pm_paypal'],
			:patinfo			=>	['delete', 'keep'],
      :resultview   =>  ['atc', 'pages'],
      :route_of_administration => [nil, 'roa_O', 'roa_P', 'roa_N', 'roa_SL', 
                         'roa_TD', 'roa_R', 'roa_V'],
			:salutation		=>	['salutation_m', 'salutation_f'],
      :yus_privileges => [ 
        'edit|yus.entities', 
        'grant|login', 
        'grant|view', 
        'grant|create', 
        'grant|edit', 
        'grant|credit', 
        'set_password',
        'login|org.oddb.RootUser', 
        'login|org.oddb.AdminUser', 
        'login|org.oddb.PowerUser', 
        'login|org.oddb.CompanyUser', 
        'login|org.oddb.PowerLinkUser', 
        #'view|org.oddb', 
        'edit|org.oddb.drugs', 
        'edit|org.oddb.powerlinks',
        'create|org.oddb.registration',
        'create|org.oddb.task.background',
        'edit|org.oddb.model.!company.*', 
        'edit|org.oddb.model.!sponsor.*', 
        'edit|org.oddb.model.!indication.*', 
        'edit|org.oddb.model.!galenic_group.*', 
        'edit|org.oddb.model.!incomplete_registration.*', 
        'edit|org.oddb.model.!address.*', 
        'edit|org.oddb.model.!atc_class.*',
        'invoice|org.oddb.processing', 
        'view|org.oddb.patinfo_stats', 
        'view|org.oddb.patinfo_stats.associated', 
        'credit|org.oddb.download', 
      ],
		}	
		EVENTS = [
			:accept,
			:add_to_interaction_basket,
			:addresses,
			:ajax,
			:ajax_autofill,
      :ajax_create_active_agent,
      :ajax_create_composition,
      :ajax_create_part,
      :ajax_delete_active_agent,
      :ajax_delete_composition,
      :ajax_delete_part,
			:ajax_ddd_price,
			:ajax_swissmedic_cat,
			:analysis_alphabetical,
			:assign,
			:assign_deprived_sequence,
			:assign_fachinfo,
			:assign_patinfo,
			:atc_chooser,
			:atc_request,
			#:authenticate,
			:address_send,
			:back,
			:calculate_offer,
			:checkout,
			:choice,
			:clear_interaction_basket,
      :commercial_forms,
			:company,
			:companylist,
			:compare,
			:ddd,
      :ddd_chart,
      :ddd_price,
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
			:fipi_overview,
			:galenic_groups,
			:help,
			:home,
			:home_admin,
			:home_analysis,
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
      :listed_companies,
			:login,
			:login_form,
			:logout,
			:mailinglist,
			:merge,
			:migel_alphabetical,
			:narcotics,
			:new_active_agent,
			:new_commercial_form,
			:new_company,
			:new_fachinfo,
			:new_galenic_form,
			:new_galenic_group,
			:new_indication,
			:new_item,
			:new_package,
			:new_patent,
			:new_registration,
			:new_sequence,
			:new_substance,
      :new_user,
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
      :price_history,
			:print,
			:proceed_download,
			:proceed_payment,
			:proceed_poweruser,
			:recent_registrations,
			:resolve,
			:result,
      :rss,
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
      :user,
      :users,
			:vaccines,
			:vcard,
			:wait,
			:ywesee_contact,
		]
		FILES = [
			:logo_file,
			:logo_fr,
			:fachinfo_upload,
      :html_upload,
			:patinfo_upload,
		]
    HTML = [:html_chapter]
		NUMERIC = [
      :active_agent,
			:change_flags,
      :composition,
      :count,
			:days,
      :exam,
			:fachinfo_price,
      :factor,
			:fi_quantity,
			:index,
			:invoice,
			:item_number,
			:limitation_points,
      :longevity,
			:lookandfeel_member_count,
			:meaning_index,
			:month,
			:months,
      :multi,
      :part,
      :price_fachinfo,
			:price_index,
			:price_index_package,
			:price_lookandfeel,
			:price_lookandfeel_member,
			:price_patinfo,
			:pi_quantity,
      :pharmacode,
			:price_exfactory,
			:price_public,
      :ydim_id,
			:year,
		]
		STRINGS = [
			:additional_lines,
			:address,
			:address_email,
			:atc_descr,
			:bsv_url,
			:business_unit,
      :capabilities,
      :captcha,
			:certificate_number,
			:challenge,
			:chapter,
			:chemical_substance,
			:city,
      :commercial_form,
			:company_form,
			:company_name,
			:comparable_size,
      :composition_text,
			:connection_key,
			:contact,
			:contact_email,
      :correspondence,
			:de,
			:descr,
			:destination,
			:effective_form,
			:en,
			:equivalent_substance,
      :fachinfo_link,
			:fax,
			:fi_update,
			:fon,
      :for,
			:fr,
			:galenic_form,
      :generic_group,
			:heading,
      :highlight,
			:index_therapeuticus,
			:indication,
			:language_select,
			:location,
			:lt,
      :message,
			:name,
			:name_base,
			:name_descr,
			:name_first,
			:name_last,
			:notify_message,
			:pattern,
			:payment_status,
			:phone, ## needed for download-registration!!
      :photo_link,
			:pi_update,
			:plz,
			:powerlink,
			:range,
			:register_update,
			:regulatory_email,
      :remember,
			:size,
			:sortvalue,
			:spagyric_dose,
			:spagyric_type,
      :specialities,
			:subscribe,
			:substance,
			:substance_form,
      :substance_ids,
      :swissmedic_salutation,
			:synonym_list,
			:title,
			:token,
			:txn_id,
			:unsubscribe,
			:url,
			:urls,
		]
		ZONES = [:admin, :analysis, :doctors, :interactions, :drugs, :migel, :user, 
			:hospitals, :substances, :companies]
		@@latin1 = Iconv.new('ISO-8859-1', 'UTF-8')
		@@utf8 = Iconv.new('UTF-8', 'ISO-8859-1')
		def code(value)
			pattern = /^[A-Z]([0-9]{2}([A-Z]([A-Z]([0-9]{2})?)?)?)?$/iu
			if(valid = pattern.match(value.capitalize))
				valid[0].upcase
			elsif(value.empty?)
				nil
			else
				raise SBSM::InvalidDataError.new(:e_invalid_atc_class, :atc_class, value)
			end
		end
    @@dose = /(\d+(?:[.,]\d+)?)\s*(.*)/u
		def dose(value)
			return nil if value.empty?
			if(valid = @@dose.match(value))
				qty = valid[1].gsub(',', '.')
				[qty.to_f, valid[2].to_s]
			else
				raise SBSM::InvalidDataError.new(:e_invalid_dose, :dose, value)
			end
		end
		alias :pretty_dose :dose
		alias :chemical_dose :dose
		alias :equivalent_dose :dose
		alias :measure :dose
		alias :ddd_dose :dose
		def filename(value)
			if(value == File.basename(value))
				value
			end
		end
		def ean13(value)
			return '' if value.empty?
			ODDB::Ean13.new(value)
		end
    def emails(value)
      return if(value.empty?)
      parsed = RMail::Address.parse(value)
      if(parsed.empty?)
        raise InvalidDataError.new(:e_invalid_email_address, :email, value)
      elsif(parsed.all? { |addr| addr.domain })
        parsed.collect { |addr| addr.address }
      else
        raise InvalidDataError.new(:e_domainless_email_address, :email, value)
      end
    end
		def email_suggestion(value)
			unless(value.empty?)
				email(value)
			end
		end
		def galenic_group(value)
			pointer(value)
		end
    @@ikscat = /[ABCDE]|Sp/u
		def ikscat(value)
			return '' if value.empty?
			if(valid = @@ikscat.match(value.capitalize))
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
    def notify_recipient(value)
      RMail::Address.parse(value.to_s).collect { |parsed| parsed.address }
    end
		def search_query(value)
			result = validate_string(value).gsub(/\*/u, '')
			begin
			  @@latin1.iconv(result)
			rescue Iconv::IllegalSequence, Iconv::InvalidCharacter
		          puts result.inspect
			  result = @@utf8.iconv(result)
		          puts result.inspect
			end
			result = u result
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
    @@swissmedic = /^\d+$/u
		def swissmedic_id(key, value, range, pad=false)
			return value if value.empty?
			valid = @@swissmedic.match(value)
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
				pointer = Persistence::Pointer.parse(value)
        if(pointer.insecure?)
					path = File.expand_path('../../log/insecure_pointers',
						File.dirname(__FILE__))
					File.open(path, 'a') { |fh| fh.puts value }
          raise SBSM::InvalidDataError.new('e_insecure_pointer', :pointer, value)
        end
        pointer
			rescue StandardError, ParseException
				if(value[-1] != ?.)
					value << "."
					retry
				end
				raise SBSM::InvalidDataError.new("e_invalid_pointer", :pointer, value)
			end
		end
    @@yus = /^org\.oddb\.model\.[!*.a-z]+/u
    def yus_association(value)
      value = value.to_s
      if(@@yus.match(value.to_s))
        value
      elsif(!value.empty?)
				raise SBSM::InvalidDataError.new("e_invalid_yus_association", 
                                         :yus_association, value)
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
