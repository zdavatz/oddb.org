#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::MergeIndication -- oddb.org -- 27.06.2011 -- mhatakeyama@ywesee.com 
# ODDB::State::Admin::MergeIndication -- oddb.org -- 07.07.2003 -- hwyss@ywesee.com 

require 'state/admin/global'
require 'view/admin/mergeindication'

module ODDB
	module State
		module Admin
class MergeIndication < State::Admin::Global
	VIEW = ODDB::View::Admin::MergeIndication
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
