#!/usr/bin/env ruby
# State::Admin::Entities -- oddb.org -- 08.06.2006 -- hwyss@ywesee.com

require 'state/global_predefine'
require 'view/admin/entities'

module ODDB
  module State
    module Admin
class Entities < Global
  DIRECT_EVENT = :users
  VIEW = View::Admin::Entities
  def init
    super
    @model = @session.user.entities
  end
end
    end
  end
end
