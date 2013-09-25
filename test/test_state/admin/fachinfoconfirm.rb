#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Admin::TestFachinfoConfirm -- oddb.org -- 19.04.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Drugs::TestFachinfoConfirm -- oddb.org -- 03.10.2003 -- rwaltert@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/admin/fachinfoconfirm'
require 'state/global'

module ODDB
	module State
		module Admin
class FachinfoConfirm < State::Admin::Global
	attr_accessor :model, :errors
	attr_reader :unknown_iksnrs, :forbidden_iksnrs
	attr_reader :valid_iksnrs
end

class TestFachinfoConfirmState <Minitest::Test
  include FlexMock::TestCase
	class StubApp
		attr_reader :update_pointers, :update_values
		attr_reader :replace_iksnrs, :replace_pointers
		attr_writer :registration, :update_result
		def initialize
			@update_pointers = []
			@update_values =[]
			@replace_pointers = []
			@replace_iksnrs =[]
		end
		def registration(iksnr)
			@registration if(@registration && @registration.iksnr == iksnr)
		end
		def replace_fachinfo(iksnr, pointer)
			@replace_iksnrs << iksnr
			@replace_pointers << pointer
		end
		def update(pointer, values, unique_email=nil)
			@update_pointers.push(pointer)
			@update_values.push(values)
			@update_result
		end
	end
	class StubSession
		attr_writer :user_equiv, :user_input
		attr_accessor :app
		def initialize
			@user_input = {}
		end
		def user_equiv?(comp)
			@user_equiv
		end
		def user_input(*args)
			args.inject({}) { |inj, key|
				inj.store(key, @user_input[key])
				inj
			}
		end
	end
	class StubRegistration
		attr_reader :company
		attr_accessor :fachinfo, :pointer
		attr_accessor :iksnr
	end
	class StubFachinfoDocument
		attr_reader :iksnrs
		def initialize(iksnrs)
			@iksnrs = iksnrs
		end
	end
	class StubFachinfo
		attr_accessor :pointer
	end
	def setup
		@session = StubSession.new
		@app = StubApp.new
		@session.app = @app
		@state = State::Admin::FachinfoConfirm.new(@session, []) 
	end
	def test_validate_iksnrs3
		# erkennt Registration
		# berechtigt
		reg = StubRegistration.new
		reg.iksnr = '12345'
		@app.registration = reg
		@session.user_equiv = true
		@state.model = [
			StubFachinfoDocument.new('12345'),
			StubFachinfoDocument.new('12345'),
		]
    flexstub(@state.model) do |model|
      model.should_receive(:"registration.iksnr").and_return('12344')
    end
    flexstub(@session) do |ses|
      ses.should_receive(:allowed?).and_return(true)
    end
		@state.validate_iksnrs
		assert_equal(['12344', '12345'], @state.valid_iksnrs)
		assert_equal(false, @state.warning?)
		assert_equal(false, @state.error?)
	end
	def test_validate_iksnrs4
		# erkennt Registration
		# nicht berechtigt
		reg = StubRegistration.new
		reg.iksnr = '12345'
		@app.registration = reg
		@session.user_equiv = true
		@state.model = [
			StubFachinfoDocument.new('1234567,12345')
		]
    flexstub(@state.model) do |model|
      model.should_receive(:"registration.iksnr").and_return('12344')
    end
    flexstub(@session) do |ses|
      ses.should_receive(:allowed?).and_return(true)
    end
		@state.validate_iksnrs
		assert_equal(['12344','12345'], @state.valid_iksnrs)
		assert_equal(1, @state.warnings.size)
		assert_equal(0, @state.errors.size)
		warn = @state.warnings.first
		assert_instance_of(SBSM::Warning, warn)
		assert_equal(:w_unknown_iksnr, warn.message)
		assert_equal(true, @state.warning?)
		assert_equal(false, @state.error?)
	end
	def test_iksnrs1
		doc = StubFachinfoDocument.new('12345,67890, 54321')
		expected = [
			'12345',
			'67890',
			'54321',
		]
		assert_equal(expected, @state.iksnrs(doc))
	end
	def test_iksnrs2
		doc = StubFachinfoDocument.new('2345,7890, 4321')
		expected = [
			'02345',
			'07890',
			'04321',
		]
		assert_equal(expected, @state.iksnrs(doc))
	end
	def test_iksnrs3
		chapter = ODDB::Text::Chapter.new
		section = chapter.next_section	
		section.subheading = "2345,7890, 4'321"
		doc = StubFachinfoDocument.new(section)
		expected = [
			'02345',
			'07890',
			'04321',
		]
		assert_equal(expected, @state.iksnrs(doc))
	end
	def test_iksnrs4
		chapter = ODDB::Text::Chapter.new
		section = chapter.next_section	
		paragraph = section.next_paragraph
		paragraph << "2345,7890, 4'321"
		doc = StubFachinfoDocument.new(section)
		expected = [
			'02345',
			'07890',
			'04321',
		]
		assert_equal(expected, @state.iksnrs(doc))
	end
  def test_replaceable_fachinfo
    @state.instance_eval('@valid_iksnrs = ["12345"]')
    fachinfo = flexmock('fachinfo') 
    registration = flexmock('registration') do |reg|
      reg.should_receive(:fachinfo).and_return(fachinfo)
      reg.should_receive(:iksnr).and_return('12345')
    end
    flexstub(fachinfo) do |fi|
      fi.should_receive(:registrations).and_return([registration])
    end
    flexstub(@session) do |ses|
      ses.should_receive(:registration).and_return(registration)
    end
    assert_equal(fachinfo, @state.replaceable_fachinfo)
  end
	def test_update1
    flexstub(@state) do |sta|
      sta.should_receive(:error?).and_return(true)
    end
    flexstub(@state.model) do |model|
      model.should_receive(:"registration.iksnr").and_return('12344')
    end

		newstate = @state.update
		assert(@state.error?, "No error condition!")
		assert_equal(@state, newstate)
	end
	def test_update2
		fi_doc1 = StubFachinfoDocument.new('98765, 12345')
		fi_doc2 = StubFachinfoDocument.new('98765, 12345')
		@state.model = [ fi_doc2, fi_doc1 ]
		@session.user_input = {
			:language_select	=>	{ "0"=>"fr", '1'=>'de' }
		}
		@session.user_equiv = true
		reg_pointer = Persistence::Pointer.new([:registration, '12345'])
		reg = StubRegistration.new
		reg.iksnr = '12345'
		reg.pointer = reg_pointer
		@app.registration = reg
		fi_pointer = Persistence::Pointer.new(:fachinfo)
		fachinfo = StubFachinfo.new
		fachinfo.pointer = fi_pointer
		@app.update_result = fachinfo

    flexstub(@state.model) do |model|
      model.should_receive(:registration).and_return(reg)
      model.should_receive(:mime_type)
    end
    flexstub(fachinfo) do |fi|
      fi.should_receive(:add_change_log_item)
    end
    flexstub(@session) do |ses|
      ses.should_receive(:allowed?).and_return(true)
      ses.should_receive(:registration).and_return(reg)
      ses.should_receive(:user)
    end
    previous = flexmock('previous') do |pre|
      pre.should_receive(:previous).and_return('previous')
    end
    @state.instance_eval('@previous = previous')
    @state.instance_eval('@language = "fr"')

		@state.update
		assert_equal(false, @state.error?, @state.errors)
		pointers = @app.update_pointers
		assert_equal(2, pointers.size) 		
		assert_equal(fi_pointer.creator, pointers.first)
		values = @app.update_values
		assert_equal(2, values.size)
		expected = {
		#	'de'	=>	fi_doc1,
			'fr'	=>	fi_doc2,
		}
		assert_equal(expected, values.first)
		assert_equal(["12345", "12345"], @app.replace_iksnrs)
		assert_equal([fi_pointer, fi_pointer], @app.replace_pointers)
	end
