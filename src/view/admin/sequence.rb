#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::Sequence -- oddb.org -- 29.10.2012 -- yasaka@ywesee.com
# ODDB::View::Admin::Sequence -- oddb.org -- 14.11.2011 -- mhatakeyama@ywesee.com 
# ODDB::View::Admin::Sequence -- oddb.org -- 11.03.2003 -- hwyss@ywesee.com 

require 'view/admin/swissmedic_source'
require 'view/drugs/privatetemplate'
require 'view/form'
require 'view/dataformat'
require 'view/pointervalue'
require 'view/drugs/sequence'
require 'view/additional_information'
require 'htmlgrid/booleanvalue'
require 'htmlgrid/errormessage'
require 'htmlgrid/infomessage'
require 'htmlgrid/inputcheckbox'
require 'htmlgrid/inputdate'
require 'htmlgrid/inputfile'
require 'htmlgrid/text'
require 'htmlgrid/textarea'
require 'htmlgrid/labeltext'
require 'htmlgrid/select'
require 'htmlgrid/divlist'
require 'util/pointerarray'

module ODDB
	module View
		module Admin
class ActiveAgents < HtmlGrid::List
  COMPONENTS = {
    [0,0] => :substance,
    [1,0] => :dose,
  }
  DEFAULT_CLASS = HtmlGrid::Value
  EMPTY_LIST = true
  OMIT_HEADER = false
  STRIPED_BG = false
  SORT_DEFAULT = nil
	SORT_HEADER = false
  LEGACY_INTERFACE = false
  LABELS = false
  CSS_HEAD_MAP = {
    [1,0] => 'right',
  }
  CSS_MAP = {
    [0,0] => 'list',
    [1,0] => 'list right',
  }
  def compose_footer(offset)
    _compose_footer offset
  end
  def _compose_footer(offset)
    comp = if act = @model.first
             act.parent(@session.app)
           end
    input = galenic_form(comp)
    label = HtmlGrid::SimpleLabel.new(:galenic_form, input, @session, self)
    @grid.add [label, nil, input], *offset
    @grid.add_style 'list', *offset
    @grid.add_style 'list right', offset[0] + 1, offset[1]
    offset[1] += 1
    offset
  end
  def dose(model)
    model.dose.to_s if model
  end
  def galenic_form(model)
    element = HtmlGrid::Value.new(:galenic_form, model, @session, self)
    element.label = true
    if model && gf = model.galenic_form
      element.value = gf.send @session.language
    end
    element
  end
  def substance(model)
    if model && sub = model.substance
      sub.send(@session.language)
    end
  end
