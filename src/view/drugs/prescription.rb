#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::Prescription -- oddb.org -- 03.08.2012 -- yasaka@ywesee.com

require 'csv'
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
require 'view/additional_information'
require 'view/searchbar'
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
    [0,13] => 'prescription_signature',
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
    [0,13] => 'list bold',
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
    :prescription_comment => HtmlGrid::Textarea,
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
  def prescription_timing_fields(model, session)
    fields = []
    radio = HtmlGrid::InputRadio.new(:prescription_timing, model, session, self)
    radio.value = '1' 
    radio.set_attribute('checked', true)
    radio.set_attribute('id', 'prescription_timing_before_meal')
    fields << radio
    fields << '&nbsp;'
    fields << label_for(:prescription_timing_before_meal)
    fields << '<br/>'
    radio = HtmlGrid::InputRadio.new(:prescription_timing, model, session, self)
    radio.value = '2' 
    radio.set_attribute('id', 'prescription_timing_with_meal')
    fields << radio
    fields << '&nbsp;'
    fields << label_for(:prescription_timing_with_meal)
    fields << '<br/>'
    radio = HtmlGrid::InputRadio.new(:prescription_timing, model, session, self)
    radio.value = '3' 
    radio.set_attribute('id', 'prescription_timing_after_meal')
    fields << radio
    fields << '&nbsp;'
    fields << label_for(:prescription_timing_after_meal)
    fields
  end
  def prescription_method_fields(model, session)
    fields = []
    checkbox = HtmlGrid::InputCheckbox.new(:prescription_method_as_necessary, model, session, self)
    checkbox.set_attribute('id', 'prescription_method_as_necessary')
    fields << checkbox
    fields << '&nbsp;'
    fields << label_for(:prescription_method_as_necessary)
    fields << '<br/>'
    checkbox = HtmlGrid::InputCheckbox.new(:prescription_method_regulaly, model, session, self)
    checkbox.set_attribute('id', 'prescription_method_regulaly')
    fields << checkbox
    fields << '&nbsp;'
    fields << label_for(:prescription_method_regulaly)
    fields
  end
  def prescription_term_fields(model, session)
    fields = []
    radio = HtmlGrid::InputRadio.new(:prescription_term, model, session, self)
    radio.value = '1' 
    radio.set_attribute('id', 'prescription_term_once')
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
    fields << label_for(:prescription_term_once)
    fields << '<br/>'
    radio = HtmlGrid::InputRadio.new(:prescription_term, model, session, self)
    radio.value = '2' 
    radio.set_attribute('id', 'prescription_term_repetition')
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
    fields << label_for(:prescription_term_repetition)
    select = HtmlGrid::Select.new(:prescription_repetition, model, @session, self)
    select.valid_values = (1..12).to_a
    select.set_attribute('id', 'repetition')
    select.set_attribute('disabled', 'disabled')
    fields << '&nbsp;'
    fields << select
    fields << '<br/>'
    radio = HtmlGrid::InputRadio.new(:prescription_term, model, session, self)
    radio.value = '3' 
    radio.set_attribute('id', 'prescription_term_per_month')
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
    fields << label_for(:prescription_term_per_month)
    select = HtmlGrid::Select.new(:prescription_per_month, model, @session, self)
    select.valid_values = (1..12).to_a
    select.set_attribute('id', 'per_month')
    select.set_attribute('disabled', 'disabled')
    fields << '&nbsp;'
    fields << select
    fields
  end
  private
  def label_for(key)
    text = HtmlGrid::LabelText.new(key, @model, @session, self)
    HtmlGrid::Label.new(text, @session)
  end
