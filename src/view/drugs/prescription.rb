#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::Prescription -- oddb.org -- 27.07.2012 -- yasaka@ywesee.com

require 'htmlgrid/errormessage'
require 'htmlgrid/infomessage'
require 'htmlgrid/select'
require 'htmlgrid/textarea'
require 'htmlgrid/inputtext'
require 'htmlgrid/inputcheckbox'
require 'htmlgrid/inputradio'
require 'view/drugs/privatetemplate'
require 'view/additional_information'
require 'view/printtemplate'
require 'view/publictemplate'
require 'view/form'

module ODDB
  module View
    module Drugs
class PrescriptionInnerForm < HtmlGrid::Composite
  COMPONENTS = {
    [0,0]  => 'prescription_quantity_morning',
    [1,0]  => :prescription_quantity_morning,
    [0,1]  => 'prescription_quantity_noon',
    [1,1]  => :prescription_quantity_noon,
    [0,2]  => 'prescription_quantity_evening',
    [1,2]  => :prescription_quantity_evening,
    [0,3]  => 'prescription_quantity_night',
    [1,3]  => :prescription_quantity_night,
    [0,4]  => :prescription_timing_fields,
    [0,6]  => :prescription_method_fields,
    [0,8]  => :prescription_term_fields,
    [0,10] => 'prescription_comment',
    [0,11] => :prescription_comment,
    [0,13] => :prescription_signature,
  }
  CSS_MAP = {
    [0,0]  => 'list bold',
    [1,0]  => 'list',
    [0,1]  => 'list bold',
    [1,1]  => 'list',
    [0,2]  => 'list bold',
    [1,2]  => 'list',
    [0,3]  => 'list bold',
    [1,3]  => 'list',
    [0,4]  => 'list top',
    [0,6]  => 'list top',
    [0,8]  => 'list top',
    [0,10] => 'list bold',
    [0,11] => 'list',
    [0,13] => 'list',
  }
  COLSPAN_MAP = {
    [0,4]  => 6,
    [0,6]  => 6,
    [0,8]  => 6,
    [0,10] => 6,
    [0,11] => 6,
    [0,13] => 6,
  }
  SYMBOL_MAP = {
    :prescription_comment   => HtmlGrid::Textarea,
    :prescription_generic   => HtmlGrid::LabelText,
    :prescription_signature => HtmlGrid::LabelText,
  }
  LABELS = true
  def self.define_quantity_method(key)
    name = "prescription_quantity_#{key}".to_sym
    define_method(name) do |model, session|
      input = HtmlGrid::InputText.new(name, model, session, self)
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
  def prescription_method_fields(model, session)
    fields = []
    checkbox = HtmlGrid::InputCheckbox.new(:prescription_method_as_necessary, model, session, self)
    fields << checkbox
    fields << '&nbsp;'
    fields << @lookandfeel.lookup(:prescription_method_as_necessary)
    fields << '<br/>'
    checkbox = HtmlGrid::InputCheckbox.new(:prescription_method_regulaly, model, session, self)
    fields << checkbox
    fields << '&nbsp;'
    fields << @lookandfeel.lookup(:prescription_method_regulaly)
    fields
  end
  def prescription_timing_fields(model, session)
    fields = []
    radio = HtmlGrid::InputRadio.new(:prescription_timing, model, session, self)
    radio.value = '1' 
    radio.set_attribute('checked', true)
    fields << radio
    fields << '&nbsp;'
    fields << @lookandfeel.lookup(:prescription_timing_before_meal)
    fields << '<br/>'
    radio = HtmlGrid::InputRadio.new(:prescription_timing, model, session, self)
    radio.value = '2' 
    fields << radio
    fields << '&nbsp;'
    fields << @lookandfeel.lookup(:prescription_timing_with_meal)
    fields << '<br/>'
    radio = HtmlGrid::InputRadio.new(:prescription_timing, model, session, self)
    radio.value = '3' 
    fields << radio
    fields << '&nbsp;'
    fields << @lookandfeel.lookup(:prescription_timing_after_meal)
    fields
  end
  def prescription_term_fields(model, session)
    fields = []
    radio = HtmlGrid::InputRadio.new(:prescription_term, model, session, self)
    radio.value = '1' 
    js = <<-JS
    var repetition = document.getElementById('repetition')
    var month = document.getElementById('per_month')
    month.value = '1';
    month.disabled = true;
    repetition.value = '1';
    repetition.disabled = true;
    JS
    radio.set_attribute('checked', true)
    radio.set_attribute('onClick', js)
    fields << radio
    fields << '&nbsp;'
    fields << @lookandfeel.lookup(:prescription_term_once)
    fields << '<br/>'
    radio = HtmlGrid::InputRadio.new(:prescription_term, model, session, self)
    radio.value = '2' 
    js = <<-JS
    var repetition = document.getElementById('repetition')
    var month = document.getElementById('per_month')
    month.value = '1';
    month.disabled = true;
    repetition.disabled = false;
    JS
    radio.set_attribute('onClick', js)
    fields << radio
    fields << '&nbsp;'
    fields << @lookandfeel.lookup(:prescription_term_repetition)
    select = HtmlGrid::Select.new(:prescription_repetition, model, @session, self)
    select.valid_values = (1..12).to_a
    select.set_attribute('id', 'repetition')
    select.set_attribute('disabled', 'disabled')
    fields << '&nbsp;'
    fields << select
    fields << '<br/>'
    radio = HtmlGrid::InputRadio.new(:prescription_term, model, session, self)
    radio.value = '3' 
    js = <<-JS
    var repetition = document.getElementById('repetition')
    var month = document.getElementById('per_month')
    repetition.value = '1';
    repetition.disabled = true;
    month.disabled = false;
    JS
    radio.set_attribute('onClick', js)
    fields << radio
    fields << '&nbsp;'
    fields << @lookandfeel.lookup(:prescription_term_per_month)
    select = HtmlGrid::Select.new(:prescription_per_month, model, @session, self)
    select.valid_values = (1..12).to_a
    select.set_attribute('id', 'per_month')
    select.set_attribute('disabled', 'disabled')
    fields << '&nbsp;'
    fields << select
    fields
  end
