#!/usr/bin/env ruby

TEST_NAMES ='unparsed.txt'
OUT_NAME ='spec/parslet_errors_spec.rb'

HEADER = %(VERBOSE_MESSAGES = false
if File.exists?("#{Dir.pwd}/lib/oddb2xml/parslet_compositions.rb")
  require_relative "../lib/oddb2xml/parslet_compositions"
else
  puts :ParseFailed
  require_relative "../src/plugin/parslet_compositions"
end
require "parslet/rig/rspec"
describe ParseComposition do

)

FOOTER = %(
end
)

to_add = {}
lines = File.readlines(TEST_NAMES)
lines.each do | line |
# line = lines.first
  found = /^\s*(\d*): (.*)/.match(line)
  if found
    to_add[found[1]] = found[2] unless to_add.values.index(found[2])
  end
end

output = File.open(OUT_NAME, 'w+')
output.puts HEADER
to_add.each_with_index do |(iksnr, line), index|
  output.puts %(
  it "should handle isknr #{iksnr}" do
      string = "#{line}"
      composition = ParseComposition.from_string(string)
      expect(composition.source).to eq string
      expect(composition.substances.size).to be > 1
  end
)
#break
end

output.puts %(
end
)

puts "Wrote #{to_add.size} tests to #{OUT_NAME} from #{TEST_NAMES}"
