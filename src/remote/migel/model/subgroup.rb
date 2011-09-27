#!/usr/bin/env ruby
# encoding: utf-8
# Migel::Model::Subgroup -- migel -- 06.09.2011 -- mhatakeyama@ywesee.com

module Migel
  module Model
    class Subgroup < Migel::ModelSuper
      belongs_to :group
      #has_many :migelids, on_delete(:cascade), on_save(:cascade)
      has_many :migelids, on_delete(:cascade)
      attr_reader :code
      alias :pointer_descr :code
      alias :products :migelids
      multilingual :limitation_text
      multilingual :name
			def initialize(code)
				@code = code
      end
      def parent(app = nil)
        @group
      end
			def migel_code
				[ group.code, code ].join('.')
			end
      def structural_ancestors(app)
        [group]
      end
      def items
        nil
      end
      def product_text
        nil
      end
      def respond_to?(mth, *args)
        super
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
