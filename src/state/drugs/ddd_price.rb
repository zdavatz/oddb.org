#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::DDDPrice -- oddb.org -- 10.04.2006 -- hwyss@ywesee.com
# ODDB::State::Drugs::DDDPrice -- oddb.org -- 10.04.2006 -- hwyss@ywesee.com

require 'state/drugs/global'
require 'view/drugs/ddd_price'

module ODDB
	module State
		module Drugs
class DDDPrice < Global
  LIMITED = true
	VIEW = View::Drugs::DDDPrice
	def init
		super
    pointer = @session.user_input(:pointer)
    reg  = @session.user_input(:reg)
    seq  = @session.user_input(:seq)
    pac  = @session.user_input(:pack)
    @model = if pointer
               pointer.resolve(@session.app)
             elsif (reg = @session.app.registration(reg) and seq = reg.sequence(seq))
               seq.package(pac)
             end
	end
end
		end
	end
end
