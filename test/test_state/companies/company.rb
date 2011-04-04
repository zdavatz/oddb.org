#!/usr/bin/env ruby
# ODDB::State::Companies::TestCompany -- oddb.org -- 04.04.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Companies::TestCompany -- oddb.org -- 02.10.2003 -- rwaltert@ywesee.com

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

class TestCompany < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_snapback_event
    @session = flexmock('session')
    @model   = flexmock('model', :name => 'name')
    @state   = ODDB::State::Companies::Company.new(@session, @model)
    assert_equal('name', @state.snapback_event)
  end
end

class TestUserCompany < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @app     = flexmock('app')
    @session = flexmock('session', :app => @app)
    @model   = flexmock('model')
    @state   = ODDB::State::Companies::UserCompany.new(@session, @model)
  end
  def test_validate
    # This is a testcase for a private method
    assert_equal(nil, @state.instance_eval('validate("input")'))
  end
  def test_user_or_creator
    # This is a testcase for a private method
    flexmock(@model, 
             :user  => nil,
             :carry => nil
            )
    flexmock(@session, :user_input => nil)
    assert_kind_of(ODDB::Persistence::CreateItem, @state.instance_eval('user_or_creator'))
  end
  def test_do_update
    # This is a testcase for a private method
    flexmock(@app, :update => 'update')
    address = flexmock('address', 
                       :address=  => nil,
                       :location= => nil,
                       :fon=      => nil,
                       :fax=      => nil
                      )
    flexmock(@model, 
             :address => address,
             :pointer => 'pointer'
            )
    flexmock(@session, 
             :user_input => 'user_input',
             :user       => 'user'
            )
    keys = ['key']
    assert_kind_of(ODDB::State::Companies::UserCompany, @state.instance_eval('do_update(keys)'))
  end
  def test_do_update__upload
    # This is a testcase for a private method
    flexmock(FileUtils, :mkdir_p => nil)
    flexmock(File) do |f|
      f.should_receive(:open).and_yield('')
      f.should_receive(:exist?).and_return(true)
      f.should_receive(:delete)
    end
    flexmock(@app, :update => 'update')
    address = flexmock('address', 
                       :address=  => nil,
                       :location= => nil,
                       :fon=      => nil,
                       :fax=      => nil
                      )
    flexmock(@model, 
             :address       => address,
             :pointer       => 'pointer',
             :logo_filename => 'logo_filename',
             :oid           => 'oid'
            )
    input   = flexmock('input', 
                       :original_filename => 'original_filename',
                       :read              => nil
                      )
    flexmock(@session, 
             :user_input => input,
             :user       => 'user'
            )
    keys    = [:logo_file, :name]
    assert_kind_of(ODDB::State::Companies::UserCompany, @state.instance_eval('do_update(keys)'))
  end
  def test_do_update__error
    # This is a testcase for a private method
    flexmock(FileUtils, :mkdir_p => nil)
    flexmock(File) do |f|
      f.should_receive(:open).and_yield('')
      f.should_receive(:exist?).and_return(true)
      f.should_receive(:delete).and_raise(StandardError)
    end
    flexmock(@app, :update          => 'update')
    address = flexmock('address', 
                       :address=  => nil,
                       :location= => nil,
                       :fon=      => nil,
                       :fax=      => nil
                      )
    flexmock(@model, 
             :address       => address,
             :pointer       => 'pointer',
             :logo_filename => 'logo_filename',
             :oid           => 'oid'
            )
    input   = flexmock('input', 
                       :original_filename => 'original_filename',
                       :read              => nil
                      )
    flexmock(@session, 
             :user_input => input,
             :user       => 'user'
            )
    keys    = [:logo_file, :name]
    assert_kind_of(ODDB::State::Companies::UserCompany, @state.instance_eval('do_update(keys)'))
  end
  def test_do_update__input_name
    # This is a testcase for a private method
    flexmock(FileUtils, :mkdir_p => nil)
    flexmock(File) do |f|
      f.should_receive(:open).and_yield('')
      f.should_receive(:exist?).and_return(true)
      f.should_receive(:delete).and_raise(StandardError)
    end
    flexmock(@app, 
             :update          => 'update',
             :company_by_name => 'company'
            )
    address = flexmock('address', 
                       :address=  => nil,
                       :location= => nil,
                       :fon=      => nil,
                       :fax=      => nil
                      )
    flexmock(@model, 
             :address       => address,
             :pointer       => 'pointer',
             :logo_filename => 'logo_filename',
             :oid           => 'oid'
            )
    flexmock(@session, 
             :user_input => 'name',
             :user       => 'user'
            )
    keys    = [:name]
    assert_kind_of(ODDB::State::Companies::UserCompany, @state.instance_eval('do_update(keys)'))
  end

  def test_update
    flexmock(@app, :update   => 'update')
    address = flexmock('address', 
                       :address=  => nil,
                       :location= => nil,
                       :fon=      => nil,
                       :fax=      => nil
                      )
    pointer = flexmock('pointer', :to_yus_privilege => nil)
    flexmock(@model, 
             :address => address,
             :pointer => pointer
            )
    flexmock(@session, 
             :user_input => 'user_input',
             :user       => 'user',
             :allowed?   => true
            )
    keys = ['key']

    assert_kind_of(ODDB::State::Companies::UserCompany, @state.update)
  end
  def test_update__return_company
    flexmock(@app, :update   => 'update')
    address = flexmock('address', 
                       :address=  => nil,
                       :location= => nil,
                       :fon=      => nil,
                       :fax=      => nil
                      )
    pointer = flexmock('pointer', :to_yus_privilege => nil)
    flexmock(@model, 
             :address => address,
             :pointer => pointer
            )
    flexmock(@session, 
             :user_input => 'user_input',
             :user       => 'user',
             :allowed?   => nil
            )
    keys = ['key']

    assert_kind_of(ODDB::State::Companies::Company, @state.update)
  end
  def test_set_pass
    flexmock(@app, :update   => 'update')
    address = flexmock('address', 
                       :address=  => nil,
                       :location= => nil,
                       :fon=      => nil,
                       :fax=      => nil
                      )
    pointer = flexmock('pointer', :to_yus_privilege => nil)
    flexmock(@model, 
             :address => address,
             :pointer => pointer
            )
    flexmock(@session, 
             :user_input => {'name' => 'value'},
             :user       => 'user',
             :allowed?   => true
            )
    keys = ['key']

    assert_equal(nil, @state.set_pass)
  end
end

		end
	end
end
