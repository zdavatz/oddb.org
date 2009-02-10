#!/usr/bin/env ruby
# State::Admin::MergeIndication -- oddb -- 07.07.2003 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'view/admin/mergeindication'

module ODDB
	module State
		module Admin
class MergeIndication < State::Admin::Global
	VIEW = View::Admin::MergeIndication
  def merge
    indication = @session.user_input(:indication)
    target = @session.app.indication_by_text(indication)
    if(target.nil?)
      @errors.store(:indication, create_error('e_unknown_indication', :indication, indication))
      self
    elsif(target == @model)
      @errors.store(:indication, create_error('e_selfmerge_indication', :indication, indication))
      self
    else
      @session.app.merge_indications(@model, target)
      State::Admin::Indication.new(@session, target)
    end
  end
end
		end
	end
end
