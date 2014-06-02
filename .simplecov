# test/test_helper.rb
require 'simplecov'
SimpleCov.merge_timeout(3600) # 1hr
SimpleCov.use_merging true
puts "Reading #{File.expand_path(__FILE__)} merge #{SimpleCov.use_merging.inspect}"
SimpleCov.start do
  add_group "src", "src"
  add_group "Extensions", "ext"
  add_filter "/test/"
end

SimpleCov.maximum_coverage_drop 99
SimpleCov.minimum_coverage 10
