#!/usr/bin/env ruby
# View::Admin::MergeCommercialForm -- oddb.org -- 24.11.2006 -- hwyss@ywesee.com

module ODDB
  module View
    module Admin
class MergeCommercialFormForm < View::Form
  include HtmlGrid::ErrorMessage
  LABELS = false
  COMPONENTS = {
    [0,0,0] =>  :description,
    [0,0,1] =>  'merge_with',
    [1,0,2] =>  :commercial_form,
    [1,1]   =>  :submit,
  }
  EVENT = 'merge'
  SYMBOL_MAP = {
    :commercial_form  =>  HtmlGrid::InputText
  }
  def init
    super
    error_message()
  end
  def description(model, offset)
    model.description(@lookandfeel.language)
  end
end
class MergeCommercialFormComposite < HtmlGrid::Composite
  COMPONENTS = {
    [0,0]  =>  'commercial_form',
    [0,1]  =>  :merge_commercial_form,
    [0,2]  =>  MergeCommercialFormForm,
  }
  CSS_CLASS = 'composite'
  CSS_MAP = {
    [0,0]  =>  'th',
  }
  LABELS = true
  def merge_commercial_form(model, session)
    @lookandfeel.lookup(:merge_commercial_form, @model.package_count)
  end
end
class MergeCommercialForm < PrivateTemplate
  CONTENT = MergeCommercialFormComposite
  SNAPBACK_EVENT = :commercial_forms
end
    end
  end
end
