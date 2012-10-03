# encoding: utf-8
# ODDB::View::User::Preferences -- oddb -- 03.10.2012 -- yasaka@ywesee.com

require 'view/publictemplate'
require 'view/form'

module ODDB
  module View
    module User
class PreferencesForm < View::Form
  COMPONENTS = {
    [0,0] => 'style_chooser_description',
    [0,2] => :styles,
    [0,3] => 'search_type_selection_description',
    [0,5] => :search_types,
    [0,7] => :button,
  }
  CSS_MAP = {
    [0,0] => 'subheading',
    [0,2] => 'list',
    [0,3] => 'subheading',
    [0,5] => 'list',
    [0,7] => 'button',
  }
  CSS_CLASS = 'composite'
  def styles(model, session=@session)
    fields = []
    chosen = session.get_cookie_input(:style)
    unless chosen
      chosen = 'default'
    end
    @lookandfeel.attributes(:styles).each_pair do |name, attrs|
      radio = HtmlGrid::InputRadio.new(:style, model, session, self)
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
      label = @lookandfeel.lookup("oddb_style_#{name}")
      fields << [radio, '&nbsp;', label, div]
      fields << '<br/>'
    end
    fields
  end
  def search_types(model, session=@session)
    fields = []
    chosen = session.get_cookie_input(:search_type)
    unless chosen
      chosen = 'st_oddb'
    end
    @session.valid_values(:search_type).each do |name|
      radio = HtmlGrid::InputRadio.new(:search_type, model, session, self)
      radio.value = name
      if chosen and name == chosen
        radio.set_attribute('checked', true)
      end
      label = @lookandfeel.lookup(name).dup
      if label == @lookandfeel.lookup(:compare)
        label << " (oddb.org Default)"
      end
      fields << [radio, '&nbsp;', label]
      fields << '<br/>'
    end
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
end
    end
  end
end
