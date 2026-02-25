#!/usr/bin/env ruby

# State::Admin::Entity -- oddb.org -- 08.06.2006 -- hwyss@ywesee.com

require "state/global_predefine"
require "view/admin/entity"

module ODDB
  module State
    module Admin
      class Entity < Global
        VIEW = ODDB::View::Admin::Entity
        def update
          # User management is now handled via etc/swiyu_roles.yml
          self
        end

        def set_pass
          # Passwords removed — authentication via Swiyu
          self
        end
      end
    end
  end
end
