#!/usr/bin/env ruby
# States -- oddb -- 22.10.2002 -- hwyss@ywesee.com

def require_r(dir, prefix)
	path = File.expand_path(dir)
	Dir.entries(path).each { |file|
		if /^[a-z_]+\.rb$/.match(file)
			#print file
			#print ":"
			#puts file
			require([prefix, file].join('/'))
		elsif(!/^\./.match(file))
			dirpath = File.expand_path(file, path)
			new_prefix = [prefix, file].join('/')
			if (File.ftype(dirpath) == 'directory')
				require_r(dirpath, new_prefix)
			end
		end
	}
end

require_r(File.expand_path(File.dirname(__FILE__)), 'state')
