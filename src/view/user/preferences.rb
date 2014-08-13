# encoding: utf-8
# ODDB::View::User::Preferences -- oddb -- 04.10.2012 -- yasaka@ywesee.com

require 'htmlgrid/form'
require 'htmlgrid/inputradio'
require 'view/publictemplate'
require 'view/form'
require 'view/zsr'

module ODDB
  module View
    module User
class PreferencesForm < View::Form
  COMPONENTS = {
    [0,0] => 'style_chooser_description',
    [0,2] => :styles,
    [0,3] => 'search_type_selection_description',
    [0,5] => :search_forms,
    [0,7] => :search_types,
    [0,8] => :zsr_id,
    [0,9] => View::ZsrDetails,
    [0,10] => :button,
  }
  CSS_MAP = {
    [0,0] => 'subheading',
    [0,2] => 'list',
    [0,3] => 'subheading',
    [0,5] => 'list',
    [0,7] => 'list',
    [0,8] => 'list',
    [0,9] => 'list',
    [0,10] => 'button',
  }
  CSS_CLASS = 'composite'
  def styles(model, session=@session)
    fields = []
    chosen = session.get_cookie_input(:style)
    $stdout.puts "get_cookie_input style is #{chosen}"
    unless chosen
      chosen = 'default'
    end
    @lookandfeel.attributes(:styles).each_pair do |name, attrs|
      radio = HtmlGrid::InputRadio.new(:style, model, session, self)
      radio.set_attribute('id', name)
      radio.value = name
      if chosen and name == chosen
        radio.set_attribute('checked', true)
      end
      div = HtmlGrid::Div.new(model, session, self)
      div.value = []
      attrs.keys.each do |attr|
        inner = HtmlGrid::Div.new(model, session, self)
        inner.value = '&nbsp;'
        inner.set_attribute('style', "width:200px;background-color:#{attrs[attr]};")
        div.value << inner
      end
      label = label_for(name, @lookandfeel.lookup("oddb_style_#{name}"))
      fields << [radio, '&nbsp;', label, div]
      fields << '<br/>'
    end
    fields
  end
  def search_forms(model, session=@session)
    fields = []
    chosen = session.get_cookie_input(:search_form)
    unless chosen
      chosen = 'plus'
    end
    %w[plus instant].each do |method|
      radio = HtmlGrid::InputRadio.new(:search_form, model, session, self)
      radio.set_attribute('id', method)
      radio.value = method
      if chosen and method == chosen
        radio.set_attribute('checked', true)
      end
      label = label_for(method.capitalize)
      if label.value == 'Plus'
        label.value << " (oddb.org Default)"
      end
      fields << [radio, '&nbsp;', label]
      fields << '<br/>'
    end
    fields
  end
  def search_types(model, session=@session)
    fields = []
    chosen = session.get_cookie_input(:search_type)
    $stdout.puts "search_types search_type #{chosen.inspect}"
    unless chosen
      chosen = 'st_oddb'
    end
    @session.valid_values(:search_type).each do |name|
      radio = HtmlGrid::InputRadio.new(:search_type, model, session, self)
      radio.set_attribute('id', name)
      radio.value = name
      if chosen and name == chosen
        radio.set_attribute('checked', true)
      end
      label = label_for(name, @lookandfeel.lookup(name).dup)
      if label.value == @lookandfeel.lookup(:compare)
        label.value << " (oddb.org Default)"
      end
      fields << [radio, '&nbsp;', label]
      fields << '<br/>'
    end
    fields
  end
  def label_for(name, text=nil)
    label = HtmlGrid::SimpleLabel.new(name, @model, @session, self)
    label.instance_eval{ @attributes['for'] = name.downcase }
    label.set_attribute('style', 'font-weight:normal;')
    label.value = (text ? text : name)
    label
  end
  def zsr_id(model, session)
    fields = []
    fields << @lookandfeel.lookup(:zsr_id) + '&nbsp;'
    input = HtmlGrid::InputText.new(:zsr_id, model, session, self)
    zsr_id = session.get_cookie_input(:zsr_id)
    $stdout.puts "get_cookie_input zsr_id is #{zsr_id}"    
    input.value = zsr_id
    ODDB::View::Helpers.saveFieldValueForLaterUse(input, :zsr_id, '')
    js =  "require(['dojo/domReady!'], function(){ js_save_zsr_id();});"
    input.onclick = js
    input.set_attribute('onBlur', js)
    input.set_attribute('onchange', js)
    fields << input
    fields
  end  
  def button(model, session=@session)
    post_event_button(:update)
  end
end
class PreferencesComposite < HtmlGrid::Composite
  COMPONENTS = {
    [0,0] => 'preferences',
    [0,1] => View::User::PreferencesForm,
    [0,2] => '&nbsp;',
  }
  CSS_MAP = {
    [0,0] => 'th bold',
    [0,1] => 'component',
  }
  CSS_CLASS = 'composite'
end
class Preferences < View::PublicTemplate
  CONTENT = View::User::PreferencesComposite
  HEAD    = View::LogoHead
  JAVASCRIPTS = ['prescription']
  private
  def init
    super
    self.onload = "require(['dojo/domReady!'], function(){ js_get_zsr_id();});"
  end
end
    end
  end
end
