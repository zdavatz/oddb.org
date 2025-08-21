#!/usr/bin/env ruby

# ODDB::View::DataFormat -- oddb.org -- 11.10.2012 -- yasaka@ywesee.com
# ODDB::View::DataFormat -- oddb.org -- 02.03.2012 -- mhatakeyama@ywesee.com
# ODDB::View::DataFormat -- oddb.org -- 14.03.2003 -- hwyss@ywesee.com

require "view/external_links"

module ODDB
  module View
    module DataFormat
      include ExternalLinks
      def breakline(txt, length)
        name = ""
        line = ""
        last = ""
        txt.to_s.split(/(:?[\s-])/u).each { |part|
          if (line.length + last.length + part.length) > length \
            && part.length > 3
            name << line << last << "<br>"
            line = ""
          else
            line << last
          end
          last = part
        }
        name << line << last
      end

      def company_name(model, session = @session)
        if (comp = model.company)
          link = nil
          if @lookandfeel.enabled?(:powerlink, false) && comp.powerlink
            link = HtmlGrid::PopupLink.new(:name, comp, session, self)
            link.href = @lookandfeel._event_url(:powerlink, {"pointer" => comp.pointer})
            link.set_attribute("class", "powerlink")
          elsif @lookandfeel.enabled?(:companylist) \
            && comp.listed?
            link = View::PointerLink.new(:name, comp, session, self)
          else
            link = HtmlGrid::Value.new(:name, comp, session, self)
          end
          link.value = breakline(comp.name, 21)
          link
        end
      end

      def most_precise_dose(model, session = @session)
        if model.respond_to?(:most_precise_dose)
          dose = model.most_precise_dose
          if dose.is_a?(Quanty)
            dose = (dose && (dose.qty > 0)) ? dose : nil
          end
          dose.to_s.gsub(/\s+/u, "&nbsp;")
        end
      end

      def name_base(model, session = @session)
        ## optimization: there is a new Instance of the including Component for
        ## each new query. Therefore it should be _much_ faster to have an
        ## instance variable @query than to call @session.persistent_user_input
        ## for every line in a result
        @query ||= @session.persistent_user_input(:search_query)
        @type ||= @session.persistent_user_input(:search_type)
        link = HtmlGrid::Link.new(:compare, model, session, self)
        args = [
          :pointer, model.pointer, :search_type, @type, :search_query, @query
        ]
        link.href = if (ean_code = model.barcode)
          @lookandfeel._event_url(:compare) + "ean13/" + ean_code
        else
          @lookandfeel._event_url(:compare, args)
        end
        link.value = breakline(model.name_base, 25)
        link_class = "big" << resolve_suffix(model)
        link.css_class = link_class
        if model.good_result?(@query) && !@lookandfeel.disabled?(:best_result)
          link.set_attribute("name", "best_result")
        end
        indication = model.registration.indication
        descr = model.descr
        if descr && descr.empty?
          descr = nil
        end
        title = [
          descr,
          @lookandfeel.lookup(:ean_code, model.barcode),
          (indication.send(@session.language) unless indication.nil?)
        ].compact.join(", ")
        link.set_attribute("title", title)
        name_bases = [link]
        unless @lookandfeel.disabled?(:photo_link)
          if url = model.photo_link and !url.to_s.empty?
            photo = HtmlGrid::Link.new(:photo_link_short, model, @session, self)
            if model.has_flickr_photo?
              if model.has_fachinfo?
                args = [:reg, model.iksnr, :chapter, :photos]
                photo.href = @lookandfeel._event_url(:fachinfo, args)
              else
                args = [:reg, model.iksnr, :seq, model.seqnr, :pack, model.ikscd]
                photo.href = @lookandfeel._event_url(:foto, args)
              end
            else
              photo.href = url
            end
            photo.set_attribute("title", @lookandfeel.lookup(:photo_link_title))
            photo.css_class = ("square infos")
            name_bases.concat([" ‐ ", photo])
          end
        end
        if !@lookandfeel.disabled?(:atc_division_link) and
            (seq = model.sequence and div = seq.division and !div.empty?)
          div = HtmlGrid::Link.new(:division_link_short, model, @session, self)
          args = [
            :reg, model.iksnr,
            :seq, model.seqnr
          ]
          div.href = @lookandfeel._event_url(:show, args)
          div.set_attribute("title", @lookandfeel.lookup(:division_link_title))
          div.css_class = "square infos"
          name_bases.concat([" - ", div])
        end
        if @lookandfeel.enabled?(:link_trade_name_to_fachinfo, false)
          if model.fachinfo
            link.href = @lookandfeel._event_url(:fachinfo, {reg: model.iksnr})
            link.set_attribute("title", @lookandfeel.lookup(:fachinfo))
          else
            link.href = nil
            link.value = breakline(model.name_base, 25)
          end
        end
        name_bases
      rescue
        ""
      end

      def price(model, session = @session)
        formatted_price(:price, model)
      end

      def price_exfactory(model, session = @session)
        formatted_price(:price_exfactory, model)
      end

      def price_public(model, session = @session)
        span = formatted_price(:price_public, model)
        if @lookandfeel.enabled?(:link_pubprice_to_price_comparison, false)
          price_span = HtmlGrid::Link.new(:compare, model, session, self)
          price_span.href = if (ean_code = model.barcode)
            @lookandfeel._event_url(:compare) + "ean13/" + ean_code
          else
            @lookandfeel._event_url(:compare, [:pointer, model.pointer, :search_type, @type, :search_query, @query])
          end
          price_span.set_attribute("title", @lookandfeel.lookup(:compare))
          price_span.value = span.respond_to?(:value) ? span.value : span
          price_span.label = true
          return price_span
        end
        span
      end

      private

      def formatted_price(key, model)
        price_chf = model.respond_to?(key) ? model.send(key).to_i : 0
        if price_chf != 0
          span = nil
          suffix = ""
          if @lookandfeel.enabled?(:price_history) \
            && model.respond_to?(:has_price_history?) && model.has_price_history?
            span = HtmlGrid::Link.new(:price_history, model, @session, self)
            pointer = if model.is_a?(ODDB::Package) || model.is_a?(ODDB::State::Drugs::Compare::Comparison::PackageFacade)
              [:reg, model.registration.iksnr, :seq, model.sequence.seqnr, :pack, model.ikscd]
            else
              [:pointer, model.pointer]
            end
            span.href = @lookandfeel._event_url(:price_history, [pointer])
            suffix = @lookandfeel.lookup(:click_for_price_history)
          else
            span = HtmlGrid::Span.new(model, @session, self)
          end
          span.value = @lookandfeel.format_price(price_chf)
          title = "CHF"
          span.set_attribute("title", title << suffix)
          span.label = true
          span
        elsif !@lookandfeel.disabled?(:price_request)
          link = wiki_link(model, :price_request,
            :price_request_pagename)
          link.label = true
          link
        else
          @lookandfeel.lookup(:deductible_unknown)
        end
      end
    end
  end
end
