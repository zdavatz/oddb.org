#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::AssignDivision -- oddb.org -- 02.07.2012 -- yasaka@ywesee.com

require 'view/drugs/privatetemplate'
require 'view/admin/assign_deprived_sequence'
require 'htmlgrid/errormessage'

module ODDB
  module View
    module Admin
class AssignDivisionForm < View::Admin::AssignDeprivedSequenceForm
  COMPONENTS = {
    [0,0,0] => :division_pointer,
    [0,0,1] => :division_pointer_hidden,
    [1,0]   => :iksnr,
    [2,0]   => :seqnr,
    [3,0]   => :name_base,
    [4,0]   => :name_descr,
    [5,0]   => :dose,
    [6,0]   => :galenic_form,
    [7,0]   => :company_name,
    [8,0]   => :atc_class,
  }
  EVENT = :assign
  def division_pointer(model, session)
    seq = @model.sequence
    if model == seq || !@session.allowed?('edit', model)
      # nothing
    else
      check = HtmlGrid::InputCheckbox.new(
        "pointer_list[#{@list_index}]", model, session, self
      )
      check.value = model.pointer
      if seq.division and model.division == seq.division
        check.set_attribute('checked', true)
      else
        check.set_attribute('checked', false)
      end
      check
    end
  end
  def division_pointer_hidden(model, session)
    seq = @model.sequence
    if model == seq || !@session.allowed?('edit', model)
      # nothing
    else
      hidden = HtmlGrid::Input.new(
        "targets[#{@list_index}]", model, session, self
      )
      hidden.set_attribute('type', 'hidden')
      hidden.value = model.pointer
      hidden
    end
  end
end
class AssignDivisionComposite < HtmlGrid::Composite
  include HtmlGrid::ErrorMessage
  COMPONENTS = {
    [0,0] => :name,
    [0,1] => View::Admin::SearchField,
    [0,2] => View::Admin::AssignDivisionForm,
  }
  CSS_CLASS = 'composite'
  CSS_MAP = {
    [0,0] => 'th',
  }
  DEFAULT_CLASS = HtmlGrid::Value
  LEGACY_INTERFACE = false
  def init
    super
    error_message(1)
  end
  def name(model)
    @lookandfeel.lookup(:assign_division_explain, model.name_base)
  end
end
class AssignDivision < View::Drugs::PrivateTemplate
  SNAPBACK_EVENT = :result
  CONTENT = AssignDivisionComposite
end
    end
  end
end
