#!/usr/bin/env ruby

# ODDB::State::Ajax::SwissmedicCat -- oddb.org -- 14.11.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Ajax::SwissmedicCat -- oddb.org -- 15.03.2006 -- sfrischknecht@ywesee.com

require "state/ajax/global"
require "view/ajax/swissmedic_cat"

module ODDB
  module State
    module Ajax
      class SwissmedicCat < Global
        VIEW = View::Ajax::SwissmedicCat
        def init
          super
          iksnr = @session.user_input(:reg)
          seqnr = @session.user_input(:seq)
          ikscd = @session.user_input(:pack)
          @model = if reg = @session.app.registration(iksnr) and seq = reg.sequence(seqnr) and pac = seq.package(ikscd)
            pac
          end
        end
      end
    end
  end
end
