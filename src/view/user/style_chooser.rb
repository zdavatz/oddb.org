# encoding: utf-8
# ODDB::View::User::StyleChooser -- oddb -- 28.09.2012 -- yasaka@ywesee.com

require 'view/publictemplate'
require 'view/form'

module ODDB
  module View
    module User
class StyleChooserForm < View::Form
  COMPONENTS = {
    [0,0] => :styles,
    [0,1] => :button,
  }
  CSS_MAP = {
    [0,0] => 'list',
    [0,1] => 'button',
  }
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
        inner.set_attribute('style', "background-color:#{attrs[attr]};")
        div.value << inner
      end
      fields << [
        radio,
        '&nbsp;',
        @lookandfeel.lookup("oddb_style_#{name}"),
        div
      ]
      fields << '<br/>'
    end
    fields
  end
  def button(model, session=@session)
    post_event_button(:update)
  end
end
class StyleChooserComposite < HtmlGrid::Composite
  COMPONENTS = {
    [0,0] => 'style_chooser_description',
    [0,1] => View::User::StyleChooserForm,
    [0,2] => '&nbsp;',
  }
  CSS_MAP = {
    [0,0] => 'th bold',
    [0,1] => 'component',
  }
  CSS_CLASS = 'composite'
end
class StyleChooser < View::PublicTemplate
  CONTENT = View::User::StyleChooserComposite
  HEAD    = View::LogoHead
end
    end
  end
end

