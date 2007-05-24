#!/usr/bin/env ruby
# View::Notify -- oddb -- 24.10.2005 -- ffricker@ywesee.com


require 'view/publictemplate'
require 'view/additional_information'
require 'view/searchbar'
require 'htmlgrid/form'
require 'htmlgrid/inputradio'
require 'htmlgrid/textarea'
require 'htmlgrid/errormessage'
require 'htmlgrid/div'


module ODDB
	module View
		class NotifyForm < HtmlGrid::Form
			include HtmlGrid::ErrorMessage
			COMPONENTS = {
				[0,0]			=>	:name,
				[0,1]			=>	:notify_sender,
				[0,2]			=>	:notify_recipient,
				[0,3]			=>	:notify_message,
				[1,4]			=>	:submit,
			}
			CSS_MAP = {
				[0,0,2,5]	=>	'list',
				[0,3]	=>	'list top',
			}
			COMPONENT_CSS_MAP = {
				[1,0,1,3] => 'xl',
			}
			CSS_CLASS = 'component'
			LABELS = true
			EVENT = :preview
			LEGACY_INTERFACE = false
      LOOKANDFEEL_MAP = {
        :name => :name_sender,
      }
			def init
				super
				error_message()
			end
			def notify_message(model)
				input = HtmlGrid::Textarea.new(:notify_message, model, @session, self)
				input.set_attribute('wrap', true)
				js = "if(this.value.length > 500) { (this.value = this.value.substr(0,500))}" 
				input.set_attribute('onKeypress', js)
				input.label = true
				input
			end
		end
		class NotifyPreview < Form
			EVENT = :notify_send 
			CSS_CLASS = 'composite'
			COMPONENTS = {
				[0,0]			=>	'name_sender',
				[1,0]			=>	:name,
				[0,1]			=>	'notify_sender',
				[1,1]			=>	:notify_sender,
				[0,2]			=>	'notify_recipient',
				[1,2]			=>	:notify_recipient,
				[0,3]			=>	'notify_body',
				[1,3]			=>	:notify_link,
				[1,4]			=>	:notify_message,
				[0,6]			=>	:submit,
			}
			CSS_MAP = {
				[0,0] => 'list bold top',
				[0,1] => 'list bold top',
				[0,2] => 'list bold top',
				[0,3] => 'list bold top',
			}	
			LEGACY_INTERFACE = false
			def notifiy_send(model, session)
				button = HtmlGrid::Button.new(:notifiy_send, @model, @session, self)
				button.value = @lookandfeel.lookup(:notify_send)
				url = @lookandfeel.event_url(:notify_send)
				button.set_attribute('onclick', "location.href='#{url}'")
				button
			end												
			def name(model)
				model.name
			end
			def notify_sender(model)
				model.notify_sender
			end
			def notify_recipient(model)
				model.notify_recipient
			end
			def notify_link(model)
				link = HtmlGrid::PopupLink.new(:detail_view, model, @session, self)
				args = {:pointer => model.item.pointer}
        url = @lookandfeel._event_url(:show, args)
				link.href = url
				link.value = [url[0,24], url[-23,23]].join('...')
				link
			end
			def notify_message(model)
				model.notify_message.gsub("\n", '<br>')
			end
		end
		class NotifyComposite < HtmlGrid::Composite
		CSS_CLASS = 'composite'
		COMPONENTS = {
			[1,0]	  =>	View::SearchForm,
			[0,1]	  =>	:notify_title,
			[0,2]	  =>	NotifyForm,
			[1,1]	  =>	'notify_preview',
			[1,2]	  =>	:preview,
		}
		CSS_MAP = {
			[0,1] => 'th',
			[1,1] => 'th',
		}	
		def preview(model, session)
			unless model.empty?
				NotifyPreview.new(model, session, self)
			end
		end
		def notify_title(model, session)
			[@lookandfeel.lookup(:notify_title), model.item.name].join
		end
		end
	end
end
