#!/usr/bin/env ruby
# TestPlugin -- oddb -- 30.05.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'plugin/plugin'

class TestPlugin < Test::Unit::TestCase
	def setup
		@plugin = ODDB::Plugin.new(nil)
	end
	def teardown
		File.delete('/tmp/oddbtest') if File.exist?('/tmp/oddbtest')
	end
	def test_http_file
		assert_equal(nil, @plugin.http_file('www.oddb.org', '/unknown', '/tmp/oddbtest'))
		assert_equal(true, @plugin.http_file('www.google.ch', '/search?q=generika', '/tmp/oddbtest'))
		assert(File.exist?('/tmp/oddbtest'))
	end
	def test_log_info
		info = @plugin.log_info
		[:report, :change_flags, :recipients].each { |key|
			assert(info.include?(key))
		}
	end
end
