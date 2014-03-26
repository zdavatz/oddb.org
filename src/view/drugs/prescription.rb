#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::Prescription -- oddb.org -- 28.08.2012 -- yasaka@ywesee.com

require 'csv'
require 'cgi'
require 'htmlentities'
require 'htmlgrid/errormessage'
require 'htmlgrid/infomessage'
require 'htmlgrid/select'
require 'htmlgrid/textarea'
require 'htmlgrid/inputtext'
require 'htmlgrid/inputcheckbox'
require 'htmlgrid/inputradio'
require 'htmlgrid/component'
require 'view/drugs/privatetemplate'
require 'view/drugs/centeredsearchform'
require 'view/interactions/interaction_chooser'
require 'view/additional_information'
require 'view/searchbar'
require 'view/printtemplate'
require 'view/publictemplate'
require 'view/form'

module ODDB
  module View
    module Drugs
class PrescriptionInteractionDrugDiv < HtmlGrid::Div
  def init
    super
    @value = []
    @drugs = @session.persistent_user_input(:drugs)
    if @drugs and !@drugs.empty?
      @value << View::Interactions::InteractionChooserDrug.new(@model, @session, self)
    end
  end
end

class PrescriptionDrugInnerForm < HtmlGrid::Composite
  COMPONENTS = {
    [0,0] => :interactions,
    [0,1] => 'prescription_quantity_morning',
    [1,1] => :prescription_quantity_morning,
    [2,1] => 'prescription_quantity_noon',
    [3,1] => :prescription_quantity_noon,
    [4,1] => 'prescription_quantity_evening',
    [5,1] => :prescription_quantity_evening,
    [6,1] => 'prescription_quantity_night',
    [7,1] => :prescription_quantity_night,
    [8,1] => '&nbsp;&nbsp;',
    [9,1] => :prescription_method_fields,
    [0,1] => :prescription_timing_fields,
    [3,1] => :prescription_term_fields,
    [9,1] => :prescription_comment,
    [0,4] => :atc_code,
  }
  CSS_MAP = {
    [0,0] => 'div',
    [0,1] => 'list bold',
    [1,1] => 'list',
    [2,1] => 'list bold',
    [3,1] => 'list',
    [4,1] => 'list bold',
    [5,1] => 'list',
    [6,1] => 'list bold',
    [7,1] => 'list',
    [9,1] => 'list',
    [0,1] => 'list top',
    [3,1] => 'list top',
    [9,1] => 'list top',
  }
  COMPONENT_CSS_MAP = {
    [9,1] => 'wide',
  }
  COLSPAN_MAP = {
    [0,0] => 14,
    [9,1] => 2,
    [0,1] => 3,
    [3,1] => 5,
    [9,1] => 5,
  }
  LABELS = false
  def init
    @drugs = @session.persistent_user_input(:drugs)
    @index = (@drugs ? @drugs.length : 0).to_s
    super
    @grid.add_attribute('rowspan', 2, *[0,1])
    @grid.add_attribute('rowspan', 2, *[3,1])
    @grid.add_attribute('rowspan', 2, *[9,1])
  end
  def self.define_quantity_method(key)
    name = "prescription_quantity_#{key}"
    define_method(name) do |model, session|
      input = HtmlGrid::InputText.new(name + "[#{@index}]", model, session, self)
      input.set_attribute('size', 3)
      input.set_attribute('onFocus', "if (this.value == '0') { value = '' };")
      input.set_attribute('onBlur',  "if (this.value == '') { value = '0' };")
      input.label = false
      input.value = '0'
      input
    end
  end
  %w[morning noon evening night].each do |key|
    define_quantity_method(key)
  end
  def prescription_timing_fields(model, session)
    fields = []
    attrs = {
      'checked' => true,
      'id'      => 'prescription_timing_before_meal'
    }
    fields << radio_for(:prescription_timing, 1, attrs)
    fields << '&nbsp;'
    fields << label_for(:prescription_timing_before_meal)
    fields << '<br/>'
    attrs = {
      'id' => 'prescription_timing_with_meal'
    }
    fields << radio_for(:prescription_timing, 2, attrs)
    fields << '&nbsp;'
    fields << label_for(:prescription_timing_with_meal)
    fields << '<br/>'
    attrs = {
      'id' => 'prescription_timing_after_meal'
    }
    fields << radio_for(:prescription_timing, 3, attrs)
    fields << '&nbsp;'
    fields << label_for(:prescription_timing_after_meal)
    fields
  end
  def prescription_method_fields(model, session)
    fields = []
    fields << checkbox_for(:prescription_method_as_necessary)
    fields << '&nbsp;'
    fields << label_for(:prescription_method_as_necessary)
    fields << '&nbsp;&nbsp;'
    fields << checkbox_for(:prescription_method_regulaly)
    fields << '&nbsp;'
    fields << label_for(:prescription_method_regulaly)
    fields
  end
  def prescription_term_fields(model, session)
    fields = []
    js = <<-JS
