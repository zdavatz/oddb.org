#!/usr/bin/env ruby
# View::Drugs::DDD -- oddb -- 01.03.2004 -- hwyss@ywesee.com

require 'htmlgrid/list'
require 'view/popuptemplate'
require 'view/chapter'

module ODDB
	module View
		module Drugs
class DDDList < HtmlGrid::List
	CSS_CLASS = 'component'
	CSS_MAP = {
		[0,0,3]	=>	'list-r',
	}
	COMPONENTS = {
		[0,0]	=>	:dose, 
		[1,0]	=>	:administration_route,
		[2,0]	=>	:note,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = nil
	OMIT_HEAD_TAG = false
	SORT_HEADER = false
	def init
		super
	end
end
class DDDComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	=>	:description,
	}
	CSS_MAP = {
		[0,0]	=>	'subheading',	
	} 
	DEFAULT_CLASS = HtmlGrid::Value
	def init
		y = 1
		if(@model.guidelines)
			pos = [0,y]
			components.store(pos, :guidelines)
			css_map.store(pos, 'list')
			y += 1
		end
		unless(@model.ddds.empty?)
			components.store([0,y], :ddds)
			y += 1
		end
		if(@model.ddd_guidelines)
			pos = [0,y]
			components.store(pos, :ddd_guidelines)
			css_map.store(pos, 'list-bg')
		end
		super
	end
	# stay with the official WHO english Version:
	def chapter(model)
		View::Chapter.new(:en, model, @session, self)
	end
	def description(model, session)
		[ model.code, model.en ].join('&nbsp;-&nbsp;')
	end
	def ddds(model, session)
		View::Drugs::DDDList.new(model.ddds.values, session, self)
	end
	def ddd_guidelines(model, session)
		chapter(model.ddd_guidelines)
	end
	def guidelines(model, session)
		chapter(model.guidelines)
	end
end
class DDDTreeList < HtmlGrid::List
	SORT_DEFAULT = nil
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	=>	View::Drugs::DDDComposite,
	}
	OMIT_HEADER = true
end
class DDDTree < HtmlGrid::Composite
	SORT_DEFAULT = nil
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]	=>	:description,
		[1,0]	=>	:ddd_version,
		[1,0,0]	=>	:source,
		[0,1]	=>	View::Drugs::DDDTreeList,
	}
	COLSPAN_MAP = {
		[0,1]	=>	2,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[1,0]	=>	'th-r',
	}
	def init
		if(@model)
			atc = @model
			@model = [atc]
			while((code = atc.parent_code) \
				&& (atc = @session.app.atc_class(code)))
				@model.unshift(atc) if(atc.has_ddd?)
			end
		else
			@model = []
		end
		super
	end
	def ddd_version(model, session)
		if(atc = model.last)
			@lookandfeel.lookup(:ddd_version)
		end
	end
	def description(model, session)
		if(atc = model.last)
			[ atc.code, atc.en ].join('&nbsp;-&nbsp;')
		end
	end
	def source(model, session)
		if(atc = model.last)
			href = "http://www.whocc.no/atcddd/indexdatabase/index.php?query="
			href << atc.code
			link = HtmlGrid::Link.new(:ddd_source, atc, session, self)
			link.value = @lookandfeel.lookup(:ddd_source)
			link.href = href
			link
		end
	end
end
class DDD < View::PopupTemplate
	CONTENT = View::Drugs::DDDTree
end
		end
	end
end
