#!/usr/bin/env ruby
# State::Drugs::TestFachinfoConfirm -- oddb -- 03.10.2003 -- rwaltert@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/drugs/fachinfoconfirm'
require 'state/global'

module ODDB
	module State
		module Drugs
class FachinfoConfirm < State::Drugs::Global
	attr_accessor :model, :errors
	attr_reader :unknown_iksnrs, :forbidden_iksnrs
	attr_reader :valid_iksnrs
end

class TestFachinfoConfirmState < Test::Unit::TestCase
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
		def update(pointer, values)
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
		@state = State::Drugs::FachinfoConfirm.new(@session, []) 
	end
	def test_validate_iksnrs1
		# erkennt Registration nicht
		@state.model = [
			StubFachinfoDocument.new('1234567')
		]
		@state.validate_iksnrs
		assert_equal([], @state.valid_iksnrs)
		assert_equal(1, @state.warnings.size)
		assert_equal(1, @state.errors.size)
		warn = @state.warnings.first
		assert_instance_of(SBSM::Warning, warn)
		assert_equal(:w_unknown_iksnr, warn.message)
		err = @state.error(:iksnrs)
		assert_instance_of(SBSM::ProcessingError, err)
		assert_equal('e_no_valid_iksnrs', err.message)
	end
	def test_validate_iksnrs2
		# erkennt Registration
		# nicht berechtigt
		reg = StubRegistration.new
		reg.iksnr = '1234567'
		@app.registration = reg
		@state.model = [
			StubFachinfoDocument.new('1234567')
		]
		@state.validate_iksnrs
		assert_equal([], @state.valid_iksnrs)
		assert_equal(1, @state.warnings.size)
		assert_equal(1, @state.errors.size)
		warn = @state.warnings.first
		assert_instance_of(SBSM::Warning, warn)
		assert_equal(:w_access_denied_iksnr, warn.message)
		err = @state.error(:iksnrs)
		assert_instance_of(SBSM::ProcessingError, err)
		assert_equal('e_no_valid_iksnrs', err.message)
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
		@state.validate_iksnrs
		assert_equal(['12345'], @state.valid_iksnrs)
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
		@state.validate_iksnrs
		assert_equal(['12345'], @state.valid_iksnrs)
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
	def test_update1
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
		@state.update
		assert_equal(false, @state.error?, @state.errors)
		pointers = @app.update_pointers
		assert_equal(1, pointers.size) 		
		assert_equal(fi_pointer.creator, pointers.first)
		values = @app.update_values
		assert_equal(1, values.size)
		expected = {
			'de'	=>	fi_doc1,
			'fr'	=>	fi_doc2,
		}
		assert_equal(expected, values.first)
		assert_equal(["12345"], @app.replace_iksnrs)
		assert_equal([fi_pointer], @app.replace_pointers)
	end
end
		end
	end
end
