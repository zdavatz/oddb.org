#!/usr/bin/env ruby
# TestCompany -- oddb -- 28.02.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/company'
require 'state/company'

module ODDB
	class Company
		attr_accessor :registrations
		public :adjust_types
	end
end

module ODBA
	module Persistable
		def odba_store
		end
	end
end
class TestCompany < Test::Unit::TestCase
	class Array
		include ODBA::Persistable
	end
	class Hash
		include ODBA::Persistable
	end
	class StubRegistration
	end
	class StubApp
		attr_reader :companies
		def initialize
			@companies ||= {}
		end
		def create_company
			company = ODDB::Company.new
			@companies.store(company.oid, company)
		end
	end
	class StubSession
		attr_accessor :app
		def app
			@app ||= StubApp.new
		end
	end

	def setup
		@session = StubSession.new
		@company = @session.app.create_company
	end
	def test_add_registration
		@company.registrations = []
		reg = StubRegistration.new
		@company.add_registration(reg)
		assert_equal([reg], @company.registrations)
	end
	def test_remove_registration
		reg = StubRegistration.new
		@company.registrations = [reg]
		@company.remove_registration(reg)
		assert_equal([], @company.registrations)
	end
	def test_update_values
		values = {
			:name						=>	'ywesee.com',
			:cl_status			=>	true,
			:fi_status			=>	false,
			:url						=>	'www.ywesee.com',
			:business_area	=>	'Intellectual Capital',
			:contact				=>	'hwyss at ywesee.com',
			:address				=>	'Winterthurerstrasse',
			:plz						=>	'8000',
			:location				=>	'Zuerich'
		}
		reg = StubRegistration.new
		@company.add_registration(reg)
		assert_equal(nil, @company.name)
		@company.update_values(values)
		assert_equal('ywesee.com', @company.name)
		assert_equal(true, @company.cl_status)
		assert_equal(false, @company.fi_status)
		assert_equal('www.ywesee.com', @company.url)
		assert_equal('Intellectual Capital', @company.business_area)
		assert_equal('hwyss at ywesee.com', @company.contact)
		assert_equal('Winterthurerstrasse', @company.address)
		assert_equal('8000', @company.plz)
		assert_equal('Zuerich', @company.location)
		assert_equal([reg], @company.registrations)
	end		
	def test_adjust_types
		values = {
			:name						=>	'ywesee.com',
			:cl_status			=>	'true',
			:fi_status			=>	'false',
			:url						=>	'www.ywesee.com',
			:business_area	=>	'Intellectual Capital',
			:contact				=>	'hwyss at ywesee.com',
			:address				=>	'Winterthurerstrasse',
			:plz						=>	'8000',
			:location				=>	'Zuerich'
		}
		expected = {
			:name						=>	'ywesee.com',
			:cl_status			=>	true,
			:fi_status			=>	false,
			:url						=>	'www.ywesee.com',
			:business_area	=>	'Intellectual Capital',
			:contact				=>	'hwyss at ywesee.com',
			:address				=>	'Winterthurerstrasse',
			:plz						=>	'8000',
			:location				=>	'Zuerich'
		}
		assert_equal(expected, @company.adjust_types(values))
	end
end
