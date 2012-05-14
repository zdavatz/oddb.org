#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::ShortenPath -- oddb.org -- 14.05.2012 -- yasaka@ywesee.com

require 'util/persistence'

module ODDB
  class ShortenPath
    class << self
      include AccessorCheckMethod
    end
 		include Persistence
    ODBA_PREFETCH = true
    attr_accessor :created, :origin_path, :shorten_path
    check_accessor_list = {
      :origin_path  => 'String',
      :shorten_path => 'String',
    }
    define_check_class_methods check_accessor_list
    def initialize(shorten_path='', origin_path='')
      @created = Time.now.to_s
      @origin_path = origin_path
      @shorten_path = shorten_path
    end
  end
end
