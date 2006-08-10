#!/usr/bin/env ruby
# View::Admin::Entity -- oddb.org -- 08.06.2006 -- hwyss@ywesee.com

require 'view/privatetemplate'
require 'view/form'
require 'htmlgrid/errormessage'
require 'htmlgrid/select'

module ODDB
  module View
    module Admin
class YusPrivileges < HtmlGrid::List
  COMPONENTS = {
    [0,0] =>  :checkbox,
  }
  LEGACY_INTERFACE = false
  LABEL = true
  OMIT_HEADER = true
  SORT_DEFAULT = nil
  def init
    @entity = @model
    @model = @session.valid_values(:yus_privileges).select { |privilege|
      action, key = privilege.split('|')
      @session.user.allowed?('grant', action)
    }
    super
  end
  def checkbox(model)
    box = HtmlGrid::InputCheckbox.new("yus_privileges[#{model}]", model, 
                                      @session, self)
    priv = model.split('|')
    if(@entity.privileged?(*priv))
      box.set_attribute('checked', true)
    elsif(@entity.allowed?(*priv))
      box.set_attribute('disabled', true)
    end
    [box, model.sub('|', ' ')] #@lookandfeel.lookup(model)]
  end
  def row_css(model)
    priv = model.split('|')
    'disabled' if(!@entity.privileged?(*priv) && @entity.allowed?(*priv))
  end
end
class YusGroups < HtmlGrid::List
  COMPONENTS = {
    [0,0] =>  :checkbox,
  }
  LEGACY_INTERFACE = false
  LABEL = true
  OMIT_HEADER = true
  def init
    @model = @session.user.groups.reject { |group| group.name == @model.name }
    super
  end
  def checkbox(model)
    name = model.name
    affs = @container.model.affiliations || []
    box = HtmlGrid::InputCheckbox.new("yus_groups[#{name}]", model, 
                                      @session, self)
    if(affs.any? { |aff| aff.name == name })
      box.set_attribute('checked', true)
    end
    [box, name]
  end
end
class EntityForm < Form
  def EntityForm.preferences(*args)
    args.each { |name|
      define_method(name) { |model|
        input = HtmlGrid::InputText.new(name, model, @session, self)
        input.value = @session.yus_get_preference(model.name, name)
        input
      }
    }
  end
  include HtmlGrid::ErrorMessage
  LABELS = true
  LEGACY_INTERFACE = false
  LOOKANDFEEL_MAP = {
    :name => :email, 
  }
  COMPONENTS = {
    [0,0] =>  :name,
    [0,1] =>  :salutation,
    [0,2] =>  :name_first,
    [2,2] =>  :name_last,
    [0,3] =>  :address,
    [0,4] =>  :plz,
    [2,4] =>  :city,
    [0,5] =>  :groups,
    [2,5] =>  :privileges,
    [0,6] =>  :association,
    [0,7] =>  :set_pass_1,
    [1,7] =>  :set_pass,
    [2,7] =>  :set_pass_2,
    [1,8] =>  :submit,
  }
  COMPONENT_CSS_MAP = {
    [1,0,4,5] =>  'standard',
    [1,6]     =>  'standard',
  }
  CSS_MAP = {
    [0,0,4,5] =>  'list',
    [0,5,4]   =>  'list top', 
    [0,6,4,3] =>  'list',
  }
  SYMBOL_MAP = {
    :salutation => HtmlGrid::Select,
  }
  preferences :name_first, :name_last, :address, :plz, :city
  def init
    super
    error_message()
  end
  def association(model)
    ass, priv = nil
    input = HtmlGrid::InputText.new(:yus_association, model, @session, self)
    if(model.respond_to?(:association) && (priv = model.association))
      input.value = priv
    elsif(ass = @session.app.yus_model(model.name))
      priv = ass.pointer.to_yus_privilege
      input.value = priv
    end
    input
  end
  def privileges(model)
    YusPrivileges.new(model, @session, self)
  end
  def groups(model)
    YusGroups.new(model, @session, self)
  end
  def pass(model, key)
    if(set_pass? && @session.user.allowed?('set_password', model.name))
      HtmlGrid::Pass.new(key, model, @session, self)
    end
  end
  def salutation(model)
    input = HtmlGrid::Select.new(:salutation, model, @session, self)
    input.selected = @session.yus_get_preference(model.name, :salutation)
    input
  end
  def set_pass_1(model)
    pass(model, :set_pass_1)
  end
  def set_pass_2(model)
    pass(model, :set_pass_2)
  end
  def set_pass(model)
    unless(set_pass? || !@session.user.allowed?('set_password', model.name))
      button = HtmlGrid::Button.new(:set_pass, model, @session, self)
      script = 'this.form.event.value="set_pass"; this.form.submit();'
      button.set_attribute('onClick', script)
      button
    end
  end
  def set_pass?
    @model.is_a?(Persistence::CreateItem) || @session.event == :set_pass
  end
end
class EntityComposite < HtmlGrid::Composite
  LEGACY_INTERFACE = false
  COMPONENTS = {
    [0,0] =>  :name,
    [0,1] =>  EntityForm,
  }
  CSS_CLASS = 'composite'
  CSS_MAP = {
    [0,0] =>  'th', 
  }
  DEFAULT_CLASS = HtmlGrid::Value
end
class Entity < View::PrivateTemplate
  CONTENT = EntityComposite
end
    end
  end
end
