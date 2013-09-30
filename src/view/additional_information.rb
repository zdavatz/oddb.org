#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::AdditionalInformation -- oddb.org -- 27.03.2012 -- yasaka@ywesee.com
# ODDB::View::AdditionalInformation -- oddb.org -- 29.02.2012 -- mhatakeyama@ywesee.com
# ODDB::View::AdditionalInformation -- oddb.org -- 09.12.2003 -- rwaltert@ywesee.com

require 'view/drugs/atcchooser'
require 'iconv'
require 'plugin/comarketing'

module ODDB
	module View
    module PartSize
      def comparable_size(model, session=@session)
        comforms = model.commercial_forms
        unless(comforms.compact.empty?)
          model.parts.collect { |part|
            part_size part
          }.join(' + ')
        else
          model.size
        end
      end
      def part_size(part, session=@session)
        parts = []
        multi = part.multi.to_i
        count = part.count.to_i
        if(multi > 1) 
          parts.push(multi)
        end
        if(multi > 1 && count > 1)
          parts.push('x')
        end
        if(count > 1 || (count > 0 && multi > 1))
          parts.push(part.count)
        end
        measure = part.measure
        measure = nil if measure == 1
        if(comform = part.commercial_form)
          parts.push(comform.send(@session.language))
          parts.push "&agrave;" if measure
        elsif(measure && !parts.empty?)
          parts.push('x')
        end
        parts.push measure if(measure)
        parts.join(' ')
      end
    end
		module AdditionalInformation
      include Drugs::AtcLink
      include PartSize
      def atc_ddd_link(atc, session=@session)
        unless(@lookandfeel.disabled?(:atc_ddd))
          while(atc && !atc.has_ddd? && (code = atc.parent_code))
            atc = session.app.atc_class(code)
          end
          super(atc, session)
        end
      end
      def atc_drugbank_link(atc, session=@session)
        if(atc.respond_to?(:db_id) and \
           atc.db_id  and \
           !@lookandfeel.disabled?(:atc_drugbank_link))
          super(atc, session)
        end
      end
      def atc_dosing_link(atc, session=@session)
        if(atc.respond_to?(:ni_id) and \
           atc.ni_id  and \
           !@lookandfeel.disabled?(:atc_dosing_link))
          super(atc, session)
        end
      end
      def atc_pharmacokinetic_link(atc, session=@session)
        if(atc.code and \
           !@lookandfeel.disabled?(:atc_pharmacokinetic_link))
          super(atc, session)
        end
      end
			def atc_description(atc, session=@session)
				if(descr = atc.description(@lookandfeel.language))
					descr.dup.to_s << ' (' << atc.code << ')' 
				else
					atc.code
				end
			end
      def barcode(model, session=@session)
        ean13 = HtmlGrid::Value.new(:barcode, model, @session, self)
        ean13.label = false
        ean13
      end
			def comarketing(model, session=@session)
				if(model.parallel_import)
					square(:parallel_import)
				elsif(model.patent_protected?)
					link = HtmlGrid::Link.new(:square_patent, model, @session, self)
					link.href = @lookandfeel.lookup(:swissreg_url, 
                        model.patent.certificate_number)
					square(:patent, link)
				elsif(comarketing = model.comarketing_with)
					link = HtmlGrid::Link.new(:square_comarketing, model, @session, self)
					link.href = CoMarketingPlugin::SOURCE_URI
					link.set_attribute('title', 
						 @lookandfeel.lookup(:comarketing, comarketing.name_base))
					square(:comarketing, link)
				end
			end
			def complementary_type(model, session=@session)
				if(ctype = model.complementary_type)
					square(ctype)
				end
			end
      def compositions(model, session=@session)
        link = HtmlGrid::Link.new(:show, model, session, self)
        smart_link_format = model.pointer.to_csv.gsub(/registration/, 'reg').gsub(/sequence/, 'seq').gsub(/package/, 'pack').split(/,/)
        if smart_link_format.include?('reg')
          link.href = @lookandfeel._event_url(:show, smart_link_format)
        else 
          old_link_format = {:pointer => model.pointer}
          link.href = @lookandfeel._event_url(:show, old_link_format)
        end

        lang = @session.language
        comps = []
        if !model.compositions.empty?
          comps = model.compositions
        elsif model.respond_to?(:sequence)
          comps = model.sequence.compositions
        end
        parts = comps.collect { |comp|
          part = ''
          if galform = comp.galenic_form and galform.respond_to?(lang.to_sym)
            part << galform.send(lang).to_s << ': '
          end
          if comp.active_agents.size > 1
            part << @lookandfeel.lookup(:active_agents, model.active_agents.size)
          else
            part << comp.active_agents.first.to_s
          end
        }
        link.value = parts.join('<br/>')
        link
      end
			def ddd_price(model, session=@session)
        chart = @lookandfeel.enabled? :ddd_chart
        node = chart ?
                 HtmlGrid::Link.new(:ddd_price_link, model, @session, self) :
                 HtmlGrid::Span.new(model, @session, self)
				if(ddd_price = model.ddd_price)
          ddd_price = convert_price(ddd_price, @session.currency)
					@ddd_price_count ||= 0
					@ddd_price_count += 1
					node.value = ddd_price
					node.css_id = "ddd_price_#{@ddd_price_count}"
          query = @session.persistent_user_input(:search_query)
          query = model.name_base if query.is_a?(SBSM::InvalidDataError)
          query ||= model.name_base
          stype = @session.persistent_user_input(:search_type)
          pointer = if model.is_a?(ODDB::Package) || model.is_a?(ODDB::State::Drugs::Compare::Comparison::PackageFacade)
                      [:reg, model.registration.iksnr, :seq, model.sequence.seqnr, :pack, model.ikscd]
                    else
                      [:pointer, model.pointer]
                    end
					args = [
            pointer,
            [:search_query, query.gsub('/', '%2F')],
            [:search_type, stype || 'st_sequence']
          ]
          if chart
            node.set_attribute('title', @lookandfeel.lookup(:ddd_price_title))
            node.href = @lookandfeel._event_url(:ddd_price, args)
          else
            node.dojo_tooltip = @lookandfeel._event_url(:ajax_ddd_price, args)
          end
				end
				node.label = true
				node
			end
			def deductible(model, session=@session)
				@deductible_count ||= 0
				@deductible_count += 1
				span = HtmlGrid::Span.new(model, @session, self)
				tooltip = HtmlGrid::Div.new(model, @session, self)
				deductible = model.deductible
				if(deductible)
					tooltip.value = @lookandfeel.lookup(:deductible_title, 
																							@lookandfeel.lookup(deductible))
				else
					tooltip.value = @lookandfeel.lookup(:deductible_unknown_title)
				end
				span.css_id = "deductible_#{@deductible_count}"
				span.css_class = deductible.to_s
				span.dojo_tooltip = tooltip
				span.value = @lookandfeel.lookup(deductible || :deductible_unknown)
				span.label = true
				span
			end
			def fachinfo(model, session=@session, css='square infos')
				if(link = _fachinfo(model, css))
					link
				elsif(model && !model.has_fachinfo? && @session.allowed?('edit', model))
					link = HtmlGrid::Link.new(:fachinfo_create, model, @session, self)
					reg = model.is_a?(Registration) ?  model.iksnr : model.registration.iksnr
					args = [:reg, reg, :chapter, 'composition']
					link.href = @lookandfeel._event_url(:new_fachinfo, args)
					link.css_class = 'square create-infos'
					link
				end
			end
			def _fachinfo(model, css='square infos')
        iksnr = ''
        if(model.respond_to?(:fachinfo_active?) and model.fachinfo_active?) #Registration
          iksnr = model.iksnr
        elsif(model.respond_to?(:iksnrs) and iksnrs = model.iksnrs) #FachinfoDocument
          iksnr = iksnrs.first
        end
        unless iksnr.empty?
					link = HtmlGrid::Link.new(:square_fachinfo, 
							model, @session, self)
					link.href = @lookandfeel._event_url(:fachinfo, {:reg => iksnr})
					link.css_class = css
					link.set_attribute('title', @lookandfeel.lookup(:fachinfo))
					link
				end
			end
			def feedback(model, session=@session)
				link = HtmlGrid::Link.new(:square_feedback, model, session, self)
        if model.is_a?(ODDB::Package)
          link.href = @lookandfeel._event_url(:feedbacks, [:reg, model.iksnr, :seq, model.seqnr, :pack, model.ikscd])
        #elsif model.is_a?(DRb::DRbObject) # Migel::Model::Migelid
        #  link.href = @lookandfeel._event_url(:feedbacks, [:migel_product, model.migel_code.gsub(/\./,'')])
        end
        link.css_class = "square feedback"
				link.set_attribute('title', @lookandfeel.lookup(:feedback_alt, 
					model.localized_name(@session.language)))
				link
			end
      def google_search(model, session=@session)
        text = model.localized_name(@session.language).to_s.force_encoding('utf-8')
        link = HtmlGrid::Link.new(:square_google_search, @model, @session, self)
        link.href =  "http://www.google.com/search?q=#{text}"
        link.css_class= 'square google_search'
        link.set_attribute('title', "#{@lookandfeel.lookup(:google_alt)}#{text}")
        link
      end
			def ikscat(model, session=@session)
				@ikscat_count ||= 0
				@ikscat_count += 1
				txt = HtmlGrid::Span.new(model, session, self)
				text_elements = []
				if(cat = model.ikscat)
					text_elements.push(cat)
				end
				if(sl = model.sl_entry)
					text_elements.push(@lookandfeel.lookup(:sl))
				end
				if(model.lppv)
					catstr = @lookandfeel.lookup(:lppv)
					text_elements.push(catstr)
				end
				if(gt = model.sl_generic_type)
					text_elements.push(@lookandfeel.lookup("sl_#{gt}_short"))
				end
				txt.value = text_elements.join('&nbsp;/&nbsp;')
				url = @lookandfeel._event_url(:ajax_swissmedic_cat, [:reg, model.iksnr, :seq, model.seqnr, :pack, model.ikscd])
				txt.css_id = "ikscat_#{@ikscat_count}"
				txt.dojo_tooltip = url
				txt
			end
			def limitation_text(model, session=@session)
				if(sltxt = model.limitation_text)
					limitation_link(sltxt, model)
				end
			end
			def limitation_link(sltxt, model = nil)
				link = HtmlGrid::Link.new(:square_limitation, 
					nil, @session, self)
        reg = seq = pack = groupcd = poscd = nil
        if model.is_a?(ODDB::Package)
          reg  = model.registration.iksnr
          seq  = model.sequence.seqnr 
          pack = model.ikscd
        elsif model.is_a?(ODDB::Sequence)
          reg  = model.registration.iksnr
          seq  = model.seqnr 
          pack = if (packs = model.packages.values.select{|pac| pac.limitation_text} and !packs.empty?)
                   packs.first.ikscd
                 end
        elsif model.is_a?(ODDB::Analysis::Position)
          groupcd = model.groupcd
          poscd   = model.poscd
        end

        if reg and seq and pack
          link.href = @lookandfeel._event_url(:limitation_text, [:reg, reg, :seq, seq, :pack, pack])
        elsif groupcd and poscd
          link.href = @lookandfeel._event_url(:limitation_analysis, [:group, groupcd, :position, poscd])
        else
  				link.href = @lookandfeel._event_url(:resolve, {'pointer'=>CGI.escape(sltxt.pointer.to_s)})
        end
				link.set_attribute('title', 
					@lookandfeel.lookup(:limitation_text))
				#pos = components.index(:limitation_text)
				link.css_class = "square infos"
				link
			end
      def minifi(model, session=@session)
				if(mfi = model.minifi)
					link = HtmlGrid::Link.new(:square_minifi, mfi, @session, self)
          iksnr = if model.is_a?(ODDB::Registration)
                    model.iksnr
                  else # ODDB::Sequence, ODDB::Package
                    model.registration.iksnr
                  end
          link.href = @lookandfeel._event_url(:minifi, {:reg => iksnr})
					link.css_class = 'square infos'
					link.set_attribute('title', @lookandfeel.lookup(:minifi))
					link
				end
      end
			def narcotic(model, session=@session)
				if(model.bm_flag)
					link = HtmlGrid::Link.new(:square_narc, model, @session, self)
					link.href = "http://www.swissmedic.ch/produktbereiche/00447/00536/index.html?lang=#{@session.language}"
					link.css_class = 'square infos'
					link.set_attribute('title', @lookandfeel.lookup(:narcotic))
					link
				elsif(model.vaccine)
					square(:vaccine)
				#elsif(model.export_flag)
				#	square(:export_flag)
				end
			end
			def notify(model, session=@session)
				link = HtmlGrid::Link.new(:notify, model, @session, self)
        if model.is_a?(ODDB::Package)
          name = model.name
          iksnr = model.iksnr
          seqnr = model.seqnr
          ikscd = model.ikscd
          link.href = "mailto:?subject=#{SERVER_NAME}: #{name}&amp;body=http://#{SERVER_NAME}/#{@session.language}/#{@session.flavor}/drug/reg/#{iksnr}/seq/#{seqnr}/pack/#{ikscd}"
        elsif model.is_a?(DRb::DRbObject) and model.respond_to?(:article_name) # ODDB::Migel::Item
          name       = model.article_name.to_s.force_encoding('utf-8')
          migel_code = model.migel_code.to_s.force_encoding('utf-8')
          link.href = "mailto:?subject=#{SERVER_NAME}: #{name}&amp;body=http://#{SERVER_NAME}/#{@session.language}/#{@session.flavor}/migel_search/migel_code/#{migel_code}"
        elsif model.is_a?(DRb::DRbObject) # ODDB::Migel::Product
          name = [
            model,
            (model.product_text.to_s.force_encoding('utf-8') if(model.respond_to?(:product_text))),
          ].compact.collect { |item|
            if item.is_a? String
              item
            elsif item.respond_to?(@session.language)
              item.send(@session.language).to_s
            end.force_encoding('utf-8')
          }.join(': ').gsub("\n", ' ')
          if(name.size > 60)
            name = name[0,57] << '...'
          end
          name.gsub!(/,\s*\d*\s*\%.*/, '')
          link.href = if @session.state.respond_to?(:interval) and range = @session.state.interval
            "mailto:?subject=#{SERVER_NAME}: #{name}&amp;body=http://#{SERVER_NAME}/#{@session.language}/#{@session.flavor}/migel_alphabetical/range/#{range}"
                      elsif query = @session.user_input(:search_query)
            "mailto:?subject=#{SERVER_NAME}: #{name}&amp;body=http://#{SERVER_NAME}/#{@session.language}/#{@session.flavor}/search/zone/migel/search_query/#{query}"
                      end
        end
				img = HtmlGrid::Image.new(:notify, model, @session, self)
				img.set_attribute('src', @lookandfeel.resource_global(:notify))
				link.value = img
				link.set_attribute('title', @lookandfeel.lookup(:notify_alt))
				link
			end
      def patent(model, session=@session)
        if(model.patent_protected?)
          link = HtmlGrid::Link.new(:square_patent, model, @session, self)
          link.href = @lookandfeel.lookup(:swissreg_url,
                        model.patent.certificate_number)
          square(:patent, link)
        end
      end
      def patinfo(model, session=@session)
        if(model.has_patinfo?)
          href = nil
          klass = nil
          if(pdf_patinfo = model.pdf_patinfo and !pdf_patinfo.empty?)
            klass = HtmlGrid::PopupLink
            href = @lookandfeel.resource_global(:pdf_patinfo, pdf_patinfo)
          elsif (model.patinfo and seqnr = model.seqnr)
            klass = HtmlGrid::Link
            smart_link_format = [:reg, model.iksnr, :seq, seqnr]
            href = @lookandfeel._event_url(:patinfo, smart_link_format)
          elsif (patinfo = model.patinfo) # This is an old format URL for PI. Probably no need any more (but still available).
            klass = HtmlGrid::Link
            old_link_format = {'pointer' => patinfo.pointer}
            href = @lookandfeel._event_url(:resolve, old_link_format)
          end
          return nil unless model and klass
          link = klass.new(:square_patinfo, model, @session, self)
          link.href = href
          link.set_attribute('title', @lookandfeel.lookup(:patinfo))
          link.css_class = 'square infos'
          link
        end
      end
      def prescription(model, session=@session, css='important') # rezept -> prescription
        link = HtmlGrid::Link.new(:rezept, model, session, self)
        link.css_class = css
        link.set_attribute('title', @lookandfeel.lookup(:prescription))
        link.href = @lookandfeel._event_url(:rezept, [:ean, model.barcode])
        img = HtmlGrid::Image.new(:prescription, model, @session, self)
        img.set_attribute('src', @lookandfeel.resource_global(:prescription))
        link.value = img
        link
      end
      def qty_unit(model, session=@session)
        if(model.qty || model.unit)
          unit = nil
          if(u = model.unit)
            unit = u.send(@session.language)
          end
          unit.to_s.force_encoding('utf-8') if unit
          qty = model.qty.to_s.force_encoding('utf-8')
          [ '&nbsp;(', qty, unit, ')' ].compact.join(' ')
        end
      end
			def square(key, square=nil)
				square ||= HtmlGrid::Span.new(nil, @session, self)
				square.value = @lookandfeel.lookup("square_#{key}")
				square.attributes['title'] ||= @lookandfeel.lookup(key)
				square.css_class = "square #{key}"
				square
			end
      def twitter_share(model, session=@session)
        link = HtmlGrid::Link.new(:twitter_share_short, model, @session, self)
        link.value = HtmlGrid::Image.new(:icon_twitter, model, @session, self)
        base = ''
        url  = ''
        if model.is_a?(DRb::DRbObject)
          # in the case of migel items
          base = model.localized_name(session.language).to_s.force_encoding('utf-8')
          code = model.pharmacode.to_s.force_encoding('utf-8')
          url  = @lookandfeel._event_url(:migel_search, {:migel_pharmacode => code})
        else
          base = model.name_base
          url = @lookandfeel._event_url(:show, {:pointer => model.pointer})
        end
        size = comparable_size(model)
        status = u sprintf("%s, %s", base, size)
        tweet = "http://twitter.com/home?status=#{status} - "
        if ind = model.indication
          tweet << ind.send(@session.language) << " - "
        end
        link.href = '#' #tweet + url
        link.onclick = "bitly_for_twitter('#{url}', '#{tweet}');"
        link.set_attribute("title", @lookandfeel.lookup(:twitter_share))
        link.css_class = "twitter"
        link
      end
		end
	end
end
