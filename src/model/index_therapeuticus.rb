#!/usr/bin/env ruby
# IndexTherapeuticus -- oddb.org -- 20.05.2008 -- hwyss@ywesee.com

require 'util/language'
require 'model/text'

module ODDB
  class IndexTherapeuticus
    ODBA_SERIALIZABLE = ['@descriptions']
    include SimpleLanguage
    include ODBA::Persistable ## include directly to get odba_index
    attr_reader :code, :comment, :limitation_text 
    attr_accessor :source
    odba_index :code
    class << self
      alias :__find_by_normalized_code__ :find_by_code
      def find_by_code(code)
        __find_by_normalized_code__ normalize_code(code)
      end
      def normalize_code(code)
        if code && nonempty = code.to_s[/.*\d/]
          parts = nonempty.split('.', 3)
          if((str = parts.last) && str.length == 1)
            str << '0'
          end
          parts.collect! { |part| part.to_i }
          norm = ''
          while((part = parts.shift) && part > 0)
            norm << sprintf('%02i.', part)
          end
          norm
        end
      end
      def null
        @null ||= new nil
      end
    end
    def initialize code
      @code = self.class.normalize_code code
    end
    def create_comment
      @comment = Text::Document.new
    end
    def create_limitation_text
      @limitation_text = LimitationText.new
    end
    def delete_comment
      if(cm = @comment)
        @comment = nil
        cm
      end
    end
    def delete_limitation_text
      if(lt = @limitation_text)
        @limitation_text = nil
        lt
      end
    end
  end
end
