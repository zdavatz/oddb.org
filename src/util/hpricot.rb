# encoding: utf-8

##
# This Open-Class is needed for server that dose not have LANG env.
#
# String#force_encoding
# See:: /path/to/gems/hpricot/lib/hpricot/builder.rb
module Hpricot
  def self.uxs(str)
    str.to_s.force_encoding('utf-8').
        gsub(/\&(\w+);/) { [NamedCharacters[$1] || 63].pack("U*") }. # 63 = ?? (query char)
        gsub(/\&\#(\d+);/) { [$1.to_i].pack("U*") }
  end
  class Text
    def to_s
      str = content.force_encoding('utf-8')
      Hpricot.uxs(str)
    end
  end
end