end
class RootActiveAgents < ActiveAgents
  COMPONENTS = {
    [0,0] => :delete,
    [1,0] => :substance,
    [2,0,0] => :dose,
    [2,0,1] => :unsaved,
  }
  COMPONENT_CSS_MAP = { [2,0] => 'short right' }
  CSS_HEAD_MAP = {
    [2,0] => 'right',
  }
  CSS_MAP = { }
  DEFAULT_CLASS = HtmlGrid::InputText
  HTTP_HEADERS = {
    "Content-Type"	=>	"text/html; charset=UTF-8",
    "Cache-Control"	=>	"private, no-store, no-cache, must-revalidate, post-check=0, pre-check=0",
    "Pragma"				=>	"no-cache",
    "Expires"				=>	Time.now.rfc1123,
  }
  def add(model)
    link = HtmlGrid::Link.new(:plus, model, @session, self)
    link.set_attribute('title', @lookandfeel.lookup(:create_active_agent))
    link.css_class = 'create square'
    args = [ :reg, @session.state.model.iksnr, :seq, @session.state.model.seqnr, :composition, composition ]
    url = @session.lookandfeel.event_url(:ajax_create_active_agent, args)
    link.onclick = "replace_element('#{css_id}', '#{url}');"
    link
  end
  def compose_footer(offset)
    if(@model.empty? || @model.last)
      @grid.add add(@model), *offset
      offset[1] += 1
      _compose_footer [offset[0].next, offset[1]]
      offset[1] += 1
      @grid.add delete_composition(@model), *offset
      @grid.add_style 'right', *offset
      @grid.set_colspan offset.at(0), offset.at(1)
      offset[1] += 1
    else
      _compose_footer [offset[0].next, offset[1]]
    end
  end
  def composition
    @container ? @container.list_index : @session.user_input(:composition)
  end
  def css_id
    @css_id ||= "active-agents-#{composition}"
  end
  def delete(model)
    unless(@model.first.nil?)
      link = HtmlGrid::Link.new(:minus, model, @session, self)
      link.set_attribute('title', @lookandfeel.lookup(:delete))
      link.css_class = 'delete square'
      args = [ :reg, @session.state.model.iksnr, :seq, @session.state.model.seqnr, :composition, composition, :active_agent, @list_index ]
      url = @session.lookandfeel.event_url(:ajax_delete_active_agent, args)
      link.onclick = "replace_element('#{css_id}', '#{url}');"
      link
    end
  end
  def delete_composition(model)
    link = HtmlGrid::Link.new(:delete_composition, model, @session, self)
    link.css_class = 'ajax'
    args = [ :reg, @session.state.model.iksnr, :seq, @session.state.model.seqnr, :composition, composition ]
    url = @session.lookandfeel.event_url(:ajax_delete_composition, args)
    link.onclick = "replace_element('composition-list', '#{url}');"
    link
  end
  def dose(model)
    input = HtmlGrid::InputText.new(name("dose"), model, @session, self)
    input.value = super
    input
  end
  def galenic_form(model)
    input = HtmlGrid::InputText.new("galenic_form[#{composition}]", 
                                    model, @session, self)
    input.label = true
    if model && gf = model.galenic_form
      input.value = gf.send @session.language
    end
    input
  end
  def name(part)
    "#{part}[#{composition}][#@list_index]"
  end
  def substance(model)
    input = HtmlGrid::InputText.new(name("substance"), model, @session, self)
    input.value = super
    input
  end
  def unsaved(model)
    @lookandfeel.lookup(:unsaved) if model.nil?
  end
end
class CompositionList < HtmlGrid::DivList
  COMPONENTS = { [0,0] => :composition }
  LABELS = false
  OFFSET_STEP = [1,0]
  OMIT_HEADER = true
  def composition(model)
    agents = ActiveAgents.new(model.active_agents, @session, self)
    if @model.size > 1
      span = HtmlGrid::Span.new(model, @session, self)
      span.css_class = 'italic'
      label = model.label || @list_index.to_i + 1
      span.value = @lookandfeel.lookup(:part, label)
      [span, agents]
    else
      agents
    end
  end
end
class RootCompositionList < CompositionList
  attr_reader :list_index
  def add(model)
    link = HtmlGrid::Link.new(:create_composition, model, @session, self)
    link.css_class = 'ajax'
    args = [:reg, @session.state.model.iksnr, :seq, @session.state.model.seqnr]
    url = @session.lookandfeel.event_url(:ajax_create_composition, args)
    link.onclick = "replace_element('composition-list', '#{url}');"
    link
  end
  def compose
    super
    comp = @model.last
    @grid.push [add(@model)] if comp.nil? || !comp.active_agents.compact.empty?
  end
  def composition(model)
    RootActiveAgents.new(model.active_agents, @session, self)
  end
end
class Compositions < HtmlGrid::DivComposite
  COMPONENTS = { [0,0] => CompositionList }
  CSS_ID = 'composition-list'
end
class RootCompositions < Compositions
  COMPONENTS = { [0,0] => RootCompositionList }
  HTTP_HEADERS = {
    "Content-Type"	=>	"text/html; charset=UTF-8",
    "Cache-Control"	=>	"private, no-store, no-cache, must-revalidate, post-check=0, pre-check=0",
    "Pragma"				=>	"no-cache",
    "Expires"				=>	Time.now.rfc1123,
  }
