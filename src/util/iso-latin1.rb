#!/usr/bin/env ruby
# Util::IsoLatin1 -- oddb -- 05.01.2006 -- hwyss@ywesee.com

module ODDB
	module Util
		module IsoLatin1
			def locale_downcase!
				self.tr!('ÄÁÂÀËÉÊÈÏÍÎÌÖÓÔÒÜÚÛÙ', 'äáâàëéêèïíîìöóôòüúûù')
			end
		end
	end
end

class String
	unless instance_methods.include?('_downcase')
		include ODDB::Util::IsoLatin1
		alias :_downcase :downcase
		alias :_downcase! :downcase!
		def downcase
			res = _downcase
			res.locale_downcase!
			res
		end
		def downcase!
			res = _downcase!
			locale_downcase! || res
		end
	end
end
