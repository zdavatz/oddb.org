#!/usr/bin/env ruby
# LookandfeelWrapper - oddb -- 21.07.2003 -- mhuggler@ywesee.com

require 'sbsm/lookandfeelwrapper'

module ODDB
	class LookandfeelStandardResult < SBSM::LookandfeelWrapper
		ENABLED = [
      :fachinfos, :feedback,
    ]
		def compare_list_components
			{
				[0,0]	=>	:name_base,
				[1,0]	=>	:company_name,
				[2,0]	=>	:most_precise_dose,
				[3,0]	=>	:comparable_size,
				[4,0] =>	:active_agents,
				[5,0]	=>	:price_public,
				[6,0]	=>	:price_difference, 
				[7,0]	=>	:deductible,
				[8,0] =>  :ikscat,
			}	
		end
		def explain_result_components
			{
				[0,0]	=>	:explain_original,
				[0,1]	=>	:explain_generic,
				[0,2]	=>	'explain_unknown',
				[0,3]	=>	'explain_expired',
				[0,4]	=>	:explain_complementary,
				[0,5]	=>	:explain_homeopathy,
				[0,6]	=>	:explain_anthroposophy,
				[0,7] =>	:explain_phytotherapy,
				[0,8]	=>	:explain_cas,
				[1,0]	=>	:explain_parallel_import,
				[1,1]	=>	:explain_comarketing,
				[1,2]	=>	:explain_vaccine,
				[1,3]	=>	:explain_narc,
				[1,4]	=>	:explain_fachinfo,
				[1,5]	=>	:explain_patinfo,
				[1,6]	=>	:explain_limitation,
				[1,7]	=>	:explain_google_search,
				[1,8]	=>	:explain_feedback,
				[2,0]	=>	'explain_efp',
				[2,1]	=>	'explain_pbp',
				[2,2]	=>	'explain_pr',
				[2,3]	=>	:explain_deductible,
				[2,4]	=>	'explain_sl',
				[2,5]	=>	'explain_slo',
				[2,6]	=>	'explain_slg',
				[2,7]	=>	:explain_lppv,
			}
		end
		def result_list_components
			{
				[0,0]		=>	:limitation_text,
				[1,0]		=>  :fachinfo,
				[2,0]		=>	:patinfo,
				[3,0]		=>	:narcotic,
				[4,0]		=>	:complementary_type,
				[5,0,0]	=>	'result_item_start',
				[5,0,1]	=>	:name_base,
				[5,0,2]	=>	'result_item_end',
				[6,0]		=>	:galenic_form,
				[7,0]		=>	:most_precise_dose,
				[8,0]		=>	:comparable_size,
				[9,0]		=>	:price_exfactory,
				[10,0]	=>	:price_public,
				[11,0]	=>	:deductible,
				[12,0]	=>	:substances,
				[13,0]	=>	:company_name,
				[14,0]	=>	:ikscat,
				[15,0]	=>	:registration_date,
				[16,0]	=>	:feedback,
				[17,0]	=>  :google_search,
				[18,0]	=>	:notify,
			}
		end
	end
	class LookandfeelLanguages < SBSM::LookandfeelWrapper
		ENABLED = [
			:currency_switcher,
			:language_switcher,
		]
	end
	class LookandfeelExtern < SBSM::LookandfeelWrapper
		ENABLED = [
			:atc_chooser,
			:data_counts,
			:drugs, 
			:export_csv,
			:faq_link,
			:help_link,
			:home,
			:home_drugs,
			:home_migel,
			:migel,
			:migel_alphabetical,
			:recent_registrations,
			:search_reset,
			:sequences,
			:topfoot,
			:ywesee_contact,
			:logout,
		]
		RESOURCES = {}
	end
	class LookandfeelButtons < SBSM::LookandfeelWrapper
		HTML_ATTRIBUTES = {
			:search_help	=>	{ "class" => "button" },
			:search_reset	=>	{ "class" => "button" },
			:search				=>	{ "class" => "button" },
		}
	end
	class LookandfeelGenerika < SBSM::LookandfeelWrapper
		ENABLED = [
      :ajax,
      :breadcrumbs,
			:companylist,
      :country_navigation,
			:fachinfos,
			:feedback,
			:feedback_rss,
			:google_adsense,
			:limitation_texts,
			:logo,
      :minifi_rss,
			:multilingual_logo,
			:patinfos, 
			:paypal,
			:query_limit,
      :screencast,
      :price_cut_rss,
      :price_rise_rss,
			:sponsor,
			:sponsorlogo,
		]
		DICTIONARIES = {
			'de'	=>	{
				:html_title		=>	'cc: an alle - generika.cc - betreff: Gesundheitskosten senken!', 
				:home_welcome							=>  "Willkommen bei generika.cc, dem<br>aktuellsten Medikamenten-Portal der Schweiz.",
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
				:login_welcome	=>	'Willkommen bei Generika.cc',
			},
			'fr'	=>	{
				:html_title		=>	'cc: pour tous - generika.cc - concerne: r&eacute;duire les co&ucirc;ts de la sant&eacute;!', 
				:home_welcome							=>  "Bienvenue sur generika.cc,<br>le portail des g&eacute;n&eacute;riques de la Suisse avec<br>tous les m&eacute;dicaments disponibles sur le march&eacute; suisse!",
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
				:login_welcome	=>	'Bienvenu sur Generika.cc',
			},
			'en'	=>	{
				:html_title		=>	'cc: to everybody - generika.cc - subject: reduce health costs!', 
				:home_welcome							=>  "Welcome to generika.cc<br>the open drug database of Switzerland.",
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
				:login_welcome	=>	'Welcome to Generika.cc',
			}
		}
		HTML_ATTRIBUTES = {
			:logo => {
				'width'		=>	'338',
				'height'	=>	'87',
			},
		}
		def navigation(filter=false)
			@component.navigation(false)
		end
		def zones(filter=false)
			@component.zones(false)
		end
	end
	class LookandfeelProvita < SBSM::LookandfeelWrapper
		ENABLED = [ ]
		DICTIONARIES = {
			'de'	=>	{
				:home_welcome	=>	'Willkommen bei Provita und oddb.org',
			},
			'fr'	=>	{
				:home_welcome	=>	'Bienvenu sur Provita et oddb.org',
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
			},
			'en'	=>	{
				:home_welcome	=>	'Welcome to Provita and oddb.org',
			},
		}
		HTML_ATTRIBUTES = {
			:logo => {
				'width'		=>	'150',
				'height'	=>	'50',
			},
		}
	end
	class LookandfeelSantesuisse < SBSM::LookandfeelWrapper
		ENABLED = [ 
      :doctors 
    ]
		DICTIONARIES = {
			'de'	=>	{
				:home_welcome		=>	'',
				:search_explain	=>	'Willkommen bei sant&eacute;suisse und oddb.org<br><br>Vergleichen Sie einfach und schnell Medikamentenpreise indem Sie<br>entweder ein Medikament oder einen Wirkstoff im Suchbalken eingeben.',
			},
			'fr'	=>	{
				:home_welcome		=>	'',
				:search_explain	=>	'Bienvenu sur santesuisse.ch et oddb.org.<br><br>Comparez simplement et rapidement les prix des m&eacute;dicaments<br>en entrant le nom du m&eacute;dicament ou un principe actif<br>dans la barre d\'outils de recherche.',
			},
			'en'	=>	{
				:home_welcome		=>	'',
				:search_explain	=>  "Welcome to santesuisse.ch and oddb.org<br><br>Compare Drug-Prices quickly by simply typing<br>a name or substance in the search bar.",
			},
		}
		HTML_ATTRIBUTES = {
			:logo => {
				'width'		=>	'252',
				'height'	=>	'96',
			},
		}
	end
	class LookandfeelAtupri < SBSM::LookandfeelWrapper
		ENABLED = [
			:external_css,
			:logo,
		]
		DICTIONARIES = {
			'de'	=>	{
				:home_welcome	=>	'Willkommen bei <a href="http://www.atupri.ch/">atupri</a> und oddb.org',
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
			},
			'fr'	=>	{
				:home_welcome	=>	'Bienvenu sur <a href="http://www.atupri.ch/">atupri</a> et oddb.org',
			},
			'en'	=>	{
				:home_welcome	=>	'Welcome to <a href="http://www.atupri.ch/">atupri</a> and oddb.org',
			},
		}
		RESOURCES = {
			:logo	=>	'logo.gif',
			:external_css	=>	'http://www.atupri.ch/misc/intranet.generika.css',
		}
		HTML_ATTRIBUTES = {
			:logo => {
				'width'		=>	'200',
				'height'	=>	'50',
			},
		}
	end
	class LookandfeelAtupriWeb < SBSM::LookandfeelWrapper
		ENABLED = [
			:atupri_web,
			:custom_navigation,
			:drugs, 
			:external_css,
      :fachinfos,
			:help_link,
			:logout,
			:migel,
			:popup_links,
			:sequences,
		]
		DICTIONARIES = {
			'de'	=>	{
				:DOCTYPE									=>	' <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 transitional//EN">',
				:explain_complementary		=>	'&nbsp;=&nbsp;Arzneimittel der Komplement&auml;rmedizin',
				:explain_original					=>	'Blau&nbsp;=&nbsp;Original',
				:explain_unknown					=>	'Grau&nbsp;=&nbsp;Nicht&nbsp;klassifiziert',
				:home_welcome							=>  "",
				:price_compare						=>	'F&uuml;r den Direktvergleich klicken Sie bitte <br>auf den Medikamentennamen im Suchergebnis!',
			},
			'fr'	=>	{
				:explain_complementary		=>	'&nbsp;=&nbsp;Produit Compl&eacute;mentaire',
				:explain_original					=>	'bleu&nbsp;=&nbsp;original',
				:explain_unknown					=>	'gris&nbsp;=&nbsp;pas classes',
				:home_welcome							=>  "",
				:price_compare						=>	'Pour la comparaison directe, cliquez s.v.p.<br>sur le nom du m&eacute;dicament dans le r&eacute;sultat de la recherche!',
			},
		}
		RESOURCES = { 
			:external_css	=>	'http://www.atupri.ch/misc/new.generika.css',
		}
		HTML_ATTRIBUTES = { }
		def compare_list_components
			{
				[0,0]	=>	:name_base,
				[1,0]	=>	:company_name,
				[2,0]	=>	:most_precise_dose,
				[3,0]	=>	:comparable_size,
				[4,0] =>	:active_agents,
				[5,0]	=>	:price_public,
				[6,0]	=>	:price_difference, 
				[7,0]	=>	:deductible,
				[8,0] =>  :ikscat,
			}	
		end
		def explain_result_components
			{
				[0,0]	=>	:explain_original,
				[0,1]	=>	:explain_generic,
				[0,2]	=>	:explain_complementary,
				[0,3]	=>	:explain_vaccine,
				[0,4]	=>	'explain_unknown',
				[0,6]	=>	:explain_limitation,
				[0,7]	=>	:explain_fachinfo,
				[0,8]	=>	:explain_patinfo,
				[0,9]	=>	:explain_narc,
				[1,0]	=>	:explain_anthroposophy,
				[1,1]	=>	:explain_homeopathy,
				[1,2] =>	:explain_phytotherapy,
				[1,3]	=>	:explain_parallel_import,
				[1,4]	=>	'explain_efp',
				[1,5]	=>	'explain_pbp',
				[1,6]	=>	:explain_deductible,
				[1,7]	=>	'explain_sl',
				[1,8]	=>	'explain_slo',
				[1,9]	=>	'explain_slg',
			}
		end
    def migel_list_components
      {
        [0,0] =>	:limitation_text,
        [1,0] =>	:migel_code,
        [2,0]	=>	:product_description,
        [3,0] =>  :date,
        [4,0] =>  :price,
        [5,0]	=>	:qty_unit,
      }
    end
		def navigation
			[ :legal_note ] + zone_navigation + [ :home ]
		end
		def result_list_components
			{
				[0,0]		=>	:limitation_text,
				[1,0]		=>  :fachinfo,
				[2,0]		=>	:patinfo,
				[3,0]		=>	:narcotic,
				[4,0]		=>	:complementary_type,
				[5,0,0]	=>	'result_item_start',
				[5,0,1]	=>	:name_base,
				[5,0,2]	=>	'result_item_end',
				[6,0]		=>	:galenic_form,
				[7,0]		=>	:most_precise_dose,
				[8,0]		=>	:comparable_size,
				[9,0]		=>	:price_exfactory,
				[10,0]	=>	:price_public,
				[11,0]	=>	:deductible,
				[12,0]	=>	:substances,
			}
		end
		def zone_navigation
			case @session.zone
			when :migel
				[:migel_alphabetical]
			else
				[:sequences]
			end
		end
	end
	class LookandfeelCarenaSchweiz < SBSM::LookandfeelWrapper
		ENABLED = [
			:atc_chooser,
			:data_counts,
			:drugs, 
			:export_csv,
			:external_css,
			:faq_link,
			:help_link,
			:home,
			:home_drugs,
			:recent_registrations,
			:search_reset,
			:sequences,
			:topfoot,
			:ywesee_contact,
			:logout,
		]
		DICTIONARIES = { }
		RESOURCES = { 
      :external_css	=>	'http://www.carenaschweiz.ch/css/oddb.css',
    }
		HTML_ATTRIBUTES = { }
	end
	class LookandfeelHirslanden < SBSM::LookandfeelWrapper
		ENABLED = [
			:atc_chooser,
			:drugs, 
			:external_css,
      :fachinfos,
			:faq_link,
			:help_link,
			:home,
			:home_drugs,
			:powerlink,
			:popup_links,
			:search_reset,
			:sequences,
			:topfoot,
			:ywesee_contact,
			:logout,
		]
		RESOURCES = {
			:external_css	=>	'http://www.hirslandenprofessional.ch/scripts/oddb.css',
		}
    DICTIONARIES = {
      'de' => {
				:contact_link	=>	'Kontakt',
				:contact_href	=>	'mailto:med-drugs@just-medical.com',
        :home_drugs   => 'med-drugs Home',
        :home_welcome => '',
      },
      'en' => {
				:contact_link	=>	'Kontakt',
				:contact_href	=>	'mailto:med-drugs@just-medical.com',
        :home_drugs   => 'med-drugs Home',
        :home_welcome => '',
      },
      'fr' => {
				:contact_link	=>	'Kontakt',
				:contact_href	=>	'mailto:med-drugs@just-medical.com',
        :home_drugs   => 'med-drugs Home',
        :home_welcome => '',
      },
    }
		DISABLED = [ :generic_definition, :legal_note, 
      :pointer_steps_header  ]
    def compare_list_components
      {
        [0,0]	=>	:name_base,
        [1,0]	=>	:company_name,
        [2,0]	=>	:most_precise_dose,
        [3,0]	=>	:comparable_size,
        [4,0] =>	:active_agents,
        [5,0]	=>	:price_public,
        [6,0]	=>	:price_difference, 
        [7,0] =>  :ddd_price,
      }	
    end
    def explain_result_components
      {
        [0,0]	=>	:explain_original,
        [0,1]	=>	:explain_generic,
        [0,2]	=>	'explain_unknown',
        [0,3]	=>	'explain_expired',
        [0,4]	=>	:explain_complementary,
        [0,5]	=>	:explain_homeopathy,
        [0,6]	=>	:explain_anthroposophy,
        [0,7] =>	:explain_phytotherapy,
        [1,0]	=>	:explain_parallel_import,
        [1,1]	=>	:explain_comarketing,
        [1,2]	=>	:explain_vaccine,
        [1,3]	=>	:explain_narc,
        [1,4]	=>	:explain_fachinfo,
        [1,5]	=>	:explain_patinfo,
        [1,6]	=>	:explain_limitation,
        [1,7]	=>	:explain_cas,
        [2,0]	=>	'explain_pbp',
        [2,1]	=>	'explain_pr',
        [2,2]	=>	:explain_ddd_price,
        [2,3]	=>	'explain_sl',
        [2,4]	=>	'explain_slo',
        [2,5]	=>	'explain_slg',
        [2,6]	=>	:explain_lppv,
      }
    end
    def navigation(*args)
      [:help_link, :faq_link, :contact_link ]
    end
    def result_list_components
      {
        [0,0]		=>	:limitation_text,
        [1,0]		=>  :fachinfo,
        [2,0]		=>	:patinfo,
        [3,0,0]	=>	:narcotic,
        [3,0,1]	=>	:complementary_type,
        [3,0,2]	=>	:comarketing,
        [4,0,0]	=>	'result_item_start',
        [4,0,1]	=>	:name_base,
        [4,0,2]	=>	'result_item_end',
        [5,0]		=>	:comparable_size,
        [6,0]	=>	:price_public,
        [7,0]	=>	:ddd_price,
        [8,0]	=>	:active_agents,
        [9,0]	=>	:company_name,
        [10,0]	=>	:ikscat,
      }
    end
    def zone_navigation
      super.push(:home_drugs)
    end
	end
	class LookandfeelJustMedical < SBSM::LookandfeelWrapper
		ENABLED = [
			:custom_navigation,
			:external_css,
      :fachinfos, 
      :feedback,
			:just_medical_structure,	
			:popup_links,
			:powerlink,
		]
		DICTIONARIES = {
			'de'	=>	{
				:all_drugs_pricecomparison	=>	'Schweizer Medikamenten-Enzyklopädie',
				:atc_chooser								=>	'ATC-Codes', 
				:data_declaration						=>	'Datenherkunft',
				:fipi_overview_explain      =>	'Stand der Publikation der Fach- und Patienteninformationen unter www.med-drugs.ch',
				:home_drugs									=>	'Medikamente',
				:legal_note									=>	'Rechtliche Hinweise',
				:meddrugs_update						=>	'med-drugs update', 
				:migel											=>	'Medizinprodukte (MiGeL)',
				:migel_alphabetical					=>	'Medizinprodukte (MiGeL) A-Z',
				:search_explain							=>	'Vergleichen Sie einfach und schnell Medikamentenpreise.<br> Suchen Sie nach Medikament, Wirkstoff oder Anwendungsgebiet.',
				:sequences									=>	'Medikamente A-Z',
			},
			'fr'	=>	{
				:all_drugs_pricecomparison	=>	'Encyclopédie des médicaments commercialisés en Suisse',
				:atc_chooser								=>	'ATC-Codes', 
				:data_declaration						=>	'Source des dates',
				:fipi_overview_explain      =>	'Publications IPro et IPat sous www.just-medical.ch',
				:home_drugs									=>	'Médicaments',
				:legal_note									=>	'Notice légale',
				:meddrugs_update						=>	'med-drugs update', 
				:migel											=>	'Dispositifs médicaux (MiGeL)',
				:migel_alphabetical					=>	'Dispositifs médicaux (MiGeL) A-Z',
				:search_explain							=>	'Comparez simplement et rapidement les prix des médicaments.<br>Cherchez le nom du médicament, le principe actif ou l\'indication.',
				:sequences									=>	'Médicaments A-Z',
			},
			'en'	=>	{
				:all_drugs_pricecomparison	=>	'Complete Swiss encyclopaedia of drugs',
				:atc_chooser								=>	'ATC-Codes', 
				:data_declaration						=>	'Source of data',
				:fipi_overview_explain      =>	'Publications of DI and CI on www.just-medical.ch',
				:home_drugs									=>	'Drugs',
				:legal_note									=>	'Legal Disclaimer',
				:meddrugs_update						=>	'med-drugs update', 
				:migel											=>	'Medical devices (MiGeL)',
				:migel_alphabetical					=>	'Medical devices (MiGeL) A-Z',
				:search_explain							=>	'Compare prices of drugs - fast and easy.<br>Search by name of drug, active agent or indication.',
				:sequences									=>	'Drugs A-Z',
			},
		}
		DISABLED = [ :pointer_steps_header ]
		RESOURCES = {
			#:external_css	=>	'http://www.just-medical.com/css/oddb.css',
			:external_css	=>	'http://www.just-medical.com/css/new.oddb.css',
		}
		def compare_list_components
			{
				[0,0]	=>	:name_base,
				[1,0]	=>	:company_name,
				[2,0]	=>	:most_precise_dose,
				[3,0]	=>	:comparable_size,
				[4,0] =>	:active_agents,
				[5,0]	=>	:price_public,
				[6,0]	=>	:price_difference, 
				[7,0]	=>	:deductible,
				[8,0] =>  :ikscat,
			}	
		end
		def explain_result_components
			{
				[0,0]	=>	:explain_original,
				[0,1]	=>	:explain_generic,
				[0,2]	=>	:explain_comarketing,
				[0,3]	=>	:explain_complementary,
				[0,4]	=>	:explain_vaccine,
				[0,5]	=>	'explain_unknown',
				[0,6]	=>	'explain_expired',
				[0,7]	=>	:explain_cas,
				[1,0]	=>	:explain_limitation,
				[1,1]	=>	:explain_fachinfo,
				[1,2]	=>	:explain_patinfo,
				[1,3]	=>	:explain_narc,
				[1,4]	=>	:explain_anthroposophy,
				[1,5]	=>	:explain_homeopathy,
				[1,6] =>	:explain_phytotherapy,
				[1,7]	=>	:explain_parallel_import,
				[2,0]	=>	'explain_pbp',
				[2,1]	=>	:explain_deductible,
				[2,2]	=>	'explain_sl',
				[2,3]	=>	'explain_slg',
				[2,4]	=>	'explain_slg',
				[2,5]	=>	:explain_feedback,
				[2,6]	=>	:explain_lppv,
				[2,7]	=>	:explain_google_search,
			}
		end
		def navigation
			[ :meddrugs_update, :legal_note, :data_declaration ] \
				+ zone_navigation + [ :home ]
		end
		def result_list_components
			{
				[0,0]		=>	:limitation_text,
				[1,0]		=>  :fachinfo,
				[2,0]		=>	:patinfo,
				[3,0]		=>	:narcotic,
				[4,0]		=>	:complementary_type,
				[5,0,0]	=>	'result_item_start',
				[5,0,1]	=>	:name_base,
				[5,0,2]	=>	'result_item_end',
				[6,0]		=>	:galenic_form,
				[7,0]		=>	:most_precise_dose,
				[8,0]		=>	:comparable_size,
				[9,0]		=>	:price_public,
				[10,0]	=>	:deductible,
				[11,0]	=>	:substances,
				[12,0]	=>	:company_name,
				[13,0]	=>	:ikscat,
				[14,0]	=>	:registration_date,
				[15,0]	=>	:feedback,
				[16,0]	=>  :google_search,
				[17,0]	=>	:notify,
			}
		end
		def zones
			[ :analysis, State::Drugs::Init, State::Drugs::AtcChooser, 
				State::Drugs::Sequences, State::Migel::Alphabetical ]
		end
		def zone_navigation
			case @session.zone
			when :analysis
				[:analysis_alphabetical]
			else
				[]
			end
		end
	end
	class LookandfeelKonsumInfo < SBSM::LookandfeelWrapper
		ENABLED = [
			:atc_chooser,
			:data_counts,
			:drugs, 
			:export_csv,
			:external_css,
			:faq_link,
			:help_link,
			:home,
			:home_drugs,
			:recent_registrations,
			:search_reset,
			:sequences,
			:topfoot,
			:ywesee_contact,
			:logout,
		]
		DICTIONARIES = { }
		RESOURCES = { 
      :external_css	=>	'http://www.konsuminfo.ch/support/css/oddb.css',
    }
		HTML_ATTRIBUTES = { }
	end
	class LookandfeelSwissmedic < SBSM::LookandfeelWrapper
		DICTIONARIES = {
			'de'	=>	{
				:home_welcome							=>  "<b>Willkommen bei swissmedic.oddb.org!</b>",
			},
			'fr'	=>	{
				:home_welcome							=>  "<b>Bienvenue sur swissmedic.oddb.org!</b>",
			},
			'en'	=>	{
				:home_welcome							=>  "<b>Welcome to swissmedic.oddb.org!</b>",
			}
		}
		def enabled?(event, default=true)
			case event.to_sym
			when :query_limit, :google_adsense, :doctors, :interactions, :migel, 
				:user , :hospitals, :companies, :analysis
				false
			else
				@component.enabled?(event, default)
			end
		end
	end
	class LookandfeelOekk < SBSM::LookandfeelWrapper
		ENABLED = [
			:drugs, 
			#:external_css,
			:help_link,
			:logout,
			:migel,
			:oekk_structure,
			:sequences,
		]
		DICTIONARIES = {
			'de'	=>	{
				:de								=>	'd',
				:explain_generic	=>	'Blau&nbsp;=&nbsp;Generikum',
				:en								=>	'e',
				:fr								=>	'f',
				:oekk_department	=>	'Medikamentenvergleich online',
				:oekk_logo				=>	'&Ouml;KK - jung und unkompliziert.',
				:oekk_title				=>	'Ihr Einsparungspotential mit Generika',
			},
			'fr'	=>	{
				:explain_generic	=>	'bleu&nbsp;=&nbsp;g&eacute;n&eacute;rique',
				:oekk_department	=>	'Comparaison de m&eacute;dicaments sur ligne',
				:oekk_logo				=>	'&Ouml;KK - jeune et sympa.',
				:oekk_title				=>	'V&ocirc;tre &eacute;conomie potentielle avec g&eacute;n&eacute;riques',
			},
			'en'	=>	{
				:explain_generic	=>	'Blue&nbsp;=&nbsp;Generic Drug',
				:oekk_department	=>	'Drug comparison online',
				:oekk_logo				=>	'&Ouml;KK - young and easy.',
				:oekk_title				=>	'Your potential savings with generics',
			},
		}
		RESOURCES = { 
			#:external_css	=>	'http://www.oekk.ch/assets/styles/oddb.css',
			#:external_css	=>	'http://www.oekk.ch/assets/styles/new.oddb.css',
			:external_css	=>	'/resources/oekk.oddb.css',
		}
		HTML_ATTRIBUTES = { }
		def languages
			[:de, :fr, :en]
		end
	end
	class LookandfeelMediservice < SBSM::LookandfeelWrapper
		ENABLED = [
      :drugs,
			:external_css,
      :home,
			:home_drugs,
			:home_migel,
			:help_link,
			:faq_link,
			:migel,
			:migel_alphabetical,
			:sequences,
			:ywesee_contact,
		]
		DISABLED = [ :atc_ddd, :feedback, :legal_note, :price_request ]
    RESOURCES = {
      :external_css	=>	'http://www.mediservice.ch/css/medisuche.css',
    }
		def compare_list_components
			{
				[0,0]	=>	:name_base,
				[1,0]	=>	:company_name,
				[2,0]	=>	:most_precise_dose,
				[3,0]	=>	:comparable_size,
				[4,0] =>	:active_agents,
				[5,0]	=>	:price_public,
				[6,0]	=>	:price_difference, 
				[7,0]	=>	:deductible,
				[8,0] =>  :ddd_price,
			}	
		end
    def comparison_sorter
      Proc.new { |facade|
        weight = case facade.company_name
                 when /^helvepharm/i
                   10
                 when /^teva/i, /^medika/i
                   1
                 when /^ecosol/i, /^sandoz/i
                   2
                 when /^spirig/i
                   3
                 when /^mepha/i
                   4
                 else
                   5
                 end
        [weight, facade]
      }
    end
		def explain_result_components
			{
				[0,0]	=>	:explain_original,
				[0,1]	=>	:explain_generic,
				[0,2]	=>	'explain_unknown',
				[0,3]	=>	'explain_expired',
				[0,4]	=>	:explain_vaccine,
				[0,5]	=>	:explain_narc,
				[0,6]	=>	:explain_limitation,
				[1,0]	=>	:explain_complementary,
				[1,1]	=>	:explain_homeopathy,
				[1,2]	=>	:explain_anthroposophy,
				[1,3] =>	:explain_phytotherapy,
				[1,4]	=>	'explain_efp',
				[1,5]	=>	'explain_pbp',
				[1,6]	=>	'explain_pr',
				[2,0]	=>	:explain_deductible,
				[2,1]	=>	:explain_ddd_price,
				[2,2]	=>	'explain_sl',
				[2,3]	=>	'explain_slo',
				[2,4]	=>	'explain_slg',
				[2,5]	=>	:explain_lppv,
				[2,6]	=>	:explain_cas,
			}
		end
    def migel_list_components
      {
        [0,0] =>	:limitation_text,
        [1,0] =>	:migel_code,
        [2,0]	=>	:product_description,
        [3,0] =>  :date,
        [4,0] =>  :price,
        [5,0]	=>	:qty_unit,
        [6,0] =>  :notify,
      }
    end
		def result_list_components
			{
				[0,0]		=>	:limitation_text,
				[1,0,0]	=>	:narcotic,
				[1,0,1]	=>	:complementary_type,
				[2,0,0]	=>	'result_item_start',
				[2,0,1]	=>	:name_base,
				[2,0,2]	=>	'result_item_end',
				[3,0]		=>	:comparable_size,
				[4,0]		=>	:price_exfactory,
				[5,0]	  =>	:price_public,
				[6,0]	  =>	:deductible,
				[7,0]	  =>	:ddd_price,
				[8,0]	  =>	:active_agents,
				[9,0]	  =>	:company_name,
				[10,0]	=>	:ikscat,
				[11,0]	=>	:notify,
			}
		end
		def search_type_selection
      [ 'st_oddb', 'st_sequence', 'st_substance', 'st_company',
        'st_unwanted_effect' ]
		end
    def sequence_list_components
      {
        [0,0]	=>	:iksnr,
        [1,0]	=>	:name_base,
        [2,0]	=>	:galenic_form,
        #[3,0]	=>	:notify,
      }
    end
	end
	class LookandfeelMyMedi < SBSM::LookandfeelWrapper
		ENABLED = [
      :explain_sort,
      :compare_backbutton,
			:external_css,
      :ajax,
			:home_drugs,
			:help_link,
			:faq_link,
      :patinfos,
			:sequences,
			:ywesee_contact,
		]
		DISABLED = [ :atc_ddd, :legal_note, :navigation, :price_request ]
    DICTIONARIES = {
      'de'	=>	{
        :explain_ddd_price_url    =>  'http://www.mymedi.ch/de/tk.htm',
        :explain_generic					=>	'Blau&nbsp;=&nbsp;Generikum',
        :explain_sort             =>  'Klicken Sie auf einen der untenstehenden Begriffe um die zugehörige Spalte auf- oder absteigend zu sortieren.',
        :price_compare            =>  "Für den Direktvergleich klicken Sie bitte auf das für Sie rezeptierte Medikament.",
      },
      'fr'	=>	{
        :explain_generic					=>	'bleu&nbsp;=&nbsp;g&eacute;n&eacute;rique',
        :explain_ddd_price_url    =>  'http://www.mymedi.ch/fr/tk.htm',
        :explain_sort             =>  "Clickez sur un des mot-clé ci-dessous pour accéder au menu déroulant.",
        :price_compare            =>  'Afin d\'avoir une comparaison, clickez s.v.p. sur le médicament qui vous a été prescrit.',
      },
      'en'	=>	{
        :explain_generic					=>	'Blue&nbsp;=&nbsp;Generic Drug',
      },
    }
    HTML_ATTRIBUTES = {
      :explain_ddd_price => {'target' => '_parent'},
    }
    RESOURCES = {
      :external_css	=>	'http://www.aixede.ch/mymedi/screen.css',
    }
		def compare_list_components
			{
				[0,0]	=>	:name_base,
				[1,0]	=>	:company_name,
				[2,0]	=>	:most_precise_dose,
				[3,0]	=>	:comparable_size,
				[4,0] =>	:active_agents,
				[5,0]	=>	:price_public,
				[6,0]	=>	:ddd_price, 
				[7,0]	=>	:price_difference, 
				[8,0]	=>	:deductible, 
			}	
		end
		def explain_result_components
			{
				[0,0]	=>	:explain_original,
				[0,1]	=>	:explain_generic,
				[0,2]	=>	'explain_expired',
				[0,3]	=>	'explain_pbp',
				[0,4]	=>	:explain_deductible,
				[0,5]	=>	:explain_ddd_price,
				[1,0]	=>	:explain_patinfo,
				[1,1]	=>	:explain_complementary,
				[1,2]	=>	'explain_sl',
				[1,3]	=>	'explain_slo',
				[1,4]	=>	'explain_slg',
				[1,5]	=>	:explain_lppv,
			}
		end
		def result_list_components
			{
				[0,0]		=>	:patinfo,
				[1,0,0]	=>	'result_item_start',
				[1,0,1]	=>	:name_base,
				[1,0,2]	=>	'result_item_end',
				[2,0]		=>	:deductible,
				[3,0]		=>	:galenic_form,
				[4,0]		=>	:most_precise_dose,
				[5,0]		=>	:comparable_size,
				[6,0]		=>	:price_public,
				[7,0]		=>	:ddd_price,
				[8,0]		=>	'nbsp',
				[9,0]		=>	:company_name,
				[10,0]	=>	:ikscat,
			}
		end
		def search_type_selection
      ['st_oddb', 'st_sequence', 'st_substance', 'st_company',
        'st_indication']
		end
		def section_style
			'font-size: 16px; margin-top: 8px; line-height: 1.4em; max-width: 600px'
		end
    def sequence_list_components
      {
        [0,0]	=>	:iksnr,
        [1,0]	=>	:patinfo,
        [2,0]	=>	:name_base,
        [3,0]	=>	:galenic_form,
      }
    end
	end
	class LookandfeelSwissMedInfo < SBSM::LookandfeelWrapper
		ENABLED = [
			:home_drugs,
			:help_link,
			:faq_link,
      :patinfos,
			:sequences,
			:ywesee_contact,
		]
		DISABLED = [ :atc_ddd ]