end

class TestFachinfoConfirm <Minitest::Test
  include FlexMock::TestCase
  def setup
    @registration = flexmock('registration', :iksnr  => 'iksnr')
    @app     = flexmock('app', :registration => @registration)
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :app      => @app,
                        :allowed? => nil,
                        :lookandfeel => @lnf
                       )
    @inject  = flexmock('inject', :each => [])
    @model   = flexmock('model', 
                        :registration => @registration,
                        :inject => @inject,
                       )
    @state   = ODDB::State::Admin::FachinfoConfirm.new(@session, @model)
  end
  def test_init
    expected = ['iksnr']
    assert_equal(expected, @state.init)
  end
  def test_back
    previous = flexmock('previous', :previous => 'previous')
    @state.instance_eval('@previous = previous')
    assert_equal('previous', @state.back)
  end
  def test_update
    flexmock(@model, 
             :at => @model,
             :mime_type => 'mime_type'
            )
    fachinfo     = flexmock('fachinfo', :pointer => 'pointer')
    registration = flexmock('registration', 
                            :fachinfo => fachinfo,
                            :iksnr    => 'iksnr'
                           )
    flexmock(fachinfo, :registrations => [registration])
    flexmock(@session, 
             :registration => registration,
             :user         => 'user'
            )
    update = flexmock('update', 
                      :add_change_log_item => 'add_change_log_item',
                      :pointer => 'pointer'
                     )
    flexmock(@app, 
             :update => update,
             :replace_fachinfo => 'replace_fachinfo'
            )
    previous = flexmock('previous', :previous => 'previous')
    @state.instance_eval('@previous = previous')
    assert_equal('previous', @state.update)
  end
  def test_store_slate_item
    user = flexmock('user', :name => 'name')
    flexmock(@session, :user => user)
    flexmock(@registration, 
             :name_base => 'name_base',
             :pointer   => 'pointer'
            )
    flexmock(@app, 
             :create => 'create',
             :update => 'update'
            )
    flexmock(@model, :mime_type => 'application/msword')
    time = Time.local(2011,2,3)
    assert_equal('update', @state.store_slate_item(time, 'type'))
  end
end
		end
	end
end
