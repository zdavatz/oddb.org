#!/usr/bin/env ruby
# encoding: utf-8
# SBSM::LookandfeelWrapper - oddb.org -- 07.09.2011 -- mhatakeyama@ywesee.com
# SBSM::LookandfeelWrapper - oddb.org -- 21.07.2003 -- mhuggler@ywesee.com

require 'sbsm/lookandfeelwrapper'
require 'state/drugs/sequences'
require 'util/money'

module SBSM
  class LookandfeelWrapper < Lookandfeel
    RESULT_FILTER = nil
    def format_price(price, currency=nil)
      unless(price.is_a?(ODDB::Util::Money))
        price = price.to_f / 100.0
      end
      if(price.to_i > 0)
        [currency, sprintf('%.2f', price)].compact.join(' ')
      end
    end
    def has_result_filter?
      !!self.class::RESULT_FILTER
    end
    def result_filter pac_or_seq
      res = @component.result_filter pac_or_seq
      if res && flt = self.class::RESULT_FILTER
        res &&= flt.call(pac_or_seq)
      end
      res
    end
  end
end
module ODDB
	class LookandfeelStandardResult < SBSM::LookandfeelWrapper
		ENABLED = [
      :fachinfos, :feedback,
    ]
		def compare_list_components
			{
				[0,0]	=>	:name_base,
				[1,0]	=>	:company_name,
				[2,0]	=>	:comparable_size,
				[3,0] =>	:compositions,
				[4,0]	=>	:price_public,
				[5,0]	=>	:price_difference,
				[6,0]	=>	:deductible,
				[7,0] =>  :ikscat,
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
				[7,0]		=>	:comparable_size,
				[8,0]		=>	:price_exfactory,
				[9,0]	  =>	:price_public,
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
      :ddd_chart,
      :facebook_fan,
      :facebook_share,
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
      :price_history,
      :price_rise_rss,
      :sl_introduction_rss,
			:sponsor,
			:sponsorlogo,
      :twitter_share,
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
		HTML_ATTRIBUTES = { }
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
				[4,0] =>	:compositions,
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
	class LookandfeelJustMedical < SBSM::LookandfeelWrapper
		ENABLED = [
			:atc_chooser,
			:custom_navigation,
      :custom_tab_navigation,
			:drugs, 
			:external_css,
      :fachinfos, 
      :feedback,
			:home,
			:home_drugs,
			:home_migel,
      :interactions, 
			:just_medical_structure,	
			:migel,
			:migel_alphabetical,
			:popup_links,
			:search_reset,
			:sequences,
      :topfoot,
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
        :price_compare              =>  "Für Preisvergleich auf Medikamentnamen klicken.",
				:search_explain							=>	'',
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
        :price_compare              =>  "Pour comparaison de prix cliquer sur nom du médicament",
				:search_explain							=>	'',
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
        :price_compare              =>  "Click name of drug for price-comparison",
				:search_explain							=>	'',
				:sequences									=>	'Drugs A-Z',
			},
		}
		DISABLED = [ :pointer_steps_header ]
		RESOURCES = {
			:external_css	=>	'http://www.just-medical.com/css/new.oddb.css',
		}
		def compare_list_components
			{
				[0,0]	=>	:name_base,
				[1,0]	=>	:company_name,
				[2,0]	=>	:most_precise_dose,
				[3,0]	=>	:comparable_size,
				[4,0] =>	:compositions,
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
				[15,0]	=>  :google_search,
			}
		end
		def zones
			[ :analysis, :interactions, State::Drugs::Init, State::Drugs::AtcChooser, 
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
      :atc_chooser,
      :drugs,
      :export_csv,
      :external_css,
      :faq_link,
      :help_link,
      :home,
      :home_drugs,
      :home_migel,
      :logout,
      :migel,
      :migel_alphabetical,
      :oekk_structure,
      :recent_registrations,
      :search_reset,
      :sequences,
      :ywesee_contact,
    ]
    DICTIONARIES = {
      'de'  =>  {
        :de                   =>  'd',
        :explain_generic      =>  'Blau&nbsp;=&nbsp;Generikum',
        :en                   =>  'e',
        :fr                   =>  'f',
        :oekk_department      =>  'Medikamentenvergleich online',
        :oekk_logo            =>  '&Ouml;KK - jung und unkompliziert.',
        :oekk_title           =>  'Ihr Einsparungspotential mit Generika',
      },
      'fr'  =>	{
        :explain_generic  =>	'bleu&nbsp;=&nbsp;g&eacute;n&eacute;rique',
        :oekk_department  =>	'Comparaison de m&eacute;dicaments sur ligne',
        :oekk_logo  			=>	'&Ouml;KK - jeune et sympa.',
        :oekk_title  			=>	'V&ocirc;tre &eacute;conomie potentielle avec g&eacute;n&eacute;riques',
      },
      'en'  =>	{
        :explain_generic  =>	'Blue&nbsp;=&nbsp;Generic Drug',
        :oekk_department  =>	'Drug comparison online',
        :oekk_logo  			=>	'&Ouml;KK - young and easy.',
        :oekk_title  			=>	'Your potential savings with generics',
      },
    }
    DISABLED = [ :best_result, :explain_link ]
    RESOURCES = {
      :external_css	=>	'http://www.oekk.ch/_css/oddb.css',
    }
    HTML_ATTRIBUTES = { }
    def compare_list_components
      {
        [0,0]	=>	:name_base,
        [1,0]	=>	:company_name,
        [2,0]	=>	:most_precise_dose,
        [3,0]	=>	:comparable_size,
        [4,0] =>	:compositions,
        [5,0]	=>	:price_public,
        [6,0]	=>	:price_difference,
        [7,0]	=>	:deductible,
        [8,0] =>  :ikscat,
      }
    end
    def explain_result_components
      {
        [0,0]	=>	'explain_expired',
        [0,1]	=>	:explain_complementary,
        [0,2]	=>	:explain_homeopathy,
        [0,3]	=>	:explain_anthroposophy,
        [0,4] =>	:explain_phytotherapy,
        [0,5]	=>	:explain_parallel_import,
        [0,6]	=>	:explain_vaccine,
        [1,0]	=>	:explain_fachinfo,
        [1,1]	=>	:explain_patinfo,
        [1,2]	=>	:explain_limitation,
        [1,3]	=>	:explain_narc,
        [1,4]	=>	'explain_pbp',
        [1,5]	=>	'explain_pr',
        [1,6]	=>	:explain_deductible,
      }
    end
    def languages
      [:de, :fr, :en]
    end
    def result_list_components
      {
        [0,0,0] =>  'result_item_start',
        [0,0,1] =>  :name_base,
        [0,0,2] =>  'result_item_end',
        [1,0]   =>  :galenic_form,
        [2,0]   =>  :most_precise_dose,
        [3,0]   =>  :comparable_size,
        [4,0]   =>  :price_public,
        [5,0]   =>  :deductible,
        [6,0]   =>  :company_name,
        [7,0]   =>  :limitation_text,
        [8,0]   =>  :narcotic,
        [9,0]   =>  :complementary_type,
        [10,0]  =>  :fachinfo,
        [11,0]  =>  :patinfo,
      }
    end
  end
  class LookandfeelMobile < SBSM::LookandfeelWrapper
    ENABLED = [
 			:atc_chooser,
      :breadcrumbs,
      :companylist,
			:data_counts,
      :drugs,
      :fachinfos,
			:faq_link,
      :feedback,
			:help_link,
			:home,
			:home_drugs,
      :download_export,
      :legal_note_vertical,
      :limitation_texts,
      :login_form,
      :logo,
			:logout,
      :patinfos, 
      :query_limit,
			:recent_registrations,
			:search_reset,
			:sequences,
			:topfoot,
      :user,
			:ywesee_contact,
   ]
    def result_list_components
      {
        [0,0]		=>	:limitation_text,
        [1,0]		=>  :minifi,
        [2,0]		=>  :fachinfo,
        [3,0]		=>	:patinfo,
        [4,0,0]	=>	:narcotic,
        [4,0,1]	=>	:complementary_type,
        [4,0,2]	=>	:comarketing,
        [5,0,0]	=>	'result_item_start',
        [5,0,1]	=>	:name_base,
        [5,0,2]	=>	'result_item_end',
        [6,0]		=>	:comparable_size,
        [7,0]		=>	:price_exfactory,
        [8,0]	=>	:price_public,
        [9,0]	=>	:ddd_price,
        [10,0]	=>	:compositions,
        [11,0]	=>	:ikscat,
        [12,0]	=>	:feedback,
        [13,0]	=>  :google_search,
        [14,0]	=>	:notify,
      }
    end
    def explain_result_components
      {
        [0,0]  => :explain_original,
        [0,1]  => :explain_generic,
        [0,2]  => 'explain_unknown',
        [0,3]  => 'explain_expired',
        [0,4]  => :explain_complementary,
        [0,5]  => :explain_homeopathy,
        [0,6]  => :explain_anthroposophy,
        [0,7]  => :explain_phytotherapy,
        [0,8]  => :explain_cas,
        [0,9]  => :explain_parallel_import,
        [0,10] => :explain_comarketing,
        [0,11] => :explain_narc,
        [0,12] => :explain_google_search,
        [0,13] => :explain_feedback,
        [1,0]  => :explain_vaccine,
        [1,1]  => :explain_minifi,
        [1,2]  => :explain_fachinfo,
        [1,3]  => :explain_patinfo,
        [1,4]  => :explain_limitation,
        [1,5]  => :explain_ddd_price,
        [1,6]  => 'explain_efp',
        [1,7]  => 'explain_pbp',
        [1,8]  => 'explain_pr',
        [1,9]  => 'explain_sl',
        [1,10] => 'explain_slo',
        [1,11] => 'explain_slg',
        [1,12] => :explain_lppv,
      }
    end
  end
	class LookandfeelMyMedi < SBSM::LookandfeelWrapper
		ENABLED = [
      :explain_sort,
      :compare_backbutton,
      :custom_tab_navigation,
      :ddd_chart,
			:external_css,
      :ajax,
			:home_drugs,
			:help_link,
			:faq_link,
      :patinfos,
			:sequences,
			:price_history,
			:ywesee_contact,
		]
		DISABLED = [ :atc_ddd, :legal_note, :navigation, :price_request ]
    DICTIONARIES = {
      'de'	=>	{
        :explain_ddd_price_url    =>  'http://www.mymedi.ch/de/tk.htm',
        :explain_generic					=>	'Blau&nbsp;=&nbsp;Generikum',
        :explain_sort             =>  'Klicken Sie auf einen der untenstehenden Begriffe um die zugehörige Spalte auf- oder absteigend zu sortieren.',
        :price_compare            =>  "Für den Direktvergleich klicken Sie bitte auf das für Sie rezeptierte Medikament.",
				:sequences								=>	'Medikamente A-Z',
      },
      'fr'	=>	{
        :explain_generic					=>	'bleu&nbsp;=&nbsp;g&eacute;n&eacute;rique',
        :explain_ddd_price_url    =>  'http://www.mymedi.ch/fr/tk.htm',
        :explain_sort             =>  "Clickez sur un des mot-clé ci-dessous pour accéder au menu déroulant.",
        :price_compare            =>  'Afin d\'avoir une comparaison, clickez s.v.p. sur le médicament qui vous a été prescrit.',
				:sequences								=>	'Médicaments A-Z',
      },
      'en'	=>	{
        :explain_generic					=>	'Blue&nbsp;=&nbsp;Generic Drug',
				:sequences								=>	'Drugs A-Z',
      },
    }
    HTML_ATTRIBUTES = {
      :explain_ddd_price => {'target' => '_parent'},
    }
    RESOURCES = {
      :external_css	=>	'http://www.mymedi.ch/css/oddb.css',
    }
		def compare_list_components
			{
				[0,0]	=>	:name_base,
				[1,0]	=>	:company_name,
				[2,0]	=>	:most_precise_dose,
				[3,0]	=>	:comparable_size,
				[4,0] =>	:compositions,
				[5,0]	=>	:price_public,
				[6,0]	=>	:ddd_price, 
				[7,0]	=>	:price_difference, 
				[8,0]	=>	:deductible, 
			}	
		end
		PH_END = Date.new(2010,4,10)
		def enabled?(event, default=false)
		  if event == :price_history && @@today < PH_END
		    true
		  else
		    super
		  end
		end
		def explain_result_components
			{
				[0,1]	=>	:explain_original,
				[0,2]	=>	:explain_generic,
				[0,3]	=>	'explain_expired',
				[0,4]	=>	'explain_pbp',
				[0,5]	=>	:explain_deductible,
				[0,6]	=>	:explain_ddd_price,
				[1,0]	=>	:explain_patinfo,
				[1,1]	=>	:explain_limitation,
				[1,2]	=>	:explain_complementary,
				[1,3]	=>	'explain_sl',
				[1,4]	=>	'explain_slo',
				[1,5]	=>	'explain_slg',
				[1,6]	=>	:explain_lppv,
			}
		end
		def result_list_components
			{
				[0,0]		=>	:limitation_text,
				[1,0]		=>	:patinfo,
				[2,0,0]	=>	'result_item_start',
				[2,0,1]	=>	:name_base,
				[2,0,2]	=>	'result_item_end',
				[3,0]		=>	:deductible,
				[4,0]		=>	:galenic_form,
				[5,0]		=>	:most_precise_dose,
				[6,0]		=>	:comparable_size,
				[7,0]		=>	:price_public,
				[8,0]		=>	:ddd_price,
				[9,0]		=>	'nbsp',
				[10,0]	=>	:company_name,
				[11,0]	=>	:ikscat,
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
        [3,0]	=>	:compositions,
      }
    end
		def zones
      # Do not show Medikamente A-Z for mymedi Look & Feel
      # This zone is refered from src/view/tab_navigation.rb
      # and it is used to customize tab navigation.
			#[ State::Drugs::Sequences ]
			[]
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
		def compare_list_components
			{
				[0,0]	=>	:name_base,
				[1,0]	=>	:company_name,
				[2,0]	=>	:most_precise_dose,
				[3,0]	=>	:comparable_size,
				[4,0] =>	:compositions,
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
  class LookandfeelComplementaryType < SBSM::LookandfeelWrapper
    ENABLED = [
      :home_drugs,
      :help_link,
      :faq_link,
      :patinfos,
      :sequences,
      :ywesee_contact,
      :logo,
    ]
    def explain_result_components
      {
        [0,0]	=>	:explain_minifi,
        [0,1]	=>	:explain_fachinfo,
        [0,2]	=>	:explain_patinfo,
        [0,3]	=>	:explain_limitation,
        [0,4]	=>	:explain_parallel_import,
        [0,5]	=>	:explain_comarketing,
        [0,6]	=>	:explain_google_search,
        [0,7]	=>	:explain_feedback,
        [1,0]	=>	'explain_expired',
        [1,1]	=>	'explain_efp',
        [1,2]	=>	'explain_pbp',
        [1,3]	=>	'explain_pr',
        [1,4]	=>	:explain_deductible,
        [1,5]	=>	:explain_ddd_price,
        [1,6]	=>	'explain_sl',
        [1,7]	=>	:explain_lppv,
      }
    end
    def result_list_components
      {
        [0,0]		=>	:limitation_text,
        [1,0]		=>  :minifi,
        [2,0]		=>  :fachinfo,
        [3,0]		=>	:patinfo,
        [4,0,0]	=>	:narcotic,
        [4,0,1]	=>	:comarketing,
        [5,0,0]	=>	'result_item_start',
        [5,0,1]	=>	:name_base,
        [5,0,2]	=>	'result_item_end',
        [6,0]		=>	:comparable_size,
        [7,0]		=>	:price_exfactory,
        [8,0]	=>	:price_public,
        [9,0]	=>	:deductible,
        [10,0]	=>	:ddd_price,
        [11,0]	=>	:compositions,
        [12,0]	=>	:company_name,
        [13,0]	=>	:ikscat,
        [14,0]	=>	:feedback,
        [15,0]	=>  :google_search,
        [16,0]	=>	:notify,
      }
    end
  end
  class LookandfeelAnthroposophy < SBSM::LookandfeelWrapper
    RESULT_FILTER = Proc.new do |seq| seq.complementary_type == :anthroposophy end
    HTML_ATTRIBUTES = {
      :logo => {
        'width'		=>	'370',
        'height'	=>	'166',
      },
    }
    DICTIONARIES = {
      'de'  =>  {
        :html_title         =>  'anthroposophika.ch - alle anthroposophischen Arzneimittel im schweizer Gesundheitswesen', 
        :home_welcome       =>  "Willkommen bei anthroposophika.ch, dem<br>Portal für anthroposophische Arzneimittel in der Schweiz.",
        :login_welcome      =>  'Willkommen bei anthroposophika.ch',
        :generic_definition =>  'Was ist ein anthroposophisches Arzneimittel?',
        :generic_definition_url => 'http://www.google.com/search?hl=en&sa=X&oi=spell&resnum=0&ct=result&cd=1&q=anthroposophische+Arzneimittel&spell=1',
      },
      'fr'  =>  {
        :html_title         =>  'anthroposophika.ch - tous les médicaments anthroposophiques Arzneimittel sur le marché suisse', 
        :home_welcome       =>  "Bienvenue sur anthroposophika.ch,<br>le portail des médicaments anthroposophiques dans la suisse.",
        :login_welcome      =>  'Bienvenue sur anthroposophika.ch',
        :generic_definition =>  'Qu\'est qu\'n médicament anthroposophique?',
        :generic_definition_url => 'http://www.google.com/search?hl=en&sa=X&oi=spell&resnum=0&ct=result&cd=1&q=médicament+anthroposophique&spell=1',
      },
      'en'  =>  {
        :html_title         =>  'anthroposophika.ch - all anthroposophical health-care products in the swiss market', 
        :home_welcome       =>  "Welcome to anthroposophika.ch,<br>the database of anthroposophical health-care products in switzerland.",
        :login_welcome      =>  'Welcome to anthroposophika.ch',
        :generic_definition =>  'What is anthroposophical medicine?',
        :generic_definition_url => 'http://www.google.com/search?hl=en&sa=X&oi=spell&resnum=0&ct=result&cd=1&q=anthroposophical+medicine&spell=1',
      }
    }
  end
  class LookandfeelHomeopathy < SBSM::LookandfeelWrapper
    RESULT_FILTER = Proc.new do |seq| seq.complementary_type == :homeopathy end
    HTML_ATTRIBUTES = {
      :logo => {
        'width'		=>	'370',
        'height'	=>	'166',
      },
    }
    DICTIONARIES = {
      'de'  =>  {
        :html_title         =>  'homöopathika.ch - alle homöopathischen Arzneimittel im schweizer Gesundheitswesen', 
        :home_welcome       =>  "Willkommen bei homöopathika.ch, dem<br>Portal für homöopathische Arzneimittel in der Schweiz.",
        :login_welcome      =>  'Willkommen bei homöopathika.ch',
        :generic_definition =>  'Was ist ein homöopathisches Arzneimittel?',
        :generic_definition_url => 'http://de.wikipedia.org/wiki/Hom%C3%B6opathisches_Arzneimittel',
      },
      'fr'  =>  {
        :html_title         =>  'homöopathika.ch - tous les médicaments homéopathiques Arzneimittel sur le marché suisse', 
        :home_welcome       =>  "Bienvenue sur homöopathika.ch,<br>le portail des médicaments homéopathiques dans la suisse.",
        :login_welcome      =>  'Bienvenue sur homöopathika.ch',
        :generic_definition =>  'Qu\'est qu\'n médicament homéopathique?',
        :generic_definition_url => 'http://fr.wikipedia.org/wiki/Hom%C3%A9opathie',
      },
      'en'  =>  {
        :html_title         =>  'homöopathika.ch - all homeopathical health-care products in the swiss market', 
        :home_welcome       =>  "Welcome to homöopathika.ch,<br>the database of homeopathical health-care products in switzerland.",
        :login_welcome      =>  'Welcome to homöopathika.ch',
        :generic_definition =>  'What is anthroposophical medicine?',
        :generic_definition_url => 'http://en.wikipedia.org/wiki/Homeopathic_medicine',
      }
    }
  end
  class LookandfeelPhytoPharma < SBSM::LookandfeelWrapper
    RESULT_FILTER = Proc.new do |seq| seq.complementary_type == :phytotherapy end
    HTML_ATTRIBUTES = {
      :logo => {
        'width'		=>	'344',
        'height'	=>	'106',
      },
    }
    DICTIONARIES = {
      'de'  =>  {
        :html_title         =>  'phyto-pharma.ch - alle phyto-therapeutischen Arzneimittel im schweizer Gesundheitswesen', 
        :home_welcome       =>  "Willkommen bei phyto-pharma.ch, dem<br>Portal für phyto-therapeutische Arzneimittel in der Schweiz.",
        :login_welcome      =>  'Willkommen bei phyto-pharma.ch',
        :generic_definition =>  'Was ist ein Phytopharmakon?',
        :generic_definition_url => 'http://de.wikipedia.org/wiki/Phytopharmakon',
      },
      'fr'  =>  {
        :html_title         =>  'phyto-pharma.ch - tous les médicaments phyto-therapeutiques Arzneimittel sur le marché suisse', 
        :home_welcome       =>  "Bienvenue sur phyto-pharma.ch,<br>le portail des médicaments phyto-therapeutiques dans la suisse.",
        :login_welcome      =>  'Bienvenue sur phyto-pharma.ch',
        :generic_definition =>  'Was ist ein Phytopharmakon?',
        :generic_definition =>  'Qu\'est qu\'n médicament pharmacokinétique?',
        :generic_definition_url => 'http://fr.wikipedia.org/wiki/Phytopharmacie',
      },
      'en'  =>  {
        :html_title         =>  'phyto-pharma.ch - all phyto-therapeutical health-care products in the swiss market', 
        :home_welcome       =>  "Welcome to phyto-pharma.ch,<br>the database of phyto-therapeutical health-care products in switzerland.",
        :login_welcome      =>  'Welcome to phyto-pharma.ch',
        :generic_definition =>  'What is phyto-therapeutical medicine?',
        :generic_definition_url => 'http://en.wikipedia.org/wiki/Phytotherapy',
      }
    }
  end
  class LookandfeelDesitin < SBSM::LookandfeelWrapper
    RESULT_FILTER = Proc.new do |seq| (comp = seq.company) && comp.oid == 215 end
    ENABLED = [ :ajax, :breadcrumbs, :ddd_chart, :login_form, :logo, :logout,
                :ywesee_contact, ]
    DICTIONARIES = {
      'de' => {
        :ywesee_contact_email => 'Franziska.Almgard@desitin.ch',
        :ywesee_contact_href  => 'mailto:Fransziska.Almgard@desitin.ch',
        :ywesee_contact       => 'Kontakt',
        :ywesee_contact_name  => 'Franziska Almgard',
        :ywesee_contact_text  => 'Bitte schreiben Sie an:',
      }
    }
    DISABLED = [ :search, :zone_navigation ]
    HTML_ATTRIBUTES = {
      :logo => {
        'width'  => '168',
        'height' => '95',
        'href'   => 'http://www.desitin.ch',
      },
    }
    RESOURCES = {
      :logo => 'logo.jpg',
    }
  end
end
