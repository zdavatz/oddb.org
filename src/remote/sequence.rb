#!/usr/bin/env ruby
# Remote::Sequence -- de.oddb.org -- 22.02.2007 -- hwyss@ywesee.com

require 'remote/object'
require 'remote/galenic_form'
require 'model/dose'

module ODDB
  module Remote
    class Sequence < Remote::Object
      def atc_code
        @atc_code ||= (atc = @remote.atc) && atc.code
      end
      def comparable?(other)
        galenic_forms.size == other.galenic_forms.size \
          && doses == other.doses \
          && galenic_forms.each_with_index { |form, idx| 
            if !form.equivalent_to?(other.galenic_forms[idx])
              return false
            end
        }
      end
      def doses
        @doses ||= @remote.doses
      end
      def galenic_forms
        @galenic_forms ||= @remote.galenic_forms.collect { |form|
          Remote::GalenicForm.new(form)
        }
      end
    end
  end
end
