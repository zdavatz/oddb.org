#!/usr/bin/env ruby
# State::Companies::TestCompany -- oddb -- 02.03.2011 -- mhatakeyama@ywesee.com
# State::Companies::TestCompany -- oddb -- 02.10.2003 -- rwaltert@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/companies/company'
require 'state/global'
require 'flexmock'

module ODDB 
	module State
		module Companies
class TestRootCompanyState < Test::Unit::TestCase
  include FlexMock::TestCase
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
    flexstub(@model) do |m|
      m.should_receive(:contact_email)
    end
		@state.update
		assert_equal(true, @state.error?)
	end
	def test_update1
    flexstub(@model) do |m|
      m.should_receive(:contact_email)
    end
		state = @state.update()
    assert_kind_of(ODDB::State::Companies::RootCompany, state)
	end
	def test_update2
    flexstub(@model) do |m|
      m.should_receive(:contact_email)
    end
		@app.company_of_same_name = StubCompany.new
		@state.update()
		assert_nil(@app.pointer)
		assert_nil(@app.input) 
	end
end
class TestUserCompanyState < Test::Unit::TestCase
  include FlexMock::TestCase
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
    flexstub(@session) do |ses|
      ses.should_receive(:allowed?)
    end
    pointer = flexmock('pointer') do |ptr|
      ptr.should_receive(:to_yus_privilege)
    end
    flexstub(@model) do |m|
      m.should_receive(:pointer).and_return(pointer)
    end

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
			:cl_status => true,
			:foo => '12434',
		}
    state = @state.update
    assert_kind_of(State::Companies::Company, state)
    assert_equal(expected, state.instance_eval('@session').instance_eval('@user_input'))
	end
	def test_update2
		@session.user_equiv = true
    flexstub(@session) do |ses|
      ses.should_receive(:allowed?)
    end
    pointer = flexmock('pointer') do |ptr|
      ptr.should_receive(:to_yus_privilege)
    end
    flexstub(@model) do |m|
      m.should_receive(:pointer).and_return(pointer)
    end
		@app.company_of_same_name = StubCompany.new
		@state.update()
		assert_nil(@app.pointer)
		assert_nil(@app.input) 
	end
	def test_update3
		@session.user_equiv = false
    flexstub(@session) do |ses|
      ses.should_receive(:allowed?)
    end
    pointer = flexmock('pointer') do |ptr|
      ptr.should_receive(:to_yus_privilege)
    end
    flexstub(@model) do |m|
      m.should_receive(:pointer).and_return(pointer)
    end
		@state.update()
		assert_nil(@app.pointer)
		assert_nil(@app.input) 
	end
end
		end
	end
end
