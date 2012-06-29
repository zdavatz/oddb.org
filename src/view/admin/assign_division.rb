#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Admin::AssignDivision -- oddb.org -- 29.06.2012 -- yasaka@ywesee.com

require 'view/drugs/privatetemplate'
require 'view/admin/assign_deprived_sequence'
require 'htmlgrid/errormessage'

module ODDB
  module View
    module Admin
class AssignDivisionForm < View::Admin::AssignDeprivedSequenceForm
  COMPONENTS = {
    [0,0] => :division_pointer,
    [1,0] => :iksnr,
    [2,0] => :seqnr,
    [3,0] => :name_base,
    [4,0] => :name_descr,
    [5,0] => :dose, 
    [6,0] => :galenic_form,
    [7,0] => :company_name,
    [8,0] => :atc_class,
  }
  EVENT = :assign
  def division_pointer(model, session)
    seq = @model.sequence
    if model == seq || !@session.allowed?('edit', model)
      # nothing
    elsif model.division == seq.division
      @lookandfeel.lookup(:assign_division_equal)      
    else
      check = HtmlGrid::InputCheckbox.new(
        "pointer_list[#{@list_index}]", model, session, self
      )
      check.value = model.pointer
      check
    end
  end
  #def compose_footer(matrix)
  #  super
  #  btn = HtmlGrid::Button.new :back, @model, @session, self
  #  args = [:reg, @model.sequence.iksnr, :seq, @model.sequence.seqnr]
  #  url = @lookandfeel._event_url(:drug, args)
  #  script = "location.href='#{url}'"
  #  btn.set_attribute('onClick', script)
  #  @grid.add(btn, *matrix)
  #end
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
