#!/usr/bin/env ruby
# View::Drugs::RootResult -- oddb -- 07.03.2003 -- hwyss@ywesee.com 

require 'view/drugs/resultlist'
require 'view/pointervalue'

module ODDB
	module View
		module Drugs
class RootResultList < View::Drugs::ResultList
	def reorganize_components
		super
		hash_insert(css_head_map, [0,0], 'th')
		hash_insert(css_map, [0,0], 'result-edit')
		hash_insert(components, [0,0], :ikskey)
	end
	def ikskey(model, session=@session)
		#@ikskey_count ||= 0
		#@ikskey_count += 1
		span = HtmlGrid::Span.new(model, @session, self)
		#tooltip = HtmlGrid::Div.new(model, @session, self)
		span.value = [
			[:iksnr, model.registration], [:seqnr, model.sequence], [:ikscd, model]
		].collect { |key, item|
			View::PointerLink.new(key, item, @session, self)
		}
=begin
		span.css_id = "iksnr_#@ikskey_count"
		span.dojo_tooltip = tooltip
		link = View::PointerLink.new(:ikskey, model, @session, self)
		span.value = link
=end
		span
	end
	private
	def hash_insert(hash, key, val)
		tmp = hash.sort.reverse
		hash.clear
		tmp.each { |matrix, value|
			mtrx = matrix.dup
			unless((mtrx <=> key) == -1)
				mtrx[0] += 1
			end
			hash.store(mtrx, value)
		}
		hash.store(key, val)
	end
end
		end
	end
end
