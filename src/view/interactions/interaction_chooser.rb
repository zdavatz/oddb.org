#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::InteractionChooser -- oddb.org -- 20.12.2012 -- yasaka@ywesee.com

require 'csv'
require 'cgi'
require 'htmlentities'
require 'htmlgrid/infomessage'
require 'view/drugs/privatetemplate'
require 'view/drugs/centeredsearchform'
require 'view/additional_information'
require 'view/searchbar'
require 'view/printtemplate'
require 'view/publictemplate'
require 'view/form'
require 'view/chapter'
# Test it with de/gcc/home_interactions/7680317061142,7680353520153,7680546420673,7680193950301,7680517950680

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
    # using the same color like https://raw.githubusercontent.com/zdavatz/AmiKo-Windows/master/css/interactions_css.css
    Colors =  {  'A' => '#caff70',
                 'B' => '#ffec8b',
                 'C' => '#ffb90f',
                 'D' => '#ff82ab',
                 'X' => '#ff6a6a',
                 }
  def self.calculate_atc_codes(drugs)
      atc_codes = []
      ean13s    = []
      if drugs and !drugs.empty?
        drugs.each{ |ean, drug|
          atc_codes << drug.atc_class.code if drug and drug.atc_class
          ean13s << ean
        }
      end
      @@ean13s    = ean13s
      @@atc_codes = atc_codes
    end
    def self.atc_codes(session)
      @@atc_codes
    end
    def self.get_interactions(my_atc_code, session, atc_codes=@@atc_codes)
      results = []
      idx=atc_codes.index(my_atc_code)
      atc_codes[0..-1].combination(2).to_a.each {
        |combination|
        [ session.app.get_epha_interaction(combination[0], combination[1]),
          session.app.get_epha_interaction(combination[1], combination[0]),
        ].each{ 
                |interaction|
          next unless interaction
          next unless interaction.atc_code_self.eql?(my_atc_code)
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
      results.uniq.sort_by { |item| item[:severity] + item[:header]  }.reverse
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
    div.value << model.atc_class.code  + ': ' + model.atc_class.name if model.atc_class
    div
  end
  
  def delete(model, session=@session)
    if @container.is_a? ODDB::View::Interactions::InteractionChooserDrug
      link = HtmlGrid::Link.new(:minus, model, session, self)
      link.set_attribute('title', @lookandfeel.lookup(:delete))
      link.css_class = 'delete square'
      if model
        args = [:ean, model.barcode] if model
        url = @session.request_path.sub(model.barcode.to_s, '').sub('/,', '/').sub(/,$/, '')
        if @session.persistent_user_input(:drugs).size == 0
          ODDB::View::Interactions.calculate_atc_codes({})
        end
        link.onclick = %(
        console.log ("Going to new url #{url} in interaction_chooser");
        window.location.href = '#{url}';
        )
        link
      end
    end
  end
end

class InteractionChooserDrug < HtmlGrid::Composite
  COMPONENTS = {}
  CSS_MAP = {}
  CSS_CLASS = 'composite'
  def init
    # When being called from rezept we should not display the heading
    @hide_interaction_headers = @session.request_path.match(/rezept/) != nil
    ean13 = @session.user_input(:search_query)
    path = @session.request_path
    @drugs = @session.persistent_user_input(:drugs)
    if @model.is_a? ODDB::Package
      nextRow = 0
      unless @hide_interaction_headers
        components.store([0,0], :header_info)
        css_map.store([0,0], 'subheading')
        nextRow += 1
      end
      if @drugs and !@drugs.empty?
        components.store([0, nextRow], :text_info)
      end
      @attributes.store('id', 'drugs_' + @model.barcode)
    end
    self.onsubmit = <<-JS
function get_to(url) {
  var form = document.createElement("form");
  form.setAttribute("method", "GET");
  form.setAttribute("action", url);
  document.body.appendChild(form);
  form.submit();
}
var url = searchbar.baseURI + 'home_interactions/' + ean13;
window.location = url;
// console.log('InteractionChooserDrug: get_to: ' + url);
get_to(url);
return false;
    JS
    super
  end
  def header_info(model, session=@session)
    View::Interactions::InteractionChooserDrugHeader.new(model, session, self)
  end
  def text_info(model, session=@session)
    return nil unless model.atc_class
    list = HtmlGrid::Div.new(model, @session, self)
    list.value = []
    ODDB::View::Interactions.get_interactions(model.atc_class.code, @session).each {
      |interaction|
      headerDiv = HtmlGrid::Div.new(model, @session, self)
      headerDiv.value = []
      headerDiv.value << interaction[:header]
      headerDiv.set_attribute('class', 'interaction-header')
      headerDiv.set_attribute('style', "background-color: #{interaction[:color]}")
      list.value << headerDiv
    
      infoDiv = HtmlGrid::Div.new(model, @session, self)
      infoDiv.value = []
      infoDiv.value << interaction[:text]
      infoDiv.set_attribute('style', "background-color: #{interaction[:color]}")
      list.value << infoDiv                                                            
    }
    list
  end  
end

class InteractionChooserDrugList < HtmlGrid::List
 attr_reader :model, :value
  COMPONENTS = {} 
  CSS_MAP = {}
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

class ExplainInteractionCodes < HtmlGrid::List
  COMPONENTS = {
    [0,0] =>  :interaction_codes,
    }
  CSS_MAP = {
    [0,0] =>  'composite',
  }
  CSS_CLASS = 'composite'
  LEGACY_INTERFACE = false
  DEFAULT_HEAD_CLASS = 'none'
  OMIT_HEADER = true
  def init
    @entity = @model
    @model = Ratings.keys
    super
    self.set_attribute('id', 'interaction_codes')
    self.set_attribute('style', 'display: none;')
  end

  def interaction_codes(model)
    txt = HtmlGrid::Div.new(model, @session, self)
    txt.value =  model + ': ' + Ratings[model]
    txt.set_attribute('style', "background-color: #{Colors[model]};")
    txt
  end

end
class InteractionLegend < HtmlGrid::Composite
  COMPONENTS = {
    [0,0] => :toogle_switch,
    [0,1] => View::Interactions::ExplainInteractionCodes,
  }
  CSS_MAP = {
    [0,0] => 'explain right',
    [0,1] => 'explain left',
  }
  COLSPAN_MAP = {
    [0,0] => 12,
    [0,1] => 12,
  }
  CSS_CLASS = 'composite'
  private
  def init
    super
  end

  def toogle_switch(model, session=@session)
    span = HtmlGrid::Span.new(model, @session, self)
    span.value = @lookandfeel.lookup(:show_legend)
    span.css_class = 'link'
    span.set_attribute('id', 'toggle_switch')
    span.onclick = <<JS
(function () {
  var span    = document.getElementById('toggle_switch');
  var legends = document.getElementById('interaction_codes');
  var applyStyle = 'none';
  if (span.innerHTML != '#{@lookandfeel.lookup(:show_legend)}') {
    span.innerHTML        = '#{@lookandfeel.lookup(:show_legend)}';
  } else {
    applyStyle = 'block';
    span.innerHTML        = '#{@lookandfeel.lookup(:hide_legend)}';
  }
  if (legends != null) legends.style.display = applyStyle;
  })();
JS
    span
  end
end
class InteractionChooserForm < View::Form
  include HtmlGrid::InfoMessage
  COMPONENTS = {
    [0,0,0] => :interaction_chooser_description,
    [0,0,1] => :epha_public_domain,
    [0,1]   => View::Interactions::InteractionChooserDrugDiv,
    [0,2]   => View::Interactions::InteractionChooserInnerForm,
    [0,3]   => :delete_all,
  }
  CSS_MAP = {
    [0,0] => 'th bold',
    [0,1] => '', # none
    [0,2] => 'inner-button',
    [0,3] => 'inner-button',
    }
  CSS_CLASS = 'composite'
  DEFAULT_CLASS = HtmlGrid::Value
  LABELS = true
  private
  def init
    super
    self.onload = %(require(["dojo/domReady!"], function(){
     if (document.getElementById('interaction_searchbar') != null) document.getElementById('interaction_searchbar').focus();
});
)
    @form_properties.update({
      'id'     => 'interaction_chooser_form',
      'target' => '_blank',
    })
  end
  def epha_public_domain(model, session=@session)
    link = HtmlGrid::Link.new(:epha_public_domain, model, session, self)
    link.css_class = 'navigation'		
    link.href = "https://github.com/epha/matrix"
    link
  end
  def delete_all(model, session=@session)
    @drugs = @session.persistent_user_input(:drugs)
    if @drugs and !@drugs.empty?
      delete_all_link = HtmlGrid::Link.new(:delete, @model, @session, self)
      delete_all_link.href  = @lookandfeel._event_url(:delete_all, [])
      delete_all_link.value = @lookandfeel.lookup(:interaction_chooser_delete_all)
      delete_all_link.css_class = 'list'
    else
      return nil
    end
    delete_all_link
  end
end
class InteractionChooserComposite < HtmlGrid::Composite
  include AdditionalInformation
  COMPONENTS = {
    [0,0] => View::Interactions::InteractionChooserForm,
    [0,1] => View::Interactions::InteractionLegend,
    }
  COMPONENT_CSS_MAP = {
    [0,0] => 'composite',
    [0,1] => 'composite',
  }
  COLSPAN_MAP = {
    [0,0] => 12,
    [0,1] => 12,
    }
  CSS_CLASS = 'composite'
end
class InteractionChooser < View::PrivateTemplate
  CONTENT = View::Interactions::InteractionChooserComposite
  SNAPBACK_EVENT = :home
  JAVASCRIPTS = ['admin']
  SEARCH_HEAD = 'nbsp'
  def init
    super
  end
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
