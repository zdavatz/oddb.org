#!/usr/bin/env ruby
# View::Ajax::SwissmedicCat -- oddb.org -- 15.03.2006 -- sfrischknecht@ywesee.com

require 'htmlgrid/composite'
require 'htmlgrid/datevalue'
require 'htmlgrid/booleanvalue'

module ODDB
	module View
		module Ajax
class SwissmedicCat < HtmlGrid::Composite
	COMPONENTS = {}
	LEGACY_INTERFACE = false
	DEFAULT_CLASS = HtmlGrid::Value
	SYMBOL_MAP = {
		:registration_date	=>	HtmlGrid::DateValue,
		:sequence_date	    =>	HtmlGrid::DateValue,
		:revision_date			=>	HtmlGrid::DateValue,
		:expiration_date		=>	HtmlGrid::DateValue,
		:market_date		    =>	HtmlGrid::DateValue,
    :out_of_trade       =>  HtmlGrid::BooleanValue,
	}
	def init
		@components = {}
		@css_map = {}
		reorganize_components if(@model)
		super
	end
	def reorganize_components
		y=0
		if(cat = @model.ikscat)
			iks = "ikscat_" << cat.to_s.downcase
			@components.store([0,y], :ikscat)
			@components.store([1,y], iks)
			y += 1
		end
		if(sl = @model.sl_entry)
			@components.store([0,y], "sl")
			@components.store([1,y,0], "sl_list")
			if(date = sl.introduction_date)
				@components.store([1,y,1], :sl_since)
			end
			y += 1
		end
		if(gt = @model.sl_generic_type)
			@components.store([0,y], "sl_#{gt}_short")
			@components.store([1,y], "sl_#{gt}")
			y += 1
		end
		if(@lookandfeel.result_list_components.has_value?(:deductible) \
			 && deductible_value(@model))
			@components.store([0,y], :deductible_label)
			@components.store([1,y], :deductible)
			y += 1
		end
		if(@model.lppv)
			@components.store([0,y], "lppv")
			@components.store([1,y], :lppv_ajax)
			y += 1
		end
		if(@model.registration_date)
			@components.store([0,y], "registration_date")
			@components.store([1,y], :registration_date)
			y += 1
		end
		if(@model.sequence_date)
			@components.store([0,y], "sequence_date")
			@components.store([1,y], :sequence_date)
			y += 1
		end
		if(@model.revision_date)
			@components.store([0,y], "revision_date")
			@components.store([1,y], :revision_date)
			y += 1
		end
		if(@model.expiration_date)
			@components.store([0,y], "expiration_date")
			@components.store([1,y], :expiration_date)
			y += 1
		end
    if(@model.index_therapeuticus)
      @components.store([0,y], "index_therapeuticus")
      @components.store([1,y], :index_therapeuticus)
      y += 1
    end
    if(@model.ith_swissmedic)
      @components.store([0,y], "ith_swissmedic")
      @components.store([1,y], :ith_swissmedic)
      y += 1
    end
    @components.store([0,y], "refdata")
    @components.store([1,y], :out_of_trade)
		y += 1
    if(@model.production_science)
      @components.store([0,y], "production_science")
      @components.store([1,y], :production_science)
      y += 1
    end
    if(@model.preview?)
      @components.store([0,y], "market_date_preview")
      @components.store([1,y], :market_date)
      y += 1
    end
		if(@model.patent)
			@components.store([0,y], "patented_until")
			@components.store([1,y], :patent_protected)
			y += 1
		end
		@css_map.store([1,0,1,y], 'list')
		@css_map.store([0,0,1,y], 'bold top list')
	end
	def deductible(model)
		link = HtmlGrid::Link.new(:deductible, model, @session, self)
		link.value = @lookandfeel.lookup(deductible_value(model))
		link.href = @lookandfeel.lookup(:explain_deductible_url)
		link.css_class = 'list'
		link
	end
  def deductible_label(model)
		link = HtmlGrid::Link.new(:deductible, model, @session, self)
		link.href = @lookandfeel.lookup(:deductible_legal_url)
		link
	end
  def deductible_value(model)
    if(@lookandfeel.enabled?(:just_medical_structure, false))
      model.deductible_m
    else
      model.deductible
    end
  end
	def lppv_ajax(model)
		link = HtmlGrid::Link.new(:lppv_ajax, model, @session, self)
		link.href = @lookandfeel.lookup(:lppv_url)
		link.css_class = 'list'
		link
	end
	def patent_protected(model)
		patent = model.patent
		date = nil
		if(cn = patent.certificate_number)
			date = HtmlGrid::Link.new(:patent_protected, patent, @session, self)
			date.href = @lookandfeel.lookup(:swissreg_url, cn)
		else
			date = HtmlGrid::Value.new(:patent_protected, patent, @session, self)
		end
		date.value = @lookandfeel.format_date(patent.expiry_date)
		date
	end
	def sl_since(model)
		sl = model.sl_entry
		date = sl.introduction_date
		@lookandfeel.lookup(:sl_since, 
												@lookandfeel.format_date(date))
	end
end
		end
	end
end
