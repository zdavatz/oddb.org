#!/usr/bin/env ruby
# ODDB::State::Admin::TestGalenicGroup -- oddb.org -- 01.07.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Drugs::TestGalenicGroup -- oddb.org -- 13.10.2003 -- mhuggler@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/admin/galenicgroup'
require 'util/language'
require 'state/admin/root'
require 'state/exception'

module ODDB
	module State
		class Global < SBSM::State
			attr_accessor :model
		end
		module Admin

class TestGalenicGroup < Test::Unit::TestCase
  include FlexMock::TestCase
	class StubSession
		attr_accessor :user_input
		def app
			@app ||= StubApp.new
		end
		def user_input(*keys)
			if(keys.size > 1)
				res = {}
				keys.each { |key|
					res.store(key, user_input(key))
				}
				res
			else
				key = keys.first
				(@user_input ||= {
					:pointer	=>	StubPointer.new
				})[key]
			end
		end
	end
	class StubPointer
		attr_writer :model
		def resolve(app)
			@model ||= StubResolved.new
		end
		def +(other)
			self
		end
	end
	class StubGalenicForm
    def initialize
      @odba_id = 123
    end
		include Language
	end
	class StubApp; end
	class StubResolved; end

	def test_pass_galenic_group
		session = StubSession.new
		model = StubGalenicForm.new
		state = State::Admin::GalenicGroup.new(session, model)
		pointer = StubPointer.new
		pointer.model = model
		model.pointer = pointer
		state.extend(State::Admin::Root)
		session.user_input = {
			:pointer	=>	pointer,
		}
		newstate = state.trigger(:new_galenic_form)
		assert_respond_to(newstate.model, :galenic_group)
		assert_equal(model, newstate.model.galenic_group)
	end
  def setup
    @model   = flexmock('model', :pointer => 'pointer')
    @app     = flexmock('app', 
                        :galenic_groups => {'key' => @model},
                        :delete => 'delete'
                       )
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :app => @app
                       )
    @state = ODDB::State::Admin::GalenicGroup.new(@session, @model)
  end
  def test_delete
    flexmock(@state, :galenic_groups => 'galenic_groups')
    assert_equal('galenic_groups', @state.delete)
  end
  def test_delete__error
    assert_kind_of(ODDB::State::Exception, @state.delete)
  end
  def test_update
    flexmock(@lnf, :languages => ['language'])
    flexmock(@session, :user_input => 'user_input')
    flexmock(@state, :unique_email => 'unique_email')
    flexmock(@app, :update => 'update')
    assert_equal(@state, @state.update)
  end
end
		end
	end
end
