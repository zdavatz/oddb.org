#!/usr/bin/env ruby

# OneDirSuite -- oddb -- 20.10.2003 -- mhuggler@ywesee.com

$: << __dir__

Dir.foreach(File.dirname(__FILE__)) { |file|
  if /.*\.rb$/o.match(file) && file != "suite.rb"
    require file
  end
}
