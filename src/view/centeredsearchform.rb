#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::CenteredSearchForm -- oddb.org -- 23.02.2012 -- mhatakeyama@ywesee.com
# ODDB::View::CenteredSearchForm -- oddb.org -- 24.10.2002 -- hwyss@ywesee.com 

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
		class CenteredNavigation < ZoneNavigation 
			CSS_CLASS = "center"
#		class CenteredNavigation < ZoneNavigation 
#			CSS_CLASS = "ccomponent"
			NAV_LINK_CLASS = CenteredNavigationLink
			NAV_LINK_CSS = 'list'
			NAV_METHOD = :zone_navigation
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
				image = HtmlGrid::Input.new(:submit, nil, session, self)
				image.attributes['src'] = @lookandfeel.resource_global(:paypal_donate)
				image.attributes['type'] = 'image'
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
				[0,0]		=>	'component tabnavigation',
			}
			CSS_MAP = {
				[0,2,1,2]	=>	'center',
			}
			CSS_CLASS = nil #'center'
			EVENT = :search
			FORM_METHOD = 'POST'
			SYMBOL_MAP = {
				:search_query			=>	View::SearchBar,	
			}
			HTML_ATTRIBUTES = {
				#'width'				=>	'100%',
				#'text-align'	=>	'center',
			}
			def init
				self.onload = "document.getElementById('searchbar').focus();"
				super
			end
			def search_help(model, session)
				button = HtmlGrid::Button.new(:search_help, model, session, self)
				url = @lookandfeel._event_url(:help)
				props = "scrollbars=yes,resizable=no,toolbar=yes,menubar=no,locationbar=no,width=600,height=500";
				script = "window.open('#{url}', '#{@name}', '#{props}').focus(); return false"
				button.set_attribute('onClick', script)
				button
			end
			def search_reset(model, session)
				if(@lookandfeel.enabled?(:search_reset))
					button = HtmlGrid::Button.new(:search_reset, model, session, self)
					button.set_attribute("type", "reset")
					#button.set_attribute("align", "center")
					button
				end
			end
		end
		class CenteredSearchComposite < HtmlGrid::Composite
			include ExternalLinks
			include UserSettings 
			COMPONENTS = {}
			CSS_CLASS = 'composite'
			CSS_MAP = {
				[0,0,1,5]		=>	'list center',
				[0,5,1,2]		=>	'list small',
				[0,7,1,1]		=>	'list center',				
				[0,8,1,1]		=>	'list small',
			}
			COMPONENT_CSS_MAP = {
				[0,9]	=>	'legal-note center',
			}
			HTML_ATTRIBUTES = {
				#'align'		=>	'center',
				#'valign'	=>	'middle',
			}
			SYMBOL_MAP = {
				:atc_chooser_text	=>	HtmlGrid::Text,
				:atc_chooser			=>	CenteredNavigationLink,
				:database_size		=>	HtmlGrid::Text,
				:database_size_text	=>	HtmlGrid::Text,
				:ddd_count_text		=>	HtmlGrid::Text,
				:fipi_offer				=>	HtmlGrid::Link,
				:interactions			=>	HtmlGrid::Link,
				:mailinglist			=>	HtmlGrid::Link,
				:narcotics				=>	HtmlGrid::Link,
				:plugin						=>	HtmlGrid::Link,
				:search_explain		=>	HtmlGrid::Text,
				:sequences				=>	CenteredNavigationLink,
				:software_feedback=>	HtmlGrid::Link,
			}
			def atc_chooser(model, session)
				if(@lookandfeel.enabled?(:atc_chooser))
					CenteredNavigationLink.new(:atc_chooser, model, @session, self)
				end
			end
			def atc_ddd_size(mode, session)
				@session.app.atc_ddd_count.to_s << '&nbsp;'
			end
			def beta(model, session)
				link = HtmlGrid::Link.new(:beta, model, session, self)
				link.href = @lookandfeel.lookup(:ywesee_contact_href)
				link.set_attribute('style','text-decoration: none; color: red; margin: 5px;')
				link
			end
			def database_size(model, session)
				@session.app.package_count.to_s << '&nbsp;'
			end
			def database_last_updated(model, session=@session)
				HtmlGrid::DateValue.new(:last_medication_update, 
																@session.app, @session, self)
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
      def download_ebook(model, session)
        link = HtmlGrid::Link.new(:download_ebook,
                                  model, session, self)
				args = {
          'download[compendium_ch.oddb.org.firefox.epub]' => 1,
          'download[compendium_ch.oddb.org.htc.prc]'      => 1,
          'download[compendium_ch.oddb.org.kindle.mobi]'  => 1,
          'download[compendium_ch.oddb.org.stanza.epub]'  => 1,
        }
        link.set_attribute('class', 'list')
        link.href = 'http://goo.gl/qWpPu'
        link
      end
      def download_app(model, session)
        link = HtmlGrid::Link.new(:download_app,
                                  model, session, self)
        link.set_attribute('class', 'list')
        link.href = 'http://itunes.apple.com/us/app/generika/id520038123?ls=1&mt=8'
        link
      end
			def download_export(model, session)
				link = HtmlGrid::Link.new(:download_export, model, session, self)
				link.href = @lookandfeel._event_url(:download_export)
				link.label = true
				link.set_attribute('class', 'list')
				link
			end
			def download_generics(model, session)
				link = HtmlGrid::Link.new(:download_generics, 
																	model, session, self)
				args = {'download[generics.xls]' => 1}
				link.href = @lookandfeel._event_url(:download_export, args)
				link.set_attribute('class', 'list')
				link
			end
			def fipi_offer(model, session)
				link = HtmlGrid::Link.new(:fipi_offer, model, session, self)
				link.href = @lookandfeel._event_url(:fipi_offer_input)
				link.label = true
				link.set_attribute('class', 'list')
				link
			end
			def fachinfo_size(model, session)
				@session.app.fachinfo_count.to_s << '&nbsp;'
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
				@session.app.limitation_text_count.to_s << '&nbsp;'
			end
			def narcotics_size(model, session)
        @session.app.narcotics.length.to_s << '&nbsp;'
			end
			def new_feature(model, session)
				span = HtmlGrid::Span.new(model, session, self)
				span.value = @lookandfeel.lookup(:new_feature)
				span.set_attribute('style','color: red; margin: 5px; font-size: 8pt;')
				#span.set_attribute('style','color: red; margin: 5px; font-size: 11pt;')
				span
			end
			def recent_registrations(model, session)
				link = HtmlGrid::Link.new(:new_registrations, model, session, self)
				link.href = @lookandfeel._event_url(:recent_registrations)
				link.set_attribute('class', 'list')
				count = @session.app.recent_registration_count
				[database_last_updated(model), ',&nbsp;', count, '&nbsp;', link]
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
				@session.app.patinfo_count.to_s << '&nbsp;'
			end
			def vaccines_size(model, session)
				@session.app.vaccine_count.to_s << '&nbsp;'
			end
		end
	end
end
