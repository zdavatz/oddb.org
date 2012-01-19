#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Narcotic -- oddb.org -- 19.01.2012 -- ffricker@ywesee.com
# ODDB::Narcotic -- oddb.org -- 04.11.2005 -- ffricker@ywesee.com

require 'util/persistence'
require 'util/language'

module ODDB
  class Narcotic2
    include Persistence
    include Language
    attr_accessor :package, :ikskey
  end
end
