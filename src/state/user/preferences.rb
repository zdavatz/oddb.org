# encoding: utf-8
# ODDB::State::User::Preferences -- oddb -- 03.10.2012 -- yasaka@ywesee.com

require 'state/global_predefine'
require 'view/user/preferences'

module ODDB
  module State
    module User
class Preferences < State::Global
  DIRECT_EVENT = :preferences
  VIEW = View::User::Preferences
  SNAPBACK_EVENT = nil
  def update
    if style = @session.user_input(:style)
      @session.set_cookie_input(:style, style)
    end
    if type = @session.user_input(:search_type)
      @session.set_cookie_input(:search_type, type)
      @session.set_persistent_user_input(:search_type, type)
    end
    self
  end
end
    end
  end
end
