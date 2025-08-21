#!/usr/bin/env ruby

# ODDB::View::Drugs::InteractionChooser -- oddb.org -- 20.12.2012 -- yasaka@ywesee.com

require "csv"
require "cgi"
require "htmlentities"
require "htmlgrid/infomessage"
require "view/drugs/privatetemplate"
require "view/drugs/centeredsearchform"
require "view/additional_information"
require "view/searchbar"
require "view/printtemplate"
require "view/publictemplate"
require "view/form"
require "view/chapter"
require "model/package"
require "model/epha_interaction"
# Test it with de/gcc/home_interactions/7680317061142,7680353520153,7680546420673,7680193950301,7680517950680

module ODDB
  module View
    module Interactions
      class InteractionChooserDrugHeader < HtmlGrid::Composite
        include View::AdditionalInformation
        COMPONENTS = {
          [0, 0] => :fachinfo,
          [1, 0] => :drug,
          [2, 0] => :delete,
          [3, 0] => :atc_code
        }
        CSS_MAP = {
          [0, 0] => "small",
          [1, 0] => "interaction-drug",
          [2, 0] => "small",
          [3, 0] => "interaction-atc"
        }
        def init
          @printing_active = !@session.request_path.index("/print/rezept/").nil?
          super
        end

        def fachinfo(model, session = @session)
          if @printing_active
            return
          end
          if fi = super(model, session, "square bold infos")
            fi.set_attribute("target", "_blank")
            fi
          end
        end

        def drug(model, session = @session)
          div = HtmlGrid::Div.new(model, @session, self)
          div.set_attribute("class", "interaction-drug")
          div.value = []
          if model
            div.value << model.name_with_size
            if price = model.price_public
              div.value << "&nbsp;-&nbsp;"
              div.value << price.to_s
            end
            unless model.substances.empty?
              div.value << "&nbsp;-&nbsp;"
              div.value << model.substances.join(",")
            end
            if company = model.company_name
              div.value << "&nbsp;-&nbsp;"
              div.value << company
            end
          end
          div
        end

        def atc_code(model, session = @session)
          div = HtmlGrid::Div.new(model, @session, self)
          div.set_attribute("class", "interaction-atc")
          div.value = []
          div.value << model.atc_class.code + ": " + model.atc_class.name if model.atc_class
          div
        end

        def delete(model, session = @session)
          return if @printing_active
          if @container.is_a? ODDB::View::Interactions::InteractionChooserDrug
            link = HtmlGrid::Link.new(:minus, model, session, self)
            link.set_attribute("title", @lookandfeel.lookup(:delete))
            link.css_class = "delete square"
            if model
              [:ean, model.barcode] if model
              url = @session.request_path.sub(model.barcode.to_s, "").sub("/,", "/").sub(/,$/, "")
              if @session.choosen_drugs.size == 0
                ODDB::View::Interactions.calculate_atc_codes({})
              end
              link.onclick = %(
        window.sessionStorage.removeItem('comment');
        console.log ("Going to new url #{url} in interaction_chooser");
        window.location.href = '#{url}';
        )
              link
            end
          end
        end
      end

      class InteractionChooserDrug < HtmlGrid::Composite
        COMPONENTS = {}
        CSS_MAP = {}
        CSS_CLASS = "composite"
        def init
          # When being called from rezept we should not display the heading
          @printing_active = !@session.request_path.index("/print/rezept/").nil?
          @hide_interaction_headers = !@session.request_path.match(/rezept/).nil?
          ean13 = @session.user_input(:search_query)
          @session.request_path
          @drugs = @session.choosen_drugs
          @interactions = if model.atc_class
            EphaInteractions.get_interactions(model.atc_class.code, @drugs)
          else
            []
          end
          if @model.is_a? ODDB::Package
            nextRow = 0
            unless @hide_interaction_headers
              components.store([0, 0], :header_info)
              css_map.store([0, 0], "subheading") unless @printing_active
              nextRow += 1
            end
            if @drugs and !@drugs.empty?
              components.store([0, nextRow], :text_info)
            end
            @attributes.store("id", "drugs_" + @model.barcode)
          end
          url = @session.create_search_url(ean13)
          self.onsubmit = <<~JS
            function get_to(url) {
              var form = document.createElement("form");
              form.setAttribute("method", "GET");
              form.setAttribute("action", url);
              document.body.appendChild(form);
              form.submit();
            }
            var url = searchbar.baseURI + 'home_interactions/' + ean13;
            var url_new = '#{url}';
            window.location = url;
            console.log('InteractionChooserDrug: get_to: ' + url + ' url_new??: ' url_new);
            window.top.location.replace(url);
            get_to(url);
            return false;
          JS
          super
        end

        def header_info(model, session = @session)
          if @printing_active
            return unless @interactions.size > 0
            span = HtmlGrid::Span.new(model, session, self)
            span.value = @lookandfeel.lookup(:interactions)
            span.set_attribute("id", "InteractionChooserDrug.header_info")
            span.set_attribute("class", "print bold")
            span
          else
            View::Interactions::InteractionChooserDrugHeader.new(model, session, self)
          end
        end

        def text_info(model, session = @session)
          @printing_active = !@session.request_path.index("/print/rezept/").nil?
          return nil unless model.atc_class
          list = HtmlGrid::Div.new(model, @session, self)
          list.value = []
          if @printing_active and @interactions.size > 0
            span = HtmlGrid::Span.new(model, session, self)
            span.value = @lookandfeel.lookup(:interactions)
            span.set_attribute("id", "InteractionChooserDrug.text_info")
            span.set_attribute("class", "print bold italic")
            list.value << span
          end
          EphaInteractions.get_interactions(model.atc_class.code, @session.choosen_drugs).each { |interaction|
            headerDiv = HtmlGrid::Div.new(model, @session, self)
            headerDiv.value = []
            headerDiv.value << interaction[:header]
            unless @printing_active
              headerDiv.set_attribute("class", "interaction-header")
              headerDiv.set_attribute("style", "background-color: #{interaction[:color]}")
            end
            list.value << headerDiv

            infoDiv = HtmlGrid::Div.new(model, @session, self)
            infoDiv.value = []
            infoDiv.value << interaction[:text]
            infoDiv.set_attribute("style", "background-color: #{interaction[:color]}") unless @printing_active
            list.value << infoDiv
          }
          list.css_class = "print" if @printing_active
          list
        end
      end

      class InteractionChooserDrugList < HtmlGrid::List
        attr_reader :model, :value
        COMPONENTS = {}
        CSS_MAP = {}
        CSS_CLASS = "composite"
        SORT_HEADER = false
        def initialize(model, session = @session, arg_self = nil)
          @drugs = session.choosen_drugs
          super # must come first or it will overwrite @value
          @value = []
          if @drugs and !@drugs.empty?
            @drugs.each { |ean, drug|
              @value << InteractionChooserDrug.new(drug, @session, self)
            }
          end
        end
      end

      class InteractionChooserDrugDiv < HtmlGrid::Div
        def init
          super
          @value = []
          @drugs = @session.choosen_drugs
          if @drugs and !@drugs.empty?
            @value << InteractionChooserDrugList.new(@drugs, @session, self)
          end
        end
      end

      class InteractionChooserInnerForm < HtmlGrid::Composite
        attr_reader :index_name
        FORM_METHOD = "POST"
        COMPONENTS = {
          [0, 0] => :searchbar
        }
        SYMBOL_MAP = {
          searchbar: View::InteractionChooserBar
        }
        CSS_MAP = {
          [0, 0] => "searchbar"
        }
        COLSPAN_MAP = {
          [0, 0] => 2
        }
        def init
          super
          @index_name = "oddb_package_name_with_size_company_name_ean13_fi"
          @additional_javascripts = []
        end

        def javascripts(context)
          scripts = ""
          @additional_javascripts.each do |script|
            args = {
              "type" => "text/javascript",
              "language" => "JavaScript"
            }
            scripts << context.script(args) { script }
          end
          scripts
        end

        def to_html(context)
          javascripts(context).to_s << super
        end
      end

      class ExplainInteractionCodes < HtmlGrid::List
        COMPONENTS = {
          [0, 0] => :interaction_codes
        }
        CSS_MAP = {
          [0, 0] => "composite"
        }
        CSS_CLASS = "composite"
        LEGACY_INTERFACE = false
        DEFAULT_HEAD_CLASS = "none"
        OMIT_HEADER = true
        def init
          @entity = @model
          @model = ODDB::EphaInteractions::Ratings.keys
          super
          set_attribute("id", "interaction_codes")
          set_attribute("style", "display: none;")
        end

        def interaction_codes(model)
          txt = HtmlGrid::Div.new(model, @session, self)
          txt.value = model + ": " + ODDB::EphaInteractions::Ratings[model]
          txt.set_attribute("style", "background-color: #{ODDB::EphaInteractions::Colors[model]};")
          txt
        end
      end

      class InteractionLegend < HtmlGrid::Composite
        COMPONENTS = {
          [0, 0] => :toogle_switch,
          [0, 1] => View::Interactions::ExplainInteractionCodes
        }
        CSS_MAP = {
          [0, 0] => "explain right",
          [0, 1] => "explain left"
        }
        COLSPAN_MAP = {
          [0, 0] => 12,
          [0, 1] => 12
        }
        CSS_CLASS = "composite"

        private

        def init
          super
        end

        def toogle_switch(model, session = @session)
          span = HtmlGrid::Span.new(model, @session, self)
          span.value = @lookandfeel.lookup(:show_legend)
          span.css_class = "link"
          span.set_attribute("id", "toggle_switch")
          span.onclick = <<~JS
            (function () {
              var span    = document.getElementById('toggle_switch');
              var legends = document.getElementById('interaction_codes');
              var applyStyle = 'none';
              if (span.innerHTML != '#{@lookandfeel.lookup(:show_legend)}') {
                span.innerHTML        = '#{@lookandfeel.lookup(:show_legend)}';
              } else {
                applyStyle = 'block';
                span.innerHTML        = '#{@lookandfeel.lookup(:hide_legend)}';
              }
              if (legends != null) legends.style.display = applyStyle;
              })();
          JS
          span
        end
      end

      class InteractionChooserForm < View::Form
        include HtmlGrid::InfoMessage
        COMPONENTS = {
          [0, 0, 0] => :interaction_chooser_description,
          [0, 0, 1] => :epha_public_domain,
          [0, 1] => View::Interactions::InteractionChooserDrugDiv,
          [0, 2] => View::Interactions::InteractionChooserInnerForm,
          [0, 3] => :delete_all
        }
        CSS_MAP = {
          [0, 0] => "th bold",
          [0, 1] => "", # none
          [0, 2] => "inner-button",
          [0, 3] => "inner-button"
        }
        COLSPAN_MAP = {
          [0, 0] => 2,
          [0, 1] => 2
        }
        CSS_CLASS = "composite"
        DEFAULT_CLASS = HtmlGrid::Value
        LABELS = true

        private

        def init
          super
          self.onload = %(require(["dojo/domReady!"], function(){
     if (document.getElementById('interaction_searchbar') != null) document.getElementById('interaction_searchbar').focus();
});
)
          @form_properties.update({
            "id" => "interaction_chooser_form",
            "target" => "_blank"
          })
        end

        def epha_public_domain(model, session = @session)
          link = HtmlGrid::Link.new(:epha_public_domain, model, session, self)
          link.css_class = "navigation"
          link.href = "https://epha.ch/matrix/search/q=/"
          link
        end

        def delete_all(model, session = @session)
          @drugs = @session.choosen_drugs
          if @drugs and !@drugs.empty?
            delete_all_link = HtmlGrid::Link.new(:delete, @model, @session, self)
            delete_all_link.href = @lookandfeel._event_url(:delete_all, [])
            delete_all_link.value = @lookandfeel.lookup(:interaction_chooser_delete_all)
            delete_all_link.css_class = "list"
          else
            return nil
          end
          delete_all_link
        end
      end

      class InteractionChooserComposite < HtmlGrid::Composite
        include AdditionalInformation
        COMPONENTS = {
          [0, 0] => View::Interactions::InteractionChooserForm,
          [0, 1] => View::Interactions::InteractionLegend
        }
        COMPONENT_CSS_MAP = {
          [0, 0] => "composite",
          [0, 1] => "composite"
        }
        COLSPAN_MAP = {
          [0, 0] => 12,
          [0, 1] => 12
        }
        CSS_CLASS = "composite"
      end

      class InteractionChooser < View::PrivateTemplate
        CONTENT = View::Interactions::InteractionChooserComposite
        SNAPBACK_EVENT = :home
        JAVASCRIPTS = ["admin"]
        SEARCH_HEAD = "nbsp"
        def init
          super
        end

        def backtracking(model, session = @session)
          fields = []
          link = HtmlGrid::Link.new(:home_interactions, model, @session, self)
          link.css_class = "list"
          link.href = @lookandfeel._event_url(:home_interactions, [])
          link.value = @lookandfeel.lookup(:home)
          fields << link
          fields << "&nbsp;-&nbsp;"
          span = HtmlGrid::Span.new(model, session, self)
          span.value = @lookandfeel.lookup(:interaction_chooser)
          span.set_attribute("class", "bold")
          fields << span
          fields
        end
      end
    end
  end
end
