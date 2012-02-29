#!/usr/bin/env ruby
# encoding: utf-8

puts 'loading testenvironment2'
module ODDB
  module OdbaExporter
   class GenericXls
     remove_const :RECIPIENTS
     RECIPIENTS = ['mhatakeyama@ywesee.com']
   end
  end
end
