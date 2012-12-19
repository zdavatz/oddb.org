#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::InteractionChooser -- oddb.org -- 19.12.2012 -- yasaka@ywesee.com

require 'csv'
require 'cgi'
require 'htmlentities'
require 'view/drugs/privatetemplate'
require 'view/drugs/centeredsearchform'
require 'view/additional_information'
require 'view/searchbar'
require 'view/printtemplate'
require 'view/publictemplate'
require 'view/form'
require 'view/chapter'

module ODDB
  module View
    module Interactions
class InteractionChooserDrugHeader < HtmlGrid::Composite
  include View::AdditionalInformation
  COMPONENTS = {
    [0,0] => :fachinfo,
    [1,0] => :drug,
    [2,0] => :delete,
  }
  CSS_MAP = {
    [0,0] => 'small',
    [1,0] => 'list',
    [2,0] => 'small',
  }
  def init
    @drugs = @session.persistent_user_input(:drugs)
    @index = (@drugs ? @drugs.length : 0).to_s
    super
  end
  def fachinfo(model, session=@session)
    if fi = super(model, session, 'square bold infos')
      fi.set_attribute('target', '_blank')
      fi
    end
  end
  def drug(model, session=@session)
    div = HtmlGrid::Div.new(model, @session, self)
    div.set_attribute('class', 'drug')
    div.value = []
    if model
      div.value << model.name_with_size
      if price = model.price_public
        div.value << '&nbsp;-&nbsp;'
        div.value << price.to_s
      end
      if company = model.company_name
        div.value << '&nbsp;-&nbsp;'
        div.value << company
      end
    end
    div
  end
  def delete(model, session=@session)
    if @container.is_a? InteractionChooserDrug and # hide at search result
       (@drugs and @drugs.length >= 1)
      link = HtmlGrid::Link.new(:minus, model, session, self)
      link.set_attribute('title', @lookandfeel.lookup(:delete))
      link.css_class = 'delete square'
      args = [:ean, model.barcode] if model
      url = @session.lookandfeel.event_url(:ajax_delete_drug, args)
      link.onclick = "replace_element('drugs_#{model.barcode}', '#{url}');"
      link
    end
  end
end
class InteractionChooserDrug < HtmlGrid::Composite
  COMPONENTS = {}
  CSS_MAP = {}
  CSS_CLASS = 'composite'
  def init
    if @model.is_a? ODDB::Package
      components.store([0,0], :drug)
      css_map.store([0,0], 'subheading')
      @attributes.store('id', 'drugs_' + @model.barcode)
    end
    super
  end
  def drug(model, session)
    View::Interactions::InteractionChooserDrugHeader.new(model, session, self)
  end
end
class InteractionChooserDrugDiv < HtmlGrid::Div
  def init
    super
    @value = []
    @drugs = @session.persistent_user_input(:drugs)
    if @drugs and !@drugs.empty?
      @drugs.values.each do |pac|
        @value << InteractionChooserDrug.new(pac, @session, self)
      end
    end
  end
  def to_html(context)
    div = HtmlGrid::Div.new(@model, @session, self)
    if @drugs and !@drugs.empty?
      delete_all_link = HtmlGrid::Link.new(:delete, @model, @session, self)
      delete_all_link.href  = @lookandfeel._event_url(:delete_all, [])
      delete_all_link.value = @lookandfeel.lookup(:interaction_chooser_delete_all)
      delete_all_link.css_class = 'list'
      div.value = delete_all_link
    end
    div.set_attribute('id', 'drugs')
    @value << div
    super
  end
end
class InteractionChooserInnerForm < HtmlGrid::Composite
  attr_reader :index_name
  FORM_METHOD = 'POST'
  COMPONENTS = {
    [0,0] => :searchbar,
  }
  SYMBOL_MAP = {
    :searchbar => View::InteractionChooserBar,
  }
  CSS_MAP = {
    [0,0] => 'searchbar',
  }
  COLSPAN_MAP = {
    [0,0] => 2,
  }
  def init
    super
    @index_name = 'oddb_package_name_with_size_company_name_ean13_fi'
    @additional_javascripts = []
  end
  def javascripts(context)
    scripts = ''
    @additional_javascripts.each do |script|
      args = {
        'type'     => 'text/javascript',
        'language' => 'JavaScript',
      }
      scripts << context.script(args) do script end
    end
    scripts
  end
  def to_html(context)
    javascripts(context).to_s << super
  end
end
class InteractionChooserForm < View::Form
  include HtmlGrid::InfoMessage
  COMPONENTS = {
    [0,0]   => 'interaction_chooser_description',
    [0,1]   => View::Interactions::InteractionChooserDrugDiv,
    [0,2]   => View::Interactions::InteractionChooserInnerForm,
    [0,4]   => :buttons,
  }
  CSS_MAP = {
    [0,0] => 'th bold',
    [0,1] => '', # none
    [0,2] => 'list',
    [0,4] => 'inner-button',
  }
  CSS_CLASS = 'composite'
  DEFAULT_CLASS = HtmlGrid::Value
  LABELS = true
  def buttons(model, session)
    post_event_button(:show_interaction)
  end
  private
  def init
    super
    self.onload = "document.getElementById('interaction_searchbar').focus();"
    @form_properties.update({
      'id'     => 'interaction_chooser_form',
      'target' => '_blank',
    })
  end
end
class InteractionChooserComposite < HtmlGrid::Composite
  include AdditionalInformation
  COMPONENTS = {
    [0,0] => View::Interactions::InteractionChooserForm,
  }
  COMPONENT_CSS_MAP = {
    [0,0] => 'composite',
  }
  COLSPAN_MAP = {
    [0,0] => 12,
  }
  CSS_CLASS = 'composite'
end
class InteractionChooser < View::PrivateTemplate
  CONTENT = View::Interactions::InteractionChooserComposite
  SNAPBACK_EVENT = :home
  JAVASCRIPTS = ['admin']
  SEARCH_HEAD = 'nbsp'
  def backtracking(model, session=@session)
    fields = []
    fields << @lookandfeel.lookup(:th_pointer_descr)
    link = HtmlGrid::Link.new(:home_interactions, model, @session, self)
    link.css_class = "list"
    link.href  = @lookandfeel._event_url(:home_interactions, [])
    link.value = @lookandfeel.lookup(:home)
    fields << link
    fields << '&nbsp;-&nbsp;'
    span = HtmlGrid::Span.new(model, session, self)
    span.value = @lookandfeel.lookup(:interaction_chooser)
    span.set_attribute('class', 'bold')
    fields << span
    fields
  end
end
    end
  end
end
