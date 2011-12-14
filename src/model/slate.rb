#!/usr/bin/env ruby
# encoding: utf-8
# Slate -- oddb -- 19.04.2005 -- hwyss@ywesee.com

require 'util/persistence'
require 'model/invoice'

module ODDB
	class Slate
		include Persistence
		attr_reader :items
		def initialize(name)
			@name = name
			@items = {}
		end
		def create_item
			item = InvoiceItem.new
			@items.store(item.oid, item)
		end
		def item(oid)
			@items[oid]
		end
	end
end
