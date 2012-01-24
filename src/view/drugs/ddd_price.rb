#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Ajax::DDDPrice -- oddb.org -- 24.01.2012 -- mhatakeyama@ywesee.com
# ODDB::View::Ajax::DDDPrice -- oddb.org -- 10.04.2006 -- hwyss@ywesee.com

require 'htmlgrid/composite'
require 'view/dataformat'
require 'view/additional_information'
require 'view/facebook'

module ODDB
	module View
		module Drugs
class DDDPriceTable < HtmlGrid::Composite
	include View::DataFormat
	include View::AdditionalInformation
	COMPONENTS = {
		[0,0]	=>	:ddd_oral,
		[2,0]	=>	:price_public,
		[0,1]	=>	:dose,
		[2,1]	=>	:size,
		[0,2]	=>	:calculation,
	}
	COLSPAN_MAP = {
		[1,2]	=>	3,
	}
	CSS_MAP = { 
		[0,0,4,2] => 'list', 
		[0,2,2]		=> 'list nowrap' 
	}
	LABELS = true
	LEGACY_INTERFACE = false
	DEFAULT_CLASS = HtmlGrid::Value
	def ddd_oral(model)
		if(model && (atc = model.atc_class) && (ddd = atc.ddd('O')) && model.dose && ddd.dose)
			comp = HtmlGrid::Value.new(:ddd_dose, ddd.dose, @session, self)
			ddose = ddd.dose
			comp.value = ddose.want(wanted_unit(model.dose, ddose)) 
			comp
		end
	end
	def dose(model)
		if(model && (atc = model.atc_class) && (ddd = atc.ddd('O')) && model.dose && ddd.dose)
			comp = HtmlGrid::Value.new(:dose, model, @session, self)
			mdose = model.dose
			comp.value = mdose.want(wanted_unit(mdose, ddd.dose))
			comp
		end
	end
	def calculation(model)
		if(model && (atc = model.atc_class) && (ddd = atc.ddd('O')) && model.dose && ddd.dose)
      currency = @session.currency
			mprice = model.price_public
      mprice = convert_price(mprice, currency)
			dprice = model.ddd_price
      dprice = convert_price(dprice, currency)
			mdose = model.dose
			ddose = ddd.dose
			wanted = wanted_unit(mdose, ddose)
			mdose = model.dose.want(wanted)
			ddose = ddd.dose.want(wanted)
			curr = @session.currency
			comp = HtmlGrid::Value.new(:ddd_calculation, model, @session, self)
      if(factor = model.longevity)
        comp.value = @lookandfeel.lookup(:ddd_calc_long, factor, mprice,
                                         model.size, dprice, curr)

      elsif(mdose > ddose)
        comp.value = @lookandfeel.lookup(:ddd_calc_tablet, mprice,
                                         model.size, dprice, curr)
      else
        comp.value = @lookandfeel.lookup(:ddd_calculation, ddose,
                                         mdose, mprice, model.size,
                                         dprice, curr)
      end
			comp
		end
	end
	def price_public(model)
		item = super
		item.value += ' ' + @session.currency
		item
	end
	def wanted_unit(mdose, ddose)
		(mdose.fact.factor < ddose.fact.factor) ? mdose.unit : ddose.unit
	end
end
class DDDPriceComposite < HtmlGrid::Composite
  include PartSize
  include View::Facebook
  COMPONENTS = {
    [0,0] => :ddd_price,
    [0,1] => DDDPriceTable,
  }
  CSS_CLASS = 'composite'
  CSS_MAP = {
    [0,0] => 'th',
  }
  LEGACY_INTERFACE = false
  def init
    if @lookandfeel.enabled?(:ddd_chart)
      components.store [0,2], :ddd_chart
      css_map.store [0,2], 'ddd-chart'
      if @lookandfeel.enabled?(:twitter_share)
        components.store [0,3,0], :twitter_share
        css_map.store [0,3], 'list'
      end
      if @lookandfeel.enabled?(:facebook_share)
        components.store [0,3,1], :facebook_share
        css_map.store [0,3], 'list spaced'
      end
    end
    super
  end
  def ddd_chart(model)
    link = HtmlGrid::Link.new(:ddd_chart, model, @session, self)
    img = HtmlGrid::Image.new(:ddd_chart, model, @session, self)
    file = sprintf "%s_%s_%s.png", model.ikskey, model.name_base,
                                   @lookandfeel.lookup(:ddd_price_comparison)
    args = [
      :for, file.gsub(/\s+/, '_')
    ]
    url = @lookandfeel._event_url(:ddd_chart, args)
    img.set_attribute('src', url)
    link.href = url
    link.value = img
    link
  end
  def ddd_price(model)
    @lookandfeel.lookup(:ddd_price_for, model.name_base)
  end
  def twitter_share(model, session=@session)
    link = HtmlGrid::Link.new(:twitter_share_short, model, @session, self)
    link.value = HtmlGrid::Image.new(:icon_twitter, model, @session, self)
    base = model.name_base
    size = comparable_size(model)
    fullname = u sprintf("%s, %s", base, size)
    title = @lookandfeel.lookup(:ddd_chart_title, fullname)
    url = @lookandfeel._event_url(:ddd_price, :pointer => model.pointer)
    tweet = "http://twitter.com/home?status=#{title} - "
    if ind = model.indication
      tweet << ind.send(@session.language) << " - "
    end
    link.href = "#" #tweet + url
    link.onclick = "bitly_for_twitter('#{url}', '#{tweet}');"
    link.set_attribute("title", @lookandfeel.lookup(:twitter_share))
    link.css_class = "twitter"
    link
  end
end
class DDDPrice < PrivateTemplate
  include InsertBackbutton
  include PartSize
  CONTENT = DDDPriceComposite
  SNAPBACK_EVENT = :result
  JAVASCRIPTS = ['bit.ly']
  def meta_tags(context)
    base = @model.name_base
    size = comparable_size(@model)
    fullname = u sprintf("%s, %s", base, size)
    title = @lookandfeel.lookup(:ddd_chart_title, fullname)
    file = sprintf "%s_%s_%s.png", @model.ikskey, @model.name_base,
                                   @lookandfeel.lookup(:ddd_price_comparison)
    args = [
      :for, file.gsub(/\s+/, '_')
    ]
    url = @lookandfeel._event_url(:ddd_chart, args)
    res = super << context.meta('name' => 'title', 'content' => title) \
      << context.link('rel' => 'image_src', 'href' => url)
    if ind = @model.indication
      res << context.meta('name' => 'description',
                          'content' => ind.send(@session.language))
    end
    res
  end
  def pointer_descr(model)
    @lookandfeel.lookup(:ddd_price_for, model.name_base)
  end
end
		end
	end
end