var month      = document.getElementById('per_month_#{@index}')
var repetition = document.getElementById('repetition_#{@index}')
month.value    = '1';
month.disabled = true;
repetition.value    = '1';
repetition.disabled = true;
    JS
    attrs = {
      'checked' => true,
      'onClick' => js,
      'id'      => 'prescription_term_once',
    }
    fields << radio_for(:prescription_term, 1, attrs)
    fields << '&nbsp;'
    fields << label_for(:prescription_term_once)
    fields << '<br/>'
    js = <<-JS
var month      = document.getElementById('per_month_#{@index}')
var repetition = document.getElementById('repetition_#{@index}')
month.value    = '1';
month.disabled = true;
repetition.disabled = false;
    JS
    attrs = {
      'onClick' => js,
      'id'      => 'prescription_term_repetition'
    }
    fields << radio_for(:prescription_term, 2, attrs)
    fields << '&nbsp;'
    fields << label_for(:prescription_term_repetition)
    fields << '&nbsp;'
    attrs = {
      'disabled' => 'disabled',
      'id'       => 'repetition'
    }
    fields << select_for(:prescription_repetition, (1..12).to_a, attrs)
    fields << '<br/>'
    js = <<-JS
var month      = document.getElementById('per_month_#{@index}')
var repetition = document.getElementById('repetition_#{@index}')
month.disabled = false;
repetition.value    = '1';
repetition.disabled = true;
    JS
    attrs = {
      'onClick' => js,
      'id'      => 'prescription_term_per_month'
    }
    fields << radio_for(:prescription_term, 3, attrs)
    fields << '&nbsp;'
    fields << label_for(:prescription_term_per_month)
    fields << '&nbsp;'
    attrs = {
      'disabled' => 'disabled',
      'id'       => 'per_month'
    }
    fields << select_for(:prescription_per_month, (1..12).to_a, attrs)
    fields
  end
  def prescription_comment(model, session)
   name = "prescription_comment[#{@index}]".intern
   textarea = HtmlGrid::Textarea.new(name, model, @session, self)
   value = @lookandfeel.lookup(:prescription_comment)
   textarea.set_attribute('onFocus', "if (this.value == '#{value}') { value = '' };")
   textarea.set_attribute('onBlur',  "if (this.value == '') { value = '#{value}' };")
   textarea.value = value
   textarea
  end
  def atc_code(model,session)
    # this is needed by js for external link to modules.epha.ch
    hidden = HtmlGrid::Input.new(:atc_code, model, session, self)
    hidden.set_attribute('type', 'hidden')
    if model and model.atc_class and code = model.atc_class.code
      hidden.value = code
    end
    hidden
  end
  private
  # handle index
  def label_for(key)
    text = HtmlGrid::LabelText.new(key, @model, @session, self)
    label = HtmlGrid::Label.new(text, @session)
    name = (key.to_s + '_' + @index)
    label.instance_eval{ @attributes['for'] = name } # overwrite for
    label
  end
  def checkbox_for(key, attrs={}) # no hidden
    name = (key.to_s + "[#{@index}]")
    checkbox = HtmlGrid::InputCheckbox.new(name, @model, @session, self)
    checkbox.set_attribute('id', key.to_s + '_' + @index)
    attrs.each_pair do |attr_key, attr_value|
      checkbox.set_attribute(attr_key, attr_value)
    end
    checkbox
  end
  def radio_for(key, value=0, attrs={})
    name  = (key.to_s + "[#{@index}]").intern
    radio = HtmlGrid::InputRadio.new(name, @model, @session, self)
    radio.value = value.to_s
    attrs.each_pair do |attr_key, attr_value|
      if attr_key == 'id'
        attr_value = (attr_value + '_' + @index)
      end
      radio.set_attribute(attr_key.to_s, attr_value)
    end
    radio
  end
  def select_for(key, values, attrs={})
    name  = (key.to_s + "[#{@index}]").intern
    select = HtmlGrid::Select.new(name, @model, @session, self)
    select.valid_values = values
    attrs.each_pair do |attr_key, attr_value|
      if attr_key == 'id'
        attr_value = (attr_value + '_' + @index)
      end
      select.set_attribute(attr_key.to_s, attr_value)
    end
    select
  end
  def interactions(model, session)
    View::Drugs::PrescriptionInteractionDrugDiv.new(model, session, self)
  end
