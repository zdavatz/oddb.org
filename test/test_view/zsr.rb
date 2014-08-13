#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestZsr -- oddb.org -- 08.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'stub/cgi'
require 'view/zsr'

module ODDB
	module View
		class TestZsr <Minitest::Test
			include FlexMock::TestCase
			def test_zsr
				@lnf     = flexmock('lookandfeel', 
														:lookup     => 'lookup',
														:attributes => {},
														:_event_url => '_event_url'
													)
				@session = flexmock('session', 
														:lookandfeel => @lnf,
														:zone => 'zone',
														:user_input => 'user_input',
														:request_path => 'dummy.oddb.org/de/gcc/preferences',
                            :zsr_id => nil,
													)
				@view    = ODDB::View::ZsrDetails.new(@model, @session)
				result = @view.to_html(CGI.new)
				assert(result.index('composite'), "HTML should contain a composite")
			end
		end
	end # View
end # ODDB

