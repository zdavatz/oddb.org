#!/usr/bin/env ruby
# FiParse::MiniFi -- oddb.org -- 23.04.2007 -- hwyss@ywesee.com

require 'rpdf2txt/parser'
require 'model/text'
require 'facet/integer/even'

module ODDB
  module FiParse
    module Indications
      class Handler  < Rpdf2txt::SimpleHandler
        attr_reader :indications, :news
        def initialize
          super('')
          @iksnr = nil
          @indication = ''
          @indications = {}
          @news = []
        end
        def send_line_break
          case @out
          when /^(\s*\*\s*)?Zul\.-Nr\.:\s*(\d{5})/,
               /^(\s*\*\s*)?N.\s*d'AMM:\s*(\d{5})/
            @iksnr = $~[2]
            @indication = ''
          when %r{^(\s*\*\s*)?Indica[tz]ion[eis]?:?\s*(.*)},
               %r{^(\s*\*\s*)?Anwendung(?:en)?:?\s*(.*)}
            @indication << $~[2]
            @news.push(@iksnr) if(@iksnr && $~[1])
          when %r{^(\s*\*\s*)?Packung/en}, %r{^(\s*\*\s*)?Conditionnements},
               %r{^(\s*\*\s*)?Confezione/i},
               %r{^(\s*\*\s*)?Bemerkung}, %r{^(\s*\*\s*)?Remarque},
               %r{^(\s*\*\s*)?Osservazione/i}
            if @iksnr && !@indication.empty?
              @indications.store @iksnr, @indication.strip
            end
            @iksnr = nil
            @indication = ''
          else
            @indication << @out unless @indication.empty?
          end
          @out = ''
        end
      end
      def Indications.extract(filename)
        pdf = Rpdf2txt::Parser.new(File.read(filename), 'latin1')
        handler = Handler.new
        pdf.extract_text(handler)
        [handler.indications, handler.news]
      end
    end
  end
end
