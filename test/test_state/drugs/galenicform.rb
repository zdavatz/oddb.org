#!/usr/bin/env ruby
# State::Drugs::TestGalenicFormState -- oddb -- 13.10.2003 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/drugs/galenicform'
require 'util/language'

module ODDB
	module State
		module Drugs
class	TestGalenicForm < Test::Unit::TestCase
	class StubSession
		attr_accessor :user_input
		def app
			@app ||= StubApp.new
		end
		def lookandfeel
			StubLookandfeel.new
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
	class StubApp
		attr_accessor :galenic_forms
		attr_reader :update_called
		def initialize
			@update_called = false
		end
		def galenic_form(name)
			@galenic_forms[name]
		end
		def update(pointer,values)	
			@update_called = true
		end
	end
	class StubPointer; end
	class StubGalenicForm
		include Language
	end
	class StubLookandfeel
		def languages
			['de', 'fr']
		end
	end

	def setup
		@session = StubSession.new
		@galform = StubGalenicForm.new
		@galform.update_values({'de'=>'Tabletten', 'fr'=>'comprimés'})
		@state = State::Drugs::GalenicForm.new(@session, @galform)
	end
	def test_update1
		@session.app.galenic_forms = { 
			'Tabletten'	=>	@galform, 
			'comprimés'	=>	@galform,
		}
		@session.user_input = { :de => 'Tabletten',  :fr => 'comprimés'}
		@state.update
		assert_equal(false, @state.error?)
	end
	def test_update2
		@session.app.galenic_forms = { 
			'Tabletten'	=>	@galform, 
			'comprimés'	=>	@galform,
		}
		@session.user_input = { :de => 'Filmtabletten', :fr => 'filmcomprimés'}
		@state.update
		assert_equal(false, @state.error?)
	end
	def test_update3
		galform = StubGalenicForm.new
		galform.update_values({'de'=>'Tabletten', 'fr'=>'comprimés'})
		@session.app.galenic_forms = { 
			'Tabletten'	=>	galform, 
			'comprimés'	=>	galform,
		}
		@session.user_input = { :de => 'Filmtabletten', :fr => 'filmcomprimés'}
		@state.update
		assert_equal(false, @state.error?)
	end
	def test_update4
		galform = StubGalenicForm.new
		galform.update_values({'de'=>'Tabletten', 'fr'=>'comprimés'})
		@session.app.galenic_forms = { 
			'Tabletten'	=>	galform, 
			'comprimés'	=>	galform,
		}
		@session.user_input = { :de =>'Tabletten', :fr => 'comprimés'}
		@state.update
		assert_equal(true, @state.error?)
	end
end
		end
	end
end
