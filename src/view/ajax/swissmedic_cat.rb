#!/usr/bin/env ruby
# View::Ajax::SwissmedicCat -- oddb.org -- 15.03.2006 -- sfrischknecht@ywesee.com

require 'htmlgrid/composite'

module ODDB
	module View
		module Ajax
class SwissmedicCat < HtmlGrid::Composite
	COMPONENTS = {}
	LEGACY_INTERFACE = false
	DEFAULT_CLASS = HtmlGrid::Value
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
			@components.store([1,y], "sl_list")
			if(date = sl.introduction_date)
				@components.store([1,y,1], :sl_since)
			end
			y += 1
		end
		if(@model.lppv)
			@components.store([0,y], "lppv")
			@components.store([1,y], :lppv_ajax)
			y += 1
		end
		if(@model.sl_generic_type == :generic)
			@components.store([0,y], "sl_generic_short")
			@components.store([1,y], "sl_generic")
			y += 1
		end
		@css_map.store([1,0,1,y], 'list')
		@css_map.store([0,0,1,y], 'bold top list')
	end
	def sl_since(model)
		sl = model.sl_entry
		date = sl.introduction_date
		@lookandfeel.lookup(:sl_since, 
												@lookandfeel.format_date(date))
	end
	def lppv_ajax(model)
		link = HtmlGrid::Link.new(:lppv_ajax, model, @session, self)
		link.href = @lookandfeel.lookup(:lppv_url)
		link.css_class = 'list'
		link
	end
end
		end
	end
end
