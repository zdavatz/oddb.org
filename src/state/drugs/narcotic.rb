#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::Narcotic -- oddb.org -- 08.11.2005 -- mhatakeyama@ywesee.com
# ODDB::State::Drugs::Narcotic -- oddb.org -- 08.11.2005 -- spfenninger@ywesee.com

require 'view/drugs/narcotic'

module ODDB
	module State
		module Drugs
class Narcotic < State::Global
	VIEW = View::Drugs::Narcotic
  def init
    if odba_id = @session.user_input(:oid)
      @model = @session.app.narcotic(odba_id)
    elsif pointer = @session.user_input(:pointer)
      @model = pointer.resolve(@session.app)
    end
  end
end
class NarcoticPlus < State::Global
	VIEW = View::Drugs::NarcoticPlus
end
		end
	end
end
