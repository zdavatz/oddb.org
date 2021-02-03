#!/usr/bin/env ruby
# Niklaus Giger 2020.06.12
#   Run each spec (Watir) test via ssh -x as chromedriver often fails after
#       running a few files
# Find alle errors via grep 'rspec ./spec' rspec_*.log
require 'date'
require 'fileutils'
log_file = 'rspec_'+Time.new.strftime('%Y.%m.%d:%H.%M')+'.log'
FileUtils.rm_f(log_file, verbose: true)
files = Dir.glob('spec/*spec.rb').sort.reverse
files.each do |name|
  content = %(#!/usr/bin/env bash
cd git/oddb.org
echo "Running #{name}"
# Xvfb :1 -screen 5 1280x1024x24 -nolisten tcp 2>/dev/null &
# export DISPLAY=:1.5

bundle exec rspec #{name}
# killall Xvfb 2> /dev/null
echo "Finished #{name}"
)
  File.open('tmp.sh', 'w+') do
    |f| f.write content
  end
  FileUtils.chmod('+x', 'tmp.sh')
  puts content
  system("ssh -X oddb-ci2.dyndns.org git/oddb.org/tmp.sh 2>&1 | tee -a #{log_file}")
end
