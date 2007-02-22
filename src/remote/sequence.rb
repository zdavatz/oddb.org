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
        galenic_form && galenic_form.equivalent_to?(other.galenic_form)\
          && doses == [other.dose]
      end
      def doses
        @doses ||= @remote.doses
      end
      def galenic_form
        @galenic_form ||= Remote::GalenicForm.new(@remote.galenic_forms.first)
      end
    end
  end
end
