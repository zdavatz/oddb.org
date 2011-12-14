#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::LimitationText -- oddb.org -- 25.10.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Drugs::LimitationText -- oddb.org -- 14.11.2003 -- mhuggler@ywesee.com

require 'state/drugs/global'
require 'view/drugs/limitationtext'

module ODDB
	module State
		module Drugs
class LimitationText < State::Drugs::Global
	VIEW = View::Drugs::LimitationText
	LIMITED = true
  def init
    iksnr = @session.user_input(:reg)
    seqnr = @session.user_input(:seq)
    ikscd = @session.user_input(:pack)
    if reg = @session.app.registration(iksnr) and seq = reg.sequence(seqnr) and pack = seq.package(ikscd) and lt = pack.limitation_text
      @model = lt
    else
      @model = nil
    end
  end
end
		end
	end
end
