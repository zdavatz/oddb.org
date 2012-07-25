#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::Prescription -- oddb.org -- 25.07.2012 -- yasaka@ywesee.com

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
class PrescriptionForm < View::Form
  include HtmlGrid::InfoMessage
  include View::AdditionalInformation
  COMPONENTS = {
    [0,0]  => :prescription_for,
    [0,1]  => :subheader,
    [0,2]  => 'prescription_quantity_morning',
    [1,2]  => :prescription_quantity_morning,
    [0,3]  => 'prescription_quantity_noon',
    [1,3]  => :prescription_quantity_noon,
    [0,4]  => 'prescription_quantity_evening',
    [1,4]  => :prescription_quantity_evening,
    [0,5]  => 'prescription_quantity_night',
    [1,5]  => :prescription_quantity_night,
    [2,3]  => :prescription_method_fields,
    [0,6]  => 'prescription_comment',
    [0,7]  => :prescription_comment,
    [0,8]  => :prescription_timing_fields,
    [0,9]  => :prescription_term_fields,
    [0,11] => :prescription_signature,
    [0,19] => :print_button,
    [0,20] => :prescription_notes,
  }
  CSS_MAP = {
    [0,0,12,1] => 'th',
    [0,1]  => 'subheading',
    [0,2]  => 'list bold',
    [1,2]  => 'list',
    [0,3]  => 'list bold',
    [1,3]  => 'list',
    [0,4]  => 'list bold',
    [1,4]  => 'list',
    [0,5]  => 'list bold',
    [1,5]  => 'list',
    [2,3]  => 'list',
    [0,6]  => 'list bold',
    [0,7]  => 'list',
    [0,8]  => 'list',
    [0,9]  => 'list',
    [0,11] => 'list',
    [0,19] => 'button',
    [0,20] => 'list',
  }
  SYMBOL_MAP = {
    :prescription_comment   => HtmlGrid::Textarea,
    :prescription_generic   => HtmlGrid::LabelText,
    :prescription_signature => HtmlGrid::LabelText,
  }
  COLSPAN_MAP = {
    [0,0]  => 12,
    [0,1]  => 12,
    [0,6]  => 3,
    [0,7]  => 3,
    [0,8]  => 3,
    [0,9]  => 3,
    [2,3]  => 6,
    [0,11] => 6,
    [0,19] => 3,
    [0,20] => 10,
  }
  DEFAULT_CLASS = HtmlGrid::Value
  LABELS = true
  CSS_CLASS = 'composite'
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
    fi = fachinfo(model, session, 'square bold infos')
    fi.set_attribute('target', '_blank')
    fields << fi
    fields << '&nbsp;'
    fields << model.name
    fields << '&nbsp;-&nbsp;'
    fields << model.ddd_price
    fields << '&nbsp;-&nbsp;'
    fields << model.company_name
    fields
  end
  def self.define_quantity_method(key)
    name = "prescription_quantity_#{key}".to_sym
    define_method(name) do |model, session|
      input = HtmlGrid::InputText.new(name, model, session, self)
      input.set_attribute('size', 3)
      input.label = false
      input.value = '0'
      input
    end
  end
  %w[morning noon evening night].each do |key|
    define_quantity_method(key)
  end
  def prescription_method_fields(model, session)
    method_fields = []
    checkbox = HtmlGrid::InputCheckbox.new(:prescription_method_as_necessary, model, session, self)
    method_fields << checkbox
    method_fields << '&nbsp;'
    method_fields << @lookandfeel.lookup(:prescription_method_as_necessary)
    method_fields << '&nbsp;'
    checkbox = HtmlGrid::InputCheckbox.new(:prescription_method_regulaly, model, session, self)
    method_fields << checkbox
    method_fields << '&nbsp;'
    method_fields << @lookandfeel.lookup(:prescription_method_regulaly)
    method_fields
  end
  def prescription_timing_fields(model, session)
    timing_fields = []
    radio = HtmlGrid::InputRadio.new(:prescription_timing, model, session, self)
    radio.value = '1' 
    radio.set_attribute('checked', true)
    timing_fields << radio
    timing_fields << '&nbsp;'
    timing_fields << @lookandfeel.lookup(:prescription_timing_before_meal)
    timing_fields << '<br/>'
    radio = HtmlGrid::InputRadio.new(:prescription_timing, model, session, self)
    radio.value = '2' 
    timing_fields << radio
    timing_fields << '&nbsp;'
    timing_fields << @lookandfeel.lookup(:prescription_timing_with_meal)
    timing_fields << '<br/>'
    radio = HtmlGrid::InputRadio.new(:prescription_timing, model, session, self)
    radio.value = '3' 
    timing_fields << radio
    timing_fields << '&nbsp;'
    timing_fields << @lookandfeel.lookup(:prescription_timing_after_meal)
    timing_fields
  end
  def prescription_term_fields(model, session)
    term_fields = []
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
    term_fields << radio
    term_fields << '&nbsp;'
    term_fields << @lookandfeel.lookup(:prescription_term_once)
    term_fields << '<br/>'
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
    term_fields << radio
    term_fields << '&nbsp;'
    term_fields << @lookandfeel.lookup(:prescription_term_repetition)
    select = HtmlGrid::Select.new(:prescription_repetition, model, @session, self)
    select.valid_values = (1..12).to_a
    select.set_attribute('id', 'repetition')
    select.set_attribute('disabled', 'disabled')
    term_fields << '&nbsp;'
    term_fields << select
    term_fields << '<br/>'
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
    term_fields << radio
    term_fields << '&nbsp;'
    term_fields << @lookandfeel.lookup(:prescription_term_per_month)
    select = HtmlGrid::Select.new(:prescription_per_month, model, @session, self)
    select.valid_values = (1..12).to_a
    select.set_attribute('id', 'per_month')
    select.set_attribute('disabled', 'disabled')
    term_fields << '&nbsp;'
    term_fields << select
    term_fields
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
  CSS_CLASS = 'composite'
  COMPONENT_CSS_MAP = {
    [0,0] => 'composite',
  }
  COLSPAN_MAP = {
    [0,0] => 12,
  }
  DEFAULT_CLASS = HtmlGrid::Value
