#!/usr/bin/env ruby

# State::Admin::PasswordLost -- oddb -- 17.02.2006 -- hwyss@ywesee.com
# Password reset removed — authentication via Swiyu

require "state/global_predefine"
require "view/search"

module ODDB
  module State
    module Admin
      class PasswordLost < State::Global
        VIEW = View::Search
      end
    end
  end
end
