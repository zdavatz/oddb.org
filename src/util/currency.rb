# encoding: utf-8
require 'drb'
require 'util/oddbconfig'

module ODDB
  Currency = DRbObject.new(nil, ODDB::CURRENCY_URI)
end
