#!/usr/bin/env ruby
# encoding: utf-8
# HtmlGrid::Composite -- oddb -- 17.02.2006 -- hwyss@ywesee.com

require 'htmlgrid/composite'

module HtmlGrid
	class Composite
		def Composite.event_link(name)
			define_method(name) { |*args|
				link = HtmlGrid::Link.new(name, args.first, @session, self)
				link.href = @lookandfeel._event_url(name)
				link
			}
		end
    def hash_insert_row(hash, key, val)
      tmp = hash.sort.reverse
      hash.clear
      tmp.each { |matrix, value|
        mtrx = matrix.dup
        unless((mtrx[1] <=> key[1]) == -1)
          mtrx[1] += 1
        end
        hash.store(mtrx, value)
      }
      hash.store(key, val)
    end
    def hash_insert_col(hash, key, val)
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
