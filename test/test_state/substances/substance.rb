#!/usr/bin/env ruby
# State::Substances::TestSubstance -- oddb -- 07.07.2004 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/substances/substance'
require 'state/admin/root'
require 'model/substance'
require 'mock'

module ODDB
	module State
		module Substances
class TestSubstanceState < Test::Unit::TestCase
	def setup
		@session = Mock.new('session')
		@model = Mock.new('model')
		@state = State::Substances::Substance.new(@session, @model)
		@state.extend(State::Admin::Root)
	end
	def teardown
		@session.__verify
		@model.__verify
	end
	def test_delete
		@model.__next(:empty?) { false }
		@state.delete
	end
	def test_delete2
		app = Mock.new('app')
		@model.__next(:empty?) { true }
		@session.__next(:app) { app }
		@model.__next(:pointer) { 'model_pointer' }
		app.__next(:delete) { |pointer| 
			assert_equal('model_pointer', pointer)
		}
		@session.__next(:app) { app }
		app.__next(:substances) { [ ODDB::Substance.new ] }	
		@session.__next(:user_input) { nil }
		@state.delete
		app.__verify
	end
	def test_merge
		app = Mock.new('app')
		substance = Mock.new('substance')
		@session.__next(:user_input) { |param|
			assert_equal(:substance_form, param)
			'substance'
		}
		@session.__next(:app) { app }
		app.__next(:substance) { |subs|
			assert_equal('substance', subs)
			substance
		}
		substance.__next(:has_connection_key?) { false }
		@session.__next(:app) { app }
		substance.__next(:pointer) { 'target_pointer' }
		@model.__next(:pointer) { 'source_pointer' }
		app.__next(:merge_substances) { |source, target|
			assert_equal('source_pointer', source)
			assert_equal('target_pointer', target)
		}
		@state.merge
		app.__verify
		substance.__verify
	end
	def test_merge2
		app = Mock.new('app')
		substance = Mock.new('substance')
		@session.__next(:user_input) { |param|
			assert_equal(:substance_form, param)
			'substance'
		}
		@session.__next(:app) { app }
		app.__next(:substance) { |subs|
			assert_equal('substance', subs)
			nil
		}
		@state.merge
		assert_equal([ :substance ], @state.errors.keys)
		app.__verify
		substance.__verify
	end
	def test_merge3
		app = Mock.new('app')
		substance = Mock.new('substance')
		@session.__next(:user_input) { |param|
			assert_equal(:substance_form, param)
			'substance'
		}
		@session.__next(:app) { app }
		app.__next(:substance) { |subs|
			assert_equal('substance', subs)
			@model
		}
		@state.merge
		assert_equal([ :substance ], @state.errors.keys)
		app.__verify
		substance.__verify
	end
	def test_update
		lookandfeel = Mock.new('lookandfeel')
		app = Mock.new('app')
		substance = Mock.new('substance')
		@session.__next(:lookandfeel) { lookandfeel }
		lookandfeel.__next(:languages) { ['de'] }
		@session.__next(:user_input) { |param|
			assert_equal(:de, param)
			'value'
		}
		@session.__next(:app) { app }
		app.__next(:substance) { |value|
			assert_equal('value', value)
			substance
		}
		@session.__next(:user_input) { |param|
			assert_equal(:en, param)
			'value'
		}
		@session.__next(:app) { app }
		app.__next(:substance) { |value|
			assert_equal('value', value)
			substance
		}
		@session.__next(:user_input) { |param|
			assert_equal(:lt, param)
			'value'
		}
		@session.__next(:app) { app }
		app.__next(:substance) { |value|
			assert_equal('value', value)
			substance
		}
		@state.update
		assert_equal(3, @state.errors.size)
		lookandfeel.__verify
		app.__verify
		substance.__verify
	end
	def test_update2
		lookandfeel = Mock.new('lookandfeel')
		app = Mock.new('app')
		@session.__next(:lookandfeel) { lookandfeel }
		lookandfeel.__next(:languages) { ['de'] }
		@session.__next(:user_input) { |param|
			assert_equal(:de, param)
			'value'
		}
		@session.__next(:app) { app }
		app.__next(:substance) { |value|
			assert_equal('value', value)
			nil
		}
		@session.__next(:user_input) { |param|
			assert_equal(:en, param)
			'value'
		}
		@session.__next(:app) { app }
		app.__next(:substance) { |value|
			assert_equal('value', value)
			@model	
		}
		@session.__next(:user_input) { |param|
			assert_equal(:lt, param)
			'value'
		}
		@session.__next(:app) { app }
		app.__next(:substance) { |value|
			assert_equal('value', value)
			@model
		}
		@session.__next(:app) { app }
		@model.__next(:pointer) { 'model_pointer' }
		app.__next(:update) { |pointer, input| 
			assert_equal('model_pointer', pointer)
			expected = { "de"=>"value", "lt"=>"value", "en"=>"value" }
			assert_equal(expected, input)
		}
		@state.update
		assert_equal(0, @state.errors.size)
		lookandfeel.__verify
		app.__verify
	end
end
		end
	end
end
