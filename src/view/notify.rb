#!/usr/bin/env ruby
# View::Notify -- oddb -- 24.10.2005 -- ffricker@ywesee.com

require 'view/publictemplate'
require 'view/additional_information'
require 'view/searchbar'
require 'view/drugs/package'
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
    class NotifyInnerComposite < HtmlGrid::Composite
			include HtmlGrid::ErrorMessage
			COMPONENTS = {
				[0,0]			=>	:name,
				[0,1]			=>	:notify_sender,
				[0,2]			=>	:notify_recipients,
				[0,3]			=>	:notify_message,
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
      def notify_recipients(model)
        input = HtmlGrid::InputText.new(:notify_recipient, model, @session, self)
        input.value = (model.notify_recipient || []).join(', ')
        input
      end
		end
    module NotifyItem
      def notify_item(model)
        mdl = model.item
        case mdl
        when ODDB::Package
          View::Drugs::PackageInnerComposite.new(mdl, @session, self)
        when ODDB::Migel::Product
          View::Migel::ProductInnerComposite.new(mdl, @session, self)
        end
      end
    end
		class NotifyForm < HtmlGrid::Form
      include NotifyItem
			EVENT = :notify_send
			LEGACY_INTERFACE = false
      COMPONENTS = {
        [0,0]	  =>	NotifyInnerComposite,
        [0,2]   =>  :notify_item,
				[0,3]		=>	:submit,
      }
      CSS_MAP = {
        [0,0] => 'bg',
        [0,2] => 'bg',
        [0,3] => 'list',
      }
    end
    class NotifyComposite < HtmlGrid::Composite
      include NotifyTitle
			LEGACY_INTERFACE = false
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
    class NotifyMail < HtmlGrid::Template
      include NotifyItem
      DEFAULT_CLASS = HtmlGrid::Value
      LABELS = false
      LEGACY_INTERFACE = false
      COMPONENTS = {
        [0,0]	  =>	:notify_message,
        [0,2]   =>  :notify_item,
      }
			CSS_CLASS = "composite"
      CSS_MAP = {
        [0,0] => 'list bg',
        [0,2] => 'bg',
      }
    end
	end
end
