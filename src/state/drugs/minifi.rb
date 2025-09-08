#!/usr/bin/env ruby

# ODDB::State::Drugs::MiniFi -- oddb.org -- 25.10.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Drugs::MiniFi -- oddb.org -- 26.04.2007 -- hwyss@ywesee.com

require "state/global_predefine"
require "view/drugs/minifi"

module ODDB
  module State
    module Drugs
      class MiniFi < Global
        VIEW = View::Drugs::MiniFi
        def init
          @model = if iksnr = @session.user_input(:reg) and reg = @session.app.registration(iksnr)
            reg.minifi
          elsif pointer = @session.user_input(:pointer) and model = pointer.resolve(@session.app)
            model
          end
        end
      end
    end
  end
end
