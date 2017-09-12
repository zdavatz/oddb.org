# encoding: utf-8
# ODDB::State::User::Preferences -- oddb -- 04.10.2012 -- yasaka@ywesee.com

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
    [ :search_type,
      :search_form,
      :search_imitation_only,
      :search_imitation_A,
      :search_imitation_B,
      :search_imitation_C,
      :search_imitation_D,
      :search_imitation_E,
      :search_imitation_valid,
     ].each do |key|
      if val = !!@session.user_input(key)
        @session.set_cookie_input(key, val)
        @session.set_persistent_user_input(key, val)
      end
    end
    if zsr_id = @session.user_input(:zsr_id)
      zsr_id = zsr_id.gsub(/[ \.]/, '')
      @session.set_cookie_input(:zsr_id, zsr_id)
      @session.set_persistent_user_input(:zsr_id, zsr_id)
    end
    self
  end
end
    end
  end
end
