#!/usr/bin/env ruby
# TestSponsor -- oddb -- 29.07.2003 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'model/sponsor'
require 'util/upload'

module ODDB
	class Sponsor
		attr_writer :logo_filename
		remove_const :PATH
		PATH = File.expand_path('../data/sponsor', File.dirname(__FILE__))
		public :adjust_types
	end
end

class TestSponsor < Test::Unit::TestCase
	class StubApp
		def company_by_name(name)
			'company_by_name'
		end
		def company(oid)
			'company_by_oid'
		end
	end
	class StubLogo
		attr_accessor :original_filename, :read
	end	

	def setup
		@sponsor = ODDB::Sponsor.new
		@app = StubApp.new
		@file = File.expand_path('../data/sponsor/foo.gif', 
			File.dirname(__FILE__))
		@file2 = File.expand_path('../data/sponsor/bar.jpg', 
			File.dirname(__FILE__))
	end
	def teardown
		File.delete(@file) if File.exists?(@file)
		File.delete(@file2) if File.exists?(@file2)
	end
	def test_initialize
		expected = ODDB::Persistence::Pointer.new(:sponsor)
		assert_equal(expected, @sponsor.pointer)
	end
	def test_adjust_types
		values = {
			:company				=>	'ywesee',
			:sponsor_until	=>	Date.new(2200, 12, 31),
		}
		expected = {
			:company				=>	'company_by_name',
			:sponsor_until	=>	Date.new(2200, 12, 31),
		}
		assert_equal(expected, @sponsor.adjust_types(values, @app))
		values = {
			:company				=>	1,
			:sponsor_until	=>	'2200-1-0',
		}
		expected = {
			:company				=>	'company_by_oid',
			:sponsor_until	=>	nil,
		}
		assert_equal(expected, @sponsor.adjust_types(values, @app))
		values = {
			:company				=>	ODDB::Persistence::Pointer.new([:company, 1]),
			:sponsor_until	=>	nil,
		}
		expected = {
			:company				=>	'company_by_oid',
			:sponsor_until	=>	nil,
		}
		assert_equal(expected, @sponsor.adjust_types(values, @app))
		values = {
			:company				=>	nil,
			:sponsor_until	=>	nil,
		}
		assert_nothing_raised { @sponsor.adjust_types(values, @app) }
	end
	def test_company_name_robust
		assert_nil(@sponsor.company)
		assert_nothing_raised { @sponsor.company_name }
	end
	def test_logo_writer1
		assert(!File.exist?(@file))
		logo = StubLogo.new
		logo.original_filename = 'foo.gif'
		logo.read = 'bar'
		upload = ODDB::Upload.new(logo)
		@sponsor.logo = upload
		assert_equal('foo.gif', @sponsor.logo_filename)
		assert(File.exist?(@file), "logo file was not saved, it's a pity.")
		assert_equal('bar', File.read(@file))
	end
	def test_logo_writer2
		@sponsor.logo_filename = 'bar.jpg'
		File.open(@file2, "w") { |fh| fh << 'baz' }
		logo = StubLogo.new
		logo.original_filename = 'foo.gif'
		logo.read = 'bar'
		upload = ODDB::Upload.new(logo)
		@sponsor.logo = upload
		assert(!File.exist?(@file2), 'old file was not deleted, sorry. Try again.')
	end
end
