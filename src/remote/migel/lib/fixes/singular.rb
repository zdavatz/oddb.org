#!/usr/bin/env ruby
# encoding: utf-8
# Fix for String#singular -- migel -- 10.10.2011 -- mhatakeyama@ywesee.com
# Fix for String#singular -- de.oddb.org -- 20.11.2006 -- hwyss@ywesee.com

require 'rubygems'
require 'facet/string/singular'

class String
  inflection_rule '', 'e', 'es'
end
