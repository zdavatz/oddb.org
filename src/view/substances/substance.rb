#!/usr/bin/env ruby
# View::Substances::Substance -- oddb -- 25.05.2004 -- maege@ywesee.com

require 'view/privatetemplate'
require 'view/descriptionform'
require 'view/pointersteps'
require 'view/form'
require 'util/pointerarray'

module ODDB
	module View
		module Substances 
module SubstrateList
	COMPONENTS = {
		[0,0]	=>	:substrates,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,1]	=>	'list',
	}	
	DEFAULT_CLASS = HtmlGrid::Value
	DEFUALT_HEAD_CLASS = 'subheading'
	SORT_HEADER = false
	def substrates(model, session)
		txt = HtmlGrid::Text.new(:substrates, model, session, self)
		txt.label = false 
		txt.value = model.cyp_id 
		txt
	end
end
module SequencesList
	COMPONENTS = {
		[0,0]	=>	:name_base,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0,1]	=>	'list',
	}	
	DEFAULT_CLASS = HtmlGrid::Value
	DEFUALT_HEAD_CLASS = 'subheading'
	SORT_HEADER = false
	SORT_DEFAULT = :name_base
end
class MergeSubstancesForm < View::Form
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0,0]	=>	'substance',
		[0,0,1]	=>	'merge_with',
		[0,0,2]	=>	:substance_form,
		[0,0,3]	=>	:submit,
	}
	SYMBOL_MAP = {
		:substance_form	=>	HtmlGrid::InputText
	}
	EVENT = 'merge' 
	LABELS = false
end
class Substrates < HtmlGrid::List
	include View::Substances::SubstrateList
end
class Sequences < HtmlGrid::List
	include View::Substances::SequencesList
end
class DescriptionForm < View::DescriptionForm
	DESCRIPTION_CSS = 'xl'
	def languages
		lang = @lookandfeel.languages.dup
		lang << 'en' << 'lt'
	end
end
class Composite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:substance_name,
		[0,1]	=>	View::Substances::DescriptionForm,
		[1,1]	=>	View::Substances::MergeSubstancesForm,
		[0,4]	=>	:substrate_connections,
		[0,5]	=>	:sequences,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
		[1,2]	=>	'button',
	}
	COLSPAN_MAP = {
		[0,0]	=>	2,
		[0,4]	=>	2,
		[0,5]	=>	2,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	def substance_name(model, session)
		model.name
	end
	def substrate_connections(model, session)
		unless(model.substrate_connections.nil?)
			connections = model.substrate_connections.values
			values = PointerArray.new(connections, model.pointer)
			View::Substances::Substrates.new(values, session, self)
		end
	end
	def sequences(model, session)
		sequences = model.sequences
		Sequences.new(sequences, session, self)
	end
end
class Substance < View::PrivateTemplate
	CONTENT = View::Substances::Composite
	SNAPBACK_EVENT = :result
end
		end
	end
end
