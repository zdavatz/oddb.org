#!/usr/bin/env ruby
# View::Doctors::DocotorList -- oddb -- 26.05.2003 -- jlang@ywesee.com

require 'htmlgrid/value'
require 'htmlgrid/link'
require 'htmlgrid/urllink'
require 'htmlgrid/list'
require 'util/umlautsort'
require 'view/pointervalue'
require 'view/publictemplate'
require 'view/alphaheader'
require 'view/searchbar'
require 'view/form'

module ODDB
	module View
		module Doctors
class DoctorList < HtmlGrid::List
	#include UmlautSort
	COMPONENTS = {
		[0,0]	=>	:name,
		[1,0]	=>	:firstname,
		[2,0]	=>	:tel,
		[3,0]	=>	:praxis_address,
		[4,0]	=>	:specialities,
	}	
	DEFAULT_CLASS = HtmlGrid::Value
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,5]	=>	'top list',
	}
	DEFAULT_HEAD_CLASS = 'th'
	SORT_DEFAULT = :name
	SORT_REVERSE = false 
	LEGACY_INTERFACE = false
	def init
		if(@session.state.paged?)
			extend(View::AlphaHeader)
		end
		super
	end
	def praxis_address(model)
		if(address = model.praxis_address)
			"#{address.lines.join("<br>")} #{model.email}"
		end
	end
	def name(model)
		View::PointerLink.new(:name, model, @session, self)
	end
	def tel(model)
		if(address = model.praxis_address)
			address.fon.join("<br>")
		end
	end
	def specialities(model)
		spc = model.specialities
		spc.join('<br>') unless spc.nil?
	end
end
class DoctorsComposite < Form
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0]		=>	:search_query,
		[0,0,1]	=>	:submit,
		[0,1]		=>	DoctorList,
	}
	EVENT = :search
	SYMBOL_MAP = {
		:search_query		=>	View::SearchBar,	
	}
end
class Doctors < View::PublicTemplate
	CONTENT = View::Doctors::DoctorsComposite
end
		end
	end
end
