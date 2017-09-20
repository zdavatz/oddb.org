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
    [:search_type, :search_form].each do |key|
      if val = @session.user_input(key)
        @session.set_cookie_input(key, val)
        @session.set_persistent_user_input(key, val)
        puts "1. Setting #{key} to #{val.inspect} from #{@session.user_input(key).inspect}"
      end
    end
    [ :search_limitation_A,
      :search_limitation_B,
      :search_limitation_C,
      :search_limitation_D,
      :search_limitation_E,
      :search_limitation_SL_only,
      :search_limitation_valid,
    ].each do |key|
      val = !!@session.user_input(key)
      @session.set_cookie_input(key, val.to_s)
      @session.set_persistent_user_input(key, val.to_s)
      puts "2. Setting #{key} to #{val.inspect} from #{@session.user_input(key).inspect}"
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
