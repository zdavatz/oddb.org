#!/usr/bin/env ruby
# MiniFi -- oddb.org -- 23.04.2007 -- hwyss@ywesee.com

require 'model/text'

module ODDB
  class MiniFi
		include ODBA::Persistable
    include Language
    ODBA_SERIALIZABLE = [ '@descriptions' ]
    attr_accessor :name, :publication_date
    alias :pointer_descr :name
    odba_index :publication_date
  end
end
