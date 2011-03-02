#!/usr/bin/env ruby
# State::Substances::TestSubstance -- oddb -- 02.03.2011 -- mhatakeyama@ywesee.com
# State::Substances::TestSubstance -- oddb -- 07.07.2004 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
#$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'htmlgrid/template'
require 'htmlgrid/inputradio'
module ODDB
  module View
    class PublicTemplate < HtmlGrid::Template; end
    class Search < View::PublicTemplate; end
  end
end
require 'test/unit'
require 'state/substances/substance'
require 'state/admin/root'
require 'model/substance'
require 'flexmock'

module ODDB
	module State
		module Substances
class TestSubstanceState < Test::Unit::TestCase
  include FlexMock::TestCase
	def setup
    @session = flexmock('session')
    @model = flexmock('model')
		@state = State::Substances::Substance.new(@session, @model)
		@state.extend(State::Admin::Root)
	end
  def test_delete
    flexstub(@model) do |m|
      m.should_receive(:empty?).and_return(true)
      m.should_receive(:pointer)
    end
    flexstub(@session) do |s|
      s.should_receive(:"app.delete")
    end
    mdl = flexmock('mdl') do |m|
      m.should_receive(:delete)
      m.should_receive(:is_a?)
    end
    new_state = flexmock('new_state') do |n|
      n.should_receive(:model).and_return(mdl)
    end
    flexstub(@state) do |s|
      s.should_receive(:result).and_return(new_state)
    end
    state = @state.delete
    assert_equal(new_state, state)
  end
	def test_delete__error
    flexstub(@model) do |m|
      m.should_receive(:empty?).and_return(false)
    end
    state = @state.delete
    assert_kind_of(State::Substances::Substance, state)
		assert_equal(true, state.error?)
	end
  def test_merge
    substance = flexmock('substance') do |s|
      s.should_receive(:has_connection_key?).and_return(false)
      s.should_receive(:pointer).and_return('target_pointer')
    end
    app = flexmock('app') do |a|
      a.should_receive(:substance).and_return(substance)
      a.should_receive(:search_substances).and_return(['substance'])
    end
    flexstub(@session) do |s|
      s.should_receive(:user_input).and_return('substance')
      s.should_receive(:app).and_return(app)
    end
    flexstub(@model) do |m|
      m.should_receive(:pointer).and_return('source_pointer')
    end
		state = @state.merge
    assert_kind_of(State::Substances::SelectSubstance, state) 
  end
	def test_merge__error
    substance = flexmock('substance') do |s|
      s.should_receive(:has_connection_key?).and_return(false)
      s.should_receive(:pointer).and_return('target_pointer')
    end
    app = flexmock('app') do |a|
      a.should_receive(:substance).and_return(substance)
      a.should_receive(:search_substances).and_return([])
    end
    flexstub(@session) do |s|
      s.should_receive(:user_input).and_return('substance')
      s.should_receive(:app).and_return(app)
    end
    flexstub(@model) do |m|
      m.should_receive(:pointer).and_return('source_pointer')
    end
		state = @state.merge
    assert_equal(@state, state)
    assert_equal(true, state.error?)
	end
  def test_update
    flexstub(@session) do |s|
      s.should_receive(:"lookandfeel.languages").and_return([])
      s.should_receive(:user_input)
      s.should_receive(:"app.update")
    end
    flexstub(@model) do |m|
      m.should_receive(:pointer)
    end
    flexstub(@state) do |s|
      s.should_receive(:unique_email)
    end
    state = @state.update
    assert_equal(@state, state)
    assert_equal(false, state.error?)
  end
  def test_update__error
    flexstub(@session) do |s|
      s.should_receive(:"lookandfeel.languages").and_return([])
      s.should_receive(:user_input).and_return('value')
      s.should_receive(:"app.update")
    end
    flexstub(@model) do |m|
      m.should_receive(:pointer)
    end
    flexstub(@state) do |s|
      s.should_receive(:unique_email)
    end
    state = @state.update
    assert_equal(@state, state)
    assert_equal(false, state.error?)

  end
=begin
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
=end
end
		end
	end
end
