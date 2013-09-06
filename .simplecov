# test/test_helper.rb
require 'simplecov'
SimpleCov.merge_timeout(3600) # 1hr
SimpleCov.use_merging true
# SimpleCov.command_name "test:oddb_#{ARGV.inspect}"
puts "Reading #{File.expand_path(__FILE__)} merge #{SimpleCov.use_merging.inspect}"
SimpleCov.start do
  add_group "src", "src"
  add_group "Extensions", "ext"
  add_filter "/test/"
end

SimpleCov.refuse_coverage_drop