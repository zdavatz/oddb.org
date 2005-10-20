#!/usr/bin/env ruby
# State::Migel::Global  -- oddb -- 04.10.2005 -- ffricker@ywesee.com

require 'state/migel/init'
require 'state/legalnote'

module ODDB
	module State
		module Migel
class Global < State::Global
	HOME_STATE = State::Migel::Init
	ZONE = :migel
	def legal_note
		State::Migel::LegalNote.new(@session, nil)
	end
end
		end
	end
end
