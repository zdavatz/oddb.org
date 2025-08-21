#!/usr/bin/env ruby

# ODDB::View::ResultFoot -- oddb.org -- 24.12.2012 -- yasaka@ywesee.com
# ODDB::View::ResultFoot -- oddb.org -- 22.06.2011 -- mhatakeyama@ywesee.com
# ODDB::View::ResultFoot -- oddb.org -- 20.03.2003 -- hwyss@ywesee.com

require "htmlgrid/composite"
require "htmlgrid/link"
require "htmlgrid/span"
require "view/external_links"
require "view/additional_information"

module ODDB
  module View
    class ExplainResult < HtmlGrid::Composite
      include ExternalLinks
      include AdditionalInformation
      COMPONENTS = {}
      CSS_MAP = {}
      CSS_KEYMAP = {
        "explain_unknown" => "infos bold",
        "explain_expired" => "infos bold expired",
        :explain_cas => "infos",
        :explain_comarketing => "infos",
        :explain_vaccine => "infos",
        :explain_ddd_price => "infos",
        :explain_deductible => "infos",
        :explain_phytotherapy => "infos",
        :explain_anthroposophy => "infos",
        :explain_homeopathy => "infos",
        :explain_parallel_import => "infos",
        :explain_fachinfo => "infos",
        "explain_ebp" => "infos",
        "explain_pbp" => "infos",
        :explain_patinfo => "infos",
        "explain_mail_order_price_title" => "bold",
        :explain_mail_order_price_compare => "infos",
        :explain_mail_order_price_discount => "infos",
        :explain_mail_order_price_normal => "infos",
        :explain_narc => "infos",
        :explain_limitation => "infos",
        :explain_google_search => "infos",
        :explain_feedback => "infos"
      }
      CSS_ID = "explain_result"
      def initialize model, session, container, components = nil
        @components = components
        super(model, session, container)
      end

      def init
        @components ||= @lookandfeel.explain_result_components
        width = 1
        height = 1
        @components.each { |key, val|
          if (klass = CSS_KEYMAP[val])
            css_map.store(key, klass)
          end
          x, y, = key
          width = [x, width].max
          height = [y.next, height].max
        }
        super
      end

      def explain_comarketing(model, session = @session)
        explain_square_link(model, :comarketing, CoMarketingPlugin.get_comarketing_url)
      end

      def explain_ddd_price(model, session = @session)
        explain_link(model, :ddd_price)
      end

      def explain_deductible(model, session = @session)
        explain_link(model, :deductible)
      end

      def explain_anthroposophy(model, session = @session)
        explain_square_link(model, :anthroposophy)
      end

      def explain_fachinfo(model, session = @session)
        explain_square_link(model, :fachinfo)
      end

      def explain_feedback(model, session = @session)
        explain_square_link(model, :feedback)
      end

      def explain_generic(model, session = @session)
        explain_link(model, :generic)
      end

      def explain_google_search(model, session = @session)
        explain_square_link(model, :google_search)
      end

      def explain_limitation(model, session = @session)
        explain_square_link(model, :limitation)
      end

      def explain_mail_order_price_compare(model, session = @session)
        [
          HtmlGrid::Image.new(:logo_rose_long, model, @session, self),
          @lookandfeel.lookup(:explain_mail_order_price_compare)
        ]
      end

      def explain_mail_order_price_discount(model, session = @session)
        [
          HtmlGrid::Image.new(:logo_rose_orange, model, @session, self),
          @lookandfeel.lookup(:explain_mail_order_price_discount)
        ]
      end

      def explain_mail_order_price_normal(model, session = @session)
        [
          HtmlGrid::Image.new(:logo_rose_green, model, @session, self),
          @lookandfeel.lookup(:explain_mail_order_price_normal)
        ]
      end

      def explain_minifi(model, session = @session)
        explain_square_link(model, :minifi)
      end

      def explain_original(model, session = @session)
        explain_link(model, :original)
      end

      def explain_patinfo(model, session = @session)
        explain_square_link(model, :patinfo)
      end

      def explain_homeopathy(model, session = @session)
        explain_square_link(model, :homeopathy)
      end

      def explain_parallel_import(model, session = @session)
        explain_square_link(model, :parallel_import)
      end

      def explain_phytotherapy(model, session = @session)
        explain_square_link(model, :phytotherapy)
      end

      def explain_vaccine(model, session = @session)
        explain_square_link(model, :vaccine, @lookandfeel.lookup(:explain_vaccine_url))
      end

      def explain_cas(model, session = @session)
        explain_link(model, :cas)
      end

      def explain_lppv(model, session = @session)
        explain_link(model, :lppv)
      end

      def explain_narc(model, session = @session)
        explain_square_link(model, :narc, @lookandfeel.lookup(:explain_narc_url))
      end

      def explain_link(model, key)
        if @lookandfeel.disabled?(:explain_link) or @lookandfeel.disabled?("explain_#{key}_url")
          link = HtmlGrid::SimpleLabel.new("explain_#{key}", model, @session, self)
          link.value = @lookandfeel.lookup("explain_#{key}")
        else
          link = external_link(model, "explain_#{key}")
          link.href = @lookandfeel.lookup("explain_#{key}_url")
        end
        link.attributes["class"] = "explain #{key}"
        link
      end

      def explain_square_link(model, key, url = nil)
        exp_key = :"explain_#{key}"
        url_key = :"explain_#{key}_url"
        square_key = :"square_#{key}"
        value = @lookandfeel.lookup(exp_key || exp_key.to_s)
        if @lookandfeel.disabled?(url_key.to_sym)
          link = HtmlGrid::SimpleLabel.new(exp_key, model, @session, self)
          link.value = @lookandfeel.lookup(square_key)
          link.value ||= ""
          link.value += value
        else
          link = HtmlGrid::Link.new(square_key, model, @session, self)
          if url
            link.href = url
            return [square(key, link), value]
          else
            return [square(key), value]
          end
        end
        link.attributes["class"] = "explain #{key}"
        link
      end
    end

    module ResultFootBuilder
      def result_foot(model, session = @session)
        View::ResultFoot.new(model, @session, self)
      end
    end

    class ResultFoot < HtmlGrid::Composite
      include ExternalLinks
      COLSPAN_MAP	= {}
      COMPONENTS = {
        [0, 0] => "nbsp",
        [0, 1] => :explain_result
      }
      CSS_MAP = {
        [0, 0] => "explain",
        [0, 1] => "explain"
      }
      CSS_CLASS = "composite"
      def init
        unless @lookandfeel.disabled?(:show_caption)
          elements = if @lookandfeel.enabled?(:legal_note_vertical, false)
            {
              [0, 0] => :toggle_switch,
              [0, 2] => :legal_note
            }
          else
            {
              [1, 0] => :toggle_switch,
              [1, 1] => :legal_note
            }
          end
          elements.each_pair do |coordinates, element|
            components.store(coordinates, element)
            css_map.store(coordinates, "explain right")
          end
          if @session.request_path.index("/drugs/search_query") ||
              @session.request_path.index("/compare/")
            components[[0, 0]] = :price_compare
          end
        end
        super
      end

      def price_compare(model, session = @session)
        span = HtmlGrid::Span.new(model, @session, self)
        span.value = @lookandfeel.lookup(:price_compare)
        span.set_attribute("id", "price_compare")
        span
      end

      def explain_result(model, session = @session)
        klass = nil
        if defined?(@container.class::EXPLAIN_RESULT)
          klass = @container.class::EXPLAIN_RESULT
        end
        klass ||= View::ExplainResult
        result = klass.new(model, @session, self)
        result.set_attribute("style", "display:none;")
        result
      end

      def legal_note(model, session = @session)
        link = super(model)
        link.set_attribute("id", "legal_note")
        link.set_attribute("style", "display:none;")
        link.css_class = "subheading"
        link
      end

      def toggle_switch(model, session = @session)
        span = HtmlGrid::Span.new(model, @session, self)
        span.value = @lookandfeel.lookup(:show_legend)
        span.css_class = "link"
        span.set_attribute("id", "toggle_switch")
        script = <<~JS
          (function () {
          var span    = document.getElementById('toggle_switch');
          var legends = document.getElementById('explain_result');
          #{legal_note? ? "var note    = document.getElementById('legal_note');" : ""}
          if (legends.style.display != 'none') {
            legends.style.display = 'none';
            #{legal_note? ? "note.style.display    = 'none'; " : ""}
            span.innerHTML        = '#{@lookandfeel.lookup(:show_legend)}';
          } else {
            legends.style.display = 'block';
            #{legal_note? ? "note.style.display    = 'block';" : ""}
            span.innerHTML        = '#{@lookandfeel.lookup(:hide_legend)}';
          }
          })();
        JS

        span.onclick = script
        span.onload = script if @lookandfeel.enabled?(:show_legend_by_default, false)
        span
      end

      def legal_note?
        !@lookandfeel.disabled?(:legal_note)
      end
    end
  end
end
