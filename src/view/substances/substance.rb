#!/usr/bin/env ruby
# View::Substances::Substance -- oddb -- 25.05.2004 -- mhuggler@ywesee.com

require 'view/privatetemplate'
require 'view/descriptionform'
require 'view/pointersteps'
require 'view/form'
require 'view/drugs/narcotic'
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
	DEFAULT_HEAD_CLASS = 'subheading'
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
	DEFAULT_HEAD_CLASS = 'subheading'
	SORT_HEADER = false
	SORT_DEFAULT = :name_base
  SYMBOL_MAP = {
    :name_base => PointerLink,
  }
end
class MergeSubstancesForm < View::Form
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0,0]	=>	'substance',
		[0,0,1]	=>	'merge_with',
		[1,0,0]	=>	:substance_form,
		[1,0,1]	=>	:submit,
	}
	CSS_MAP = {
		[0,0,3]	=>	'list',
	}
	SYMBOL_MAP = {
		:substance_form	=>	HtmlGrid::InputText
	}
	EVENT = 'merge' 
	LABELS = false
end
class ActiveFormForm < View::Form
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0,0]	=>	:effective_label,
		[1,0,1]	=>	:effective_form,
		[1,0,2]	=>	:effective_submit,
	}
	CSS_MAP = {
		[0,0,2]	=>	'list',
	}
	EVENT = :assign
	LABELS = false
	LEGACY_INTERFACE = false
	def effective_label(model)
		if(model.is_effective_form?)
			@lookandfeel.lookup(:effective_form_self)
		elsif(model.has_effective_form?)
			@lookandfeel.lookup(:effective_form_other)
		else
			@lookandfeel.lookup(:effective_form_assign)
		end
	end
	def effective_form(model)
		HtmlGrid::InputText.new(:effective_form, model, @session, self)
	end
	def effective_submit(model)
		submit(model) #unless model.is_effective_form?
	end
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
		@lookandfeel.languages + ['lt', 'synonym_list']
	end
	def synonym_list(model, session)
		input = DEFAULT_CLASS.new(:synonym_list, model, session, self)
		input.value = model.synonyms.join(', ')
		input
	end
end
class ConnectionKeys < HtmlGrid::List
	COMPONENTS = {
		[0,0]	=>	:connection_key,
		[1,0]	=>	:delete,
	}
	CSS_MAP = {
		[0,0]	=>	'list',
	}	
	CSS_CLASS = 'composite'
	LEGACY_INTERFACE = false
	DEFAULT_HEAD_CLASS = 'subheading'
	SORT_HEADER = false
	def connection_key(model)
		model.to_s
	end
	def delete(model)
		link = HtmlGrid::Link.new(:delete, model, @session, self)
		args = {
			:connection_key	=>	model,
		}
		link.href = @lookandfeel.event_url(:delete_connection_key, args)
		link.css_class = 'small'
		link
	end
end
class AdminComposite < HtmlGrid::Composite
	CSS_CLASS = 'composite top'
	COMPONENTS = {
		[0,0]	=>	View::Substances::MergeSubstancesForm,
		[0,1]	=>	View::Substances::ActiveFormForm,
    [0,2] =>  :narcotic,
	}
	CSS_MAP = {
	}
  def narcotic(model, session)
    if(narc = model.narcotic)
      View::Drugs::NarcoticInnerComposite.new(narc, @session, self)
    end
  end
end
class OuterComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:substance_name,
		[0,1]	=>	View::Substances::DescriptionForm,
		[1,1]	=>	View::Substances::AdminComposite,
		[0,4]	=>	:connection_keys,
		[0,5]	=>	:substrate_connections,
		[0,6]	=>	:sequences,
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
		[0,6]	=>	2,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	def connection_keys(model, session)
		conn_keys = model.connection_keys
		unless(conn_keys.empty?)
			View::Substances::ConnectionKeys.new(conn_keys, session, self)
		end
	end
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
	CONTENT = View::Substances::OuterComposite
	SNAPBACK_EVENT = :result
end
		end
	end
end
