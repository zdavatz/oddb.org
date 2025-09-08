#!/usr/bin/env ruby

# ODDB::State::Drugs::DDD -- oddb.org -- 20.10.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Drugs::DDD -- oddb.org -- 01.03.2004 -- hwyss@ywesee.com

require "state/drugs/global"
require "view/drugs/ddd"

module ODDB
  module State
    module Drugs
      class DDD < State::Drugs::Global
        VIEW = View::Drugs::DDD
        LIMITED = true
        def init
          @model = if (pointer = @session.user_input(:pointer))
            pointer.resolve(@session.app)
          elsif atc_code = @session.user_input(:atc_code) and atc_class = @session.app.atc_class(atc_code)
            atc_class
          end
          #     if((pointer = @session.user_input(:pointer))
          #       && (atc = pointer.resolve(@session.app)))
          #       @model = [atc]
          #       while((code = atc.parent_code)
          #         && (atc = @session.app.atc_class(code)))
          #         @model.unshift(atc) if(atc.has_ddd?)
          #       end
          #     else
          #       @model = []
          #     end
        end
      end
    end
  end
end
