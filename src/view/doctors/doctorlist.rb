#!/usr/bin/env ruby
# View::Doctors::DocotorList -- oddb -- 26.05.2003 -- maege@ywesee.com

require 'htmlgrid/value'
require 'htmlgrid/link'
require 'htmlgrid/urllink'
require 'htmlgrid/list'
require 'util/umlautsort'
require 'view/pointervalue'
require 'view/descriptionvalue'
require 'view/form'
require 'view/resultcolors'
require 'view/publictemplate'
require 'view/alphaheader'

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
class Doctors < View::PublicTemplate
	CONTENT = View::Doctors::DoctorList
end
		end
	end
end
