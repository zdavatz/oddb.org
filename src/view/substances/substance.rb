#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Substances::Substance -- oddb.org -- 19.01.2012 -- mhatakeyama@ywesee.com
# ODDB::View::Substances::Substance -- oddb.org -- 25.05.2004 -- mhuggler@ywesee.com

require 'view/privatetemplate'
require 'view/descriptionform'
require 'view/pointersteps'
require 'view/form'
require 'util/pointerarray'

module ODDB
	module View
		module Substances 
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
	}
	CSS_MAP = {
	}
end
class OuterComposite < HtmlGrid::Composite
	COMPONENTS = {
		[0,0]	=>	:substance_name,
		[0,1]	=>	View::Substances::DescriptionForm,
		[1,1]	=>	View::Substances::AdminComposite,
		[0,4]	=>	:sequences,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
		[1,2]	=>	'button',
	}
	COLSPAN_MAP = {
		[0,0]	=>	2,
		[0,4]	=>	2,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	def substance_name(model, session)
		model.name
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
