#!/usr/bin/env ruby
# encoding: utf-8
# Remote::GalenicForm -- de.oddb.org -- 22.02.2007 -- hwyss@ywesee.com

require 'remote/object'
require 'remote/galenic_group'
require 'oddb/util/multilingual'

module ODDB
  module Remote
    class GalenicForm < Remote::Object
      def equivalent_to?(other)      
        other && (other.has_description?(@remote.description.de) \
          || (galenic_group && \
              galenic_group.equivalent_to?(other.galenic_group)))
      end
      def galenic_group
        @group ||= if(group = @remote.group)
                     Remote::GalenicGroup.new(group)
                   end
      end
    end
  end
end
