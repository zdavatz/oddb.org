#!/usr/bin/env ruby

# View::Pharmacies::Init -- oddb -- 15.02.2005 -- jlang@ywesee.com, usenguel@ywesee.com

require "view/publictemplate"
require "view/pharmacies/welcomehead"
require "view/pharmacies/centeredsearchform"

module ODDB
  module View
    module Pharmacies
      class Search < View::PublicTemplate
        CONTENT = View::Pharmacies::GoogleAdSenseComposite
        CSS_CLASS = "composite"
        HEAD = View::Pharmacies::WelcomeHeadPharmacies
      end
    end
  end
end
