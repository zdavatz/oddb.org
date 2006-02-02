#!/usr/bin/env ruby
# LookandfeelWrapper - oddb -- 21.07.2003 -- mhuggler@ywesee.com

require 'sbsm/lookandfeelwrapper'

module ODDB
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
			:full_result,
			:help_link,
			:home,
			:home_drugs,
			:home_migel,
			:migel,
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
		def navigation
			[ :legal_note, :sequences, :home ]
		end
	end
	class LookandfeelJustMedical < SBSM::LookandfeelWrapper
		ENABLED = [
			:just_medical_structure,	
			:external_css,
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
				:search_explain							=>	'Vergleichen Sie einfach und schnell Medikamentenpreise.<br> Suchen Sie nach Medikament, Wirkstoff oder Anwendungsgebiet.',
				:sequences									=>	'Medikamente alphabetisch',
			},
			'fr'	=>	{
				:all_drugs_pricecomparison	=>	'Encyclopédie complète des médicaments commercialisés en Suisse',
				:atc_chooser								=>	'ATC-Codes', 
				:data_declaration						=>	'Source des dates',
				:home_drugs									=>	'Médicaments',
				:legal_note									=>	'Notice légale',
				:meddrugs_update						=>	'med-drugs update', 
				:migel											=>	'Dispositifs médicaux (MiGeL)',
				:search_explain							=>	'Comparez simplement et rapidement les prix des médicaments.<br>Cherchez le nom du médicament, le principe actif ou l\'indication.',
				:sequences									=>	'Médicaments alphabétiques',
			},
			'en'	=>	{
				:all_drugs_pricecomparison	=>	'Complete Swiss encyclopaedia of drugs',
				:atc_chooser								=>	'ATC-Codes', 
				:data_declaration						=>	'Source of data',
				:home_drugs									=>	'Drugs',
				:legal_note									=>	'Legal Disclaimer',
				:meddrugs_update						=>	'med-drugs update', 
				:migel											=>	'Medical devices (MiGeL)',
				:search_explain							=>	'Compare prices of drugs - fast and easy.<br>Search by name of drug, active agent or indication.',
				:sequences									=>	'Drugs alphabetical',
			},
		}
		RESOURCES = {
			:external_css	=>	'http://www.just-medical.com/css/oddb.css',
		}
		def navigation
			[ :meddrugs_update, :legal_note, :data_declaration, 
				:home ]
		end
		def zones
			[ State::Drugs::Init, State::Drugs::AtcChooser, 
				State::Drugs::Sequences, :migel ]
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
end
