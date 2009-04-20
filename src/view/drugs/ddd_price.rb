#!/usr/bin/env ruby
# View::Ajax::DDDPrice -- oddb.org -- 10.04.2006 -- hwyss@ywesee.com

require 'htmlgrid/composite'
require 'view/dataformat'
require 'view/additional_information'

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
		if(model && (atc = model.atc_class) && (ddd = atc.ddd('O')))
			comp = HtmlGrid::Value.new(:ddd_dose, ddd.dose, @session, self)
			ddose = ddd.dose
			comp.value = ddose.want(wanted_unit(model.dose, ddose))
			comp
		end
	end
	def dose(model)
		if(model && (atc = model.atc_class) && (ddd = atc.ddd('O')))
			comp = HtmlGrid::Value.new(:dose, model, @session, self)
			mdose = model.dose
			comp.value = mdose.want(wanted_unit(mdose, ddd.dose))
			comp
		end
	end
	def calculation(model)
		if(model && (atc = model.atc_class) && (ddd = atc.ddd('O')))
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
end
class DDDPrice < PrivateTemplate
  include InsertBackbutton
  CONTENT = DDDPriceComposite
  SNAPBACK_EVENT = :result
  def pointer_descr(model)
    @lookandfeel.lookup(:ddd_price_for, model.name_base)
  end
end
		end
	end
end
