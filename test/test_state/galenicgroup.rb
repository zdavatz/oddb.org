#!/usr/bin/env ruby
# TestGalenicGroup -- oddb -- 13.10.2003 -- maege@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/galenicgroup'
require 'util/language'
require 'state/root'

module ODDB
	class GlobalState < SBSM::State
		attr_accessor :model
	end
end

class TestGalenicGroup < Test::Unit::TestCase
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
		include ODDB::Language
	end
	class StubApp; end
	class StubResolved; end

	def test_pass_galenic_group
		session = StubSession.new
		model = StubGalenicForm.new
		state = ODDB::GalenicGroupState.new(session, model)
		pointer = StubPointer.new
		pointer.model = model
		model.pointer = pointer
		state.extend(ODDB::RootState)
		session.user_input = {
			:pointer	=>	pointer,
		}
		newstate = state.trigger(:new_galenic_form)
		assert_respond_to(newstate.model, :galenic_group)
		assert_equal(model, newstate.model.galenic_group)
	end
end
