#!/usr/bin/env ruby
# TestPowerLinkView -- oddb -- 22.10.2003 -- rwaltert@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'view/powerlink'

class TestPowerLinkView < Test::Unit::TestCase
	class StubSession
		def lookandfeel
			self
		end
	end
	class StubModel
		attr_accessor :powerlink
	end
	def setup
		@model = StubModel.new
		@session = StubSession.new
		@powerlink = ODDB::PowerLinkView.new(@model, @session)
	end
	def test_interface
		assert_respond_to(@powerlink, :http_headers)
		assert_respond_to(@powerlink, :to_html)
	end
	def test_http_headers
		expected = {
			"Location" => nil,
		}
		assert_equal(expected, @powerlink.http_headers)
		@model.powerlink = "http://www.ywesee.com"
		expected = {
			"Location" => "http://www.ywesee.com"
		}
		assert_equal(expected, @powerlink.http_headers)
		@model.powerlink = "www.ywesee.com"
		assert_equal(expected, @powerlink.http_headers)
		@model.powerlink = "https://www.ywesee.com"
		expected = {
			"Location" => "https://www.ywesee.com"
		}
		assert_equal(expected, @powerlink.http_headers)
	end
end
