#!/usr/bin/env ruby
# LookandfeelWrapper - oddb -- 21.07.2003 -- mhuggler@ywesee.com

require 'sbsm/lookandfeelwrapper'

module ODDB
	class LookandfeelExtern < SBSM::LookandfeelWrapper
		ENABLED = [
			:atc_chooser,
			:home,
			:home_admin,
			:home_companies,
			:home_doctors,
			:home_drugs,
			:home_interactions,
			:home_substances,
			:home_user,
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
		LANGUAGES = [
			'de', 'fr', 'en'
		]
		ENABLED = [
			:companylist,
			:epatents,
			:galenic_groups,
			:google_adsense,
			:incomplete_registrations,
			:indications,
			:login_form,
			:logo,
			:logout,
			:multilingual_logo,
			:patinfo,
			:paypal,
			:query_limit,
			:sponsor,
			:sponsorlogo,
			:ywesee_contact,
		]
		DICTIONARIES = {
			'de'	=>	{
				:html_title		=>	'cc: an alle - generika.cc - betreff: Gesundheitskosten senken!', 
				:home_welcome							=>  "Willkommen bei generika.cc, dem<br>aktuellsten Medikamenten-Portal der Schweiz.<br>** <a class='welcome' href='http://wiki.oddb.org/wiki.php?pagename=Swissmedic.Datendeklaration'>Herkunftsdeklaration</a> der Daten **",
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
				:login_welcome	=>	'Willkommen bei Generika.cc',
				:lookandfeel_owner =>	'Generika.cc',
			},
			'fr'	=>	{
				:html_title		=>	'cc: pour tous - generika.cc - concerne: r&eacute;duire les co&ucirc;ts de la sant&eacute;!', 
				:home_welcome							=>  "Bienvenue sur generika.cc,<br>le portail des g&eacute;n&eacute;riques de Suisse avec<br>tous les m&eacute;dicaments disponibles sur le march&eacute; suisse!<br>** <a class='welcome' href='http://wiki.oddb.org/wiki.php?pagename=Swissmedic.Datendeklaration'>D&eacute;claration d'origine</a> des donn&eacute;es **",
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
				:login_welcome	=>	'Bienvenu sur Generika.cc',
				:lookandfeel_owner =>	'Generika.cc',
			},
			'en'	=>	{
				:html_title		=>	'cc: to everybody - generika.cc - subject: reduce health costs!', 
				:home_welcome							=>  "Welcome to generika.cc<br>the open drug database of Switzerland.<br>** <a class='welcome' href='http://wiki.oddb.org/wiki.php?pagename=Swissmedic.Datendeklaration'>Declaration of origin</a> of the data **",
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
				:login_welcome	=>	'Welcome to Generika.cc',
				:lookandfeel_owner =>	'Generika.cc',
			}
		}
		HTML_ATTRIBUTES = {
			:logo => {
				'width'		=>	'338',
				'height'	=>	'87',
			},
		}
	end
	class LookandfeelProvita < SBSM::LookandfeelWrapper
		DICTIONARIES = {
			'de'	=>	{
				:home_welcome	=>	'Willkommen bei Provita und oddb.org',
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
				:lookandfeel_owner =>	'Generika.cc',
			},
			'fr'	=>	{
				:home_welcome	=>	'Bienvenu sur Provita et oddb.org',
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
				:lookandfeel_owner =>	'Generika.cc',
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
		DICTIONARIES = {
			'de'	=>	{
				:home_welcome		=>	'',
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
				:price_compare	=>	'F&uuml;r den Direktvergleich klicken Sie bitte auf den<br>Medikamentennamen im Suchergebnis!',
				:search_explain	=>	'Willkommen bei sant&eacute;suisse und oddb.org<br><br>Vergleichen Sie einfach und schnell Medikamentenpreise indem Sie<br>entweder ein Medikament oder einen Wirkstoff im Suchbalken eingeben:',
				:lookandfeel_owner =>	'Generika.cc',
			},
			'fr'	=>	{
				:home_welcome		=>	'',
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
				:price_compare	=>	'Pour la comparaison directe, veuillez cliqueter sur les noms de m&eacute;dicament dans le r&eacute;sultat de la recherche!',
				:search_explain	=>	'Bienvenu et sur sant&eacute;suisse et oddb.org.<br><br>comparaisez simplement et rapidement prix de m&eacute;dicament en vous<br>sugg&eacute;rez soit un m&eacute;dicament, soit un agent dans la poutre de recherche :',
				:lookandfeel_owner =>	'Generika.cc',
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
				:home_welcome	=>	'Willkommen bei atupri und oddb.org',
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
				:lookandfeel_owner =>	'Generika.cc',
			},
			'fr'	=>	{
				:home_welcome	=>	'Bienvenu sur atupri et oddb.org',
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
				:lookandfeel_owner =>	'Generika.cc',
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
end
