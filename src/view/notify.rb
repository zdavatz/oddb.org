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
    module NotifyTitle
      def notify_title(model, session=@session)
        key = case @session.zone
              when :migel
                :notify_migel_title
              else
                :notify_title
              end
        [@lookandfeel.lookup(key), model.item.name].join
      end
    end
		class NotifyForm < HtmlGrid::Form
			include HtmlGrid::ErrorMessage
			COMPONENTS = {
				[0,0]			=>	:name,
				[0,1]			=>	:notify_sender,
				[0,2]			=>	:notify_recipients,
				[1,3]			=>	:notify_link,
				[0,4]			=>	:notify_message,
				[1,5]			=>	:submit,
			}
			CSS_MAP = {
				[0,0,2,6]	=>	'list',
				[0,4]	=>	'list top',
			}
			COMPONENT_CSS_MAP = {
				[1,0,1,3] => 'xl',
			}
			CSS_CLASS = 'component'
			LABELS = true
			EVENT = :notify_send
			LEGACY_INTERFACE = false
      LOOKANDFEEL_MAP = {
        :name => :name_sender,
      }
			def init
				super
				error_message()
			end
			def notify_link(model)
				link = HtmlGrid::PopupLink.new(:detail_view, model, @session, self)
				args = {:pointer => model.item.pointer}
        url = @lookandfeel._event_url(:show, args)
				link.href = url
				link.value = url #[url[0,24], url[-23,23]].join('...')
				link
			end
			def notify_message(model)
				input = HtmlGrid::Textarea.new(:notify_message, model, @session, self)
				input.set_attribute('wrap', true)
				js = "if(this.value.length > 500) { (this.value = this.value.substr(0,500))}" 
				input.set_attribute('onKeypress', js)
				input.label = true
				input
			end
      def notify_recipients(model)
        input = HtmlGrid::InputText.new(:notify_recipient, model, @session, self)
        input.value = (model.notify_recipient || []).join(', ')
        input
      end
		end
    class NotifyComposite < HtmlGrid::Composite
      include NotifyTitle
      CSS_CLASS = 'composite'
      COMPONENTS = {
        [0,0]	  =>	View::SearchForm,
        [0,1]	  =>	:notify_title,
        [0,2]	  =>	NotifyForm,
      }
      CSS_MAP = {
        [0,1] => 'th',
      }	
    end
    class Notify < View::ResultTemplate
      CONTENT = View::NotifyComposite
    end
	end
end
