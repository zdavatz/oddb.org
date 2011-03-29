#!/usr/bin/env ruby
# State::Admin::TestMergeGalenicForm -- oddb -- 02.03.2011 -- mhatakeyama@ywesee.com
# State::Drugs::TestMergeGalenicForm -- oddb -- 09.04.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'command/merge'
require 'define_empty_class'
require 'htmlgrid/select'
require 'state/admin/galenicform'

module ODDB
	module State
		module Admin
class StubMGFStateSession
	attr_writer :user_input, :galenic_forms
	attr_reader :merge_galenic_forms_called
	def initialize
		@merge_galenic_forms_called = false
	end
	def app
		self
	end
	def galenic_form(key)
		(@galenic_forms ||= {})[key]
	end
	def merge_galenic_forms(source, target)
		@merge_galenic_forms_called = true
	end
	def user_input(key)
		(@user_input ||= {})[key]
	end
end
class StubMGFStateModel
	attr_accessor :form
	def initialize(form)
		@form = form
	end
	def ==(other)
		@form == other.form
	end
end

class TestMergeGalenicFormState < Test::Unit::TestCase
	def setup
		@session = StubMGFStateSession.new
		@model = StubMGFStateModel.new('Filmtabletten')
		@state = State::Admin::MergeGalenicForm.new(@session, @model)
		@session.user_input = {:galenic_form => "Tabletten"}
	end
	def test_no_target
		newstate = @state.trigger(:merge)
		assert_equal(false, @session.merge_galenic_forms_called)
		assert_equal(@state, newstate)
	end
	def test_same_target
		@model.form = 'Tabletten'
		@session.galenic_forms = { "Tabletten" =>	@model }
		newstate = @state.trigger(:merge)
		assert_equal(false, @session.merge_galenic_forms_called)
		assert_equal(@state, newstate)
	end
	def test_target
		@session.galenic_forms = { "Tabletten" =>	StubMGFStateModel.new('Tabletten') }
		newstate = @state.trigger(:merge)
		assert_equal(true, @session.merge_galenic_forms_called)
		assert_equal(State::Admin::GalenicForm, newstate.class)
	end
end
		end
	end
end
