#!/usr/bin/env ruby
# suite.rb -- oddb.org -- 15.02.2011 -- mhatakeyama@ywesee.com 

$: << File.dirname(__FILE__)

require 'tempfile'

directories = []

Dir.foreach(File.dirname(__FILE__)) { |dir|
	if /^test_.*/o.match(dir)
		directories << File.expand_path(dir, File.dirname(__FILE__))
	end
}

rcov = true
coverage = nil
#command = 'system "rcov #{path} -t --aggregate #{coverage.path} >> #{temp_out.path 2>/dev/null}"'
command = 'system "rcov #{path} -t --aggregate #{coverage.path} >> #{temp_out.path}"'
begin
  Rcov
  coverage = Tempfile.new('coverage')
#  p coverage.path
rescue
  rcov = false
  command = 'system "ruby #{path} >> #{temp_out.path}"'
end

temp_out = Tempfile.new('temp_out')
directories.each_with_index { |dir, i|
	if(File.ftype(dir) == 'directory')
		Dir.foreach(dir) { |file|
			if /suite.rb$/o.match(file)
				path = File.expand_path(file, dir)
        puts "\nNow testing #{path}\n"
        eval(command)
			end
		}
	end
}

# report output
test_names = []
test_time  = 0.0
tests      = 0
assertions = 0
failures   = 0
errors     = 0

failure_error = []
failure_error_flag = false
failure_error_no = 0

rcov = nil
temp_out.each do |line|
  if line =~ /Loaded suite (.+)/
    test_names << $1
  end
  if line =~ /Finished in ([0-9.]+) seconds/
    test_time += $1.to_f
  end
  if failure_error_flag 
    failure_error << line
  end
  if line =~ /(\d+)\) Failure:/ or line =~ /(\d+)\) Error:/
    failure_error_flag = true
    failure_error_no += 1
    failure_error << line.gsub(/\d+/,failure_error_no.to_s)
  end
  if line.strip == ''
    failure_error_flag = false
  end
  if line =~ /(\d+) tests, (\d+) assertions, (\d+) failures, (\d+) errors/
    tests      += $1.to_i
    assertions += $2.to_i
    failures   += $3.to_i
    errors     += $4.to_i
  end
  if line =~ /([0-9.]+)\%   (\d+) file\(s\)   (\d+) Lines   (\d+) LOC/
    rcov = line
  end
end

# result
print <<-EOF

Loaded suite 
 #{test_names.join(",\n ")}

Finished in #{test_time} seconds.

#{rcov if rcov}
#{failure_error}
#{tests} tests, #{assertions} assertions, #{failures} failures, #{errors} errors
EOF

temp_out.close
coverage.close if coverage
