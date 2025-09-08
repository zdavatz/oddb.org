#!/usr/bin/env ruby
require "view/pharmacies/vcard"

module ODDB
  module State
    module Pharmacies
      class VCard < Global
        VIEW = View::Pharmacies::VCard
        VOLATILE = true
        LIMITED = false
        def init
          if pointer = @session.user_input(:pointer)
            @model = pointer.resolve(@session)
          end
          super
        end
      end
    end
  end
end
