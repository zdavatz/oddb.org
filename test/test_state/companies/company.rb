#!/usr/bin/env ruby
# State::Companies::TestCompany -- oddb -- 02.10.2003 -- rwaltert@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/companies/company'
require 'state/global'

module ODDB 
	module State
		module Companies
class TestRootCompanyState < Test::Unit::TestCase
	class StubSession
		attr_writer :user_input
		attr_accessor :app
		def user_input(*args)
			input = @user_input.dup
			input.delete_if { |key, val| !args.include?(key) }
			input
		end
	end
	class StubCompany
		attr_accessor :pointer
	end
	class StubApp
		attr_reader :pointer
		attr_reader :input
		attr_writer :company_of_same_name
		def update(pointer, input)
			@pointer = pointer
			@input = input
		end
		def company_by_name(name)
			@company_of_same_name
		end
	end

	def setup
		@session = StubSession.new
		@app = StubApp.new
		@session.app = @app
		@model	= StubCompany.new
		@model.pointer = 'bar'
		@state = State::Companies::RootCompany.new(@session, @model)
		@session.user_input = {
			:name => 'Ecosol AG',
			:contact => 'Hans Meier',
			:contact_email => 'ecosol@ecosol.ch',
			:address => 'Bahnhofstrasse 10',
			:plz => '5780',
			:location => 'Baden',
			:url => 'www.oddb.org',
			:phone => '079 456 43 67',
			:fax => '655 453 44 54',
			:address_email => '',
			:cl_status => true,
			:ean13 => '1234567890976',
			:business_area => 'Pharmafirma',
			:fi_status => true,
			:foo => '12434',
		}
	end
	def test_update_no_name
		@session.user_input = {
			:name	=> nil,
		}
		@state.update
		assert_equal(true, @state.error?)
	end
	def test_update1
		@state.update()
		expected = {
			:address => 'Bahnhofstrasse 10',
			:address_email => '',
			:business_area => 'Pharmafirma',
			:cl_status => true,
			:contact_email => 'ecosol@ecosol.ch',
			:contact => 'Hans Meier',
			:ean13 => '1234567890976',
			:fax => '655 453 44 54',
			:fi_status => true,
			:location => 'Baden',
			:name => 'Ecosol AG',
			:phone => '079 456 43 67',
			:plz => '5780',
			:url => 'www.oddb.org',
		}
		assert_equal(@model.pointer, @app.pointer)
		assert_equal(expected, @app.input) 
	end
	def test_update2
		@app.company_of_same_name = @model
		@state.update()
		expected = {
			:address => 'Bahnhofstrasse 10',
			:address_email => '',
			:business_area => 'Pharmafirma',
			:cl_status => true,
			:contact_email => 'ecosol@ecosol.ch',
			:contact => 'Hans Meier',
			:ean13 => '1234567890976',
			:fax => '655 453 44 54',
			:fi_status => true,
			:location => 'Baden',
			:name => 'Ecosol AG',
			:phone => '079 456 43 67',
			:plz => '5780',
			:url => 'www.oddb.org',
		}
		assert_equal(@model.pointer, @app.pointer)
		assert_equal(expected, @app.input) 
	end
	def test_update3
		@app.company_of_same_name = StubCompany.new
		@state.update()
		assert_nil(@app.pointer)
		assert_nil(@app.input) 
	end
end
class TestUserCompanyState < Test::Unit::TestCase
	class StubSession
		attr_writer :user_input, :user_equiv
		attr_accessor :app
		def user_input(*args)
			input = @user_input.dup
			input.delete_if { |key, val| !args.include?(key) }
			input
		end
		def user_equiv?(*args)
			@user_equiv
		end
	end
	class StubCompany
		attr_accessor :pointer
	end
	class StubApp
		attr_reader :pointer
		attr_reader :input
		attr_writer :company_of_same_name
		def update(pointer, input)
			@pointer = pointer
			@input = input
		end
		def company_by_name(name)
			@company_of_same_name
		end
	end

	def setup
		@session = StubSession.new
		@app = StubApp.new
		@session.app = @app
		@model	= StubCompany.new
		@model.pointer = 'bar'
		@state = State::Companies::UserCompany.new(@session, @model)
		@session.user_input = {
			:name => 'Ecosol AG',
			:contact => 'Hans Meier',
			:contact_email => 'ecosol@ecosol.ch',
			:address => 'Bahnhofstrasse 10',
			:plz => '5780',
			:location => 'Baden',
			:url => 'www.oddb.org',
			:phone => '079 456 43 67',
			:fax => '655 453 44 54',
			:address_email => '',
			:cl_status => true,
			:ean13 => '1234567890976',
			:business_area => 'Pharmafirma',
			:fi_status => true,
			:foo => '12434',
		}
	end
	def test_update1
		@session.user_equiv = true
		@state.update()
		expected = {
			:address => 'Bahnhofstrasse 10',
			:address_email => '',
			:business_area => 'Pharmafirma',
			:contact_email => 'ecosol@ecosol.ch',
			:contact => 'Hans Meier',
			:ean13 => '1234567890976',
			:fax => '655 453 44 54',
			:fi_status => true,
			:location => 'Baden',
			:name => 'Ecosol AG',
			:phone => '079 456 43 67',
			:plz => '5780',
			:url => 'www.oddb.org',
		}
		assert_equal(@model.pointer, @app.pointer)
		assert_equal(expected, @app.input) 
	end
	def test_update2
		@session.user_equiv = true
		@app.company_of_same_name = @model
		@state.update()
		expected = {
			:address => 'Bahnhofstrasse 10',
			:address_email => '',
			:business_area => 'Pharmafirma',
			:contact_email => 'ecosol@ecosol.ch',
			:contact => 'Hans Meier',
			:ean13 => '1234567890976',
			:fax => '655 453 44 54',
			:fi_status => true,
			:location => 'Baden',
			:name => 'Ecosol AG',
			:phone => '079 456 43 67',
			:plz => '5780',
			:url => 'www.oddb.org',
		}
		assert_equal(@model.pointer, @app.pointer)
		assert_equal(expected, @app.input) 
	end
	def test_update3
		@session.user_equiv = true
		@app.company_of_same_name = StubCompany.new
		@state.update()
		assert_nil(@app.pointer)
		assert_nil(@app.input) 
	end
	def test_update3
		@session.user_equiv = false
		@state.update()
		assert_nil(@app.pointer)
		assert_nil(@app.input) 
	end
end
		end
	end
end