end
class PrescriptionDrugHeader < HtmlGrid::Composite
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
    if @model and @model.barcode and @model.barcode.length == 13
      @index = @drugs.keys.index(@model.barcode)
    else
      @index = 0
    end
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
    if (@drugs and @drugs.length >= 1) #and model.barcode != drugs.first.barcode)
      link = HtmlGrid::Link.new(:minus, model, session, self)
      link.set_attribute('title', @lookandfeel.lookup(:delete))
      link.css_class = 'delete square'
      args = [:ean, model.barcode] if model
      url = @session.request_path.sub(/(,|)#{model.barcode.to_s}/, '')
      link.onclick = %(
      console.log ("Going to new url #{url} in prescription");
      window.top.location.replace('#{url}');
      )
      link
    end
  end
end
class PrescriptionDrugMoreArea < HtmlGrid::Div # replace target
  def init
    super
    if @model
      div = HtmlGrid::Div.new(@model, @session, self)
      div.set_attribute('id', 'drugs')
      @value = div
    end
  end
end
class PrescriptionDrug < HtmlGrid::Composite
  COMPONENTS = {
    [0,0] => :drug,
    [0,1] => :inner_form,
  }
  CSS_MAP = {
    [0,0] => 'subheading',
    [0,1] => 'list',
  }
  CSS_CLASS = 'composite'
  def init
    @drugs = @session.persistent_user_input(:drugs)
    index = -1
    if @model and @drugs and !@drugs.empty?
      index = @drugs.keys.index(@model.barcode)
    end
    if @drugs and !@drugs.empty?
      @model = @drugs.values[index]
    end
    @attributes.store('id', 'drugs_' + @model.barcode) if @attributes and @model
    super
  end
  def drug(model, session)
    View::Drugs::PrescriptionDrugHeader.new(model, session, self)
  end
  def inner_form(model, session)
    View::Drugs::PrescriptionDrugInnerForm.new(model, session, self)
  end
end
class PrescriptionDrugDiv < HtmlGrid::Div
  def init
    @drugs = @session.persistent_user_input(:drugs)
    super # must come first or it will overwrite @value
    @value = []
    ODDB::View::Interactions.calculate_atc_codes(@drugs)
    if @drugs and !@drugs.empty?
      @drugs.each{ |ean, drug|
        @value << PrescriptionDrug.new(drug, @session, self)
      }
    end
# was    super
# was    @value = PrescriptionDrug.new(@model, @session, self)
  end
  def to_html(context)
    html = super
    html << View::Drugs::PrescriptionDrugMoreArea.new(@model, @session, self).to_html(context)
    html
  end
end
class PrescriptionDrugSearchForm < HtmlGrid::Composite # see View::Drugs::CenteredComperSearchForm
  attr_reader :index_name
  EVENT = :compare
  FORM_METHOD = 'POST'
  COMPONENTS = {
    [0,0] => :searchbar,
  }
  SYMBOL_MAP = {
    :searchbar => View::PrescriptionDrugSearchBar,
  }
  CSS_MAP = {
    [0,0] => 'searchbar',
  }
  def init
    super
    self.onload = %(require(["dojo/domReady!"], function(){
  document.getElementById('searchbar').focus();
});
)
    @index_name = 'oddb_package_name_with_size_company_name_and_ean13'
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
class PrescriptionForm < View::Form
  include HtmlGrid::InfoMessage
  COMPONENTS = {
    [0,0]  => :prescription_for,
    [0,1]  => View::Drugs::PrescriptionDrugDiv,
    [0,2]  => View::Drugs::PrescriptionDrugSearchForm,
    [0,3]  => 'prescription_signature',
    [0,13] => :buttons,
    [0,14] => 'prescription_notes',
  }
  CSS_MAP = {
    [0,0]  => 'th bold',
    [0,1]  => '', # none
    [0,2]  => 'list',
    [0,3]  => 'list bold',
    [0,13] => 'button',
    [0,14] => 'list bold',
  }
  COLSPAN_MAP = {
    [0,0]  => 3,
    [0,1]  => 3,
    [0,2]  => 3,
    [0,3]  => 3,
    [0,13] => 3,
    [0,14] => 3,
  }
  CSS_CLASS = 'composite'
  DEFAULT_CLASS = HtmlGrid::Value
  LABELS = true
  def prescription_for(model, session)
    fields = []
    fields << @lookandfeel.lookup(:prescription_for)
    fields << '&nbsp;&nbsp;&nbsp;'
    %w[first_name family_name birth_day].each do |attr|
      key = "prescription_#{attr}".to_sym
      fields << @lookandfeel.lookup(key)
      fields << '&nbsp;'
      input = HtmlGrid::InputText.new(key, model, session, self)
      input.set_attribute('size', 13)
      input.label = false
      fields << input
      fields << '&nbsp;&nbsp;'
    end
    fields << @lookandfeel.lookup(:prescription_sex)
    fields << '&nbsp;'
    radio = HtmlGrid::InputRadio.new(:prescription_sex, model, session, self)
    radio.value = '1'
    radio.set_attribute('checked', true)
    fields << radio
    fields << '&nbsp;'
    fields << @lookandfeel.lookup(:prescription_sex_w)
    fields << '&nbsp;'
    radio = HtmlGrid::InputRadio.new(:prescription_sex, model, session, self)
    radio.value = '2'
    fields << radio
    fields << '&nbsp;'
    fields << @lookandfeel.lookup(:prescription_sex_m)
    fields
  end
  def hidden_fields(context)
    hidden = super
    # main drug
    hidden << context.hidden('ean', @model.barcode) if @model
    hidden << context.hidden('prescription', true)
    hidden
  end
  def buttons(model, session)
    buttons = []
    buttons << post_event_button(:print)
    buttons << '&nbsp;'
    buttons << post_event_button(:export_csv)
    buttons << '&nbsp;'
    buttons
  end
  private
  def init
    super
    @form_properties.update({
      'id'     => 'prescription_form',
      'target' => '_blank'
    })
  end
end
class PrescriptionComposite < HtmlGrid::Composite
  include AdditionalInformation
  COMPONENTS = {
    [0,0] => View::Drugs::PrescriptionForm,
  }
  COMPONENT_CSS_MAP = {
    [0,0] => 'composite',
  }
  COLSPAN_MAP = {
    [0,0] => 12,
  }
  CSS_CLASS = 'composite'
  DEFAULT_CLASS = HtmlGrid::Value
end
class PrescriptionPrintInnerComposite < HtmlGrid::Composite
  COMPONENTS = {
    [0,1] => :name,
    [0,2] => :quantity_value,
    [0,3] => :timing_value,
    [0,4] => :method_value,
    [0,5] => :term_value,
    [0,7] => 'prescription_comment',
    [0,9] => :comment_value,
  }
  CSS_MAP = {
    [0,1] => 'print bold',
    [0,2] => 'print',
    [0,3] => 'print',
    [0,4] => 'print top',
    [0,5] => 'print',
    [0,7] => 'print bold',
    [0,9] => 'print',
  }
  COLSPAN_MAP = {
    [0,1] => 5,
    [0,2] => 5,
    [0,3] => 5,
    [0,4] => 5,
    [0,5] => 5,
    [0,7] => 5,
    [0,9] => 5,
  }
  CSS_CLASS = 'compose'
  DEFAULT_CLASS = HtmlGrid::Value
  def init
    @drugs = @session.persistent_user_input(:drugs) || {}
    if !@drugs.empty? and @model and index = @drugs.keys.index(@model.barcode)
      index += 1 # main model
    else
      index = 0
    end
    @index = index.to_s
    super
  end
  def name(model, session=@session)
    span = HtmlGrid::Span.new(model, session, self)
    span.value = ''
    span.value << model.name_with_size
    if price = model.price_public
      span.value << '&nbsp;-&nbsp;'
      span.value << price.to_s
    end
    if company = model.company_name
      span.value << '&nbsp;-&nbsp;'
      span.value << company
    end
    span.set_attribute('class', 'bold')
    span
  end
  def quantity_value(model, session=@session)
    fields = []
    [:morning, :noon, :evening, :night].each do |at_time|
      key = "prescription_quantity_#{at_time.to_s}".to_sym
      if quantities = session.user_input(key) and quantity = quantities[@index] and
         quantity =~ /^[0-9]+$/ and !quantity.to_i.zero?
        fields << '<br/>' if fields.empty?
        fields << HtmlGrid::LabelText.new(key, model, session, self)
        text = HtmlGrid::Value.new(:prescription_quantity, model, session, self)
        text.value = quantity
        fields << '&nbsp;'
        fields << text
        fields << '<br/>'
      end
    end
    fields << '<br/>' unless fields.empty?
    fields
  end
  def timing_value(model, session=@session)
    timings = session.user_input(:prescription_timing)
    name = case timings[@index]
    when '1'; :prescription_timing_before_meal;
    when '2'; :prescription_timing_with_meal;
    when '3'; :prescription_timing_after_meal;
    end
    if name
      text = HtmlGrid::Value.new(name, model, session, self)
      text.value = @lookandfeel.lookup(name)
      text
    end
  end
  def method_value(model, session=@session)
    fields = []
    [:as_necessary, :regulaly].each do |method|
      key = "prescription_method_#{method.to_s}".to_sym
      if methods = session.user_input(key) and name = methods[@index]
        text = HtmlGrid::Value.new(name, model, session, self)
        text.value = @lookandfeel.lookup(key)
        fields << '<br/>' if fields.empty?
        fields << text
        fields << '<br/>'
      end
    end
    fields << '<br/>' unless fields.empty?
    fields
  end
  def term_value(model, session=@session)
    fields = []
    terms = session.user_input(:prescription_term)
    name = case terms[@index]
    when '1'; :prescription_term_once;
    when '2'; :prescription_term_repetition;
    when '3'; :prescription_term_per_month;
    end
    if name
      text = HtmlGrid::Value.new(name, model, session, self)
      text.value = @lookandfeel.lookup(name)
      fields << text
      if name.to_s =~ /repetition/ and repetitions = @session.user_input(:prescription_repetition) and
         repetition = repetitions[@index]
        text = HtmlGrid::Value.new(:prescription_repetition, model, session, self)
        text.value = repetition
        fields << '&nbsp;'
        fields << text
      elsif name.to_s =~ /month/ and months = @session.user_input(:prescription_per_month) and
            month = months[@index]
        text = HtmlGrid::Value.new(:prescription_per_month, model, session, self)
        text.value = month
        fields << '&nbsp;'
        fields << text
      end
      fields
    end
  end
  def comment_value(model, session=@session)
    if texts = session.user_input(:prescription_comment) and
       comment_text = texts[@index]
      text = HtmlGrid::Value.new(:prescription_comment, model, session, self)
      text.value = comment_text
      text
    end
  end
end
class PrescriptionPrintComposite < HtmlGrid::DivComposite
  include PrintComposite
  include View::AdditionalInformation
  INNER_COMPOSITE = View::Drugs::PrescriptionPrintInnerComposite
  PRINT_TYPE = ""
  COMPONENTS = {
    [0,0] => :print_type,
    [0,1] => '&nbsp;',
    [0,2] => :prescription_for,
    [0,3] => '&nbsp;',
    [0,4] => :prescription_title,
    [0,5] => :document,
    [0,6] => '&nbsp;',
    [0,7] => 'prescription_signature',
  }
  CSS_MAP = {
    0 => 'print-type',
    1 => 'print',
    2 => 'print',
    3 => 'print',
    4 => 'print',
    5 => 'print',
    7 => 'print bold',
  }
  def init
    @drugs = @session.persistent_user_input(:drugs)
    super
  end
  def prescription_for(model, session=@session)
    fields = []
    fields << HtmlGrid::LabelText.new(:prescription_for, model, session, self)
    %w[first_name family_name birth_day].each do |attr|
      key = "prescription_#{attr}".to_sym
      span = HtmlGrid::Span.new(model, session, self)
      span.set_attribute('class', 'bold')
      span.value = @session.user_input(key)
      fields << span
      fields << '&nbsp;'
    end
    span = HtmlGrid::Span.new(model, session, self)
    type = (@session.user_input(:prescription_sex) == '1' ? 'w' : 'm')
    span.value = @lookandfeel.lookup("prescription_sex_#{type}".to_sym)
    span.set_attribute('class', 'bold')
    fields << span
  end
  def prescription_title(model, session=@session)
    "#{@lookandfeel.lookup(:date)}:&nbsp;#{Date.today.strftime("%d.%m.%Y")}"
  end
  def document(model, session=@session)
    if @drugs
      packages = @drugs.values.unshift(model)
    else
      packages = [model]
    end
    fields = []
    packages.each do |pack|
      composite = self::class::INNER_COMPOSITE.new(pack, session, self)
      fields << composite
    end
    fields
  end
end
class Prescription < View::PrivateTemplate
  CONTENT = View::Drugs::PrescriptionComposite
  SNAPBACK_EVENT = :result
  JAVASCRIPTS = ['admin']
  def backtracking(model, session=@session)
    fields = []
    fields << @lookandfeel.lookup(:th_pointer_descr)
    link = HtmlGrid::Link.new(:result, model, @session, self)
    link.css_class = "list"
    query = @session.persistent_user_input(:search_query)
    if query and !query.is_a?(SBSM::InvalidDataError)
      args = [
        :zone, :drugs, :search_query, query.gsub('/', '%2F'), :search_type,
        @session.persistent_user_input(:search_type) || 'st_oddb',
      ]
      link.href = @lookandfeel._event_url(:search, args)
      link.value = @lookandfeel.lookup(:result)
    end
    fields << link
    fields << '&nbsp;-&nbsp;'
    title = @lookandfeel.lookup(:prescription_title)
    span = HtmlGrid::Span.new(model, session, self)
    span.value = "#{title}:&nbsp;#{Date.today.strftime("%d.%m.%Y")}"
    span.set_attribute('class', 'bold')
    fields << span
    fields
  end
end
class PrescriptionPrint < View::PrintTemplate
  CONTENT = View::Drugs::PrescriptionPrintComposite
  def head(model, session=@session)
    span = HtmlGrid::Span.new(model, session, self)
    span.value = @lookandfeel.lookup(:print_of) +
      @lookandfeel._event_url(:rezept, [:ean, model.barcode])
    span
  end
end
class PrescriptionCsv < HtmlGrid::Component
  COMPONENTS = [ # of package
    :barcode,
    :name_with_size,
    :price_public,
    :company_name,
  ]
  def init
    super
    @coder = HTMLEntities.new
  end
  def http_headers
    prescription_for = []
    %w[first_name family_name birth_day].each do |attr|
      prescription_for << user_input(attr)
    end
    name = @lookandfeel.lookup(:prescription).dup + '_'
    unless prescription_for.empty?
      name << prescription_for.join('_').gsub(/[\s]+/u, '_')
    else
      name << Date.today.strftime("%d.%m.%Y")
    end
    {
      'Content-Type'        => 'text/csv',
      'Content-Disposition' => "attachment;filename=#{name}.csv",
    }
  end
  def to_csv
    @lines = []
    @lines << person
    insert_blank
    @lines << date
    insert_blank
    if drugs = @session.persistent_user_input(:drugs)
      @packages = drugs.values.unshift(model)
    else
      @packages = [model]
    end
    # by packages
    @packages.each_with_index do |pack, index|
      @index = index.to_s
      @lines << extract(pack)
      insert_blank
      quantity_value.each{ |qv| @lines << qv }
      insert_blank
      @lines << timing_value
      insert_blank
      method_value.each{ |mv| @lines << mv }
      insert_blank
      @lines << term_value
      if comment = comment_value
        insert_blank
        @lines << comment
      end
      insert_blank
    end
    @lines.pop
    csv = ''
    @lines.collect do |line|
      csv << CSV.generate_line(line, {:col_sep => ';'})
    end
    csv
  end
  def to_html(context)
    to_csv
  end
  private
  def user_input(attr)
    key = "prescription_#{attr}".to_sym
    input = @session.user_input(key)
    case input
    when String
      # pass
    when Hash
       if element = input[@index] and !element.empty?
         input = element
       else
         input = nil
       end
    else
      input = nil
    end
    input = @coder.decode(input).gsub(/;/, ' ') if input.class == String
    input
  end
  def lookup(attr)
    key = "prescription_#{attr}".to_sym
    if value = @lookandfeel.lookup(key)
      @coder.decode(value)
    end
  end
  def insert_blank
    if !@lines.last or !@lines.last.empty?
      @lines << []
    end
  end
  # line
  def person
    type = (user_input(:sex) == '1' ? 'w' : 'm')
    [
      user_input(:first_name)  || '',
      user_input(:family_name) || '',
      user_input(:birth_day)   || '',
      lookup("sex_#{type}")
    ]
  end
  def date
    [Date.today.strftime("%d.%m.%Y")]
  end
  def extract(pack)
    COMPONENTS.collect do |key|
      value = if(self.respond_to?(key))
        self.send(key, pack)
      elsif pack
        pack.send(key)
      else
        ""
      end.to_s
      value.empty? ? nil : value
    end
  end
  def quantity_value
    _value = []
    [:morning, :noon, :evening, :night].each do |at_time|
      key = "quantity_#{at_time}"
      if quantity = user_input(key) and
         quantity =~ /^[0-9]+$/ and
         !quantity.to_i.zero?
        text = lookup(key) + ' '
        text << quantity.to_s
        _value << [text]
      end
    end
    _value
  end
  def timing_value
    key = case user_input(:timing)
    when '1'; :timing_before_meal;
    when '2'; :timing_with_meal;
    when '3'; :timing_after_meal;
    end
    key ? [lookup(key)] : []
  end
  def method_value # checkbox
    _value = []
    [:as_necessary, :regulaly].each do |method|
      key = "method_#{method}"
      if user_input(key)
        _value << [lookup(key)]
      end
    end
    _value
  end
  def term_value
    _value = []
    key = case user_input(:term)
    when '1'; :term_once;
    when '2'; :term_repetition;
    when '3'; :term_per_month;
    end
    if key
      text = lookup(key)
      if key.to_s =~ /repetition/ and repetition = user_input(:repetition)
        text << ' '
        text << repetition
      elsif key.to_s =~ /month/ and month = user_input(:per_month)
        text << ' '
        text << month
      end
      _value = [text]
    end
    _value
  end
  def comment_value
    comment = user_input(:comment)
    comment ? [comment] : []
  end
end
    end
  end
end