end
class RootDivisionComposite < HtmlGrid::Composite
  COMPONENTS = {
    [0,0] => :divisable,
    [0,1] => :dissolvable,
    [0,2] => :crushable,
    [0,3] => :openable,
    [0,4] => :notes,
    [0,5] => :division_source,
    [0,6] => :source,
    [0,7] => :assign_division,
  }
  COLSPAN_MAP = {
    [0,5] => 3,
    [0,6] => 4,
  }
  CSS_MAP = {
    [0,0] => 'list',
    [0,1] => 'list',
    [0,2] => 'list',
    [0,3] => 'list',
    [0,4] => 'list',
    [0,5] => 'list',
    [0,6] => 'list',
    [0,7] => 'list',
  }
  LABELS = true
  DEFAULT_CLASS = HtmlGrid::Value
  def divisable(model, session)
    input = HtmlGrid::InputText.new(:division_divisable, model, @session, self)
    input.set_attribute('size', 71)
    if model
      input.value = model.divisable
    end
    input
  end
  def dissolvable(model, session)
    input = HtmlGrid::InputText.new(:division_dissolvable, model, @session, self)
    input.set_attribute('size', 40)
    if model
      input.value = model.dissolvable
    end
    input
  end
  def crushable(model, session)
    input = HtmlGrid::InputText.new(:division_crushable, model, @session, self)
    input.set_attribute('size', 40)
    if model
      input.value = model.crushable
    end
    input
  end
  def openable(model, session)
    input = HtmlGrid::InputText.new(:division_openable, model, @session, self)
    input.set_attribute('size', 40)
    if model
      input.value = model.openable
    end
    input
  end
  def notes(model, session)
    input = HtmlGrid::InputText.new(:division_notes, model, @session, self)
    input.set_attribute('size', 71)
    if model
      input.value = model.notes
    end
    input
  end
  def source(model, session)
    textarea = HtmlGrid::Textarea.new(:division_source, model, @session, self)
    textarea.label = false
    textarea.set_attribute('class', 'huge')
    if model
      textarea.value = model.source
    end
    textarea
  end
  def assign_division(model, session)
    link = HtmlGrid::Link.new(:assign_division, model, session, self)
    link.href = @lookandfeel.event_url(:assign_division)
    if model
      link.value = @lookandfeel.lookup(:assign_this_division)
    else
      link.value = @lookandfeel.lookup(:assign_other_division)
    end
    link.set_attribute('class', 'small')
    link
  end
