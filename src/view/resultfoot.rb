#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::ResultFoot -- oddb.org -- 21.12.2012 -- yasaka@ywesee.com
# ODDB::View::ResultFoot -- oddb.org -- 22.06.2011 -- mhatakeyama@ywesee.com 
# ODDB::View::ResultFoot -- oddb.org -- 20.03.2003 -- hwyss@ywesee.com 

require 'htmlgrid/composite'
require 'htmlgrid/link'
require 'view/external_links'
require 'view/additional_information'

module ODDB
	module View
		class ExplainResult < HtmlGrid::Composite
			include ExternalLinks
			include AdditionalInformation
			COMPONENTS = {}
			CSS_MAP = {}
      CSS_KEYMAP = {
        'explain_unknown'        => 'infos bold',
        'explain_expired'        => 'infos bold expired',
        :explain_cas             => 'infos',
        :explain_comarketing     => 'infos',
        :explain_complementary   => 'infos',
        :explain_vaccine         => 'infos',
        :explain_ddd_price       => 'infos',
        :explain_deductible      => 'infos',
        :explain_phytotherapy    => 'infos',
        :explain_anthroposophy   => 'infos',
        :explain_homeopathy      => 'infos',
        :explain_parallel_import => 'infos',
        :explain_fachinfo        => 'infos',
        'explain_pbp'            => 'infos',
        :explain_patinfo         => 'infos',
        'explain_mail_order_price_title'   => 'bold',
        :explain_mail_order_price_compare  => 'infos',
        :explain_mail_order_price_discount => 'infos',
        :explain_mail_order_price_normal   => 'infos',
        :explain_narc            => 'infos',
        :explain_limitation      => 'infos',
        :explain_google_search   => 'infos',
        :explain_feedback        => 'infos',
      }
      CSS_ID = 'explain_result'
      def initialize model, session, container, components=nil
        @components = components
        super model, session, container
      end
			def init
				@components ||= @lookandfeel.explain_result_components
				width = 1
				height = 1
				@components.each { |key, val| 
					if(klass = CSS_KEYMAP[val])
						css_map.store(key, klass)
					end
					x, y, = key
					width = [x, width].max
					height = [y.next, height].max
				}
				super
			end
			def explain_comarketing(model, session=@session)
				link = HtmlGrid::Link.new(:square_comarketing, model, @session, self)
				link.href = CoMarketingPlugin::SOURCE_URI
				[square(:comarketing, link), @lookandfeel.lookup(:explain_comarketing) ]
			end
			def explain_ddd_price(model, session=@session)
				explain_link(model, :ddd_price)
			end
			def explain_deductible(model, session=@session)
				explain_link(model, :deductible)
			end
			def explain_anthroposophy(model, session=@session)
				[square(:anthroposophy), @lookandfeel.lookup(:explain_anthroposophy) ]
			end
			def explain_complementary(model, session=@session)
				link = HtmlGrid::Link.new(:square_complementary, model, session, self)
				link.href = @lookandfeel.lookup(:explain_complementary_url)
				[square(:complementary, link), @lookandfeel.lookup(:explain_complementary) ]
			end
			def explain_fachinfo(model, session=@session)
				[square(:fachinfo), @lookandfeel.lookup(:explain_fachinfo) ]
			end
			def explain_feedback(model, session=@session)
				[square(:feedback), @lookandfeel.lookup(:explain_feedback) ]
			end
			def explain_generic(model, session=@session)
				explain_link(model, :generic)
			end
			def explain_google_search(model, session=@session)
				[square(:google_search), @lookandfeel.lookup(:explain_google_search) ]
			end
			def explain_limitation(model, session=@session)
				[square(:limitation), @lookandfeel.lookup(:explain_limitation) ]
			end
      def explain_mail_order_price_compare(model, session=@session)
        [
          HtmlGrid::Image.new(:logo_rose_long, model, @session, self),
          @lookandfeel.lookup(:explain_mail_order_price_compare)
        ]
      end
      def explain_mail_order_price_discount(model, session=@session)
        [
          HtmlGrid::Image.new(:logo_rose_orange, model, @session, self),
          @lookandfeel.lookup(:explain_mail_order_price_discount)
        ]
      end
      def explain_mail_order_price_normal(model, session=@session)
        [
          HtmlGrid::Image.new(:logo_rose_green, model, @session, self),
          @lookandfeel.lookup(:explain_mail_order_price_normal)
        ]
      end
			def explain_minifi(model, session=@session)
				[square(:minifi), @lookandfeel.lookup(:explain_minifi) ]
			end
			def explain_original(model, session=@session)
				explain_link(model, :original)
			end
			def explain_patinfo(model, session=@session)
				[square(:patinfo), @lookandfeel.lookup(:explain_patinfo) ]
			end
			def explain_homeopathy(model, session=@session)
				[square(:homeopathy), @lookandfeel.lookup(:explain_homeopathy) ]
			end
			def explain_parallel_import(model, session=@session)
				[square(:parallel_import), @lookandfeel.lookup(:explain_parallel_import) ]
			end
			def explain_phytotherapy(model, session=@session)
				[square(:phytotherapy), @lookandfeel.lookup(:explain_phytotherapy) ]
			end
			def explain_vaccine(model, session=@session)
				link = HtmlGrid::Link.new(:square_vaccines, model, session, self)
				link.href = @lookandfeel.lookup(:explain_vaccine_url)
				[square(:vaccine, link), @lookandfeel.lookup(:explain_vaccine) ]
			end
			def explain_cas(model, session=@session)
				link = HtmlGrid::Link.new(:explain_cas,
					model, @session, self)
				link.href = "http://cas.org"
				link
			end
			def explain_lppv(model, session=@session)
				link = HtmlGrid::Link.new(:explain_lppv, model, @session, self)
				link.href = @lookandfeel.lookup(:lppv_url)
				link
			end
			def explain_narc(model, session=@session)
				[square(:narc), @lookandfeel.lookup(:explain_narc) ]
			end
			def explain_link(model, key)
				link = external_link(model, "explain_#{key}")
        unless @lookandfeel.disabled?(:explain_link)
          link.href = @lookandfeel.lookup("explain_#{key}_url")
        end
				link.attributes['class'] = "explain #{key}"
				link 
			end
		end
		module ResultFootBuilder
			EXPLAIN_RESULT = ExplainResult
			def result_foot(model, session=@session)
				if(@lookandfeel.navigation.include?(:legal_note) \
          || @lookandfeel.disabled?(:legal_note))
					self.class::EXPLAIN_RESULT.new(model, @session, self)
				else
					View::ResultFoot.new(model, @session, self)
				end
			end
		end
		class ResultFoot < HtmlGrid::Composite
			include ExternalLinks
			COLSPAN_MAP	= {
			}
      COMPONENTS = {
        [0,0] => 'nbsp',
        [0,1] => :explain_result,
      }
      CSS_MAP = {
        [0,0] => 'explain',
        [0,1] => 'explain',
      }
      CSS_CLASS = 'composite'
      def init
        if @lookandfeel.enabled?(:legal_note_vertical, false)
          {
            [0,0] => :toggle_switch,
            [0,2] => :legal_note
          }
        else
          {
            [1,0] => :toggle_switch,
            [1,1] => :legal_note
          }
        end.each_pair do |coordinates, element|
          components.store(coordinates, element)
          css_map.store(coordinates, 'explain right')
        end
        super
      end
			def explain_result(model, session=@session)
				klass = nil
				if(defined?(@container.class::EXPLAIN_RESULT))
					klass = @container.class::EXPLAIN_RESULT
				end
				klass ||= View::ExplainResult
				klass.new(model, @session, self)
			end
      def toggle_switch(model, session=@session)
        span = HtmlGrid::Span.new(model, @session, self)
        span.value = @lookandfeel.lookup(:hide_legend)
        span.css_class = 'link'
        span.set_attribute('id', 'toggle_switch')
        span.onclick = <<JS
(function () {
  var span    = document.getElementById('toggle_switch');
  var legends = document.getElementById('explain_result');
  var note    = document.getElementById('legal_note');
  if (note.style.display != 'none') {
    legends.style.display = 'none';
    note.style.display    = 'none';
    span.innerHTML        = '#{@lookandfeel.lookup(:show_legend)}';
  } else {
    legends.style.display = 'block';
    note.style.display    = 'block';
    span.innerHTML        = '#{@lookandfeel.lookup(:hide_legend)}';
  }
})();
JS
        span
      end
			def legal_note(model, session=@session)
				link = super(model)
        link.set_attribute('id', 'legal_note')
				link.css_class = 'subheading'
				link
			end
		end
	end
end
