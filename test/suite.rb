#!/usr/bin/env ruby
# suite.rb -- oddb -- 18.11.2002 -- hwyss@ywesee.com 

$: << File.expand_path(File.dirname(__FILE__))

directories = []

require '../../sbsm/test/suite'
require '../../htmlgrid/test/suite'
require '../../datastructure/test/suite'
Dir.foreach(File.dirname(__FILE__)) { |dir|
	if /^test_.*/o.match(dir)
		directories << File.expand_path(dir, File.dirname(__FILE__))
	end
}

directories.each { |dir|
	if(File.ftype(dir) == 'directory')
		Dir.foreach(dir) { |file|
			if /.*\.rb$/o.match(file)&&file!='suite.rb'
				#require file 
				require File.expand_path(file, dir)
			end
		}
	end
}
