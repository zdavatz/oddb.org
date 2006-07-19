#!/usr/bin/env ruby
# LookandfeelWrapper - oddb -- 21.07.2003 -- mhuggler@ywesee.com

require 'sbsm/lookandfeelwrapper'

module ODDB
	class LookandfeelStandardResult < SBSM::LookandfeelWrapper
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
		def explain_result_components
			{
				[0,0]	=>	:explain_original,
				[0,1]	=>	:explain_generic,
				[0,2]	=>	:explain_comarketing,
				[0,3]	=>	:explain_complementary,
				[0,4]	=>	:explain_vaccine,
				[0,5]	=>	'explain_unknown',
				[0,6]	=>	'explain_expired',
				[0,8]	=>	:explain_cas,
				[1,0]	=>	'explain_li',
				[1,1]	=>	'explain_fi',
				[1,2]	=>	'explain_pi',
				[1,3]	=>	'explain_narc',
				[1,4]	=>	'explain_a',
				[1,5]	=>	'explain_h',
				[1,6]	=>	'explain_p',
				[1,7]	=>	'explain_pr',
				[2,0]	=>	'explain_efp',
				[2,1]	=>	'explain_pbp',
				[2,2]	=>	:explain_deductible,
				[2,3]	=>	'explain_sl',
				[2,4]	=>	'explain_slo',
				[2,5]	=>	'explain_slg',
				[2,6]	=>	:explain_lppv,
				[2,7]	=>	'explain_g',
				[2,8]	=>	'explain_fd',
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
			:companylist,
			:fachinfos,
			:google_adsense,
			:limitation_texts,
			:logo,
			:multilingual_logo,
			:patinfos, 
			:paypal,
			:query_limit,
			:sponsor,
			:sponsorlogo,
		]
		DICTIONARIES = {
			'de'	=>	{
				:html_title		=>	'cc: an alle - generika.cc - betreff: Gesundheitskosten senken!', 
				:home_welcome							=>  "Willkommen bei generika.cc, dem<br>aktuellsten Medikamenten-Portal der Schweiz.<br>** <a class='welcome' href='http://wiki.oddb.org/wiki.php?pagename=Swissmedic.Datendeklaration'>Herkunftsdeklaration</a> der Daten **",
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
				:login_welcome	=>	'Willkommen bei Generika.cc',
			},
			'fr'	=>	{
				:html_title		=>	'cc: pour tous - generika.cc - concerne: r&eacute;duire les co&ucirc;ts de la sant&eacute;!', 
				:home_welcome							=>  "Bienvenue sur generika.cc,<br>le portail des g&eacute;n&eacute;riques de Suisse avec<br>tous les m&eacute;dicaments disponibles sur le march&eacute; suisse!<br>** <a class='welcome' href='http://wiki.oddb.org/wiki.php?pagename=Swissmedic.Datendeklaration'>D&eacute;claration d'origine</a> des donn&eacute;es **",
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
				:login_welcome	=>	'Bienvenu sur Generika.cc',
			},
			'en'	=>	{
				:html_title		=>	'cc: to everybody - generika.cc - subject: reduce health costs!', 
				:home_welcome							=>  "Welcome to generika.cc<br>the open drug database of Switzerland.<br>** <a class='welcome' href='http://wiki.oddb.org/wiki.php?pagename=Swissmedic.Datendeklaration'>Declaration of origin</a> of the data **",
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
		ENABLED = [ :doctors ]
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
			:logo	=>	'logo.png',
		}
		HTML_ATTRIBUTES = {
			:logo => {
				'width'		=>	'323',
				'height'	=>	'92',
			},
		}
	end
	class LookandfeelAtupriWeb < SBSM::LookandfeelWrapper
		ENABLED = [
			:atupri_web,
			:custom_navigation,
			:drugs, 
			:external_css,
			:help_link,
			:logout,
			:migel,
			:popup_links,
			:sequences,
		]
		DICTIONARIES = {
			'de'	=>	{
				:DOCTYPE									=>	' <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 transitional//EN">',
				:explain_complementary		=>	'Lila&nbsp;=&nbsp;Arzneimittel der Komplement&auml;rmedizin',
				:explain_original					=>	'Blau&nbsp;=&nbsp;Original',
				:explain_unknown					=>	'Grau&nbsp;=&nbsp;Nicht&nbsp;klassifiziert',
				:home_welcome							=>  "",
				:price_compare						=>	'F&uuml;r den Direktvergleich klicken Sie bitte <br>auf den Medikamentennamen im Suchergebnis!',
			},
			'fr'	=>	{
				:explain_complementary		=>	'Lilas&nbsp;=&nbsp;Produit Compl&eacute;mentaire',
				:explain_original					=>	'bleu&nbsp;=&nbsp;original',
				:explain_unknown					=>	'gris&nbsp;=&nbsp;pas classes',
				:home_welcome							=>  "",
				:price_compare						=>	'Pour la comparaison directe, cliquez s.v.p.<br>sur le nom du m&eacute;dicament dans le r&eacute;sultat de la recherche!',
			},
		}
		RESOURCES = { 
			:external_css	=>	'http://www.atupri.ch/misc/generika.css',
		}
		HTML_ATTRIBUTES = { }
		def explain_result_components
			{
				[0,0]	=>	:explain_original,
				[0,1]	=>	:explain_generic,
				[0,2]	=>	:explain_complementary,
				[0,3]	=>	:explain_vaccine,
				[0,4]	=>	'explain_unknown',
				[0,6]	=>	'explain_li',
				[0,7]	=>	'explain_fi',
				[0,8]	=>	'explain_pi',
				[0,9]	=>	'explain_narc',
				[1,0]	=>	'explain_a',
				[1,1]	=>	'explain_h',
				[1,2]	=>	'explain_p',
				[1,3]	=>	'explain_pr',
				[1,4]	=>	'explain_efp',
				[1,5]	=>	'explain_pbp',
				[1,6]	=>	:explain_deductible,
				[1,7]	=>	'explain_sl',
				[1,8]	=>	'explain_slo',
				[1,9]	=>	'explain_slg',
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
	class LookandfeelJustMedical < SBSM::LookandfeelWrapper
		ENABLED = [
			:custom_navigation,
			:external_css,
			:just_medical_structure,	
			:popup_links,
			:powerlink,
		]
		DICTIONARIES = {
			'de'	=>	{
				:all_drugs_pricecomparison	=>	'Komplette Schweizer Medikamenten-Enzyklopädie',
				:atc_chooser								=>	'ATC-Codes', 
				:data_declaration						=>	'Datenherkunft',
				:home_drugs									=>	'Medikamente',
				:legal_note									=>	'Rechtliche Hinweise',
				:meddrugs_update						=>	'med-drugs update', 
				:migel											=>	'Medizinprodukte (MiGeL)',
				:migel_alphabetical					=>	'Medizinprodukte (MiGeL) A-Z',
				:search_explain							=>	'Vergleichen Sie einfach und schnell Medikamentenpreise.<br> Suchen Sie nach Medikament, Wirkstoff oder Anwendungsgebiet.',
				:sequences									=>	'Medikamente A-Z',
			},
			'fr'	=>	{
				:all_drugs_pricecomparison	=>	'Encyclopédie complète des médicaments commercialisés en Suisse',
				:atc_chooser								=>	'ATC-Codes', 
				:data_declaration						=>	'Source des dates',
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
				:home_drugs									=>	'Drugs',
				:legal_note									=>	'Legal Disclaimer',
				:meddrugs_update						=>	'med-drugs update', 
				:migel											=>	'Medical devices (MiGeL)',
				:migel_alphabetical					=>	'Medical devices (MiGeL) A-Z',
				:search_explain							=>	'Compare prices of drugs - fast and easy.<br>Search by name of drug, active agent or indication.',
				:sequences									=>	'Drugs A-Z',
			},
		}
		RESOURCES = {
			:external_css	=>	'http://www.just-medical.com/css/oddb.css',
		}
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
				[1,0]	=>	'explain_li',
				[1,1]	=>	'explain_fi',
				[1,2]	=>	'explain_pi',
				[1,3]	=>	'explain_narc',
				[1,4]	=>	'explain_a',
				[1,5]	=>	'explain_h',
				[1,6]	=>	'explain_p',
				[1,7]	=>	'explain_pr',
				[2,0]	=>	'explain_pbp',
				[2,1]	=>	:explain_deductible,
				[2,2]	=>	'explain_sl',
				[2,3]	=>	'explain_slg',
				[2,4]	=>	'explain_slg',
				[2,5]	=>	'explain_fd',
				[2,6]	=>	:explain_lppv,
				[2,7]	=>	'explain_g',
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
				:user , :hospitals, :companies,
				false
			else
				@component.enabled?(event, default)
			end
		end
	end
	class LookandfeelOekk < SBSM::LookandfeelWrapper
		ENABLED = [
			:drugs, 
			:external_css,
			:help_link,
			:logout,
			:migel,
			:oekk_structure,
			:sequences,
		]
		DICTIONARIES = {
			'de'	=>	{
				:de								=>	'd',
				:en								=>	'e',
				:fr								=>	'f',
				:oekk_department	=>	'Medikamentenvergleich online',
				:oekk_logo				=>	'&Ouml;KK - jung und unkompliziert.',
				:oekk_title				=>	'Ihr Einsparungspotential mit Generika',
			},
			'fr'	=>	{
				:oekk_department	=>	'Comparaison de m&eacute;dicaments sur ligne',
				:oekk_logo				=>	'&Ouml;KK - jeune et sympa.',
				:oekk_title				=>	'V&ocirc;tre &eacute;conomie potentielle avec g&eacute;n&eacute;riques',
			},
			'en'	=>	{
				:oekk_department	=>	'Drug comparison online',
				:oekk_logo				=>	'&Ouml;KK - young and easy.',
				:oekk_title				=>	'Your potential savings with generics',
			},
		}
		RESOURCES = { 
			:external_css	=>	'http://www.oekk.ch/assets/styles/oddb.css',
		}
		HTML_ATTRIBUTES = { }
		def languages
			[:de, :fr, :en]
		end
	end
	class LookandfeelMedicalTribune < SBSM::LookandfeelWrapper
		ENABLED = [
			:custom_navigation,
			:drugs, 
			:home_drugs,
			:home_migel,
			:external_css,
			:help_link,
			#:logout,
			:migel,
			:sequences,
		]
		RESOURCES = { 
			:external_css	=>	'http://www.medical-tribune.ch/css/oddb_deutsch.css',
		}
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
				[1,0]	=>	'explain_li',
				[1,1]	=>	'explain_fi',
				[1,2]	=>	'explain_pi',
				[1,3]	=>	'explain_narc',
				[1,4]	=>	'explain_a',
				[1,5]	=>	'explain_h',
				[1,6]	=>	'explain_p',
				[1,7]	=>	'explain_pr',
				[2,0]	=>	'explain_efp',
				[2,1]	=>	'explain_pbp',
				[2,2]	=>	'explain_sl',
				[2,3]	=>	'explain_slg',
				[2,4]	=>	'explain_slg',
				[2,5]	=>	'explain_fd',
				[2,6]	=>	:explain_lppv,
				[2,7]	=>	'explain_g',
			}
		end
		def languages
			[:de, :fr, :en]
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
	class LookandfeelMedicalTribune1 < SBSM::LookandfeelWrapper
		ENABLED = [
			:custom_navigation,
			:drugs, 
			:home_drugs,
			:external_css,
			:help_link,
			#:logout,
		]
		RESOURCES = { 
			:external_css	=>	'http://www.medical-tribune.ch/css/oddb_public.css',
		}
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
				[1,0]	=>	'explain_li',
				[1,1]	=>	'explain_fi',
				[1,2]	=>	'explain_pi',
				[1,3]	=>	'explain_narc',
				[1,4]	=>	'explain_a',
				[1,5]	=>	'explain_h',
				[1,6]	=>	'explain_p',
				[1,7]	=>	'explain_pr',
				[2,0]	=>	'explain_efp',
				[2,1]	=>	'explain_pbp',
				[2,2]	=>	'explain_sl',
				[2,3]	=>	'explain_slg',
				[2,4]	=>	'explain_slg',
				[2,5]	=>	'explain_fd',
				[2,6]	=>	:explain_lppv,
				[2,7]	=>	'explain_g',
			}
		end
		def languages
			[:de, :fr, :en]
		end
		def navigation(filter=false)
			[:help_link]
		end
		def result_list_components
			{
				[0,0]		=>	:patinfo,
				[1,0,0]	=>	'result_item_start',
				[1,0,1]	=>	:name_base,
				[1,0,2]	=>	'result_item_end',
				[2,0]		=>	:galenic_form,
				[3,0]		=>	:most_precise_dose,
				[4,0]		=>	:comparable_size,
				[5,0]		=>	:price_exfactory,
				[6,0]		=>	:price_public,
			}
		end
		def search_type_selection
			['st_sequence', 'st_substance', 'st_indication']
		end
		def zones(filter=false)
			[]
		end
	end
	class LookandfeelGeriMedi < SBSM::LookandfeelWrapper
		ENABLED = [
			#:external_css,
			:home_drugs,
			:help_link,
			:faq_link,
			:ywesee_contact,
			:sequences,
		]
		DISABLED = [ :atc_ddd ]
		RESOURCES = {
			#:external_css	=>	'http://www.gerimedi.ch/css/oddb.css',
			:external_css	=>	'http://kunde.aixede.ch/gerimedi/screen.css',
		}
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
		def explain_result_components
			{
				[0,0]	=>	:explain_original,
				[0,1]	=>	:explain_generic,
				[0,2]	=>	:explain_complementary,
				[0,3]	=>	'explain_expired',
				[0,4]	=>	'explain_pbp',
				[0,5]	=>	:explain_deductible,
				[0,6]	=>	:explain_ddd_price,
				[1,0]	=>	'explain_pi',
				[1,1]	=>	'explain_fd',
				[1,2]	=>	'explain_g',
				[1,3]	=>	'explain_sl',
				[1,4]	=>	'explain_slo',
				[1,5]	=>	'explain_slg',
				[1,6]	=>	:explain_lppv,
			}
		end
		def result_list_components
			{
				[0,0]		=>	:patinfo,
				[1,0,0]	=>	'result_item_start',
				[1,0,1]	=>	:name_base,
				[1,0,2]	=>	'result_item_end',
				[2,0]		=>	:galenic_form,
				[3,0]		=>	:most_precise_dose,
				[4,0]		=>	:comparable_size,
				[5,0]		=>	:price_public,
				[6,0]		=>	:deductible,
				[7,0]		=>	:company_name,
				[8,0]		=>	:ddd_price,
				[9,0]		=>	'nbsp',
				[10,0]	=>	:ikscat,
				[11,0]	=>	:feedback,
				[12,0]	=>  :google_search,
			}
		end
		def section_style
			'font-size: 16px; margin-top: 8px; line-height: 1.4em; max-width: 600px'
		end
	end
	class LookandfeelSwissMedInfo < SBSM::LookandfeelWrapper
		ENABLED = [
			:home_drugs,
			:help_link,
			:faq_link,
			:ywesee_contact,
			:sequences,
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
		def explain_result_components
			{
				[0,0]	=>	:explain_original,
				[0,1]	=>	:explain_generic,
				[0,2]	=>	:explain_complementary,
				[0,3]	=>	'explain_expired',
				[0,4]	=>	'explain_pbp',
				[0,5]	=>	:explain_deductible,
				[0,6]	=>	:explain_ddd_price,
				[1,0]	=>	'explain_pi',
				[1,1]	=>	'explain_fd',
				[1,2]	=>	'explain_g',
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
