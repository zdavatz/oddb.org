#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Analysis::LimitationText -- oddb.org -- 11.01.2012 -- mhatakeyama@ywesee.com

require 'state/analysis/global'
require 'view/analysis/limitationtext'

module ODDB
	module State
		module Analysis
class LimitationText < State::Analysis::Global
	VIEW = ODDB::View::Analysis::LimitationText
	LIMITED = true
  def init
    if groupcd = @session.user_input(:group) and poscd   = @session.user_input(:position)\
      and group = @session.app.analysis_group(groupcd) and position = group.position(poscd)
      @model = position.limitation_text
    end
  end
end
		end
	end
end