end
module SequencePackageList
	include DataFormat
  include PartSize
	COMPONENTS = {
		[0,0]	=>	:ikscd,
		[1,0]	=>	:size,
		[2,0]	=>	:price_exfactory,
		[3,0]	=>	:price_public,
		[4,0]	=>	:ikscat,
		[5,0]	=>	:sl_entry,
		[6,0]	=>	:out_of_trade,
	}
	CSS_CLASS = 'composite'
	CSS_MAP = {
		[0,0]		=>	'list',
		[1,0,6]	=>	'list right',
	}
	CSS_HEAD_MAP = {
		[0,0]	=>	'subheading',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	DEFAULT_HEAD_CLASS = 'subheading right'
	EVENT = :new_package
	SORT_DEFAULT = :ikscd
	SORT_HEADER = false
	SYMBOL_MAP = {
		:ikscd				=>	View::PointerLink,
		:out_of_trade	=>	HtmlGrid::BooleanValue,
	}
	def ikscd(model, session=@session)
		if(@session.allowed?('edit', 'org.oddb.drugs'))
			PointerLink.new(:ikscd, model, @session, self)
		else
      evt = @session.state.respond_to?(:suggest_choose) ? :suggest_choose : :show
			link = HtmlGrid::Link.new(:ikscd, model, @session, self)
			link.value = model.ikscd
      smart_link_format = model.pointer.to_csv.gsub(/registration/, 'reg').gsub(/sequence/, 'seq').gsub(/package/, 'pack').split(/,/)
      if evt == :show and smart_link_format.include?('reg')
  			link.href = @lookandfeel.event_url(evt, smart_link_format)
      else
        old_link_format = {:pointer => model.pointer}
  			link.href = @lookandfeel.event_url(evt, old_link_format)
      end
			link
		end
	end
  def size(model, session=@session)
    comparable_size model
  end
	def sl_entry(model, session=@session)
		@lookandfeel.lookup(:sl) unless model.sl_entry.nil?
	end
end
class SequencePackages < HtmlGrid::List
	include View::Admin::SequencePackageList
end
class RootSequencePackages < View::FormList
	include View::Admin::SequencePackageList
	EMPTY_LIST_KEY = :empty_package_list
end
module SequenceDisplay
	def atc_class(model, session)
		self::class::DEFAULT_CLASS.new(:code, model.atc_class, session, self)
	end	
	def atc_descr(model, session)
		if(atc = model.atc_class)
			txt = HtmlGrid::Text.new(:atc_descr, model, session, self)
			txt.label = true
			txt.value = atc.description(@lookandfeel.language)
			txt
		end
	end
	def atc_request(model, session)
		if(time = model.atc_request_time)
			days = ((((Time.now - @model.atc_request_time) / 60) / 60) / 24)
			output = "#{@lookandfeel.lookup(:atc_request_time)}"
			if(days > 1)
				output + "#{days.round} #{@lookandfeel.lookup(:atc_request_days)}"
			else
				days = (days * 24)  
				output + "#{days.round} #{@lookandfeel.lookup(:atc_request_hours)}"
			end
		else
			button = HtmlGrid::Button.new(:atc_request, @model, @session, self)
			button.value = @lookandfeel.lookup(:atc_request)
			url = @lookandfeel.event_url(:atc_request)
			button.set_attribute('onclick', "location.href='#{url}'")
			button
		end
	end
end
class SequenceInnerComposite < HtmlGrid::Composite
	include View::Admin::SequenceDisplay
	COMPONENTS = {
		[0,0]		=>	:iksnr,
		[2,0]		=>	:seqnr,
		[0,1]		=>	:name_base,
		[2,1]		=>	:name_descr,
		[0,2]		=>	:atc_class,
		[2,2]		=>	:atc_descr,
		[0,3]		=>	:sequence_date,
	}
	CSS_MAP = {
		[0,0,4,4]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	LABELS = true
  SYMBOL_MAP = {
    :sequence_date => HtmlGrid::DateValue,
  }
end
class SequenceForm < HtmlGrid::Composite
	include HtmlGrid::ErrorMessage
	include HtmlGrid::InfoMessage
	include View::Admin::SequenceDisplay
	include View::AdditionalInformation
  include FormMethods
	COMPONENTS = {
		[0,0]		=>	:iksnr,
		[2,0]		=>	:seqnr,
		[0,1]		=>	:name_base,
		[2,1]		=>	:name_descr,
		[0,2]		=>	:longevity,
		[2,2]		=>	:export_flag,
		[0,3]		=>	:atc_class,
		[2,3]		=>	:atc_descr,
		[0,4]		=>	:sequence_date,
	}
	COMPONENT_CSS_MAP = {
		[1,0,1,5]	=>	'standard',
		[3,0,1,2]	=>	'standard',
		[3,3]	    =>	'standard',
	}
  CSS_MAP = {
    [0,0,4,5]	=>	'list',
  }
	LABELS = true
  LOOKANDFEEL_MAP = {
    :language_select => :language_select_html,
  }
	SYMBOL_MAP = {
		:export_flag				=> HtmlGrid::InputCheckbox,
		:iksnr							=> HtmlGrid::Value,
    :html_upload        => HtmlGrid::InputFile,
		:patinfo_label			=> HtmlGrid::LabelText,
		:atc_request_label	=> HtmlGrid::LabelText,
		:no_company					=> HtmlGrid::LabelText,
		:regulatory_email		=> HtmlGrid::InputText,
    :activate_patinfo   => HtmlGrid::InputDate,
		:deactivate_patinfo => HtmlGrid::InputDate,
		:sequence_date      => HtmlGrid::InputDate,
	}
	def init
		reorganize_components
		super
		error_message()
		info_message()
	end
	def reorganize_components
		if(@model.is_a?(ODDB::Sequence))
			components.update({
				[0,5]		=>	:html_upload,
				[2,5]		=>	:language_select,
				[0,6]		=>	:patinfo_upload,
				[2,6]   =>  :patinfo_label,
				[3,6,1] =>  :patinfo,
				[3,6,2] =>  :assign_patinfo,
				[3,6,3] =>  :delete_patinfo,
        [0,7]   =>  :activate_patinfo,
        [2,7]   =>  :deactivate_patinfo,
				[1,8,0]	=>	:submit,
				[1,8,1] =>  :delete_item,
			})
			css_map.update({
				[0,5,4,4]	=>	'list',
				[0,6,5]   =>	'list',
			})
			if(@model.atc_class.nil? && !atc_descr_error?)
				if(@model.company.nil?)
					components.store([5,3], :atc_request_label)
					components.store([3,3], :no_company)
				else
					if(@model.company.regulatory_email.to_s.empty?)
						components.store([2,3], :regulatory_email)
					else
						components.store([2,3], :atc_request_label)
						components.store([3,3], :atc_request)
					end
				end
			end
		else
			components.store([1,5], :submit)
		end
	end
	def assign_patinfo(model, session=@session)
		link = HtmlGrid::Link.new(:assign_patinfo, model, session, self)
		link.href = @lookandfeel.event_url(:assign_patinfo)
		if(@model.has_patinfo?)
			link.value = @lookandfeel.lookup(:assign_this_patinfo)
		else
			link.value = @lookandfeel.lookup(:assign_other_patinfo)
		end
		link.set_attribute('class', 'small')
		link
	end
	def atc_descr(model, session=@session)
		if(atc_descr_error?)
			HtmlGrid::InputText.new(:atc_descr, model, session, self)
		else
			super
		end
	end
	def atc_descr_error?
		((err = @session.error(:atc_class)) \
		 && err.message == "e_unknown_atc_class") \
		 || ((atc = @model.atc_class) \
				 && atc.description.empty?)
	end
	def delete_item(model, session=@session)
		delete_item_warn(model, :w_delete_sequence)
	end
	def delete_patinfo(model, session=@session)
		if(model.has_patinfo?)
			button = HtmlGrid::Button.new(:delete_patinfo, 
																		model, session, self)
			script = "this.form.patinfo.value = 'delete'; this.form.submit();"
			button.set_attribute('onclick', script)
			button
		end
	end
	def language_select(model, session=@session)
		sel = View::Admin::FachinfoLanguageSelect.new(:language_select, model, 
			session, self)
		#sel.label = false
		sel
	end
	def seqnr(model, session=@session)
		klass = if(model.seqnr.nil?)
							HtmlGrid::InputText
						else
							HtmlGrid::Value
						end
		klass.new(:seqnr, model, session, self)
	end
	def patinfo(model, session=@session)
		if(link = super)
			pos = components.index(:patinfo)
			link.set_attribute('class', 'square infos')
			link
		end
	end
	def profile_link(model, session=@session)
		if(comp = model.company)
			link = HtmlGrid::Link.new(:company_link, model, session, self)  
			args = { :pointer	=>	comp.pointer }
			link.href = @lookandfeel._event_url(:resolve, args)
			link.set_attribute('class', 'small')
			link.label = false
			link  
		end
	end
	def patinfo_label(model, session=@session)
		HtmlGrid::LabelText.new(:patinfo, model, session , self)
	end
	def patinfo_upload(model, session=@session)
		if(model.company.invoiceable?)
			HtmlGrid::InputFile.new(:patinfo_upload, model, @session, self)
		else
			PointerLink.new(:e_company_not_invoiceable, model.company, @session, self)
		end
	end
end
class ResellerSequenceForm < SequenceForm
	include HtmlGrid::ErrorMessage
	include View::Admin::SequenceDisplay
	include View::AdditionalInformation
	DEFAULT_CLASS = HtmlGrid::Value
end
class SequenceComposite < HtmlGrid::Composite
  include SwissmedicSource
	#AGENTS = View::Admin::SequenceAgents
  COMPONENTS = {
    [0,0] => :sequence_name,
    [0,1] => View::Admin::SequenceInnerComposite,
    [0,2] => 'composition',
    [0,3] => :composition_text,
    [0,4] => 'active_agents',
    [0,5] => :compositions,
    [0,6] => :sequence_packages
  }
  CSS_CLASS = 'composite'
  CSS_MAP = {
    [0,0] => 'th',
    [0,2] => 'subheading',
    [0,3] => 'list',
    [0,4] => 'subheading',
  }
	PACKAGES = View::Admin::SequencePackages
  SYMBOL_MAP = {
    :composition_text => HtmlGrid::Value,
  }
  def init
    if div = @model.division and !div.empty?
      components.store [0,6], 'division'
      components.store [0,7], :division
      components.store [0,8], :sequence_packages
      css_map.store [0,6], 'subheading'
    end
    super
  end
  def compositions(model, session=@session)
    Compositions.new(model.compositions, @session, self)
  end
  def division(model, session)
    View::Drugs::DivisionComposite.new(model.division, session, self)
  end
	def sequence_name(model, session)
		[ 
			(model.company.name if model.company),
			model.name,
		].compact.join('&nbsp;-&nbsp;')
		#HtmlGrid::Value.new('name', model, session, self)
	end
	def sequence_packages(model, session)
		if(packages = model.packages)
			values = ODDB::PointerArray.new(packages.values, model.pointer)
			self::class::PACKAGES.new(values, session, self)
		end
	end
  def source(model, session=@session)
    val = HtmlGrid::Value.new(:source, model, @session, self)
    val.value = sequence_source(model) if model
    val
  end
end
class RootSequenceForm < HtmlGrid::Form
  include FormMethods
  TAG_METHOD = :multipart_form
  COMPONENTS = {
    [0,0] => View::Admin::SequenceForm,
    [0,1] => 'composition',
    [0,2] => :composition_text,
    [0,3] => 'active_agents',
    [0,4] => :compositions,
    [0,5] => 'division',
    [0,6] => :division,
  }
  CSS_MAP = {
    [0,1] => 'subheading',
    [0,3] => 'subheading',
    [0,5] => 'subheading',
  }
  SYMBOL_MAP = {
    :composition_text => HtmlGrid::Textarea,
  }
  COMPONENT_CSS_MAP = {
    [0,2] => 'huge',
  }
  def compositions(model, session=@session)
    RootCompositions.new(model.compositions, @session, self)
  end
  def division(model, session=@session)
    RootDivisionComposite.new(model.division, session, self)
  end
  def hidden_fields(context)
    super << context.hidden('patinfo', 'keep')
  end
end
class RootSequenceComposite < View::Admin::SequenceComposite
  COMPONENTS = {
    [0,0]	=>	:sequence_name,
    [0,1]	=>	RootSequenceForm,
    [0,2]	=>	:sequence_packages,
    [0,3]	=>	"th_source",
    [0,4]	=>	:source,
  }
  CSS_MAP = {
    [0,0]	=>	'th',
    [0,3]	=>	'subheading',
  }
  #DEFAULT_CLASS = HtmlGrid::Value
	PACKAGES = View::Admin::RootSequencePackages
end
class ResellerSequenceComposite < View::Admin::SequenceComposite
	COMPONENTS = {
		[0,0]	=>	:sequence_name,
		[0,1]	=>	View::Admin::ResellerSequenceForm,
		[0,2]	=>	'compositions',
		[0,3]	=>	:compositions,
		[0,4]	=>	:sequence_packages,
		[0,5]	=>	"th_source",
		[0,6]	=>	:source,
	}
	CSS_MAP = {
		[0,0]	=>	'th',
		[0,2]	=>	'subheading',
		[0,5]	=>	'subheading',
		[0,6]	=>	'list',
	}
	DEFAULT_CLASS = HtmlGrid::Value
	PACKAGES = View::Admin::RootSequencePackages
  def compositions(model, session=@session)
    RootCompositions.new(model.compositions, @session, self)
  end
end
class Sequence < View::Drugs::PrivateTemplate
	CONTENT = View::Admin::SequenceComposite
	SNAPBACK_EVENT = :result
end
class RootSequence < View::Admin::Sequence
	CONTENT = View::Admin::RootSequenceComposite
  JAVASCRIPTS = ['admin']
end
class ResellerSequence < View::Admin::Sequence
	CONTENT = View::Admin::ResellerSequenceComposite
  JAVASCRIPTS = ['admin']
end
		end
	end
end
