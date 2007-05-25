#!/usr/bin/env ruby
# View::Latin1 -- oddb.org -- 23.05.2007 -- hwyss@ywesee.com

module ODDB
  module View
module Latin1
  def sanitize(string)
    string = string.dup
    string.gsub!("\140", '-')
    string.gsub!(/[\x00-\x08\x0b-\x1f\x7f-\x9f]/, '')
    string
  end
end
  end
end
