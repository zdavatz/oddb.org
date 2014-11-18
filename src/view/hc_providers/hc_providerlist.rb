#!/usr/bin/env ruby
# encoding: utf-8
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
require 'view/address'

module ODDB
	module View
		module HC_providers
class HC_providerList < HtmlGrid::List
	include AlphaHeader
	include UmlautSort
	include AddressMap
	include VCardMethods
	COMPONENTS = {
		[0,0]	=>	:name,
		[1,0]	=>	:business_unit,
		[2,0]	=>	:city,
		[3,0]	=>	:plz,
		[4,0]	=>	:canton,
		[5,0]	=>	:narcotics,
		[6,0]	=>	:map,
		[7,0]	=>	:vcard,
	}
	DEFAULT_CLASS = HtmlGrid::Value
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'list',
		[1,0]	=>	'list',
		[2,0]	=>	'list',
		[3,0]	=>	'list',
		[4,0]	=>	'list',
		[5,0]	=>	'list',
		[6,0]	=>	'list',
		[7,0]	=>	'list',
	}
	CSS_HEAD_MAP = {
		[0,0] =>	'th',
		[1,0] =>	'th',
		[2,0] =>	'th',
		[3,0] =>	'th',
		[4,0] =>	'th',
		[5,0] =>	'th',
		[6,0] =>	'th',
		[7,0] =>	'th',
	}
	LOOKANDFEEL_MAP = {
		:name						=>	:hc_provider_name,
		:canton					=>	:canton,
	}
	SORT_DEFAULT = :name
	SORT_REVERSE = false
	LEGACY_INTERFACE = false
	def plz(model)
		if(addr = model.addresses.first)
			addr.plz
		end
	end
	def city(model)
		if(addr = model.address(0))
			addr.city
		end
	end
	def canton(model)
		if(addr = model.addresses.first)
			addr.canton
		end
	end
	def name(model)
    link = View::PointerLink.new(:name, model, @session, self)
    new_href = nil
    if model.is_a?(ODDB::Company)
      new_href = @lookandfeel._event_url(:company, {:ean => model.ean13})
    elsif model.is_a?(ODDB::Doctor)
      new_href = @lookandfeel._event_url(:doctor, {:ean => model.ean13})
    elsif  model.is_a?(ODDB::Hospital)
      new_href = @lookandfeel._event_url(:hospital, {:ean => model.ean13})
    else
      return nil
    end
		link.set_attribute('title', "EAN: #{model.ean13}")
    link.href = new_href
		link
	end
	def narcotics(model)
    if model.respond_to?(:may_dispense_narcotics)
			if(model.may_dispense_narcotics)
				@lookandfeel.lookup(:true)
			else
				@lookandfeel.lookup(:false)
			end
    elsif model.respond_to?(:narcotics)
      if(model.narcotics == "Keine Betäubungsmittelbewilligung")
        @lookandfeel.lookup(:false)
      else
        @lookandfeel.lookup(:true)
      end
    else
      # TODO:
      @lookandfeel.lookup(:false)
    end
	end
	def map(model)
		if(addr = model.addresses.first)
			super(addr)
		end
	end
  def vcard(model)
    link = View::PointerLink.new(:vcard, model, @session, self)
    ean_or_oid = if ean = model.ean13 and ean.to_s.strip != ""
                   ean
                 else
                   model.oid
                 end
    new_href = nil
    if model.is_a?(ODDB::Company)
      new_href = @lookandfeel._event_url(:vcard, {:company => ean_or_oid})
    elsif model.is_a?(ODDB::Doctor)
      new_href = @lookandfeel._event_url(:vcard, {:doctor => ean_or_oid})
    elsif  model.is_a?(ODDB::Hospital)
      new_href = @lookandfeel._event_url(:vcard, {:hospital => ean_or_oid})
    else
      return nil
    end
    link.href = new_href
    link
  end
end
class HC_providersComposite < Form
	CSS_CLASS = 'composite'
	COMPONENTS = {
		[0,0,0]	=>	:search_query,
		[0,0,1]	=>	:submit,
		[0,1]		=>	:hc_provider_list,
	}
	CSS_MAP = {
		[0,0]	=> 'right',
	}
	EVENT = :search
	SYMBOL_MAP = {
		:search_query		=>	View::SearchBar,
	}
	def hc_provider_list(model, session)
    HC_providerList.new(model, session, self)
	end
end
class HC_providers < View::PublicTemplate
	CONTENT = View::HC_providers::HC_providersComposite
end
class EmptyResultForm < HtmlGrid::Form
	COMPONENTS = {
		[0,0,0]	=>	:search_query,
		[0,0,1]	=>	:submit,
		[0,1]		=>	:title_none_found,
		[0,2]		=>	'e_empty_result',
		[0,3]		=>	'explain_search_hc_provider',
	}
	CSS_MAP = {
		[0,0]			=>	'search',
		[0,1]			=>	'th',
		[0,2,1,2]	=>	'list atc',
	}
	CSS_CLASS = 'composite'
	EVENT = :search
	FORM_METHOD = 'GET'
	SYMBOL_MAP = {
		:search_query		=>	View::SearchBar,
	}
	def title_none_found(model, session)
		query = session.persistent_user_input(:search_query)
		@lookandfeel.lookup(:title_none_found, query)
	end
end
class EmptyResult < View::PublicTemplate
	CONTENT = View::HC_providers::EmptyResultForm
end
		end
	end
end
