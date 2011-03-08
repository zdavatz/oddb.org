#!/usr/bin/env ruby
# State::Migel::Product -- oddb -- 08.03.2011 -- mhatakeyama@ywesee.com
# State::Migel::Product -- oddb -- 05.10.2005 -- ffricker@ywesee.com

require 'view/migel/product'

module ODDB
  module State
    module Migel
      class Product < Global
        VIEW = View::Migel::Product
        LIMITED = true
      end
    end
  end
end
