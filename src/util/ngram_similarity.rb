#!/usr/bin/env ruby
# encoding: utf-8
# n-gram similarity -- oddb.org -- 19.06.2009 -- hwyss@ywesee.com

module ODDB
  module Util
module NGramSimilarity
  def self.compare(str1, str2, n=5)
    str1 = u(str1).downcase.gsub(/[\s,.\-\/]+/, '')
    str2 = u(str2).downcase.gsub(/[\s,.\-\/]+/, '')
    if(str1.length < str2.length)
      str1, str2 = str2, str1
    end
    parts = [ str1.length - n, 0 ].max + 1
    count = 0
    parts.times { |idx|
      if(str2.include? str1[idx, n])
        count += 1
      end
    }
    count.to_f / parts
  end
end
  end
end
