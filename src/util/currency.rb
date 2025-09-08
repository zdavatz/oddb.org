require "drb"
require "util/oddbconfig"

module ODDB
  CURRENCY_URI = "druby://localhost:10999"
  Currency = DRbObject.new(nil, ODDB::CURRENCY_URI)
end
