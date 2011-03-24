#!/usr/bin/env ruby
# Vewi::TestSearch -- oddb -- 10.03.2011 -- mhatakeyama@ywesee.com
# View::TestSearch -- oddb -- 12.11.2002 -- hwyss@ywesee.com 

$: << File.expand_path("..", File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'stub/odba'
require 'view/search'
require 'custom/lookandfeelbase'
require 'util/validator'
require 'stub/oddbapp'
require 'stub/session'
require 'stub/cgi'
require 'mock'
require 'odba'

=begin
module ODDB
	class GalenicGroup
		def GalenicGroup.reset_oid
			@oid=0
		end
	end

	module View
	class TestSearch < Test::Unit::TestCase
		def setup
			ODBA.storage = Mock.new
			ODBA.storage.__next(:next_id) {
				1
			}
			GalenicGroup.reset_oid
			validator = Validator.new
			@session = Session.new("test", App.new, validator)
			@session.lookandfeel = LookandfeelBase.new(@session)
			@view = View::Search.new(nil, @session)
		end
		def teardown
			ODBA.storage = nil
		end
		def test_http_headers
			headers = @view.http_headers
			time = headers["Expires"]
			expected = {
				"Content-Type"	=>	"text/html; charset=UTF-8",
				"Cache-Control"	=>	"private, no-store, no-cache, must-revalidate, post-check=0, pre-check=0",
				"Pragma"				=>	"no-cache",
				"Expires"				=>	time,
				"P3P"						=>	"CP='OTI NID CUR OUR STP ONL UNI PRE'",
			}
			assert_equal(expected, headers)
			pattern = /^[A-Z][a-z]{2}, \d{2} [A-Z][a-z]{2} \d{4} (\d{2}:){2}\d{2} GMT$/
			assert_match(pattern, time)
		end
	end
	end
end
=end
