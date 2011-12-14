#!/usr/bin/env ruby
# encoding: utf-8
# encondig: utf-8
# Migel::Model::Product -- migel -- 06.09.2011 -- mhatakeyama@ywesee.com

module Migel
  module Model
    class Product < Migel::ModelSuper 
      belongs_to :migelid, delegates(:price, :qty, :unit, :migel_code)
      alias :pointer_descr :migel_code 
      attr_accessor :ean_code, :article_name, :companyname, :companyean, :ppha, :ppub, :factor, :pzr, :status, :datetime, :stdate, :language
      attr_reader :pharmacode
      multilingual :article_name
      multilingual :companyname
      multilingual :size
      alias :description :article_name
      alias :name :article_name
      alias :company_name :companyname
      def initialize(pharmacode)
        @pharmacode = pharmacode
      end
      def full_description(lang)
        [(article_name.send(lang) or ''), (companyname and companyname.send(lang) or '')].join(' ')
      end
      def to_s
        name.to_s
      end
=begin
      def <=>(other)
        self.pharmacode <=> other.pharmacode
      end
=end
    end
  end
end
