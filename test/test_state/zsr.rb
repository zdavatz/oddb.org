#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::TestZSR -- oddb.org -- 09.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'state/global'

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/zsr'
require 'util/mail'

module ODDB 
	module State
		class TestZSR <Minitest::Test
			include FlexMock::TestCase
			def test_zsr
				@app     = flexmock('app')
				@session = flexmock('session', 
														:app => @app,
														:lookandfeel => @lnf,
														)
				flexmock(@session, :request_path => 'zsr/J888')
				@state   = ODDB::State::Zsr.new(@session, @model)
#				assert(nil != @state.events[:home_interactions], "must find home_interactions")
				assert(nil != @state.events[:zsr], "must find zsr")
			end
		end
	end # State
end # ODDB
