#!/usr/bin/env ruby
# View::Admin::Package -- oddb -- 14.03.2003 -- hwyss@ywesee.com 

require 'view/admin/swissmedic_source'
require 'view/drugs/privatetemplate'
require 'view/form'
require 'view/pointervalue'
require 'view/dataformat'
require 'htmlgrid/inputcheckbox'
require 'htmlgrid/inputcurrency'
require 'htmlgrid/inputdate'
require 'htmlgrid/errormessage'
require 'htmlgrid/select'
require 'htmlgrid/link'
require 'htmlgrid/booleanvalue'

module ODDB
	module View
		module Admin
class CompositionSelect < HtmlGrid::AbstractSelect
  def selection(context)
    lang = @session.language
    @selected ||= (comp = @model.composition) && shorten(comp)
    res = []
    @model.registration.compositions.each_with_index { |composition, idx|
      comp = shorten(composition)
      attribs = { "value" => idx }
      attribs.store("selected", 1) if(comp == selected)
      res << context.option(attribs) { comp }
    }
    res
  end
  def shorten(comp)
    str = comp.to_s
    if(str.length > 60)
      str[0,57] << '...'
    else 
      str
    end
  end
end
class Parts < HtmlGrid::List
  class << self
    def input_text(*keys)
      keys.each { |key|
        define_method(key) { |model| 
          input = HtmlGrid::Input.new(name(key), model, @session, self)
          input.value = model.send(key) if model
          input
        }
      }
    end
  end
  COMPONENTS = {
    [0,0] => :delete,
    [1,0] => :multi,
    [2,0] => "x",
    [3,0] => :count,
    [4,0] => :commercial_form,
    [5,0] => "à",
    [6,0] => :measure,
    [7,0] => :composition,
    [8,0] => :unsaved,
  }
  COMPONENT_CSS_MAP = { 
    [1,0,3] => "small right",
    [6,0]   => "small right",
  }
  CSS_ID = 'parts'
  DEFAULT_CLASS = HtmlGrid::InputText
  EMPTY_LIST = true
  HTTP_HEADERS = {
    "Content-Type"	=>	"text/html; charset=UTF-8",
    "Cache-Control"	=>	"private, no-store, no-cache, must-revalidate, post-check=0, pre-check=0",
    "Pragma"				=>	"no-cache",
    "Expires"				=>	Time.now.rfc1123,
  }
  OMIT_HEADER = true
  LEGACY_INTERFACE = false
  SORT_DEFAULT = nil
  input_text :multi, :count, :commercial_form, :measure
  def add(model)
    link = HtmlGrid::Link.new(:plus, model, @session, self)
    link.set_attribute('title', @lookandfeel.lookup(:create_part))
    link.css_class = 'create square'
    args = [ :pointer, @session.state.model.pointer ]
    url = @session.lookandfeel.event_url(:ajax_create_part, args)
    link.onclick = "replace_element('#{css_id}', '#{url}');"
    link
  end
  def compose_footer(offset)
    if(@model.empty? || !@model.last.is_a?(Persistence::CreateItem))
      @grid.add add(@model), *offset
    end
  end
  def composition(model)
    CompositionSelect.new(name("composition"), model, @session, self)
  end
  def delete(model)
    if(@model.size > 1)
      link = HtmlGrid::Link.new(:minus, model, @session, self)
      link.set_attribute('title', @lookandfeel.lookup(:delete))
      link.css_class = 'delete square'
      args = [ :pointer, @session.state.model.pointer, :part, @list_index ]
      url = @session.lookandfeel.event_url(:ajax_delete_part, args)
      link.onclick = "replace_element('#{css_id}', '#{url}');"
      link
    end
  end
  def name(part)
    "#{part}[#@list_index]"
  end
  def unsaved(model)
    @lookandfeel.lookup(:unsaved) if model.is_a?(Persistence::CreateItem)
  end