end
class PrescriptionForm < View::Form
  include HtmlGrid::InfoMessage
  include View::AdditionalInformation
  COMPONENTS = {
    [0,0]  => :prescription_for,
    [0,1]  => :subheader,
    [0,2]  => View::Drugs::PrescriptionInnerForm,
    [0,12] => :print_button,
    [0,13] => :prescription_notes,
  }
  CSS_MAP = {
    [0,0]  => 'th',
    [0,1]  => 'subheading',
    [0,2]  => 'list',
    [0,12] => 'button',
    [0,13] => 'list',
  }
  COLSPAN_MAP = {
    [0,0]  => 3,
    [0,1]  => 3,
    [0,2]  => 3,
    [0,12] => 3,
    [0,13] => 3,
  }
  CSS_CLASS = 'composite'
  DEFAULT_CLASS = HtmlGrid::Value
  LABELS = true
  def prescription_for(model, session)
    fields = []
    label = HtmlGrid::LabelText.new(:prescription_for, model, session, self)
    fields << label
    fields << '&nbsp;&nbsp;&nbsp;'
    %w[first_name family_name birth_day].each do |attr|
      key = "prescription_#{attr}".to_sym
      label = HtmlGrid::LabelText.new(key, model, session, self)
      fields << label
      fields << '&nbsp;'
      input = HtmlGrid::InputText.new(key, model, session, self)
      input.set_attribute('size', 13)
      input.label = false
      fields << input
      fields << '&nbsp;&nbsp;'
    end
    label = HtmlGrid::LabelText.new(:prescription_sex, model, session, self)
    fields << label
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
  def subheader(model, session)
    fields = []
    if fi = fachinfo(model, session, 'square bold infos')
      fi.set_attribute('target', '_blank')
      fields << fi
      fields << '&nbsp;'
    end
    fields << model.name
    fields << '&nbsp;-&nbsp;'
    fields << model.price_public.to_s
    fields << '&nbsp;-&nbsp;'
    fields << model.company_name
    fields
  end
  def hidden_fields(context)
    hidden = super
    hidden << context.hidden('ean13', @model.barcode)
    [:reg, :seq, :pack].each do |key|
      hidden << context.hidden(key.to_s, @session.user_input(key))
    end
    hidden << context.hidden('prescription', true)
    hidden
  end
  def print_button(model, session)
    post_event_button(:print)
  end
  private
  def init
    super
    @form_properties.update('target' => '_blank')
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
    [0,2]  => :quantity_value,
    [0,3]  => :timing_value,
    [0,5]  => :method_value,
    [0,7]  => :term_value,
    [0,9]  => 'prescription_comment',
    [0,10] => :comment_value,
    [0,12] => 'prescription_signature',
  }
  CSS_MAP = {
    [0,2]  => 'print',
    [1,3]  => 'print',
    [0,5]  => 'print top',
    [0,7]  => 'print',
    [0,9]  => 'print bold',
    [0,10] => 'print',
    [0,12] => 'print bold'
  }
  COLSPAN_MAP = {
    [0,2]  => 5,
    [0,3]  => 5,
    [0,5]  => 5,
    [0,7]  => 5,
    [0,9]  => 5,
    [0,10] => 5,
    [0,12] => 5,
  }
  CSS_CLASS = 'compose'
  DEFAULT_CLASS = HtmlGrid::Value
  def quantity_value(model, session=@session)
    fields = []
    [:morning, :noon, :evening, :night].each do |at_time|
      key = "prescription_quantity_#{at_time.to_s}".to_sym
      if quantity = @session.user_input(key) and quantity =~ /^[0-9]+$/ and !quantity.to_i.zero?
        fields << HtmlGrid::LabelText.new(key, model, session, self)
        text = HtmlGrid::Value.new(:prescription_quantity, model, session, self)
        text.value = quantity
        fields << '&nbsp;'
        fields << text
        fields << '<br/>'
      end
    end
    fields
  end
  def timing_value(model, session=@session)
    key = case @session.user_input(:prescription_timing)
    when '1'; :prescription_timing_before_meal;
    when '2'; :prescription_timing_with_meal;
    when '3'; :prescription_timing_after_meal;
    end
    if key
      text = HtmlGrid::Value.new(key, model, session, self)
      text.value = @lookandfeel.lookup(key)
      text
    end
  end
  def method_value(model, session=@session)
    fields = []
    [:as_necessary, :regulaly].each do |method|
      key = "prescription_method_#{method.to_s}".to_sym
      if @session.user_input(key)
        text = HtmlGrid::Value.new(key, model, session, self)
        text.value = @lookandfeel.lookup(key)
        fields << text
        fields << '<br/>'
      end
    end
    fields
  end
  def term_value(model, session=@session)
    fields = []
    key = case @session.user_input(:prescription_term)
    when '1'; :prescription_term_once;
    when '2'; :prescription_term_repetition;
    when '3'; :prescription_term_per_month;
    end
    if key
      text = HtmlGrid::Value.new(key, model, session, self)
      text.value = @lookandfeel.lookup(key)
      fields << text
      if key.to_s =~ /repetition/ and repetition = @session.user_input(:prescription_repetition)
        text = HtmlGrid::Value.new(:prescription_repetition, model, session, self)
        text.value = repetition
        fields << '&nbsp;'
        fields << text
      elsif key.to_s =~ /month/ and month = @session.user_input(:prescription_per_month)
        text = HtmlGrid::Value.new(:prescription_per_month, model, session, self)
        text.value = month
        fields << '&nbsp;'
        fields << text
      end
      fields
    end
  end
  def comment_value(model, session=@session)
    if comment_text = @session.user_input(:prescription_comment)
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
    [0,5] => '&nbsp;',
    [0,6] => :name,
    [0,7] => :document,
  }
  CSS_MAP = {
    0 => 'print-type',
    1 => 'print',
    2 => 'print',
    3 => 'print',
    4 => 'print',
    5 => 'print',
    6 => 'print bold',
    7 => 'print',
  }
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
  def name(model, session=@session)
    span = HtmlGrid::Span.new(model, session, self)
    span.value = ''
    span.value << model.name
    span.value << '&nbsp;-&nbsp;'
    span.value << model.price_public.to_s
    span.value << '&nbsp;-&nbsp;'
    span.value << model.company_name
    span.set_attribute('class', 'bold')
    span
  end
  def document(model, session=@session)
    self::class::INNER_COMPOSITE.new(model, session, self)
  end
end
class Prescription < View::PrivateTemplate
  CONTENT = View::Drugs::PrescriptionComposite
  SNAPBACK_EVENT = :result
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
      @lookandfeel._event_url(:rezept, [:reg, model.iksnr, :seq, model.seqnr, :pack, model.ikscd])
    span
  end
end
    end
  end
end
