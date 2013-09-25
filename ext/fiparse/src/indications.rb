#!/usr/bin/env ruby
# FiParse::MiniFi -- oddb.org -- 23.04.2007 -- hwyss@ywesee.com

require 'rpdf2txt/parser'  unless defined?(Minitest)
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
          when /^(\s*\*\s*)?Zul\.-Nr\.:\s*(\d{5})/u,
               /^(\s*\*\s*)?N.\s*d'AMM:\s*(\d{5})/u
            @iksnr = $~[2]
            @indication = ''
          when %r{^(\s*\*\s*)?Indica[tz]ion[eis]?:?\s*(.*)}u,
               %r{^(\s*\*\s*)?Anwendung(?:en)?:?\s*(.*)}u
            @indication << $~[2]
            @news.push(@iksnr) if(@iksnr && $~[1])
          when %r{^(\s*\*\s*)?Packung/en}u, %r{^(\s*\*\s*)?Conditionnements}u,
               %r{^(\s*\*\s*)?Confezione/i}u,
               %r{^(\s*\*\s*)?Bemerkung}u, %r{^(\s*\*\s*)?Remarque}u,
               %r{^(\s*\*\s*)?Osservazione/i}u
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
        pdf = Rpdf2txt::Parser.new(File.read(filename), 'UTF-8')
        handler = Handler.new
        pdf.extract_text(handler)
        [handler.indications, handler.news]
      end
    end
  end  unless defined?(Minitest)
end
