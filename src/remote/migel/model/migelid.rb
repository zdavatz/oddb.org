#!/usr/bin/env ruby
# encoding: utf-8
# Migel::Model::Migelid -- migel -- 06.09.2011 -- mhatakeyama@ywesee.com

# This is necessary for a drb client connection from ch.oddb.org
# because ODDB::Migel::Product@items is a Hash, not an Array.
class Array
  def values
    self
  end
end

module Migel
  module Model
    class Migelid < Migel::ModelSuper
      belongs_to :subgroup, delegates(:group)
      #has_many :products, on_delete(:cascade), on_save(:cascade)
      has_many :products, on_delete(:cascade)
      has_many :accessories
      has_many :migelids
			attr_accessor :limitation, :price, :type, :date, :qty
      attr_reader  :code
			alias :pointer_descr :code
      alias :items :products
      multilingual :limitation_text
      multilingual :migelid_text
      multilingual :name
      multilingual :unit
      alias :product_text :migelid_text
			def initialize(code)
        @code = code
      end
			def migel_code
				[ subgroup.migel_code, code ].join('.')
			end
      def parent(app = nil)
        @subgroup
      end
      def update_multilingual(data, language)
        data.keys.each do |key|
          self.send(key, true).send(language.to_s + '=', data[key])
        end
        if @limitation_text
          @limitation_text.parent = self
        end
      end
      def full_description(lang = 'de')
        [subgroup.group.name.send(lang)||'', subgroup.name.send(lang)||'', name.send(lang), (migelid_text and migelid_text.send(lang) or '')].join(' ')
      end
      def add_accessory(acc)
        accessories.push(acc)
			end
      def add_migelid(mi)
        unless(migelids.include?(mi))
          mi.add_accessory(self)
          migelids.push(mi)
        end
        mi
      end
      def localized_name(language)
        self
      end
      def structural_ancestors(app)
        # This is necessary for the snapback links of view class in migel DRb client (oddb.org/src/view/migel/product.rb)
        [group, subgroup]
      end
      def limitation_text(update = false)
        if update
          @limitation_text ||= Migel::Util::Multilingual.new
        else
          if @limitation_text
            ODBA::DRbWrapper.new(@limitation_text)
          end
        end
      end
      def en
        name.de
      end
      def de
        name.de
      end
      def fr
        name.fr
      end
		end
	end
end
