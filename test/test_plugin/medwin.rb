#!/usr/bin/env ruby
#	TestMedwin -- oddb -- 06.10.2003 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'plugin/medwin'
require 'util/html_parser'

module ODDB
	class MedwinPlugin < Plugin
		attr_accessor :updated, :checked, :found, :session
		attr_accessor :errors
	end
	class MedwinCompanyPlugin < MedwinPlugin
		attr_accessor :update_company_called 
	end
	class MedwinPackagePlugin < MedwinPlugin
		attr_accessor :update_package_called
	end
end

class TestMedwinCompanyPlugin < Test::Unit::TestCase
	class StubApp
		attr_reader :pointers, :values, :companies
		def initialize
			@pointers = []
			@values = []
			@companies = {
				'comp1'	=>	StubCompany.new('ecosol ag', 'comp1'),
				'comp2'	=>	StubCompany.new('foobar', 'comp2'),
			}
		end
		def update(pointer, values)
			@pointers << pointer
			@values << values
		end
	end
	class StubCompany
		attr_accessor :name, :pointer, :ean13, :address 
		attr_accessor :plz, :location, :phone, :fax
		def initialize(name, pointer)
			@name = name
			@pointer = pointer
		end
		def listed?
			false
		end
		def has_user?
			false
		end
	end
	class StubSession
		attr_accessor :http_path
		def company_html(comp)
			target = File.expand_path('../../test/data/html/medwin', File.dirname(__FILE__))
			case comp.name
			when 'normal'
				table = 'medwin.html'
			when 'none'
				table = 'medwin_no_rslts.html'
			when 'multiple'
				table = 'medwin_2_many_rslts.html'
			end
			html = File.read([target, table].join("/"))

		end
	end
	def setup
		@app = StubApp.new
		@plugin = ODDB::MedwinCompanyPlugin.new(@app)
		@plugin.session = StubSession.new
		target = File.expand_path('../../test/data/html/medwin', File.dirname(__FILE__))
		table = 'medwin.html'
		@html = File.read([target, table].join("/"))
	end
	def test_report
		@plugin.checked = 5
		@plugin.found = 4
		@plugin.updated = ['a','b','c']
		@plugin.errors = {
			'err_comp1'	=>	'error one',
			'err_comp2'	=>	'error two',
			'err_comp3'	=>	'error three',
		}
		lines = @plugin.report
		expected = "Checked 5 Companies\nCompared 4 Medwin Entries\nUpdated  3 Companies:\na\nb\nc\nErrors:\nerr_comp1 => error one\nerr_comp2 => error two\nerr_comp3 => error three"
		assert_equal(expected, lines)
	end
	def test_update
		begin
			@plugin.instance_eval <<-EOS
				alias :original_update_company :update_company
				def update_company(comp)
					@update_company_called = true
				end
			EOS
			@plugin.update
			assert_equal(2, @plugin.checked)
			assert_equal(true, @plugin.update_company_called)
		ensure
			@plugin.instance_eval <<-EOS
				alias :update_company :original_update_company
			EOS
		end
	end
	def test_update_company_data
		@plugin.updated.clear
		comp = @app.companies.values.first
		data = {
			:ean13 =>	'1234567891111',
		}
		@plugin.update_company_data(comp, data)
		result = @app.pointers.first
		assert_equal('comp1', result)
		assert_equal(['ecosol ag'], @plugin.updated)
	end
end
class TestMedwinPackagePlugin < Test::Unit::TestCase
	class StubApp
		attr_reader :pointers, :values, :packages
		def initialize
			@pointers = []
			@values = []
			@packages = {
				:normal		=>	StubPackage.new('normal'),
				:none			=>	StubPackage.new('none'),
				:multiple	=>	StubPackage.new('multiple'),
				#:nil			=>	StubPackage.new('nil'),
			}
		end
		def each_package(&block)
			@packages.each_value(&block)
		end
		def update(pointer, values)
			@pointers << pointer
			@values << values
		end
	end
	class StubPackage
		attr_accessor :barcode, :pointer
		attr_reader :name_base
		def initialize(barcode)
			@barcode = barcode
			@name_base = "name base"
		end
	end
	class StubSession
		attr_accessor :http_path
		def package_html(pack)
			unless(pack.barcode=='nil')
				target = File.expand_path('../../test/data/html/medwin', File.dirname(__FILE__))
				case pack.barcode
				when 'normal'
					table = 'medwin_package.html'
				when 'none'
					table = 'medwin_no_rslts.html'
				when 'multiple'
					table = 'medwin_2_many_rslts.html'
				end
					html = File.read([target, table].join("/"))
			else
				nil
			end
		end
	end
	def setup
		@app = StubApp.new
		@plugin = ODDB::MedwinPackagePlugin.new(@app)
		@plugin.session = StubSession.new
		target = File.expand_path('../../test/data/html/medwin', File.dirname(__FILE__))
		table = 'medwin_package.html'
		@html = File.read([target, table].join("/"))
	end
	def test_update
		begin
			@plugin.instance_eval <<-EOS
				alias :original_update_package :update_package
				def update_package(comp)
					@checked += 1
					@update_package_called = true
				end
			EOS
			@plugin.update
			assert_equal(3, @plugin.checked)
			assert_equal(true, @plugin.update_package_called)
		ensure
			@plugin.instance_eval <<-EOS
				alias :update_package :original_update_package
			EOS
		end
	end
	def test_update_package_data
		@plugin.updated.clear
		pack = @app.packages[:normal]
		pack.pointer = "normal_pack"
		data = {
			:pharmacode =>	"123456\240",
		}
		@plugin.update_package_data(pack, data)
		result = @app.pointers.first
		assert_equal('normal_pack', result)
		assert_equal(['normal'], @plugin.updated)
	end
end