end
class PackageInnerComposite < HtmlGrid::Composite
	include DataFormat
	COMPONENTS = {
		[0,0]		=>	:iksnr,
		[2,0]		=>	:ikscd,
		[0,1]		=>	:descr,
		[2,1]		=>	:ikscat,
		[2,1]		=>	:sl_entry,
		[0,2]		=>	:price_exfactory,
		[2,2]		=>	:price_public,
	}
	CSS_MAP = {
		[0,0,4,3]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LABELS = true
  LOOKANDFEEL_MAP = {
    :descr  =>  :description,
  }
	SYMBOL_MAP = {
		:sl_entry	=>	HtmlGrid::BooleanValue,
	}
end
class PackageForm < HtmlGrid::Composite
  include FormMethods
	include HtmlGrid::ErrorMessage
	COMPONENTS = {
		[0,0]		=>	:iksnr,
		[2,0]		=>	:ikscd,
		[0,1]		=>	:descr,
		[2,1]		=>	:pretty_dose,
		[0,2]		=>	:ikscat,
		[2,2]		=>	:sl_entry,
		[0,3]		=>	:price_exfactory,
		[2,3]		=>	:price_public,
    [0,4]   =>  :market_date,
    [2,4]   =>  :preview_with_market_date,
    [0,5]   =>  :deductible,
    [2,5]   =>  :lppv,
    [0,6]   =>  :out_of_trade,
    [0,7]   =>  :disable,
    [2,7]   =>  :pharmacode,
    [0,8]   =>  :generic_group,
    [1,9,0] =>  :submit,
    [1,9,1] =>  :delete_item,
	}
	COMPONENT_CSS_MAP = {
		[0,0,4,5]	=>	'standard',
    [3,7]     =>  'standard',
    [1,8]     =>  'standard',
		[3,2]			=>	'list',
	}
	CSS_MAP = {
		[0,0,4,10]	=>	'list',
    [0,8]       =>  'list top',
	}
	LABELS = true
  LOOKANDFEEL_MAP = {
    :descr  =>  :description,
  }
	SYMBOL_MAP = {
		:deductible				=>	HtmlGrid::Select,
		:disable     			=>	HtmlGrid::InputCheckbox,
		:price_exfactory	=>	HtmlGrid::InputCurrency,
		:price_public			=>	HtmlGrid::InputCurrency,
		:iksnr						=>	HtmlGrid::Value,
		:market_date			=>	HtmlGrid::InputDate,
		:out_of_trade			=>	HtmlGrid::BooleanValue,
		:preview_with_market_date =>	HtmlGrid::InputCheckbox,
		:refdata_override	=>	HtmlGrid::InputCheckbox,
		:lppv							=>	HtmlGrid::Select,
	}
	def init
		if(@model.out_of_trade)
			components.store([2,7], :refdata_override)
		end
		super
		error_message()
	end
=begin
  def commercial_form(model, session=@session)
    input = HtmlGrid::InputText.new(:commercial_form, 
                                    model, @session, self)
    if(comform = model.commercial_form)
      input.value = comform.send(@session.language)
    end
    input
  end
=end
	def delete_item(model, session)
		delete_item_warn(model, :w_delete_package)
	end
	def sl_entry(model, session)
		unless (model.is_a? Persistence::CreateItem)
			link = nil
			if (sl_entry = model.sl_entry)
				link = HtmlGrid::Link.new(:sl_modify, sl_entry, session, self)
				args = {'pointer' => sl_entry.pointer}
				link.href = @lookandfeel._event_url(:resolve, args)
			else
				link = HtmlGrid::Link.new(:sl_create, sl_entry, session, self)
				link.href = @lookandfeel.event_url(:new_item)
			end
			link.label = true
			link.set_attribute('class', 'list')
			link
		end
	end
  def generic_group(model, session=@session)
    input = HtmlGrid::Textarea.new(:generic_group, model, @session, self)
    input.value = model.generic_group_comparables.collect do |pac|
      pac.ikskey
    end.sort.join(', ')
    input.label = true
    input
  end
end
class DeductiblePackageForm < View::Admin::PackageInnerComposite
	include View::HiddenPointer
	LABELS = true
	DEFAULT_CLASS = HtmlGrid::Value
	EVENT = :update
	COMPONENTS = {
		[0,0]		=>	:iksnr,
		[2,0]		=>	:ikscd,
		[0,1]		=>	:descr,
		[2,1]		=>	:pretty_dose,
		[0,2]		=>	:ikscat,
		[2,2]		=>	:sl_entry,
		[0,3]		=>	:price_exfactory,
		[2,3]		=>	:price_public,
		[0,4]		=>	:deductible_m,
		[1,5]		=>	:submit,
	}
	SYMBOL_MAP = {
		:deductible_m	=>	HtmlGrid::Select,
		:sl_entry			=>	HtmlGrid::BooleanValue,
	}
	CSS_MAP = {
		[0,0,4,6]	=>	'list',
	}
	LOOKANDFEEL_MAP = {
		:deductible_m	=>	:deductible,	
	}
end
class PackageComposite < HtmlGrid::Composite
  include SwissmedicSource
	COMPONENTS = {
		[0,0]	=>	:package_name,
		[0,1]	=>	View::Admin::PackageInnerComposite,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]	=>	'th',
	}
	def package_name(model, session=@session)
		sequence = model.parent(session.app)
		[sequence.name, model.size].compact.join('&nbsp;-&nbsp;')
	end
  def source(model, session=@session)
    val = HtmlGrid::Value.new(:source, model, @session, self)
    val.value = package_source(model) if model
    val
  end
end
class RootPackageComposite < View::Admin::PackageComposite
  include HtmlGrid::FormMethods
  include FormMethods
  LEGACY_INTERFACE = false
	COMPONENTS = {
		[0,0]	=>	:package_name,
		[0,1]	=>	View::Admin::PackageForm,
		[0,2]	=>	'th_source',
		[0,3]	=>	:source,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,2]	=>	'subheading',
	}
  def init
    unless @model.is_a?(Persistence::CreateItem)
      components.update(
        [0,2] =>  :parts,
        [0,3] =>  :parts_form,
        [0,4]	=>	'th_source',
        [0,5]	=>	:source
      )
      css_map.store [0,4], 'subheading'
    end
    super
  end
  def parts(model)
    key = model.parts.size > 1 ? :parts : :package_and_substances
    @lookandfeel.lookup(key)
  end
  def parts_form(model)
    Parts.new(model.parts, @session, self)
  end
end
class DeductiblePackageComposite < View::Admin::RootPackageComposite
	COMPONENTS = {
		[0,0]	=>	:package_name,
		[0,1]	=>	View::Admin::DeductiblePackageForm,
		[0,2]	=>	'th_source',
		[0,3]	=>	:source,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,2]	=>	'subheading',
	}
	def source(model, session=@session)
		HtmlGrid::Value.new(:source, model.sequence, @session, self)
	end
end
class Package < View::Drugs::PrivateTemplate
	CONTENT = View::Admin::PackageComposite
	SNAPBACK_EVENT = :result
end
class RootPackage < View::Admin::Package
	CONTENT = View::Admin::RootPackageComposite
  JAVASCRIPTS = ['admin']
end
class DeductiblePackage < View::Admin::Package
	CONTENT = View::Admin::DeductiblePackageComposite
end
		end
	end
end
