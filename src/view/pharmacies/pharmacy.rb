#!/usr/bin/env ruby
require "htmlgrid/composite"
require "htmlgrid/labeltext"
require "htmlgrid/select"
require "htmlgrid/text"
require "htmlgrid/urllink"
require "view/privatetemplate"
require "htmlgrid/value"
require "htmlgrid/inputfile"
require	"htmlgrid/errormessage"
require	"htmlgrid/infomessage"
require	"htmlgrid/form"
require "view/descriptionform"
require "view/form"
require "view/captcha"
require "view/address"
require "view/admin/address_suggestion"
require "view/pointervalue"
require "view/sponsorlogo"

module ODDB
  module View
    module Pharmacies
      class PharmacyInnerComposite < HtmlGrid::Composite
        include VCardMethods
        include AddressMap
        COMPONENTS = {
          [0, 1, 0] => :ean13_header,
          [0, 1, 1] => :nbsp,
          [0, 1, 2] => :ean13,
          [0, 2, 0] => :business_area_header,
          [0, 2, 1] => :nbsp,
          [0, 2, 2] => :business_area,
          [0, 3, 0] => :narcotics_header,
          [0, 3, 1] => :nbsp,
          [0, 3, 2] => :narcotics,
          [0, 4] => :address_header,
          [0, 5] => :address
          # [0,12]		=>	:map,
          # [0,4]		=>	:vcard,
        }
        SYMBOL_MAP = {
          address_header: HtmlGrid::LabelText,
          ean13_header: HtmlGrid::LabelText,
          business_area_header: HtmlGrid::LabelText,
          narcotics_header: HtmlGrid::LabelText,
          fons_header: HtmlGrid::LabelText,
          fax_header: HtmlGrid::LabelText,
          nbsp: HtmlGrid::Text,
          url: HtmlGrid::HttpLink
        }
        CSS_MAP = {
          [0, 1] => "list",
          [0, 2] => "list",
          [0, 3] => "list",
          [0, 4] => "list",
          [0, 5] => "list"
        }
        DEFAULT_CLASS = HtmlGrid::Value
        LEGACY_INTERFACE = false
        def business_area(model, session = @session)
          if (area = model.business_area) && !area.empty?
            @lookandfeel.lookup(area)
          end
        end

        def narcotics(model)
          if model.respond_to?(:narcotics)
            model.narcotics
          else
            @lookandfeel.lookup(:false)
          end
        end

        def mapsearch_format(*args)
          args.compact.join("-").gsub(/\s+/u, "-")
        end

        def address(model)
          Address.new(model.addresses.first, @session, self)
        end

        def location(model)
          if (addr = model.addresses.first)
            addr.location
          end
        end

        def vcard(model)
          link = View::PointerLink.new(:vcard, model, @session, self)
          link.href = @lookandfeel._event_url(:vcard, {pharmacy: model.ean13})
          link
        end
      end

      class PharmacyForm < HtmlGrid::Form
        include View::Admin::AddressFormMethods
        COMPONENTS = {
          [0, 0]	=>	:ean13,
          [0, 1]	=>	:name,
          [0, 3]	=>	:address_type,
          [0, 4]	=>	:title,
          [0, 5]	=>	:contact,
          [0, 6]	=>	:additional_lines,
          [0, 7]	=>	:address,
          [0, 8]	=>	:location,
          [0, 9]	=>	:canton,
          [0, 10]	=>	:fon,
          [0, 11]	=>	:fax,
          [1, 12]	=>	:submit,
          [1, 12, 1] =>	:set_pass
        }
        CSS_MAP = {
          [0, 0, 2, 13]	=>	"list",
          [0, 6]	=> "list top"
        }
        COMPONENT_CSS_MAP = {
          [0, 0, 2, 12]	=>	"standard"
        }
        EVENT = :update
        LABELS = true
        LEGACY_INTERFACE = false
        SYMBOL_MAP = {
          ean13: HtmlGrid::Value
        }
        def additional_lines(model)
          super(model.address(0))
        end

        def address(model)
          Address.new(model.addresses.first, @session, self)
        end

        def address_input(symbol, model)
          HtmlGrid::InputText.new(symbol, model.address(0), @session, self)
        end

        def contact(model)
          address_input(:contact, model)
        end

        def address_type(model)
          HtmlGrid::Select.new(:address_type, model.address(0),
            @session, self)
        end

        def canton(model)
          address_input(:canton, model)
        end

        def fax(model)
          address_input(:fax, model)
        end

        def fon(model)
          address_input(:fon, model)
        end

        def title(model)
          address_input(:title, model)
        end

        def location(model)
          address_input(:location, model)
        end

        def set_pass(model)
          button = HtmlGrid::Button.new(:set_pass, model, @session, self)
          script = 'this.form.event.value="set_pass"; this.form.submit();'
          button.set_attribute("onClick", script)
          button
        end
      end

      class PharmacyComposite < HtmlGrid::Composite
        include VCardMethods
        COMPONENTS = {
          [0, 0, 0]	=>	:title,
          [0, 0, 1]	=>	:nbsp,
          [0, 0, 2]	=>	:firstname,
          [0, 0, 3]	=>	:nbsp,
          [0, 0, 4]	=>	:name,
          [0, 1]	=> PharmacyInnerComposite
          # [0,3]		=>	:vcard,
        }
        SYMBOL_MAP = {
          nbsp: HtmlGrid::Text
        }
        CSS_MAP = {
          [0, 0]	=> "th",
          [0, 1]	=> "list"
        }
        CSS_CLASS = "composite"
        DEFAULT_CLASS = HtmlGrid::Value
        LEGACY_INTERFACE = false
      end

      class RootPharmacyComposite < PharmacyComposite
        COMPONENTS = {
          [0, 0, 0]	=>	:title,
          [0, 0, 1]	=>	:nbsp,
          [0, 0, 2]	=>	:firstname,
          [0, 0, 3]	=>	:nbsp,
          [0, 0, 4]	=>	:name,
          [0, 1]	=> PharmacyForm
        }
      end

      class Pharmacy < PrivateTemplate
        CONTENT = View::Pharmacies::PharmacyComposite
        SNAPBACK_EVENT = :result
      end

      class RootPharmacy < Pharmacy
        CONTENT = View::Pharmacies::RootPharmacyComposite
      end
    end
  end
end
