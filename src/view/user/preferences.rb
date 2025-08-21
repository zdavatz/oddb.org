# ODDB::View::User::Preferences -- oddb -- 04.10.2012 -- yasaka@ywesee.com

require "htmlgrid/form"
require "htmlgrid/inputradio"
require "htmlgrid/inputcheckbox"
require "view/privatetemplate"
require "view/form"

module ODDB
  module View
    module User
      class PreferencesForm < View::Form
        COMPONENTS = {
          [0, 0] => "style_chooser_description",
          [0, 1] => :styles,
          [0, 2] => "search_type_selection_description",
          [0, 3] => :search_forms,
          [0, 4] => :search_types,
          [0, 5] => "search_limitation_description",
          [0, 6] => :search_limitation_types,
          [0, 7] => :search_limitation_SL_only,
          [0, 8] => "search_swissmedic_description",
          [0, 9] => :search_limitation_valid,
          [0, 10] => :button
        }
        CSS_MAP = {
          [0, 0] => "subheading",
          [0, 1] => "list",
          [0, 2] => "subheading",
          [0, 3] => "list",
          [0, 4] => "list",
          [0, 5] => "subheading",
          [0, 6] => "list",
          [0, 7] => "list",
          [0, 8] => "subheading",
          [0, 9] => "list",
          [0, 10] => "button"
        }
        CSS_CLASS = "composite"
        def styles(model, session = @session)
          fields = []
          chosen = session.get_cookie_input(:style)
          chosen ||= "default"
          @lookandfeel.attributes(:styles).each_pair do |name, attrs|
            radio = HtmlGrid::InputRadio.new(:style, model, session, self)
            radio.set_attribute("id", name)
            radio.value = name
            if chosen and name == chosen
              radio.set_attribute("checked", true)
            end
            div = HtmlGrid::Div.new(model, session, self)
            div.value = []
            attrs.keys.each do |attr|
              inner = HtmlGrid::Div.new(model, session, self)
              inner.value = "&nbsp;"
              inner.set_attribute("style", "width:200px;background-color:#{attrs[attr]};")
              div.value << inner
            end
            label = label_for(name, @lookandfeel.lookup("oddb_style_#{name}"))
            fields << [radio, "&nbsp;", label, div]
            fields << "<br/>"
          end
          fields
        end

        def search_limitation_SL_only(model, session = @session)
          get_checkbock(:search_limitation_SL_only, model, session)
        end

        def get_checkbock(method, model, session)
          chosen = session.get_cookie_input(method)
          checkbox = ::HtmlGrid::InputCheckbox.new(method, model, session, self)
          checkbox.set_attribute("id", method.to_s)
          if chosen && chosen.to_s.eql?("true")
            checkbox.value = "true"
            checkbox.set_attribute("checked", true)
          end
          [checkbox, "&nbsp;", @lookandfeel.lookup(method)]
        end

        def search_limitation_valid(model, session = @session)
          get_checkbock(:search_limitation_valid, model, session)
        end

        def search_limitation_types(model, session = @session)
          fields = []
          [
            :search_limitation_A,
            :search_limitation_B,
            :search_limitation_C,
            :search_limitation_D,
            :search_limitation_E
          ].each do |method|
            fields << get_checkbock(method, model, session) + ["<br/>"]
          end
          fields
        end

        def search_forms(model, session = @session)
          fields = []
          chosen = session.get_cookie_input(:search_form)
          chosen ||= "plus"
          %w[plus instant].each do |method|
            radio = HtmlGrid::InputRadio.new(:search_form, model, session, self)
            radio.set_attribute("id", method)
            radio.value = method
            if chosen and method == chosen
              radio.set_attribute("checked", true)
            end
            label = label_for(method.capitalize)
            if label.value == "Plus"
              label.value << " (oddb.org Default)"
            end
            fields << [radio, "&nbsp;", label]
            fields << "<br/>"
          end
          fields
        end

        def search_types(model, session = @session)
          fields = []
          chosen = session.get_cookie_input(:search_type)
          chosen ||= "st_oddb"
          @session.valid_values(:search_type).each do |name|
            radio = HtmlGrid::InputRadio.new(:search_type, model, session, self)
            radio.set_attribute("id", name)
            radio.value = name
            if chosen and name == chosen
              radio.set_attribute("checked", true)
            end
            label = label_for(name, @lookandfeel.lookup(name).dup)
            if label.value == @lookandfeel.lookup(:compare)
              label.value << " (oddb.org Default)"
            end
            fields << [radio, "&nbsp;", label]
            fields << "<br/>"
          end
          fields
        end

        def label_for(name, text = nil)
          label = HtmlGrid::SimpleLabel.new(name, @model, @session, self)
          label.instance_eval { @attributes["for"] = name.downcase }
          label.set_attribute("style", "font-weight:normal;")
          label.value = (text || name)
          label
        end

        def button(model, session = @session)
          post_event_button(:update)
        end
      end

      class PreferencesComposite < HtmlGrid::Composite
        COMPONENTS = {
          [0, 0] => "preferences",
          [0, 1] => View::User::PreferencesForm,
          [0, 2] => "&nbsp;"
        }
        CSS_MAP = {
          [0, 0] => "th bold",
          [0, 1] => "component"
        }
        CSS_CLASS = "composite"
      end

      class Preferences < View::PrivateTemplate
        SEARCH_HEAD = ODDB::View::SelectSearchForm
        CONTENT = View::User::PreferencesComposite
        HEAD = View::LogoHead
        JAVASCRIPTS = ["autofill"]
      end
    end
  end
end
