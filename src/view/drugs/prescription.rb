#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::Prescription -- oddb.org -- 28.08.2012 -- yasaka@ywesee.com
# before commit 83d798fb133f10008dd95f2b73ebc3e11c118b16 of 2014-10-14 we had a view which 
# allowed entering a lot of details (before, during, after meals, repetitions, etc)
# Test it with http://oddb-ci2.dyndns.org/de/gcc/rezept/ean/7680317061142,7680353520153,7680546420673,7680193950301,7680517950680
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
      JS_RESTORE_PRESCRIPTION_COMMENTS = %(
  for (index = 0; index < 99; ++index) {
    var field_id = 'prescription_comment_' + index;
    var saved_value =  sessionStorage.getItem(field_id, '');
    var x=document.getElementById(field_id);
    console.log ('PrescriptionForm.onload ?? ' + field_id +': set value : ' + x + ' -> ' + saved_value);
    if (x != null) {
      if (saved_value != null && saved_value != 'null') {
        x.value = saved_value; 
      }
      console.log ('PrescriptionForm.onload ' + field_id +': set value : ' + x + ' -> ' + saved_value);
    } else { break; }
  } 
)      
      
      JS_RESTORE_PRESCRIPTION_PATIENT_INFO = %(
  document.getElementById('searchbar').focus();
    var fields = [ 'prescription_first_name',
     'prescription_family_name',
      'prescription_birth_day',
  ]
  for (index = 0; index < fields.length; ++index) {
    var field_id = fields[index];
    var saved_value =  sessionStorage.getItem(field_id, '');
    var x=document.getElementById(field_id);
    if (x != null) {
      if (saved_value != null && saved_value != 'null') {
        x.value = saved_value; 
      }
//      console.log ('PrescriptionForm.onload ' + field_id +': set value : ' + x + ' -> ' + saved_value);
    }
  } 
      )
      JS_RESTORE_PRESCRIPTION_SEX = %(
  var field_id = 'prescription_sex';
  var saved_value =  sessionStorage.getItem(field_id, '');
//  console.log ('PrescriptionForm.onload ' + field_id +': saved_value' + saved_value);
  if (saved_value == '1') {
    document.getElementById('prescription_sex_1').checked = true;
    document.getElementById('prescription_sex_2').checked = false;
  } else {
    document.getElementById('prescription_sex_1').checked = false;
    document.getElementById('prescription_sex_2').checked = true;
  }
)      
      
      def Drugs.saveFieldValueForLaterUse(field, field_id, default_value)
        if field.is_a?(HtmlGrid::InputRadio)
          field.set_attribute('onClick', "
                                  var new_value = sessionStorage.getItem('#{field_id}');
                                  sessionStorage.setItem('#{field_id}', '#{default_value}');
                                  console.log ('#{field_id}.onClick is '+ '#{default_value}');
                                ")
          field_id = field_id.to_s  + '_' + default_value.to_s
        else
        field.set_attribute('onFocus', "
                                var new_value = sessionStorage.getItem('#{field_id}');
                                console.log ('onFocus new_value: ' + new_value);
                                if (this.value == '#{default_value}') { this.value = '' ; }
                              ")
        field.set_attribute('onBlur',  "if (this.value == '') { value = '#{default_value}';
                              } else {
                                sessionStorage.setItem('#{field_id}', this.value);
                                console.log ('#{field_id}.onblur2 of sessionStorage #{field_id} to #{default_value}  is '+ sessionStorage.getItem('#{field_id}'));  
                              }
                              ")
        end
        field.set_attribute('id', field_id)
        field.value = default_value unless field.value
      end
      
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
      url = @session.request_path.sub(/(,|)#{model.barcode.to_s}/, '').sub(/\?$/, '')
      link.onclick = "
      console.log ('Delete index #{@index}: going to new url #{url} in prescription');
      for (index = #{@index}; index < 99; ++index) {
        var cur_id  = 'prescription_comment_' + index;
        var next_id = 'prescription_comment_' + (index+1);
        var next_value =  sessionStorage.getItem(next_id, '');
        if (next_value != '' && next_value != 'null' && next_value != null) {
          sessionStorage.setItem(cur_id, next_value);
          console.log ('PrescriptionDrugHeader.delete nextvalue ' + cur_id + ': set value : ' + next_value);
        } else {
          sessionStorage. removeItem(cur_id);
        }
      }           
      window.top.location.replace('#{url}');
      "
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
#    [0,1] => :inner_form,
		[0,1] => :interactions,
    [0,2] => :prescription_comment,
		[0,4] => :atc_code,
  }
  CSS_MAP = {
    [0,0] => 'subheading',
    [0,1] => 'list',
    [0,2] => 'list top',
  }
  COMPONENT_CSS_MAP = {
    [0,2] => 'wide',
  }
  CSS_CLASS = 'composite'
  def init
    @drugs = @session.persistent_user_input(:drugs)
    @index = -1
    if @model and @drugs and !@drugs.empty?
      @index = @drugs.keys.index(@model.barcode)
    end
    if @drugs and !@drugs.empty?
      @model = @drugs.values[@index]
    end
    @attributes.store('id', 'drugs_' + @model.barcode) if @attributes and @model
    super
  end
  def interactions(model, session)
    View::Drugs::PrescriptionInteractionDrugDiv.new(model, session, self)
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
  def drug(model, session)
    View::Drugs::PrescriptionDrugHeader.new(model, session, self)
  end
  def prescription_comment(model, session)
    name = "prescription_comment_#{@index}".intern
    textarea = HtmlGrid::Textarea.new(name.intern, model, @session, self)
    Drugs.saveFieldValueForLaterUse(textarea, name, @lookandfeel.lookup(:prescription_comment))
    textarea
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
			value = @lookandfeel.lookup(key)
      fields << @lookandfeel.lookup(key)
      fields << '&nbsp;'
      input = HtmlGrid::InputText.new(key, model, session, self)
      input.set_attribute('size', 13)
      input.label = false
      Drugs.saveFieldValueForLaterUse(input, key, '')
      fields << input
      fields << '&nbsp;&nbsp;'
    end
    fields << @lookandfeel.lookup(:prescription_sex)
    fields << '&nbsp;'
    radio = HtmlGrid::InputRadio.new(:prescription_sex, model, session, self)
    Drugs.saveFieldValueForLaterUse(radio, :prescription_sex, 1)
    radio.value = '1'
    radio.set_attribute('checked', true)
    fields << radio
    fields << '&nbsp;'
    fields << @lookandfeel.lookup(:prescription_sex_w)
    fields << '&nbsp;'
    radio = HtmlGrid::InputRadio.new(:prescription_sex, model, session, self)
    Drugs.saveFieldValueForLaterUse(radio, :prescription_sex, 2)
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
    self.onload = %(require(["dojo/domReady!"], function(){  
      #{Drugs::JS_RESTORE_PRESCRIPTION_PATIENT_INFO}
      #{Drugs::JS_RESTORE_PRESCRIPTION_SEX}
      #{Drugs::JS_RESTORE_PRESCRIPTION_COMMENTS}
});
)
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
    [0,2] => :interactions,
    [0,3] => :prescription_comment,
    [0,4] => :comment_value,
  }
  CSS_MAP = {
    [0,1] => 'print bold',
    [0,3] => 'print bold',
    [0,4] => 'print',
  }
  CSS_CLASS = 'compose'
  DEFAULT_CLASS = HtmlGrid::Value
  def init
    @drugs = @session.persistent_user_input(:drugs)
    @index = -1
    if @model and @drugs and !@drugs.empty?
      @index = @drugs.keys.index(@model.barcode)
    end
    if @drugs and !@drugs.empty?
      @model = @drugs.values[@index]
    end
    @texts = @session.user_input(:prescription_comment)
    @texts ||= {}
    @comment_header = @lookandfeel.lookup(:prescription_comment)
    @comment_text = @texts[(@index.to_i).to_s]
    if @comment_text == @comment_header
      components.delete([0,3])
      components.delete([0,4])
    end
    super
  end
  def interactions(model, session)
    View::Drugs::PrescriptionInteractionDrugDiv.new(model, session, self)
  end

  def name(model, session=@session)
    span = HtmlGrid::Span.new(model, session, self)
    span.value = ''
    return span unless model
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
  def prescription_comment(model, session=@session)
    span = HtmlGrid::Span.new(model, session, self)
    span.value = @comment_header    
  end
  def comment_value(model, session=@session)
    field_id = "prescription_comment_#{@index}"
    text = HtmlGrid::Value.new(:prescription_comment, model, session, self)
    text.value = @comment_text
    text.set_attribute('id', field_id)
    text
  end
end
class PrescriptionPrintComposite < HtmlGrid::DivComposite
  include PrintComposite
  include View::AdditionalInformation
  PRINT_TYPE = ""
  COMPONENTS = {
    [0,0] =>  :epha_public_domain,
    [0,1] => :print_type,
    [0,2] => '&nbsp;',
    [0,3] => :prescription_for,
    [0,4] => '&nbsp;',
    [0,5] => :prescription_title,
    [0,6] => :document,
    [0,7] => '&nbsp;',
    [0,8] => 'prescription_signature',
  }
  CSS_MAP = {
    0 => 'print-type',
    1 => 'print-type',
    2 => 'print',
    3 => 'print',
    4 => 'print',
    5 => 'print',
    6 => 'print',
    7 => 'print',
    8 => 'print bold',
  }
  def init
    @session.set_persistent_user_input(:printing, true)
    @drugs = @session.persistent_user_input(:drugs)
    super
self.onload = %(require(["dojo/domReady!"], function(){ 
      #{JS_RESTORE_PRESCRIPTION_COMMENTS}
  });
  )
  
  end
  def epha_public_domain(model, session=@session)
    desc = @lookandfeel.lookup(:interaction_chooser_description) + ' ' + @lookandfeel.lookup(:epha_public_domain)
    span = HtmlGrid::Span.new(model, session, self)
    span.value = desc
    span 
  end
  def prescription_for(model, session=@session)
    fields = []
    fields << @lookandfeel.lookup(:prescription_for)
    fields << '&nbsp;&nbsp;&nbsp;'
    %w[first_name family_name birth_day].each do |attr|
      key = "prescription_#{attr}".to_sym
      value = @lookandfeel.lookup(key)
      fields << value
      fields << '&nbsp;'
      span = HtmlGrid::Span.new(model, session, self)
      span.set_attribute('class', 'bold')
      span.value = @session.user_input(key)
      fields << span
      fields << '&nbsp;&nbsp;'
    end
    span = HtmlGrid::Span.new(model, session, self)
    type = (@session.user_input(:prescription_sex) == '1' ? 'w' : 'm')
    span.value = @lookandfeel.lookup("prescription_sex_#{type}".to_sym)
    span.set_attribute('class', 'bold')
    fields << span
    fields
  end
  def prescription_title(model, session=@session)
    "#{@lookandfeel.lookup(:date)}:&nbsp;#{Date.today.strftime("%d.%m.%Y")}"
  end
  def document(model, session=@session)
    fields = []
    @drugs.each do |key, pack|
      composite = View::Drugs::PrescriptionPrintInnerComposite.new(pack, session, self)
      fields << composite
    end
    fields
  end
end
class Prescription < View::PrivateTemplate
  CONTENT = View::Drugs::PrescriptionComposite
  SNAPBACK_EVENT = :result
  JAVASCRIPTS = ['admin']
  def init
    @session.set_persistent_user_input(:printing, nil)
    super
  end
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
  def init
    @session.set_persistent_user_input(:printing, true)
    @drugs = @session.persistent_user_input(:drugs)
    @index = (@drugs ? @drugs.length : 0).to_s
    if @model and @drugs and !@drugs.empty?
      @index = @drugs.keys.index(@model.barcode).to_s
    end
    super
  end
  def head(model, session=@session)
    span = HtmlGrid::Span.new(model, session, self)
    drugs = @session.persistent_user_input(:drugs)
    span.value = @lookandfeel.lookup(:print_of) +
      @lookandfeel._event_url(:print, [:rezept, :ean, drugs.keys].flatten)
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
    name ||= '_'
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
  def comment_value
    comment = user_input(:comment)
    comment ? [comment] : []
  end
end
    end
  end
end
