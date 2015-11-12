#!/usr/bin/env ruby
# TestSuite -- fipdf -- 19.02.2004 -- hwyss@ywesee.com

class Dir
	def Dir.recursive(dirpath, parent=dirpath, &block)
		foreach(dirpath) { |item|
			path = File.expand_path(item, parent)
			if(!/^\.{1,2}$/.match(item) && File.ftype(path) == 'directory')
				recursive(File.expand_path(item, dirpath), path, &block)
			else
				block.call(path)
			end
		}
	end
end

Dir.recursive(File.expand_path(File.dirname(__FILE__))) { |item|
	if(/test.*\.rb$/.match(item))
		require item
	end
}
