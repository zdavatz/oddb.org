#!/usr/bin/env ruby
# View::CenteredSearchForm -- oddb -- 24.10.2002 -- hwyss@ywesee.com 

require 'htmlgrid/form'
require 'htmlgrid/input'
require 'htmlgrid/button'
require 'htmlgrid/link'
require 'htmlgrid/span'
require 'view/searchbar'
require 'view/resultfoot'
require 'view/navigationlink'
require 'view/legalnote'
require 'view/tab_navigation'

module ODDB
	module View
		class CenteredNavigationLink < HtmlGrid::Link
			CSS_CLASS = "ccomponent"
			def init
				super
				unless (@lookandfeel.direct_event == @name)
					@attributes.store("href", @lookandfeel.event_url(@name))
				end
			end
		end
		class CenteredNavigation < HtmlGrid::Composite
			COMPONENTS = {}
			CSS_CLASS = "ccomponent"
			HTML_ATTRIBUTES = {
				'text-align'	=>	'center',
			}
			SYMBOL_MAP = {
				:navigation_divider	=>	HtmlGrid::Text,
			}
			def init
				build_navigation()
				super
			end
			def build_navigation
				@lookandfeel.zone_navigation.each_with_index { |state, idx| 
					evt = if(state.is_a?(Symbol))
						state
					else
						evt = state.direct_event
						symbol_map.store(evt, View::CenteredNavigationLink)
						evt
					end
					components.store([idx*2,0], evt)
					components.store([idx*2-1,0], :divider) if idx > 0
					component_css_map.store([idx*2,0], 'list')
				}
			end
			def divider(model, session)
				span = HtmlGrid::Span.new(model, session, self)
				span.value = '&nbsp;|&nbsp;'
				span.set_attribute('style','color: black;')
				span
			end
=begin
			def contact_oddb(model, session)
				link = HtmlGrid::Link.new(:contact_oddb, model, session, self)
				link.href = @lookandfeel.lookup(:contact_oddb_href)
				link.attributes['class'] = 'navigation'
				link
			end
=end
		end
		class PayPalForm < HtmlGrid::Form
			COMPONENTS = {
				[0,0]	=> :donation_logo,
			}
			FORM_ACTION = 'https://www.paypal.com/cgi-bin/webscr'
			COMPONENT_CSS_MAP = {
				[0,0]	=>	'donate',
			}
			HTML_ATTRIBUTES = {
				'width'				=>	'100%',
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
				context.hidden('return', @lookandfeel.event_url(:paypal_thanks))<<
				context.hidden('cancel_return', @lookandfeel.base_url)<<
				context.hidden('currency_code', "EUR")<<
				context.hidden('tax', "0")
			end
		end
		class CenteredSearchForm < HtmlGrid::Form
			COMPONENTS = {
				[0,0]		=>	View::TabNavigation,
				[0,1]		=>	:search_query,
				[0,2]		=>	:submit,
				[0,2,1]	=>	:search_reset,
				[0,2,2]	=>	:search_help,
			}
			COMPONENT_CSS_MAP = {
				[0,1]	=>	'search-center',
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
				url = @lookandfeel.event_url(:help)
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
			COMPONENTS = {
				[0,0]		=>	:language_de,
				[0,0,1]	=>	:divider,
				[0,0,2]	=>	:language_fr,
				[0,0,3]	=>	:beta,
				[0,1]		=>	View::CenteredSearchForm,
				[0,2]		=>	:search_explain, 
				#[0,3]		=>	:atc_chooser_text,
				[0,3,1]	=>	:atc_chooser,
				[0,3,2]	=>	'ddd_feature_text',
				[0,4]		=>	:search_compare,
				[0,5]		=>	:plugin,
				[0,5,1]	=>	:export_divider,
				[0,5,2]	=>	:download_export,
				[0,5,3]	=>	:divider,
				[0,5,4]	=>	:recent_registrations,
				[0,6]		=>	:software_feedback,
				[0,6,1]	=>	:divider,
				[0,6,2]	=>	:mailinglist,
				[0,6,3]	=>	:divider,
				[0,6,4]	=>	:fipi_offer,
				[0,7]		=>	:database_size,
				[0,7,1]	=>	'database_size_text',
				[0,7,2]	=>	'comma_separator',
				[0,7,3]	=>	'database_last_updated_txt',
				[0,7,4]	=>	:database_last_updated,
				[0,8]		=>	:generic_definition,
				[0,8,1]	=>	:new_feature,
				[0,9]		=>	View::LegalNoteLink,
				[0,10]		=>	:paypal,
			}
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
				:fipi_offer				=>	HtmlGrid::Link,
				:interactions			=>	HtmlGrid::Link,
				:language_de			=>	HtmlGrid::Link,
				:language_fr			=>	HtmlGrid::Link,
				:mailinglist			=>	HtmlGrid::Link,
				:plugin						=>	HtmlGrid::Link,
				:software_feedback=>	HtmlGrid::Link,
				:search_compare		=>	HtmlGrid::Text,
				:search_explain		=>	HtmlGrid::Text,
				#:search_reset			=>	HtmlGrid::Button,
			}
			def atc_chooser(model, session)
				link = HtmlGrid::Link.new(:atc_chooser, model, session, self)
				link.href = @lookandfeel.event_url(:atc_chooser)
				link.label = true
				link.set_attribute('class', 'list-b')
				link
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
				link.href = @lookandfeel.event_url(:fipi_offer_input)
				link.label = true
				link.set_attribute('class', 'list')
				link
			end
			def generic_definition(model, session)
				link = HtmlGrid::PopupLink.new(:generic_definition, model, session, self)
				link.href = @lookandfeel.event_url(:generic_definition)
				link.value = @lookandfeel.lookup(:generic_definition) 
				link.set_attribute('class', 'list')
				link
			end
			def export_divider(model, session)
				divider(model, session)
			end
			def interactions(model, session)
				link = HtmlGrid::Link.new(:interactions, model, session, self)
				link.href = @lookandfeel.event_url(:interactions_home)
				link.label = true
				link.set_attribute('class', 'list')
				link
			end
			def mailinglist(model, session)
				link = HtmlGrid::Link.new(:mailinglist, model, session, self)
				link.href = @lookandfeel.event_url(:mailinglist)
				link.label = true
				link.set_attribute('class', 'list')
				link
			end
			def language_de(model, session)
				link = HtmlGrid::Link.new(:de, model, session, self)
				link.href = @lookandfeel.language_url(:de)
				link.value = @lookandfeel.lookup(:de)
				link.attributes['class'] =	'list'
				link
			end
			def language_fr(model, session)
				link = HtmlGrid::Link.new(:fr, model, session, self)
				link.href = @lookandfeel.language_url(:fr)
				link.value = @lookandfeel.lookup(:fr)
				link.attributes['class'] =	'list'
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
				link.href = @lookandfeel.event_url(:recent_registrations)
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
				link.href = @lookandfeel.event_url(:plugin)
				link.label = true
				link.set_attribute('class', 'list')
				link
			end
		end
	end
end
