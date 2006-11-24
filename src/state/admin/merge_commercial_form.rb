#!/usr/bin/env ruby
# State::Admin::MergeCommercialForm -- oddb.org -- 24.11.2006 -- hwyss@ywesee.com

require 'state/admin/global'
require 'view/admin/merge_commercial_form'

module ODDB
  module State
    module Admin
class MergeCommercialForm < State::Admin::Global
  VIEW = View::Admin::MergeCommercialForm
  def merge
    commercial_form = @session.user_input(:commercial_form)
    target = ODDB::CommercialForm.find_by_name(commercial_form)
    if(target.nil?)
      @errors.store(:commercial_form, create_error('e_unknown_commercial_form', :commercial_form, commercial_form))
      self
    elsif(target == @model)
      @errors.store(:commercial_form, create_error('e_selfmerge_commercial_form', :commercial_form, commercial_form))
      self
    else
      @session.app.merge_commercial_forms(@model, target)
      State::Admin::CommercialForm.new(@session, target)  
    end
  end
end
    end
  end
end
