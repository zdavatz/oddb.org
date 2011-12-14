#!/usr/bin/env ruby
# encoding: utf-8
# AcceptOrphan -- oddb -- 05.12.2003 -- rwaltert@ywesee.com

require 'util/persistence' 
require 'digest/md5'

module ODDB
	class AcceptOrphan
		def initialize(orphan, pointers, otype, origin=nil)
			@orphan = orphan
			@pointers = pointers
			@orphantype = otype
			@origin = origin
		end
		def	execute(app)
			pointer = ODDB::Persistence::Pointer.new(@orphantype)
			digest = Digest::MD5.hexdigest(@orphan.sort.to_s)
      info = app.accepted_orphans.fetch(digest) {
        inf = app.update(pointer.creator, @orphan, @origin)
        app.accepted_orphans.store(digest, inf)
        app.accepted_orphans.odba_store
        inf
      }
      @pointers.each { |ptr|
        parent = ptr.resolve(app)
        old_info = parent.send(@orphantype)
        writer = @orphantype.to_s << "="
        parent.send(writer, info)
        parent.odba_store
        if(old_info && old_info.empty?)
          app.delete(old_info.pointer)
        end
      }
		end
	end
end
