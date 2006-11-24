#!/usr/bin/env ruby
# CommercialForm -- oddb.org -- 23.11.2006 -- hwyss@ywesee.com

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
				pac.commercial_form = self
				pac.odba_isolated_store
			}
			self.synonyms += other.all_descriptions - self.all_descriptions
		end
  end
end
