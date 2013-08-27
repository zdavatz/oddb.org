#!/usr/bin/env ruby
# encoding: utf-8
# suite.rb -- oddb.org -- 11.04.2012 -- yasaka@ywesee.com
# suite.rb -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com 
# In order to execute test/suite.rb,
# yusd and meddatad is needed to run.

$: << File.dirname(__FILE__)

require 'tempfile'

dir = File.expand_path(File.dirname(__FILE__))
# Below test_suites contain tests that call each other. 
# This can result in a wrong coverage summary as shown in the example of oddbapp.rb
# Out of this reason we run test_util/suite.rb first - but this may cause other problems. Lets see.
directories = [
  "#{dir}/../ext/suite.rb",
  "#{dir}/test_util/suite.rb",
  "#{dir}/test_model/suite.rb",
  "#{dir}/test_plugin/suite.rb",
  "#{dir}/test_state/suite.rb",
  "#{dir}/test_view/suite.rb",
  "#{dir}/test_custom/suite.rb",
  "#{dir}/test_command/suite.rb",
  "#{dir}/test_remote/suite.rb",
]
# directories = [ "#{dir}/test_command/suite.rb", ]

rcov = true
coverage = nil
command = 'system "ruby #{path} >> #{temp_out.path}"'
begin
  # FIXME
  # There is ARGV problem in test-unit
  require 'simplecov'
  SimpleCov.start
rescue
  begin
    Rcov
    coverage = Tempfile.new('coverage')
    command = 'system "rcov #{path} -t --aggregate #{coverage.path} >> #{temp_out.path}"'
  rescue
    rcov = false
  end
end

temp_out = Tempfile.new('temp_out')
directories.each_with_index { |path, i|
  puts "\nNow testing #{path}\n"
  require path
  # eval(command)
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
