#!/usr/bin/env ruby
# TestSession -- oddb -- 22.10.2002 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'stub/session'
require 'state/drugs/init'
require 'sbsm/request'
require 'stub/cgi'

module Apache
	REMOTE_NOLOOKUP = 1
	class Request
		attr_accessor :unparsed_uri
		def headers_in
			{}
		end
		def remote_host(arg)
			'127.0.0.1'
		end
	end
	def request
		Request.new
	end
	module_function :request
end
module ODDB
	class TestOddbSession < Test::Unit::TestCase
		class StubUnknownUser
		end
		class StubApp
			def unknown_user
				StubUnknownUser.new
			end
			def async(&block)
				#block.call
			end
		end
		class StubValidator
			def reset_errors; end
			def validate(key, value, mandatory=false)
				value
			end
			def error?
				false
			end
		end
		
		def setup
			@session = ODDB::Session.new("test", StubApp.new, StubValidator.new)
			@session.reset
		end
		def test_initialize
			assert_nothing_raised { ODDB::Session.new("test", StubApp.new, nil) }
		end
		def test_init_state
			assert_equal(ODDB::State::Drugs::Init, @session.state.class)
		end
		def test_unwrapped_lookandfeel
			assert_equal(ODDB::LookandfeelBase, @session.lookandfeel.class)
		end
		def test_cgi_compatible
			assert_respond_to(@session, :restore)
			assert_respond_to(@session, :update)
			assert_respond_to(@session, :close)
			assert_respond_to(@session, :delete)
		end
		def test_restore
			restore = @session.restore[:proxy]
			assert_instance_of(Session, restore)
		end
		def test_process
			request = SBSM::Request.new('druby://localhost:10001')
			assert_nothing_raised {
				@session.process(request)
			}
		end
		def test_user_input_no_context
			assert_equal(nil, @session.user_input("no_input"))
		end
		def test_user_input_nil
			@session.process SBSM::Request.new('druby://localhost:10001')
			assert_not_nil(@session.request)
			assert_equal(nil, @session.user_input("no_input"))
		end
		def test_user_input
			request = SBSM::Request.new('druby://localhost:10001')
			request.cgi["foo"] = "bar"
			request.cgi["bar"] = "foo"
			@session.process(request) 
			assert_equal("bar", @session.user_input(:foo))
			assert_equal("foo", @session.user_input(:bar))
		end
		def test_user_input_hash
			request = SBSM::Request.new('druby://localhost:10001')
			request.cgi["hash[1]"] = "4"
			request.cgi["hash[2]"] = "5"
			request.cgi["hash[3]"] = "6"
			@session.process request
			hash = @session.user_input(:hash)
			assert_equal(Hash, hash.class)
			assert_equal(3, hash.size)
			assert_equal("4", hash["1"])
			assert_equal("5", hash["2"])
			assert_equal("6", hash["3"])
		end
		def test_flavor
			assert_equal('gcc', @session.flavor)
			request = SBSM::Request.new('druby://localhost:10001')
			@session.process(request)
			assert_equal('gcc', @session.flavor)
			request.params["flavor"] = 'hdd'
			@session.process(request)
			assert_equal('gcc', @session.flavor)
		end
	end
end
