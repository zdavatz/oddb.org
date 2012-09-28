# encoding: utf-8
# ODDB::State::User::StyleChooser -- oddb -- 28.09.2012 -- yasaka@ywesee.com

require 'state/global_predefine'
require 'view/user/style_chooser'

module ODDB
  module State
    module User
class StyleChooser < State::Global
  DIRECT_EVENT = :style_chooser
  VIEW = View::User::StyleChooser
  SNAPBACK_EVENT = nil
  def update
    if style = @session.user_input(:style)
      @session.set_cookie_input(:style, style)
    end
    self
  end
end
    end
  end
end

