#!/usr/bin/env ruby
# encoding: utf-8
# View::Drugs::RootResult -- oddb -- 07.03.2003 -- hwyss@ywesee.com 

require 'view/drugs/resultlist'
require 'view/pointervalue'

module ODDB
	module View
		module Drugs
class RootResultList < View::Drugs::ResultList
	def reorganize_components(*args)
		super
		hash_insert_col(css_head_map, [0,0], 'th')
		hash_insert_col(css_map, [0,0], 'list edit')
		hash_insert_col(components, [0,0], :ikskey)
	end
	def ikskey(model, session=@session)
		span = HtmlGrid::Span.new(model, @session, self)
		span.value = [
			[:iksnr, model.registration], [:seqnr, model.sequence], [:ikscd, model]
		].collect { |key, item|
			View::PointerLink.new(key, item, @session, self)
		}
		span
	end
end
		end
	end
end