=begin
		DICTIONARIES = {
			'de'	=>	{
				:explain_generic					=>	'Blau&nbsp;=&nbsp;Generikum',
			},
			'fr'	=>	{
				:explain_generic					=>	'bleu&nbsp;=&nbsp;g&eacute;n&eacute;rique',
			},
			'en'	=>	{
				:explain_generic					=>	'Blue&nbsp;=&nbsp;Generic Drug',
			},
		}
=end
		def compare_list_components
			{
				[0,0]	=>	:name_base,
				[1,0]	=>	:company_name,
				[2,0]	=>	:most_precise_dose,
				[3,0]	=>	:comparable_size,
				[4,0] =>	:active_agents,
				[5,0]	=>	:price_public,
				[6,0]	=>	:price_difference, 
				[7,0]	=>	:ddd_price, 
				[8,0] =>  :ikscat,
			}	
		end
		def explain_result_components
			{
				[0,0]	=>	:explain_original,
				[0,1]	=>	:explain_generic,
				[0,2]	=>	:explain_complementary,
				[0,3]	=>	'explain_expired',
				[0,4]	=>	'explain_pbp',
				[0,5]	=>	:explain_deductible,
				[0,6]	=>	:explain_ddd_price,
				[1,0]	=>	:explain_patinfo,
				[1,1]	=>	:explain_feedback,
				[1,2]	=>	:explain_google_search,
				[1,3]	=>	'explain_sl',
				[1,4]	=>	'explain_slo',
				[1,5]	=>	'explain_slg',
				[1,6]	=>	:explain_lppv,
			}
		end
		def result_list_components
			{
				[0,0]		=>	:patinfo,
				[1,0]		=>	:comarketing,
				[2,0,0]	=>	'result_item_start',
				[2,0,1]	=>	:name_base,
				[2,0,2]	=>	'result_item_end',
				[3,0]		=>	:galenic_form,
				[4,0]		=>	:most_precise_dose,
				[5,0]		=>	:comparable_size,
				[6,0]		=>	:price_public,
				[7,0]		=>	:deductible,
				[8,0]		=>	:company_name,
				[9,0]		=>	:ddd_price,
				[10,0]		=>	'nbsp',
				[11,0]	=>	:ikscat,
				[12,0]	=>	:feedback,
				[13,0]	=>  :google_search,
			}
		end
		def section_style
			'font-size: 18px; margin-top: 8px; line-height: 1.4em; max-width: 600px'
		end
	end
end
