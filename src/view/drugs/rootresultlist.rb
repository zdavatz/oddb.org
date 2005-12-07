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
	def iksnr(model, session)
		reg = model.registration
		View::PointerLink.new(:iksnr, reg, session, self)
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
