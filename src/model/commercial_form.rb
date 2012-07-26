#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::CommercialForm -- oddb.org -- 26.07.2012 -- yasaka@ywesee.com
# ODDB::CommercialForm -- oddb.org -- 23.11.2006 -- hwyss@ywesee.com

require 'util/language'
require 'model/package_observer'

module ODDB
  class CommercialForm
    include Language
    include PackageObserver
    include ODBA::Persistable ## include directly to get odba_index
		ODBA_SERIALIZABLE = [ '@descriptions', '@synonyms' ]
    odba_index :name, 'all_descriptions'
		def init(app)
			@pointer.append(@oid)
		end
		def merge(other)
			other.packages.dup.each { |pac|
        pac.parts.each { |part|
          if part.commercial_form == other
            part.commercial_form = self
            part.odba_isolated_store
          end
        }
				pac.odba_isolated_store
			}
			self.synonyms += other.all_descriptions - self.all_descriptions
		end
    def to_s
      self.description
    end
  end
end
