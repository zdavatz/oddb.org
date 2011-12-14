#!/usr/bin/env ruby
# encoding: utf-8
# Remote::Package -- de.oddb.org -- 22.02.2007 -- hwyss@ywesee.com

require 'remote/object'
require 'remote/sequence'

module ODDB
  module Remote
    class Package < Remote::Object
      def comparable?(other)
        csize = comparable_size
        csize.length == 1 or return false
        size = csize.first
        range = (size*0.75)..(size*1.25)
        range.include?(other.comparable_size)
      end
      def comparable_size
        @comparable_size ||= @remote.comparable_size
      end
      def sequence
        @sequence ||= Remote::Sequence.new(@remote.sequence)
      end
      def size
        @size ||= @remote.size
      end
    end
  end
end
