#!/usr/bin/env ruby
# LookandfeelWrapper - oddb -- 21.07.2003 -- maege@ywesee.com

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
	class LookandfeelDrOuwerkerk < SBSM::LookandfeelWrapper
		ENABLED = [
			:paypal,
			:powerlink,
		]
		DICTIONARIES = {
			'de'	=>	{
				:home_welcome	=>	'',
				:lookandfeel_owner =>	'dr-ouwerkerk.com',
			},
			'fr'	=>	{
				:home_welcome	=>	'',
				:lookandfeel_owner =>	'dr-ouwerkerk.com',
			},
		}
		HTML_ATTRIBUTES = {
			:logo => {
				'width'		=>	'468',
				'height'	=>	'60',
			},
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
			:sponsor,
			:sponsorlogo,
			:ywesee_contact,
		]
		DICTIONARIES = {
			'de'	=>	{
				:html_title		=>	'cc: an alle - generika.cc - betreff: Gesundheitskosten senken!', 
				:home_welcome	=>	'Willkommen bei generika.cc, dem<br>aktuellsten Generika-Portal der Schweiz.<br>Die monatliche Aktualisierung erfolgt direkt<br>über die offiziellen Daten vom <a class="welcome" href="http://www.bsv.admin.ch/sl/liste/d/index.htm" target="_blank">BSV</a> und der <a class="welcome" href="http://www.swissmedic.ch/de/industrie/overall.asp?theme=0.00110.00001&theme_id=980" target="_blank">Swissmedic</a>.',
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
				:login_welcome	=>	'Willkommen bei Generika.cc',
				:lookandfeel_owner =>	'Generika.cc',
			},
			'fr'	=>	{
				:html_title		=>	'cc: pour tous - generika.cc - concerne: r&eacute;duire les co&ucirc;ts de la sant&eacute;!', 
				:home_welcome	=>	"Bienvenu sur generika.cc,<br>le Generika-Portal le plus actuel de la Suisse.<br>La mise à jour mensuelle s'effectue directement<br>par les données officielles du <a class=\"welcome\" href=\"http://www.bsv.admin.ch/sl/liste/d/index.htm\" target=\"_blank\">BSV</a> et les <a class=\"welcome\" href=\"http://www.swissmedic.ch/de/industrie/overall.asp?theme=0.00110.00001&theme_id=980\" target=\"_blank\">Swissmedic</a>.",
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
				:login_welcome	=>	'Bienvenu sur Generika.cc',
				:lookandfeel_owner =>	'Generika.cc',
			},
			'en'	=>	{
				:html_title		=>	'cc: to everybody - generika.cc - subject: reduce health costs!', 
				:home_welcome							=>  'Welcome to generika.cc,<br>Switzerland\'s most up-to-date portal for generics<br>The data is being updated by the monthly publication of the<br><a class="welcome" href="http://www.bsv.admin.ch/sl/liste/d/index.htm" target="_self">Swiss Federal Office of Public Health</a> and the <a class="welcome" href="http://www.swissmedic.ch/de/industrie/overall.asp?theme=0.00110.00001&amp;theme_id=980" target="_self">Swissmedic-Journal</a>.',
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
	class LookandfeelInnova < SBSM::LookandfeelWrapper
		ENABLED = [
			:logo,
			:ywesee_contact,
		]
		DICTIONARIES = {
			'de'	=>	{
				:home_welcome	=>	'Willkommen bei Innova und oddb.org',
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
				:lookandfeel_owner =>	'Generika.cc',
			},
			'fr'	=>	{
				:home_welcome	=>	'Bienvenu sur Innova et oddb.org',
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
				:lookandfeel_owner =>	'Generika.cc',
			},
		}
		HTML_ATTRIBUTES = {
			:logo => {
				'width'		=>	'209',
				'height'	=>	'70',
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
	class LookandfeelSchoenenberger < SBSM::LookandfeelWrapper
		DICTIONARIES = {
			'de'	=>	{
				:home_welcome	=>	'Willkommen bei Sch&ouml;nenberger Pharma AG und oddb.org',
				:lookandfeel_owner =>	'Generika.ch',
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
			},
			'fr'	=>	{
				:home_welcome	=>	'Bienvenu sur Sch&ouml;nenberger Pharma AG et oddb.org',
				:lookandfeel_owner =>	'Generika.ch',
				:mailinglist_title	=>	'Mailinglist - Generika.cc',
			},
		}
		HTML_ATTRIBUTES = {
			:logo => {
				'width'		=>	'100',
				'height'	=>	'200',
			},
		}
	end
	class LookandfeelAtupri < SBSM::LookandfeelWrapper
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
