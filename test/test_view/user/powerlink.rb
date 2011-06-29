#!/usr/bin/env ruby
# ODDB::View::User::TestPowerLink -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com
# ODDB::View::User::TestPowerLink -- oddb.org -- 22.10.2003 -- rwaltert@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'view/user/powerlink'

module ODDB
	module View
		module User
class TestPowerLink < Test::Unit::TestCase
  include FlexMock::TestCase
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
		@powerlink = View::User::PowerLink.new(@model, @session)
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
  def test_to_html
    flexmock(@model, :oid => 'oid')
    flexmock(@session, :remote_addr => 'remote_addr')
    assert_equal('', @powerlink.to_html('context'))
  end
end
		end
	end
end