end
class PrescriptionDrugsHeader < HtmlGrid::List
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
  CSS_ID = 'drugs'
  CSS_CLASS = 'compose'
  OMIT_HEADER = true
  SORT_DEFAULT = nil
  BACKGROUND_SUFFIX = ''
  def init
    if drugs = @session.persistent_user_input(:drugs)
      @model = drugs.values.unshift(@model)
    else
      @model = [@model]
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
    div.value << model.name_with_size
    if price = model.price_public
      div.value << '&nbsp;-&nbsp;'
      div.value << price.to_s
    end
    if company = model.company_name
      div.value << '&nbsp;-&nbsp;'
      div.value << company
    end
    div
  end
  def delete(model, session=@session)
    if(@model.length > 1 and model.barcode != @model.first.barcode)
      link = HtmlGrid::Link.new(:minus, model, session, self)
      link.set_attribute('title', @lookandfeel.lookup(:delete))
      link.css_class = 'delete square'
      args = [ :reg, @session.state.model.iksnr, :seq, @session.state.model.seqnr, :pack, @session.state.model.ikscd, :ean13, model.barcode ]
      url = @session.lookandfeel.event_url(:ajax_delete_drug, args)
      link.onclick = "replace_element('#{css_id}', '#{url}');"
      link
    end
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
    self.onload = "document.getElementById('searchbar').focus();"
    @index_name = 'oddb_package_name_with_size_and_ean13'
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
    [0,1]  => View::Drugs::PrescriptionDrugsHeader,
    [0,2]  => View::Drugs::PrescriptionDrugSearchForm,
    [0,3]  => View::Drugs::PrescriptionInnerForm,
    [0,13] => :buttons,
    [0,14] => 'prescription_notes',
  }
  CSS_MAP = {
    [0,0]  => 'th bold',
    [0,1]  => 'subheading',
    [0,2]  => 'list',
    [0,3]  => 'list',
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
    hidden << context.hidden('ean13', @model.barcode)
    [:reg, :seq, :pack].each do |key|
      hidden << context.hidden(key.to_s, @session.user_input(key))
    end
    hidden << context.hidden('prescription', true)
    hidden
  end
  def buttons(model, session)
    buttons = []
    buttons << post_event_button(:print)
    buttons << '&nbsp;'
    buttons << post_event_button(:export_csv)
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
    if drugs = session.persistent_user_input(:drugs)
      packages = drugs.values.unshift(model)
    else
      packages = [model]
    end
    fields = []
    packages.each do |pack|
      span = HtmlGrid::Span.new(pack, session, self)
      span.value = ''
      span.value << pack.name_with_size
      if price = pack.price_public
        span.value << '&nbsp;-&nbsp;'
        span.value << price.to_s
      end
      if company = pack.company_name
        span.value << '&nbsp;-&nbsp;'
        span.value << company
      end
      span.set_attribute('class', 'bold')
      fields << span
      fields << "<br/>"
    end
    fields
  end
  def document(model, session=@session)
    self::class::INNER_COMPOSITE.new(model, session, self)
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
      @lookandfeel._event_url(:rezept, [:reg, model.iksnr, :seq, model.seqnr, :pack, model.ikscd])
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
  def to_csv(keys)
    result = []
    # person
    type = (user_input(:sex) == '1' ? 'w' : 'm')
    result << [
      user_input(:first_name),
      user_input(:family_name),
      user_input(:birth_day),
      lookup("sex_#{type}")
    ]
    result << [Date.today.strftime("%d.%m.%Y")]
    # packages
    if drugs = @session.persistent_user_input(:drugs)
      packages = drugs.values.unshift(model)
    else
      packages = [model]
    end
    packages.each do |pack|
      result << keys.collect do |key|
        value = if(self.respond_to?(key))
          self.send(key, pack)
        else
          pack.send(key)
        end.to_s
        value.empty? ? nil : value
      end
    end
    # prescription
    result << []
    [:morning, :noon, :evening, :night].each do |at_time|
      key = "quantity_#{at_time}"
      if quantity = user_input(key) and quantity =~ /^[0-9]+$/ and !quantity.to_i.zero?
        text = lookup(key) + ' '
        text << quantity.to_s
        result << [text]
      end
    end
    result << [] unless result.last.empty?
    key = case user_input(:timing)
    when '1'; :timing_before_meal;
    when '2'; :timing_with_meal;
    when '3'; :timing_after_meal;
    end
    result << [lookup(key)] if key
    result << [] unless result.last.empty?
    [:as_necessary, :regulaly].each do |method|
      key = "method_#{method}"
      if user_input(key)
        result << [lookup(key)]
      end
    end
    result << [] unless result.last.empty?
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
      result << [text]
    end
    if comment = user_input(:comment)
      result << [] unless result.last.empty?
      result << [comment]
    end
    csv = ''
    result.collect do |line|
      csv << CSV.generate_line(line, {:col_sep => ';'})
    end
    csv
  end
  def to_html(context)
    to_csv(COMPONENTS)
  end
  private
  def user_input(attr)
    key = "prescription_#{attr}".to_sym
    if input = @session.user_input(key) and !input.empty?
      @coder.decode(input).gsub(/;/, ' ')
    end
  end
  def lookup(attr)
    key = "prescription_#{attr}".to_sym
    if value = @lookandfeel.lookup(key)
      @coder.decode(value)
    end
  end
end
    end
  end
end
