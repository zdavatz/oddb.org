#!/usr/bin/env ruby
# encondig: utf-8
# ODDB::Migel::Item -- oddb.org -- 15.08.2011 -- mhatakeyama@ywesee.com

require 'util/language'
require 'model/text'

module ODDB
  module Migel
    class Item
      include SimpleLanguage
      attr_accessor :ean_code, :pharmacode, :article_name, :companyname, :companyean, :ppha, :ppub, :factor, :pzr, :size, :status, :datetime, :stdate, :language
      attr_reader :product
      def initialize(product)
        @product = product
      end
      def price
        @product.price
      end
      def qty
        @product.qty
      end
      def unit
        @product.unit
      end
      def pointer_descr
        @product.migel_code
      end
      alias :migel_code :pointer_descr
    end
  end
end
