#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestZsr -- oddb.org -- 08.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))


require 'minitest/autorun'
require 'flexmock/minitest'
require 'view/zsr_json'

module ODDB
	module View   
		class TestZsrJson <Minitest::Test
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
														:request_path => 'dummy.oddb.org/de/gcc/zsr/J039019',
													)
				@view    = ODDB::View::ZsrJson.new(@model, @session)
				result = @view.to_html('context')
        skip('ZSR do not work')
				assert(result.index('"last_name":"Davatz"'))
				assert(result.index('"title":"Dr. med."'))
			end
		end
	end # View
end # ODDB

