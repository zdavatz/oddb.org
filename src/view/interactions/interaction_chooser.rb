#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::InteractionChooser -- oddb.org -- 20.12.2012 -- yasaka@ywesee.com

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
    # see http://matrix.epha.ch/#/56751,61537,39053,59256
    Ratings = {  'A' => 'Keine Massnahmen erforderlich',
                  'B' => 'Vorsichtsmassnahmen empfohlen',
                  'C' => 'Regelmässige Überwachung',
                  'D' => 'Kombination vermeiden',
                  'X' => 'Kontraindiziert',
                }
    Colors =  {  'A' => 'white',
                  'B' => 'yellow',
                  'C' => 'orange',
                  'D' => 'red',
                  'X' => 'firebrick',
                }
    def self.calculate_atc_codes(drugs)
      atc_codes = []
      if drugs and !drugs.empty?
        drugs.each{ |ean, drug|
          atc_codes << drug.atc_class.code
        }
      end
      @@atc_codes = atc_codes
    end
    def self.atc_codes(session)
      @@atc_codes
    end
    def self.get_interactions(my_atc_code, session, atc_codes=@@atc_codes)
      results = []
      idx=atc_codes.index(my_atc_code)
      atc_codes[0..idx].combination(2).to_a.each {
        |combination|
        next unless combination.index(my_atc_code)
        [ session.app.get_epha_interaction(combination[0], combination[1]),
          session.app.get_epha_interaction(combination[1], combination[0]),       
        ].each{ 
                |interaction|
          next unless interaction
          header = ''
          header += interaction.atc_code_self  + ': ' + interaction.atc_name + ' => '
          header += interaction.atc_code_other + ': ' + interaction.name_other
          header += ' ' + interaction.info
          text = ''
          text += interaction.severity + ': ' + Ratings[interaction.severity]
          text += '<br>' + interaction.action
          text += '<br>' + interaction.measures + '<br>'
              
          results << { :header => header,
                      :severity => interaction.severity,
                    :color => Colors[interaction.severity],
                    :text => text
                    }
        }
      }
      results.uniq
    end    
class InteractionChooserDrugHeader < HtmlGrid::Composite
  include View::AdditionalInformation
  COMPONENTS = {
    [0,0] => :fachinfo,
    [1,0] => :drug,
    [2,0] => :delete,
    [3,0] => :atc_code,
  }
  CSS_MAP = {
    [0,0] => 'small',
    [1,0] => 'interaction-drug',
    [2,0] => 'small',
    [3,0] => 'interaction-atc',
  }
  def init
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
    div.set_attribute('class', 'interaction-drug')
    div.value = []
    if model
      div.value << model.name_with_size
      if price = model.price_public
        div.value << '&nbsp;-&nbsp;'
        div.value << price.to_s
      end
      unless model.substances.empty?
        div.value << '&nbsp;-&nbsp;'
        div.value << model.substances.join(',')
      end
      if company = model.company_name
        div.value << '&nbsp;-&nbsp;'
        div.value << company
      end
    end
    div
  end
  def atc_code(model, session=@session)
    div = HtmlGrid::Div.new(model, @session, self)
    div.set_attribute('class', 'interaction-atc')
    div.value = []
    div.value << model.atc_class.code  + ': ' + model.atc_class.name
    div
  end
  
  def delete(model, session=@session)
    if @container.is_a? ODDB::View::Interactions::InteractionChooserDrug
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
  COMPONENTS = {
    }
  CSS_MAP = {}
  CSS_CLASS = 'composite'
  def init
    @drugs = @session.persistent_user_input(:drugs)
    if @model.is_a? ODDB::Package
      components.store([0,0], :header_info)
      css_map.store([0,0], 'subheading')
      if @drugs and !@drugs.empty?
        components.store([0, 1], :text_info)
      end
      @attributes.store('id', 'drugs_' + @model.barcode)
    end
    super
  end
  def header_info(model, session=@session)
    View::Interactions::InteractionChooserDrugHeader.new(model, session, self)
  end
  def text_info(model, session=@session)
    div = HtmlGrid::Div.new(model, @session, self)
    # the first element cannot have an interaction
    return div if ODDB::View::Interactions.atc_codes(@session).index(model.atc_class.code) == 0
    div.set_attribute('class', 'interaction-info')
    div.value = []
    list = HtmlGrid::Div.new(model, @session, self)
    list.value = []
    ODDB::View::Interactions.get_interactions(model.atc_class.code, @session).each {
      |interaction|
      headerDiv = HtmlGrid::Div.new(model, @session, self)
      headerDiv.value = []
      headerDiv.value << interaction[:header]
      headerDiv.set_attribute('class', 'interaction-header')
      list.value << headerDiv
    
      infoDiv = HtmlGrid::Div.new(model, @session, self)
      infoDiv.value = []
      infoDiv.value << interaction[:text]
      infoDiv.set_attribute('style', "background-color: #{interaction[:color]}")
      list.value << infoDiv
                                                            
    }
    div.value << list
    div
  end  
end

class InteractionChooserDrugList < HtmlGrid::List
 attr_reader :model, :value
  COMPONENTS = {
    [0,0] =>  :info_drug,
  } 
  CSS_MAP = {
    [0,0] =>  'css.info',
  }
  CSS_CLASS = 'composite'
  SORT_HEADER = false
  def initialize(model, session=@session, arg_self=nil)    
    @drugs = session.persistent_user_input(:drugs)
    super # must come first or it will overwrite @value
    @value = []
    ODDB::View::Interactions.calculate_atc_codes(@drugs)
    if @drugs and !@drugs.empty?
      @drugs.each{ |ean, drug|
        @value << InteractionChooserDrug.new(drug, @session, self)
      }
    end
  end
  
end
class InteractionChooserDrugDiv < HtmlGrid::Div
  def init
    super
    @value = []
    @drugs = @session.persistent_user_input(:drugs)
    if @drugs and !@drugs.empty?
      @value << InteractionChooserDrugList.new(@drugs, @session, self)
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
    link = HtmlGrid::Link.new(:home_interaction, model, @session, self)
    link.css_class = "list"
    link.href  = @lookandfeel._event_url(:home_interaction, [])
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
