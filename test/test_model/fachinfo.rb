#!/usr/bin/env ruby
# TestFachinfo -- oddb -- 17.09.2003 -- rwaltert@ywesee.com

$: << File.dirname(__FILE__)
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/fachinfo'
require 'model/text'
require 'odba'
require 'mock'

module ODDB
	class Fachinfo
		attr_accessor :registrations
	end
	class FachinfoDocument
		attr_accessor :registrations
	end
end

module ODBA
	module Persistable
		def odba_store
		end
		def odba_isolated_store
		end
	end
end
class TestFachinfo < Test::Unit::TestCase
	class Array
		include ODBA::Persistable
	end
	class Hash
		include ODBA::Persistable
	end
	class StubRegistration
		attr_accessor :company_name
		attr_accessor :generic_type
		attr_accessor :substance_names
	end
	def setup
		ODBA.storage =  Mock.new
		ODBA.storage.__next(:next_id) {
			1
		}
		ODBA.storage.__next(:next_id) {
			2
		}
		@fachinfo = ODDB::Fachinfo.new
	end
	def teardown
		ODBA.storage = nil
	end
	def test_add_registration
		reg = StubRegistration.new
		@fachinfo.add_registration(reg)
		assert_equal([reg], @fachinfo.registrations)
	end
	def test_remove_registration
		reg = StubRegistration.new
		@fachinfo.registrations = [reg]
		@fachinfo.remove_registration(reg)
		assert_equal([], @fachinfo.registrations)
	end
	def test_each_chapter
		fachinfo = ODDB::FachinfoDocument.new
		fachinfo.galenic_form = ODDB::Text::Chapter.new
		fachinfo.composition = ODDB::Text::Chapter.new
		chapters = []
		fachinfo.each_chapter { |chap|
			chapters << chap	
		}
		assert_equal(2, chapters.size)
	end
	def test_each_chapter2
		fachinfo = ODDB::FachinfoDocument2001.new
		fachinfo.amzv = ODDB::Text::Chapter.new
		fachinfo.composition = ODDB::Text::Chapter.new
		fachinfo.effects = ODDB::Text::Chapter.new
		chapters = []
		fachinfo.each_chapter { |chap|
			chapters << chap	
		}
		assert_equal(3, chapters.size)
	end
	def test_company_name
		reg = StubRegistration.new
		expected = "Ywesee"
		reg.company_name = expected
		@fachinfo.registrations.push(reg)
		assert_equal(expected, @fachinfo.company_name)
	end
	def test_substance_names
		reg = StubRegistration.new
		expected = ["Magnesuim", "Mannidol"]
		reg.substance_names = expected
		@fachinfo.registrations.push(reg)
		assert_equal(expected, @fachinfo.substance_names)
	end
	def test_generic_type
		reg = StubRegistration.new
		expected = :generic
		reg.generic_type = expected
		@fachinfo.registrations.push(reg)
		assert_equal(expected, @fachinfo.generic_type)
	end
end
