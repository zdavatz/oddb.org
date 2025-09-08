#!/usr/bin/env ruby

# State::Admin::GalenicGroup -- oddb -- 26.03.2003 -- andy@jetnet.ch

require "state/admin/global"
require "state/admin/galenicgroups"
require "view/admin/galenicgroup"

module ODDB
  module State
    module Admin
      class GalenicGroup < State::Admin::Global
        VIEW = View::Admin::GalenicGroup
        def delete
          @session.app.delete(@model.pointer)
          galenic_groups # from RootState
        rescue => e
          State::Exception.new(@session, e)
        end

        def update
          keys = [:route_of_administration].concat @session.lookandfeel.languages
          input = user_input(keys)
          @model = @session.app.update(@model.pointer, input, unique_email)
          self
        end
      end
    end
  end
end
