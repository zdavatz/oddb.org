#!/usr/bin/env ruby
#	TestMedwin -- oddb -- 06.10.2003 -- maege@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'plugin/medwin'
require 'util/html_parser'

class TestMedwinCompanyPlugin < Test::Unit::TestCase
	class StubHttp < Net::HTTP
		def post
		end
	end
end
module ODDB
	class MedwinWriter < NullWriter
		attr_writer :tablehandlers
		attr_accessor :extract_called
		def initialize(medwin_template)
			@extract_called = 0
			@tablehandlers = []
			@medwin_template = medwin_template
		end
	end
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
	class MedwinSession < HttpSession
		attr_reader :comp_name, :ean13
		#HTTP_CLASS = TestMedwinCompanyPlugin::StubHttp
		def build_first_post_hash(comp_name, ean13)
			@comp_name = comp_name
			@ean13 = ean13
			{}
		end
		def post(path, hash, id)
			resp = TestMedwinSession::StubResp.new
			resp.body = "html"	
			resp
		end
	end
end

class TestMedwinWriter < Test::Unit::TestCase
	class StubHandler
		attr_reader :extract_cdata_called
		attr_reader :attributes
		def initialize(value, writer)
			@writer = writer
			@attributes = [
				[ '', value]
			]
		end
		def extract_cdata(*args)
			@writer.extract_called += 1
			true
		end
	end
	def setup
		@writer = ODDB::MedwinWriter.new({:key => [1,0]})
	end
	def test_extract_data
		handler = StubHandler.new('tblFind', @writer)
		handler2 = StubHandler.new('tblFind', @writer)
		handler3 = StubHandler.new('foobar', @writer)
		@writer.tablehandlers = [handler, handler2, handler3]
		@writer.extract_data
		assert_equal(2, @writer.extract_called)
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
	def test_plugin_company_html
		normal = StubCompany.new('normal', 'comp1')
		none = StubCompany.new('none', 'comp2')
		multiple = StubCompany.new('multiple', 'comp3')
		result = @plugin.company_html(normal)
		assert_equal(String, result.class)
		result = @plugin.company_html(none)
		assert_equal(nil, result)
		errors = @plugin.errors.keys
		assert_equal('none', errors.first)
		result = @plugin.company_html(multiple)
		assert_equal(nil, result)
		errors = @plugin.errors.keys
		assert_equal(2, errors.size)
	end
	def test_extract
		data = @plugin.extract(@html)
		expected = '7601001003668'
		result = data[:ean13]
		assert_equal(expected, result)
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
	def test_update_company_data2
		comp = @app.companies.values.first
		data = {
			:fax =>	"041 111 22 33\240\240",
		}
		@plugin.update_company_data(comp, data)
		result = @app.values.first.values.first
		assert_equal("041 111 22 33", result)
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
	def test_plugin_package_html
		normal = @app.packages[:normal]
		none = @app.packages[:none]
		multiple = @app.packages[:multiple]
		result = @plugin.package_html(normal)
		assert_equal(String, result.class)
		result = @plugin.package_html(none)
		assert_equal(nil, result)
		errors = @plugin.errors.keys
		assert_equal('none - name base', errors.first)
		result = @plugin.package_html(multiple)
		assert_equal(nil, result)
		errors = @plugin.errors.keys
		assert_equal(2, errors.size)
	end
	def test_extract
		data = @plugin.extract(@html)
		expected = "0342781\240"
		result = data[:pharmacode]
		assert_equal(expected, result)
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
	def test_update_package
		@app.each_package { |pack| @plugin.update_package(pack) }
		assert_equal(3, @plugin.checked)
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
class TestMedwinSession < Test::Unit::TestCase
	class StubResp
		attr_accessor :body
	end
	class StubCompany
		attr_accessor :name, :pointer, :ean13, :address 
		attr_accessor :plz, :location, :phone, :fax
		def initialize(name, pointer)
			@name = name
			@pointer = pointer
		end
	end
	class StubPackage
		attr_accessor :barcode
		def initialize(name)
			@name = name
		end
	end
	def setup
		@session = ODDB::MedwinSession.new("foo")
	end
	def test_company_html
		comp_one = StubCompany.new('comp_one', 'comp1')
		@session.company_html(comp_one)
		assert_equal('comp_one', @session.comp_name)
		comp_two = StubCompany.new("com'p_two", 'comp2')
		@session.company_html(comp_two)
		assert_equal('comp_two', @session.comp_name)
		comp_three = StubCompany.new('a comp three', 'comp3')
		@session.company_html(comp_three)
		assert_equal('comp', @session.comp_name)
	end
	def test_package_html
		pack_one = StubPackage.new('pack_one')
		pack_one.barcode = '1234567890123'
		@session.package_html(pack_one)
		assert_equal('1234567890123', @session.ean13)
	end
	def test_handle_resp
		path = File.expand_path('../data/html/medwin', File.dirname(__FILE__))
		file = "medwin.html"
		html = File.read([path, file].join("/"))
		result = @session.handle_resp(html)
		assert_equal("FooViewState=", result)
	end
end
