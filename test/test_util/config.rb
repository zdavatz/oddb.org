#!/usr/bin/env ruby
# TestConfig -- oddb -- 14.10.2004 -- hwyss@ywesee.com, usenguel@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'mock'
require 'util/config'
require 'odba'
module ODDB
	class Foo
		def odba_isolated_store
		end
	end
	class TestConfig < Test::Unit::TestCase
		def setup
			@cache = ODBA.cache_server = Mock.new('Cache')
			@config = Config.new
		end
		def teardown
			ODBA.cache_server = nil
			ODBA.storage = nil
		end
		def test_reader
			assert_nil(@config.foo)
			assert_nil(@config.bar)
			assert_nil(@config.hatto)
		end
		def test_creator
			subconfig = @config.create_foo
			assert_instance_of(Config, subconfig)
			assert_equal(subconfig, @config.foo)
			subconfig2 = @config.create_foo
			assert_equal(subconfig, subconfig2)
			assert_equal(subconfig, @config.foo)
		end
		def test_writer
			foo = nil
			@cache.__next(:store) { |obj|
				assert_equal(@config.instance_variable_get('@values'), obj)
			}
			assert_nothing_raised {
				foo = Foo.new
				@config.bar = foo
			}
			assert_equal(foo, @config.bar)
		end
		def test_dumpable
			@cache.__next(:store) { |obj|
				assert_equal(@config.instance_variable_get('@values'), obj)
			}
			@config.foo = Foo.new
			assert_nothing_raised {
				Marshal.dump(@config)
			}
		end
		def test_method
			@cache.__next(:store) { |obj|
				assert_equal(@config.instance_variable_get('@values'), obj)
			}
			@config.bar = Foo.new
			result = nil
			assert_nothing_raised {
				mth = @config.method(:bar)
				assert_equal(-1, mth.arity)
				result = mth.call
			}
			assert_equal(@config.bar, result)
		end
	end
end
