#!/usr/bin/env ruby
# Dir -- ODDB -- 21.10.2003 -- hwyss@ywesee.com

class Dir
	def Dir.mkdir_r(name)
		parent = File.dirname(name)
		unless(File.exist?(parent))
			self.mkdir_r(parent)
		end
		mkdir(name)
	end
end