end
class PrescriptionPrintInnerComposite < HtmlGrid::Composite
  COMPONENTS = {
    [0,1]  => :prescription_for,
    [0,3]  => :quantity_value,
    [1,3]  => :method_value,
    [0,4]  => :timing_value,
    [0,6]  => :term_value,
    [0,8]  => 'prescription_comment',
    [0,9]  => :comment_value,
    [0,11] => 'prescription_signature',
  }
  CSS_MAP = {
    [0,1]  => 'print',
    [0,3]  => 'print',
    [1,3]  => 'print',
    [0,4]  => 'print',
    [0,6]  => 'print',
    [0,8]  => 'print bold',
    [0,9]  => 'print',
    [0,11] => 'print bold'
  }
  COLSPAN_MAP = {
    [0,1]  => 5,
    [1,3]  => 4,
    [0,4]  => 5,
    [0,8]  => 5,
    [0,9]  => 5,
    [0,11] => 5,
  }
  CSS_CLASS = 'composite'
  DEFAULT_CLASS = HtmlGrid::Value
  def prescription_for(model, session=@session)
    fields = []
    %w[first_name family_name birth_day].each do |attr|
      key = "prescription_#{attr}".to_sym
      text = HtmlGrid::Value.new(key, model, session, self)
      text.value = @session.user_input(key)
      fields << text
      fields << '&nbsp;&nbsp;'
    end
    text = HtmlGrid::Value.new(:prescription_sex, model, session, self)
    type = (@session.user_input(:prescription_sex) == '1' ? 'w' : 'm')
    text.value = "<span>%s</span>" % @lookandfeel.lookup("prescription_sex_#{type}".to_sym)
    fields << '&nbsp;'
    fields << text
  end
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
  def method_value(model, session=@session)
    fields = []
    [:as_necessary, :regulaly].each do |method|
      key = "prescription_method_#{method.to_s}".to_sym
      if @session.user_input(key)
        text = HtmlGrid::Value.new(key, model, session, self)
        text.value = @lookandfeel.lookup(key)
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
    [0,1] => :prescription_title,
    [0,2] => :name,
    [0,3] => :document,
  }
  CSS_MAP = {
    0 => 'print-type',
    1 => 'print-title',
    2 => 'print',
    3 => 'print',
  }
  def prescription_title(model, session=@session)
    title = @lookandfeel.lookup(:prescription_title)
    "#{title}:&nbsp;#{Date.today.strftime("%d.%m.%Y")}"
  end
  def name(model, session=@session)
    fields = []
    fields << model.name
    fields << '&nbsp;-&nbsp;'
    fields << model.ddd_price
    fields << '&nbsp;-&nbsp;'
    fields << model.company_name
    fields
  end
  def document(model, session=@session)
    self::class::INNER_COMPOSITE.new(model, session, self)
  end
end
class Prescription < View::PrivateTemplate
  CONTENT = View::Drugs::PrescriptionComposite
  SNAPBACK_EVENT = :rezept
  def backtracking(model, session=@session)
    fields = []
		link = HtmlGrid::Link.new(:result, model, session, self)
    link.href = "javascript:history.back();"
    link.set_attribute('onClick', 'history.back();')
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
end
    end
  end
end
