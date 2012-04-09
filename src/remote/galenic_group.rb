#!/usr/bin/env ruby
# encoding: utf-8
# Remote::GalenicGroup -- de.oddb.org -- 09.04.2012 -- yasaka@ywesee.com
# Remote::GalenicGroup -- de.oddb.org -- 22.02.2007 -- hwyss@ywesee.com

require 'remote/object'
require 'remote/migel/util/multilingual'

module ODDB
  module Remote
    class GalenicGroup < Remote::Object
      def equivalent_to?(other)
        other && other.has_description?(@remote.name.de)
      end
    end
  end
end
