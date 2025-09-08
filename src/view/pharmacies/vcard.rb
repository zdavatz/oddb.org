#!/usr/bin/env ruby
require "htmlgrid/component"
require "view/vcard"

module ODDB
  module View
    module Pharmacies
      class VCard < View::VCard
        def init
          @content = [:name, :addresses]
        end

        def get_filename
          @model.name.gsub(/\s/u, "_").to_s +
            "_" + @model.ean13.gsub(/\s/u, "_").to_s + ".vcf"
        end
      end
    end
  end
end
