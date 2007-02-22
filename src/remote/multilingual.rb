#!/usr/bin/env ruby
# Remote::Multilingual -- de.oddb.org -- 22.02.2007 -- hwyss@ywesee.com

require 'remote/object'

module ODDB
  module Remote
    class Multilingual < Remote::Object
      def de
        @remote.de
      end
    end
  end
end
