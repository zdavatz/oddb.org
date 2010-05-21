#!/usr/bin/env ruby
# TestConfig -- oddb -- 14.10.2004 -- hwyss@ywesee.com, usenguel@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))
$: << File.expand_path("..", File.dirname(__FILE__))

require 'stub/odba'
require 'test/unit'
require 'util/config'

module ODDB
	class Foo
		def odba_isolated_store
		end
	end
	class TestConfig < Test::Unit::TestCase
		def setup
      ##### OBSOLETE ######
			@config = Config.new
		end
		def test_reader
			assert_nil(@config.foo)
			assert_nil(@config.bar)
			assert_nil(@config.hatto)
		end
	end
end
