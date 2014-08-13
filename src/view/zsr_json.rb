#!/usr/bin/env ruby
# encoding: utf-8

require 'htmlgrid/composite'
require 'util/zsr'
require 'json'

module ODDB
  module View
    class ZsrJson < HtmlGrid::Composite
      COMPONENTS = {
        [1,0] =>  :zsr,
        [1,1] =>  :gln_in,
        [1,1] =>  :title,
        [1,1] =>  :first_name,
        [1,1] =>  :last_name,
        [1,1] =>  :street,
        [1,1] =>  :pobox,
        [1,1] =>  :zip,
        [1,1] =>  :city,
        [1,1] =>  :phone,
        [1,1] =>  :fax,
      }
      DEFAULT_CLASS = HtmlGrid::Text
      LEGACY_INTERFACE = false
      def init
        zsr_id = @session.request_path.split('/').last
        @info = ODDB::ZSR.info(zsr_id)
        super
      end
      def to_html(context = nil)
        @info.to_json
      end
    end
  end
end
