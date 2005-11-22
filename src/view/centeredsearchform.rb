#!/usr/bin/env ruby
# View::CenteredSearchForm -- oddb -- 24.10.2002 -- hwyss@ywesee.com 

require 'htmlgrid/form'
require 'htmlgrid/input'
require 'htmlgrid/button'
require 'htmlgrid/link'
require 'htmlgrid/span'
require 'view/searchbar'
require 'view/resultfoot'
require 'view/navigation'
require 'view/tab_navigation'
require	'view/language_chooser'
require 'view/external_links'

module ODDB
	module View
		class CenteredNavigationLink < NavigationLink
			CSS_CLASS = "list"
		end
		class CenteredNavigation < Navigation 
			CSS_CLASS = "ccomponent"
			NAV_LINK_CLASS = CenteredNavigationLink
			NAV_LINK_CSS = 'list'
			NAV_METHOD = :zone_navigation
			HTML_ATTRIBUTES = {
				'align' => 'center',
			}
		end
		class PayPalForm < HtmlGrid::Form
			CSS_CLASS = 'center'
			COMPONENTS = {
				[0,0]	=> :donation_logo,
			}
			FORM_ACTION = 'https://www.paypal.com/cgi-bin/webscr'
			COMPONENT_CSS_MAP = {
				[0,0]	=>	'donate',
			}
			HTML_ATTRIBUTES = {
				#'width'				=>	'100%',
			}
			def donation_logo(model, session)
				image = HtmlGrid::Input.new(:submit, model, session, self)
				image.attributes['src'] = @lookandfeel.resource_global(:paypal_donate)
				image.attributes['type'] = 'image'
				image.attributes['border'] = '0'
				image.attributes['alt'] = "Make payments with PayPal - it's fast, free and secure!"
				image
			end
			def hidden_fields(context)
				''<<
				context.hidden('cmd', "_xclick")<<
				context.hidden('business', "zdavatz@ywesee.com")<<
				context.hidden('item_name', "ODDB.org")<<
				context.hidden('image_url', "https://www.generika.cc/images/oddb_paypal.jpg")<<
				context.hidden('no_note', "1")<<
				context.hidden('return', @lookandfeel._event_url(:paypal_thanks))<<
				context.hidden('cancel_return', @lookandfeel.base_url)<<
				context.hidden('currency_code', "EUR")<<
				context.hidden('tax', "0")
			end
		end
		class CenteredSearchForm < HtmlGrid::Form
			COMPONENTS = {
				[0,0]			=>	View::TabNavigation,
				[0,2,0,1]	=>	:search_query,
				[0,3,0,2]	=>	:submit,
				[0,3,0,3]	=>	:search_reset,
			}
			COMPONENT_CSS_MAP = {
				[0,0]		=>	'component tabnavigation center',
			}
			CSS_MAP = {
				[0,2,1,2]	=>	'search-center',
			}
			EVENT = :search
			FORM_METHOD = 'POST'
			SYMBOL_MAP = {
				:search_query			=>	View::SearchBar,	
			}
			HTML_ATTRIBUTES = {
				'width'				=>	'100%',
				'text-align'	=>	'center',
			}
			def search_help(model, session)
				button = HtmlGrid::Button.new(:search_help, model, session, self)
				url = @lookandfeel._event_url(:help)
				props = "scrollbars=yes,resizable=no,toolbar=yes,menubar=no,locationbar=no,width=600,height=500";
				script = "window.open('#{url}', '#{@name}', '#{props}').focus(); return false"
				button.set_attribute('onClick', script)
				button
			end
			def search_reset(model, session)
				button = HtmlGrid::Button.new(:search_reset, model, session, self)
				button.set_attribute("type", "reset")
				button.set_attribute("align", "center")
				button
			end
		end
		class CenteredSearchComposite < HtmlGrid::Composite
			include ExternalLinks
			include UserSettings 
			COMPONENTS = {}
			CSS_CLASS = 'composite'
			CSS_MAP = {
				[0,0,1,5]		=>	'ccomponent',
				[0,5,1,2]		=>	'small-font',
				[0,7,1,1]		=>	'ccomponent',				
				[0,8,1,1]		=>	'small-font',
			}
			COMPONENT_CSS_MAP = {
				[0,9]	=>	'legal-note-center',
			}
			HTML_ATTRIBUTES = {
				#'align'		=>	'center',
				#'valign'	=>	'middle',
			}
			SYMBOL_MAP = {
				:atc_chooser_text	=>	HtmlGrid::Text,
				:atc_chooser			=>	HtmlGrid::Link,
				:database_size		=>	HtmlGrid::Text,
				:database_size_text	=>	HtmlGrid::Text,
				:ddd_count_text		=>	HtmlGrid::Text,
				:fipi_offer				=>	HtmlGrid::Link,
				:interactions			=>	HtmlGrid::Link,
				:language_de			=>	HtmlGrid::Link,
				:language_en			=>	HtmlGrid::Link,
				:language_fr			=>	HtmlGrid::Link,
				:mailinglist			=>	HtmlGrid::Link,
				:plugin						=>	HtmlGrid::Link,
				:search_explain		=>	HtmlGrid::Text,
				:software_feedback=>	HtmlGrid::Link,
			}
			def atc_chooser(model, session)
				link = HtmlGrid::Link.new(:atc_chooser, model, session, self)
				link.href = @lookandfeel._event_url(:atc_chooser)
				link.label = true
				link.set_attribute('class', 'list-b')
				link
			end
			def atc_ddd_size(mode, session)
				@session.app.atc_ddd_count
			end
			def beta(model, session)
				link = HtmlGrid::Link.new(:beta, model, session, self)
				link.href = @lookandfeel.lookup(:ywesee_contact_href)
				link.set_attribute('style','text-decoration: none; color: red; margin: 5px;')
				link
			end
			def database_size(model, session)
				@session.app.package_count
			end
			def database_last_updated(model, session)
				HtmlGrid::DateValue.new(:last_medication_update, session.app, session, self)
			end
			def ddd_count_text(model, session)
				link = HtmlGrid::Link.new(:ddd_count_text, model, session, self)
				link.href = @lookandfeel.event_url(:ddd_count_text)
				link.label = true
				link.set_attribute('class', 'list-b')
				link
			end
			def divider(model, session)
				span = HtmlGrid::Span.new(model, session, self)
				span.value = '&nbsp;|&nbsp;'
				span.set_attribute('style','color: black;')
				span
			end
			def download_export(model, session)
				link = HtmlGrid::Link.new(:download_export, model, session, self)
				link.href = @lookandfeel.event_url(:download_export)
				link.label = true
				link.set_attribute('class', 'list')
				link
			end
			def export_divider(model, session)
				divider(model, session)
			end
			def fipi_offer(model, session)
				link = HtmlGrid::Link.new(:fipi_offer, model, session, self)
				link.href = @lookandfeel._event_url(:fipi_offer_input)
				link.label = true
				link.set_attribute('class', 'list')
				link
			end
			def fachinfo_size(model, session)
				@session.app.fachinfo_count
			end
			def generic_definition(model, session)
				link = nil
				if(@lookandfeel.language == 'en')
					link = HtmlGrid::Link.new(:generic_definition, model, session, self)
					link.href = "http://www.fda.gov/cder/ogd/"
				else
					link = HtmlGrid::PopupLink.new(:generic_definition, model, session, self)
					link.href = @lookandfeel._event_url(:generic_definition)
				end
				link.value = @lookandfeel.lookup(:generic_definition) 
				link.set_attribute('class', 'list')
				link
			end
			def export_divider(model, session)
				divider(model, session)
			end
			def interactions(model, session)
				link = HtmlGrid::Link.new(:interactions, model, session, self)
				link.href = @lookandfeel._event_url(:interactions_home)
				link.label = true
				link.set_attribute('class', 'list')
				link
			end
			def mailinglist(model, session)
				link = HtmlGrid::Link.new(:mailinglist, model, session, self)
				link.href = @lookandfeel._event_url(:mailinglist)
				link.label = true
				link.set_attribute('class', 'list')
				link
			end
			def limitation_size(mode, session)
				@session.app.limitation_text_count
			end
			def plugin(model, session)
				link = HtmlGrid::Link.new(:plugin, model, session, self)
				link.href = @lookandfeel._event_url(:plugin)
				link.label = true
				link.set_attribute('class', 'list')
				link
			end
			def new_feature(model, session)
				span = HtmlGrid::Span.new(model, session, self)
				span.value = @lookandfeel.lookup(:new_feature)
				span.set_attribute('style','color: red; margin: 5px; font-size: 8pt;')
				#span.set_attribute('style','color: red; margin: 5px; font-size: 11pt;')
				span
			end
			def recent_registrations(model, session)
				link = HtmlGrid::Link.new(:recent_registrations, model, session, self)
				link.href = @lookandfeel._event_url(:recent_registrations)
				link.label = true
				link.set_attribute('class', 'list')
				link
			end
			def paypal(model, session)
				if(@lookandfeel.enabled?(:paypal))
					PayPalForm.new(model, session, self)
				end
			end
			def plugin(model, session)
				link = HtmlGrid::Link.new(:plugin, model, session, self)
				link.href = @lookandfeel._event_url(:plugin)
				link.label = true
				link.set_attribute('class', 'list')
				link
			end
			def patinfo_size(model, session)
				@session.app.patinfo_count
			end
		end
	end
end
