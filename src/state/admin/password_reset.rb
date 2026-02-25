#!/usr/bin/env ruby

# State::Admin::PasswordReset -- oddb -- 20.02.2006 -- hwyss@ywesee.com
# Password reset removed — authentication via Swiyu

require "state/global_predefine"
require "state/admin/login"
require "view/search"

module ODDB
  module State
    module Admin
      class PasswordReset < Global
        VIEW = View::Search
      end
    end
  end
end
