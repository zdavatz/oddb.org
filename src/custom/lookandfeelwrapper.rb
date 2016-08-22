#!/usr/bin/env ruby
# encoding: utf-8
# SBSM::LookandfeelWrapper - oddb.org -- 27.12.2012 -- yasaka@ywesee.com
# SBSM::LookandfeelWrapper - oddb.org -- 16.01.2012 -- mhatakeyama@ywesee.com
# SBSM::LookandfeelWrapper - oddb.org -- 21.07.2003 -- mhuggler@ywesee.com

require 'sbsm/lookandfeelwrapper'
require 'state/drugs/sequences'
require 'util/money'

module SBSM
  class LookandfeelWrapper < Lookandfeel
    def google_analytics_token
      "UA-115196-1"
    end
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
      :fachinfos,
      :feedback,
    ]
    def compare_list_components
      {
        [0,0]  => :prescription,
        [1,0]  => :fachinfo,
        [2,0]  => :patinfo,
        [3,0]  => :name_base,
        [4,0]  => :company_name,
        [5,0]  => :comparable_size,
        [6,0]  => :compositions,
        [7,0]  => :price_public,
        [8,0]  => :price_difference,
        [9,0]  => :deductible,
        [10,0] => :ikscat,
      }
    end
    def explain_result_components
      {
        [0,0] => :explain_original,
        [0,0] => :explain_original,
        [0,1] => :explain_generic,
        [0,2] => 'explain_unknown',
        [0,3] => 'explain_expired',
        [0,4] => :explain_homeopathy,
        [0,5] => :explain_anthroposophy,
        [0,6] => :explain_phytotherapy,
        [0,7] => :explain_cas,
        [1,0] => :explain_parallel_import,
        [1,1] => :explain_comarketing,
        [1,2] => :explain_vaccine,
        [1,3] => :explain_narc,
        [1,4] => :explain_fachinfo,
        [1,5] => :explain_patinfo,
        [1,6] => :explain_limitation,
        [1,7] => :explain_google_search,
        [1,8] => :explain_feedback,
        [2,0] => 'explain_efp',
        [2,1] => 'explain_pbp',
        [2,2] => 'explain_pr',
        [2,3] => :explain_deductible,
        [2,4] => 'explain_sl',
        [2,5] => 'explain_slo',
        [2,6] => 'explain_slg',
        [2,7] => :explain_lppv,
      }
    end
    def result_list_components
      {
        [0,0]   => :limitation_text,
        [1,0]   => :prescription,
        [2,0]   => :fachinfo,
        [3,0]   => :patinfo,
        [4,0]   => :narcotic,
        [5,0]   => :complementary_type,
        [6,0,0] => 'result_item_start',
        [6,0,1] => :name_base,
        [6,0,2] => 'result_item_end',
        [7,0]   => :galenic_form,
        [8,0]   => :comparable_size,
        [9,0]   => :price_exfactory,
        [10,0]  => :price_public,
        [11,0]  => :deductible,
        [12,0]  => :substances,
        [13,0]  => :company_name,
        [14,0]  => :ikscat,
        [15,0]  => :registration_date,
        [16,0]  => :feedback,
        [17,0]  => :google_search,
        [18,0]  => :notify,
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
      :generic_definition,
      :limitation_texts,
      :logo,
      :minifi_rss,
      :multilingual_logo,
      :patinfos,
      :paypal,
      :screencast,
      :price_cut_rss,
      :price_history,
      :price_rise_rss,
      :sl_introduction_rss,
      :sponsor,
      :sponsorlogo,
      :show_ean13,
      :twitter_share,
    ]
    DISABLED = [
      :atc_drugbank_link,
      :atc_dosing_link,
      :atc_division_link,
      :atc_pharmacokinetic_link,
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
      [ :drugs, :user, :companies ]
    end
    def zone_navigation(filter=false)
      super
    end
  end
	class LookandfeelSantesuisse < SBSM::LookandfeelWrapper
    ENABLED = [
      :ajax,
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
    def zones(filter=false)
      [ :doctors, :drugs ]
    end
	end
  class LookandfeelEvidentia < SBSM::LookandfeelWrapper
    def google_analytics_token
      'UA-22215261-3'
    end
    ENABLED = [
      :ajax,
      :evidentia,
      :just_medical_structure,
      :custom_navigation,
      :custom_tab_navigation,
      :google_analytics,
      :drugs,
      :external_css,
      :help_link,
      :legal_note_vertical,
      :link_trade_name_to_fachinfo,
      :link_pubprice_to_price_comparison,
      :logout,
      :patinfos,
      :popup_links,
      :sequences,
      :display_3_active_agents,
      :display_fachinfo_th,
      :prepend_limitation_text,
      :show_legend_by_default,
    ]
    DISABLED = [
      :atc_ddd,
      :atc_drugbank_link,
      :atc_dosing_link,
      :atc_division_link,
      :atc_pharmacokinetic_link,
      :legal_note,
      :explain_atc,
      :explain_link,
      :explain_comarketing_url,
      :explain_efp_url,
      :explain_pbp_url,
      :explain_ddd_price_url,
      :explain_deductible_url,
      :explain_generic_url,
      :explain_narc_url,
      :explain_lppv_url,
      :explain_original_url,
      :explain_vaccine_url,
      :feedback,
      :fi_link_to_ddd,
      :navigation,
      :price_request,
      :search_result_head_navigation,
      :substances_link,
      :photo_link,
      :show_substance_dose,
    ]
    DICTIONARIES = {
      'de'  =>  {
        :change_log               =>  'Textänderungen',
        :deductible_title0        =>  'Für dieses Produkt bezahlen Sie ',
        :deductible_title1        =>  ' Selbstbehalt.<br>Achten Sie auf Ihre Krankenkassen-Abrechnung!',
        :explain_comarketing_url   =>  false,
        :explain_ddd_price_url     =>  false,
        :explain_deductible_url    =>  false,
        :explain_generic_url       =>  false,
        :explain_original         =>  'Blau&nbsp;=&nbsp;Original',
        :explain_original_url      =>  false,
        :explain_search            =>  'Sie können nach Originalpräparat, Generikum oder Wirkstoff suchen.<br>Die Suche erfolgt nach dem ATC-Code. ',
        :explain_vaccine_url       =>  false,
        :fachinfo_clinic_info     =>  'Klinische Informationen',
        :fachinfo_extra_info      =>  'Zusatzinformationen',
        :fachinfo_all_icon        =>  'evidentia/Vollstaendige_Fachinformation.png',
        :fachinfo_print_icon      =>  'evidentia/Drucken.png',
        :fachinfo_product_overview_link_icon      =>  'evidentia/evidentia.png',
        :fachinfo_indications_icon    => 'evidentia/Indikationen.png',
        :fachinfo_usage_icon          => 'evidentia/Dosierung.png',
        :fachinfo_contra_indications_icon  => 'evidentia/Kontraindikationen.png',
        :fachinfo_restrictions_icon   => 'evidentia/Warnhinweise.png',
        :fachinfo_interactions_icon   => 'evidentia/Interaktionen.png',
        :fachinfo_pregnancy_icon      => 'evidentia/Schwangerschaft.png',
        :fachinfo_driving_ability_icon  => 'evidentia/Fahrtuechtigkeit.png',
        :fachinfo_unwanted_effects_icon  => 'evidentia/Unerwuenschte_Wirkungen.png',
        :fachinfo_overdose_icon       => 'evidentia/Ueberdosierung.png',
        :fachinfo_effects_icon        => 'evidentia/Eigenschaften.png',
        :fachinfo_kinetic_icon        => 'evidentia/Pharmakokinetik.png',
        :fachinfo_preclinic_icon      => 'evidentia/Praeklinische_Daten.png',
        :fachinfo_photo_icon          => 'evidentia/Foto.png',
        :fachinfo_composition_icon    => 'evidentia/Zusammensetzung.png',
        :fachinfo_galenic_form_icon   => 'evidentia/Galenische_Form.png',
        :fachinfo_other_advice_icon   => 'evidentia/Sonstige_Hinweise.png',
        :fachinfo_iksnrs_icon         => 'evidentia/Zulassungsnummer.png',
        :fachinfo_packages_icon       => 'evidentia/Packungen.png',
        :fachinfo_registration_owner_icon  => 'evidentia/Zulassungsinhaber.png',
        :fachinfo_date_icon           => 'evidentia/Stand_der_Information.png',
        :fachinfo_change_log_icon     => 'evidentia/Textaenderungen.png',
        :fachinfo_all             =>  'Vollständige Fachinformation',
        :product_overview_link    =>  'Produktportrait',
        :fi_composition           =>  'Zusammensetzung',
        :fi_contra_indications    =>  'Kontraindikationen',
        :fi_date                  =>  'Stand der Information',
        :fi_driving_ability       =>  'Fahrtüchtigkeit',
        :fi_effects               =>  'Eigenschaften',
        :fi_galenic_form_amzv     =>  'Galenische Form',
        :fi_iksnrs                =>  'Zulassungsnummer',
        :fi_indications           =>  'Indikationen',
        :fi_interactions          =>  'Interaktionen',
        :fi_kinetic               =>  'Pharmakokinetik',
        :fi_other_advice          =>  'Sonstige Hinweise',
        :fi_overdose              =>  'Überdosierung',
        :fi_preclinic             =>  'Präklinische Daten',
        :fi_product_overview_link =>  'evidentia Produktportrait',
        :fi_registration_owner    =>  'Zulassungsinhaberin',
        :fi_restrictions_amzv     =>  'Warnhinweise',
        :fi_unwanted_effects      =>  'Unerwünschte Wirkungen',
        :fi_usage                 =>  'Dosierung',
        :html_title               =>  'evidentia - Wissen und Werkzeuge für Ärzte',
        :price_compare            =>  'F&uuml;r den Direktvergleich klicken Sie bitte <br>auf den Medikamentennamen im Suchergebnis!',
        :refdata                  =>  'In RefData nicht gelistet',
        :th_fachinfo              =>  'Fach&shy;info',
        :th_ikscat                =>  'Ka&shy;te&shy;go&shy;ri&shy;sie&shy;rung',
        :th_price_public          =>  'PP/&shy;Vergleich',
      },
      'fr'  =>  {
        :deductible_title0        =>  'Le quote-part pour ce produit est ',
        :deductible_title1        =>  '.<br>Faites attention à votre facture de la caisse maladie!',
        :explain_comarketing_url   =>  false,
        :explain_ddd_price_url     =>  false,
        :explain_deductible_url    =>  false,
        :explain_generic_url       =>  false,
        :explain_original         =>  'bleu&nbsp;=&nbsp;original',
        :explain_original_url      =>  false,
        :explain_search           =>  'Vous pouvez chercher des produit spécifiques génériques ou des principes actifs.<br>La recherche est basée sur le code ATC.',
        :explain_unknown          =>  'noir&nbsp;=&nbsp;pas classes',
        :explain_vaccine_url       =>  false,
        :fachinfo_all             =>  'Information professionnelle complète',
        :product_overview_link    =>  'Portrait du produit',
        :fi_composition           =>  'Composition',
        :fi_contra_indications    =>  'Contre-indication',
        :fi_date                  =>  'Mise à jour',
        :fi_driving_ability       =>  'Aptitude à la conduite',
        :fi_effects               =>  'Effect',
        :fi_galenic_form_amzv     =>  'Forme galénique',
        :fi_iksnrs                =>  'Numéro registration',
        :fi_indications           =>  'Indications',
        :fi_interactions          =>  'Interactions',
        :fi_kinetic               =>  'Pharmacocinétique',
        :fi_overdose              =>  'Surdosage',
        :fi_preclinic             =>  'Données précliniques',
        :fi_product_overview_link =>  'evidentia portrait produit',
        :fi_registration_owner    =>  'Titulaire',
        :fi_restrictions_amzv     =>  'Précautions',
        :fi_unwanted_effects      =>  'Effets indésirables',
        :fi_usage                 =>  'Posologuie',
        :home_welcome              =>  'Bienvenu sur <a href="http://www.evidentia.ch/">evidentia</a> et oddb.org',
        :html_title                =>  'evidentia - savoir et outils pour médecins',
        :price_compare            =>  'Pour la comparaison directe, cliquez s.v.p.<br>sur le nom du m&eacute;dicament dans le r&eacute;sultat de la recherche!',
        :refdata                  =>  'Ne figurant pas dans RefData',
        :th_fachinfo              =>  'Infor&shy;mation pro&shy;fession&shy;nelle',
        :th_price_public          =>  'PP/&shy;Comparaison',
      },
      'en'  =>  {
        :html_title               =>  'evidentia - know-how and tools for doctors',
        :home_welcome             =>  'Welcome to <a href="http://www.evidentia.ch/">evidentia</a> and oddb.org',
      },
    }
    RESOURCES = {
      :external_css => 'http://evidentia.ch/css/oddb.css',
    }
    def compare_list_components
      {
        [2,0]  => :name_base,
        [3,0]  => :company_name,
        [4,0]  => :most_precise_dose,
        [5,0]  => :comparable_size,
        [6,0]  => :compositions,
        [7,0]  => :price_exfactory,
        [8,0]  => :price_public,
        [9,0]  => :price_difference,
        [10,0] => :deductible,
        [10,0] => :ikscat,
      }
    end
    def explain_result_components
      {
        [0,0] =>  :explain_original,
        [0,1] =>  :explain_generic,
        [0,2] =>  'explain_unknown',
        [0,3] =>  :explain_limitation,

        [1,0] =>  'explain_efp',
        [1,1] =>  'explain_pbp',
        [1,2] =>  :explain_deductible,
        [1,3] =>  'explain_sl',

        [2,0] =>  'explain_slg',
        [2,1] =>  'explain_slo',
        [2,2] =>  :explain_lppv
      }
    end
    def navigation
      [ :meddrugs_update, :data_declaration ] + zone_navigation + [ :home ]
    end
    def result_list_components
      {
        [0,0,0] => :name_base,
        [0,0,1] => 'result_item_end',
        [0,0,2] => :limitation_text,
        [1,0]   => :product_overview_link,
        [2,0]   => :substances,
        [3,0]   => :galenic_form,
        [4,0]   => :most_precise_dose,
        [5,0]   => :comparable_size,
        [6,0]   => :price_exfactory,
        [7,0]   => :price_public,
        [8,0]   => :deductible,
        [9,0]   => :company_name,
        [10,0]  => :ikscat,
      }
    end
    def search_type_selection
      ['st_combined']
    end
    def zones
      [
        :analysis, :interactions,
        State::Drugs::Init, State::Drugs::AtcChooser, State::Drugs::Sequences
      ]
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
  class LookandfeelJustMedical < SBSM::LookandfeelWrapper
    ENABLED = [
      :ajax,
      :atc_chooser,
      :breadcrumbs,
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
      :popup_links,
      :powerlink,
      :recall_rss,
      :hpc_rss,
      :search_reset,
      :sequences,
      :show_ean13,
      :topfoot,
    ]
    DISABLED = [
      :rss_box,
      :search_result_head_navigation,
      :pointer_steps_header,
      :language_switcher,
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
    RESOURCES = {
      :external_css => 'http://www.just-medical.com/css/new.oddb.css',
    }
    def compare_list_components
      {
        [0,0]  => :prescription,
        [2,0] => :fachinfo,
        [3,0] => :patinfo,
        [4,0] => :name_base,
        [4,0] => :company_name,
        [5,0] => :comparable_size,
        [6,0] => :compositions,
        [7,0] => :price_public,
        [8,0] => :price_difference,
        [9,0] => :deductible,
        [10,0] => :ikscat,
      }
    end
		def explain_result_components
			{
				[0,0]	=>	:explain_original,
				[0,1]	=>	:explain_generic,
				[0,2]	=>	:explain_comarketing,
				[0,3]	=>	:explain_vaccine,
				[0,4]	=>	'explain_unknown',
				[0,5]	=>	'explain_expired',
				[0,6]	=>	:explain_cas,
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
				[2,3]	=>	'explain_slo',
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
        [0,0]   => :limitation_text,
        [1,0]   => :prescription,
        [2,0]   => :fachinfo,
        [3,0]   => :patinfo,
        [4,0]   => :narcotic,
        [5,0]   => :complementary_type,
        [6,0,0] => 'result_item_start',
        [6,0,1] => :name_base,
        [6,0,2] => 'result_item_end',
        [7,0]   => :comparable_size,
        [8,0]   => :price_public,
        [9,0]   => :deductible,
        [10,0]  => :compositions,
        [11,0]  => :company_name,
        [12,0]  => :ikscat,
        [13,0]  => :registration_date,
        [14,0]  => :google_search,
      }
    end
    def search_type_selection
      [
        'st_sequence','st_substance', 'st_company', 'st_oddb',
      ]
    end
    def zones
      [
        :analysis, :interactions,
        State::Drugs::Init, State::Drugs::AtcChooser, State::Drugs::Sequences
      ]
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
				:user , :hospitals, :companies, :analysis, :pharmacies
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
    RESOURCES = { }
    HTML_ATTRIBUTES = { }
    def compare_list_components
      {
        [1,0]  => :name_base,
        [2,0]  => :company_name,
        [3,0]  => :most_precise_dose,
        [4,0]  => :comparable_size,
        [5,0]  => :compositions,
        [6,0]  => :price_public,
        [7,0]  => :price_difference,
        [8,0]  => :deductible,
        [9,0]  => :ikscat,
        [10,0] => :fachinfo,
        [11,0] => :patinfo,
      }
    end
    def explain_result_components
      {
        [0,0]	=>	'explain_expired',
        [0,1]	=>	:explain_homeopathy,
        [0,2]	=>	:explain_anthroposophy,
        [0,3] =>	:explain_phytotherapy,
        [0,4]	=>	:explain_parallel_import,
        [0,5]	=>	:explain_vaccine,
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
      :ajax,
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
      :home_interactions,
      :home_migel,
      :interactions,
      :download_export,
      :legal_note_vertical,
      :limitation_texts,
      :login_form,
      :logo,
			:logout,
      :migel,
      :patinfos,
      :preferences,
      :price_history,
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
        [0,4]  => :explain_homeopathy,
        [0,5]  => :explain_anthroposophy,
        [0,6]  => :explain_phytotherapy,
        [0,7]  => :explain_cas,
        [0,8]  => :explain_parallel_import,
        [0,9] => :explain_comarketing,
        [0,10] => :explain_narc,
        [0,11] => :explain_google_search,
        [0,12] => :explain_feedback,
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
	class LookandfeelSwissMedInfo < SBSM::LookandfeelWrapper
		ENABLED = [
      :ajax,
			:home_drugs,
			:help_link,
			:faq_link,
      :fachinfos,
      :patinfos,
			:sequences,
			:ywesee_contact,
		]
		DISABLED = [ :atc_ddd ]
    def compare_list_components
      {
        [0,0]  => :fachinfo,
        [1,0]  => :patinfo,
        [2,0]  => :name_base,
        [3,0]  => :company_name,
        [4,0]  => :most_precise_dose,
        [5,0]  => :comparable_size,
        [6,0]  => :compositions,
        [7,0]  => :price_public,
        [8,0]  => :price_difference,
        [9,0]  => :ddd_price,
        [10,0] => :ikscat,
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
				[0,6]	=>	:explain_fachinfo,
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
				[0,0]		=>	:fachinfo,
				[1,0]		=>	:patinfo,
				[2,0]		=>	:comarketing,
				[3,0,0]	=>	'result_item_start',
				[2,0,1]	=>	:name_base,
				[3,0,2]	=>	'result_item_end',
				[4,0]		=>	:galenic_form,
				[5,0]		=>	:most_precise_dose,
				[6,0]		=>	:comparable_size,
				[7,0]		=>	:price_public,
				[8,0]		=>	:deductible,
				[9,0]		=>	:company_name,
				[10,0]	=>	:ddd_price,
				[11,0]	=>	'nbsp',
				[12,0]	=>	:ikscat,
				[13,0]	=>	:feedback,
				[14,0]	=>  :google_search,
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
    ENABLED = [
      :generic_definition,
    ]
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
    ENABLED = [
      :generic_definition,
    ]
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
    ENABLED = [
      :generic_definition,
    ]
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
