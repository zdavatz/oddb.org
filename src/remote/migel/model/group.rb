#!/usr/bin/env ruby
# encoding: utf-8
# Migel::Model::Group -- migel -- 06.09.2011 -- mhatakeyama@ywesee.com

module Migel
  module Model
    class Group < Migel::ModelSuper
      attr_reader :code
      has_many :subgroups, on_delete(:cascade) #, on_save(:cascade)
      multilingual :limitation_text
      multilingual :name
      alias :pointer_descr :code
      alias :migel_code :code
      def initialize(groupcd)
        @code = groupcd
      end
      def parent(app = nil)
        nil
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
