#!/usr/bin/env ruby
# State::TestGlobal -- oddb -- 03.03.2011 -- mhatakeyama@ywesee.com
# State::TestGlobal -- oddb -- 13.10.2003 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
require 'test/unit'
require 'state/global'
require 'mock'
require 'util/language'
#require 'sbsm/validator'
require 'sbsm/state'
require 'flexmock'

module ODDB
	module State
		module Admin
class TransparentLogin < State::Admin::Login
	def init
		@session.app.state_transp_called = true
		super
	end
end
		end
		class Global < SBSM::State
			attr_accessor :model
		end
		class TestGlobal < Test::Unit::TestCase
      include FlexMock::TestCase
			class StubSession
				attr_accessor :user_input, :request_path
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
				def allowed?(foo, bar)
					true
				end
				def user
					self
				end
				def request_path
					# disable self-caching for tests
					@rp = @rp.to_i.next
				end
			end
			class StubApp
				attr_accessor :companies, :galenic_groups, :fachinfos
				attr_accessor :state_transp_called
				def initialize
					@state_transp_called = false
					@companies ||= {}
				end
				def company(oid)
					@companies[oid.to_i]
				end
				def galenic_group(oid)
					@galenic_groups[oid.to_i]
				end
				def fachinfo(oid)
					@fachinfos[oid]
				end
			end
			class StubPointer; end
			class StubCompany; end
			class StubGalenicGroup
				attr_accessor :galenic_forms
				def galenic_form(oid)
					@galenic_forms[oid.to_i]
				end
			end
			class StubGalenicForm
				include Language
			end

			def setup
				@session = StubSession.new
				@state = State::Global.new(@session, @session)
			end
			def teardown
				ODBA.storage = nil
			end
			def test_resolve1
				@company = StubCompany.new
				@session.app.companies = { 
					4	=>	@company, 
				}
        pointer = flexmock('pointer') do |ptr|
          ptr.should_receive(:is_a?).and_return(true)
          ptr.should_receive(:resolve).and_return('model')
          ptr.should_receive(:skeleton).and_return([:company])
        end
        flexstub(@session) do |s|
          s.should_receive(:user_input).and_return(pointer) 
        end
				newstate = @state.resolve
				assert_instance_of(State::Companies::Company, newstate)
			end
			def test_resolve__print1
				@session.app.fachinfos = { 0	=>	:foo}
        pointer = flexmock('pointer') do |ptr|
          ptr.should_receive(:is_a?).and_return(true)
          ptr.should_receive(:resolve).and_return('model')
          ptr.should_receive(:skeleton).and_return([:fachinfo])
        end
        flexstub(@session) do |s|
          s.should_receive(:user_input).and_return(pointer) 
        end

				newstate = @state.print
				assert_instance_of(State::Drugs::FachinfoPrint, newstate)
			end
			def test_user_input1
				@session.user_input = {
					:good => 'foo', 
					:bad => SBSM::InvalidDataError.new('e_invalid_bad', :bad, 'bar')
				}
				result = @state.user_input([:good, :bad])
				expected = {:good => 'foo'}
				assert_equal(expected, result)
				assert_equal(true, @state.errors.has_key?(:bad))
				assert_instance_of(SBSM::InvalidDataError, @state.error(:bad))
			end
			def test_user_input2
				@session.user_input = {
					:good => 'foo', 
					:bad => SBSM::InvalidDataError.new('e_invalid_bad', :bad, 'bar')
				}
				@state.model = Persistence::CreateItem.new()
				@state.user_input([:good, :bad])
				assert_instance_of(Persistence::CreateItem, @state.model)
				assert_equal('foo', @state.model.good)
				assert_equal('bar', @state.model.bad)
			end
		end
	end
end
