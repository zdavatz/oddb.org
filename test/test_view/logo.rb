#!/usr/bin/env ruby
# View::TestLogo -- oddb -- 01.10.2003 -- maege@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'view/logo'

module ODDB
	module View
		class Logo < PopupLogo
			attr_reader :lookandfeel
		end

		class TestLogo < Test::Unit::TestCase
			class StubSession
				attr_accessor :enabled, :attributes
				attr_reader	:function_called
				def initialize(function_called=nil, enabled=true)
					@function_called = function_called
					@enabled = enabled
					@attributes = {}
				end
				def attributes(key)
					@attributes
				end
				def lookandfeel
					self
				end
				def enabled?(logo, default=nil)
					@enabled
				end
				def resource(arg)
					@function_called = 'not localized'
				end
				def resource_localized(arg)
				 @function_called = "localized"
				end
				def lookup(arg)
				end
			end
			def test_init
				session = StubSession.new
				view = View::Logo.new('model', session)
				result = view.lookandfeel.function_called
				assert_equal('localized', result)
			end
			def test_init2
				session = StubSession.new
				session.enabled = false
				view = View::Logo.new('model', session)
				result = view.lookandfeel.function_called
				assert_equal('not localized', result)
			end
		end
	end
end
