#!/usr/bin/env ruby
# ModelLoader -- oddb -- 03.03.2003 -- hwyss@ywesee.com 

dir = File.expand_path('model', File.dirname(__FILE__))
Dir.foreach(dir) { |filename|
	require('model/' + filename) if /\.rb$/u.match(filename)
}
%w{analysis migel}.each do |subdir|
  prefix = "model/#{subdir}/"
  dir = File.expand_path(prefix, File.dirname(__FILE__))
  Dir.foreach(dir) { |filename|
    require(prefix + filename) if /\.rb$/u.match(filename)
  }
end
