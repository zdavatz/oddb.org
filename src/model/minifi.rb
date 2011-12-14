#!/usr/bin/env ruby
# encoding: utf-8
# MiniFi -- oddb.org -- 23.04.2007 -- hwyss@ywesee.com

require 'model/text'
require 'model/registration_observer'

module ODDB
  class MiniFi
		include ODBA::Persistable
    include Language
		include RegistrationObserver
    ODBA_SERIALIZABLE = [ '@descriptions' ]
    attr_accessor :name, :publication_date
    alias :pointer_descr :name
    odba_index :publication_date
  end
end
