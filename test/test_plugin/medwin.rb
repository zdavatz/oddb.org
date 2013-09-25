#!/usr/bin/env ruby
# encoding: utf-8
# TestMedwin -- oddb -- 25.03.2011 -- mhatakeyama@ywesee.com
#	TestMedwin -- oddb -- 06.10.2003 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))
$: << File.expand_path("../..", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'plugin/medwin'
require 'util/html_parser'
require 'flexmock'
require 'ext/meddata/src/meddata'

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

class TestMedwinCompanyPlugin <Minitest::Test
  include FlexMock::TestCase
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
		def update(pointer, values, origin)
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
    def data_origin(key)
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
  def test_update_company_data__phone_fax
    company = flexmock('company', 
                       :data_origin => 'data_origin',
                       :name        => 'name',
                       :pointer     => 'pointer'
                      )
    data    = {:address => 'address', :phone => 'phone', :fax => 'fax'}
    assert_equal([{}], @plugin.update_company_data(company, data))
  end
  def stderr_null
    require 'tempfile'
    $stderr = Tempfile.open('stderr')
    yield
    $stderr.close
    $stderr = STDERR
  end
  def replace_constant(constant, temp)
    stderr_null do
      keep = eval constant
      eval "#{constant} = temp"
      yield
      eval "#{constant} = keep"
    end
  end
  def test_update_company
    meddata = flexmock('meddata', 
                       :search => ['result'],
                       :detail => {'key' => 'detail'}
                      )
    server  = flexmock('server') do |s|
      s.should_receive(:session).and_yield(meddata)
    end
    company = flexmock('company', 
                       :ean13       => 'ean13',
                       :name        => 'name',
                       :data_origin => 'data_origin',
                       :pointer     => 'pointer'
                      )
    replace_constant('ODDB::MedwinCompanyPlugin::MEDDATA_SERVER', server) do  
      assert_equal(nil, @plugin.update_company(company))
    end
  end
  def test_update_company__result_empty
    meddata = flexmock('meddata', 
                       :search => [],
                       :detail => {'key' => 'detail'}
                      )
    server  = flexmock('server') do |s|
      s.should_receive(:session).and_yield(meddata)
    end
    company = flexmock('company', 
                       :ean13       => 'ean13',
                       :name        => 'name',
                       :data_origin => 'data_origin',
                       :pointer     => 'pointer'
                      )
    replace_constant('ODDB::MedwinCompanyPlugin::MEDDATA_SERVER', server) do  
      assert_equal(nil, @plugin.update_company(company))
    end
  end

end

class TestMedwinPackagePlugin <Minitest::Test
  include FlexMock::TestCase
	class StubSequence
		attr_accessor :packages
		def active?
			true
		end
		def each_package(&block)
			@packages.each_value(&block)
		end
	end
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
			@sequence = StubSequence.new
			@sequence.packages = @packages
		end
		def each_package(&block)
			@packages.each_value(&block)
		end
		def each_sequence(&block)
			block.call(@sequence)
		end
		def update(pointer, values, origin)
			@pointers << pointer
			@values << values
		end
	end
	class StubPackage
		attr_accessor :barcode, :pointer, :pharmacode, :out_of_trade
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
  def test_report
    errors = {'key' => 'value'}
    @plugin.instance_eval('@errors = errors')
    expected = "\nChecked 0 Packages\nTried 0 Medwin Entries\nUpdated  0 Packages\nProbable Errors in ODDB: 0\nProbable Errors in Medwin: 0\n\nProbable Errors in ODDB: 0\nIn den folgenden Fällen ist die Swissmedic-Packungsnummer von ODDB.org ziemlich\nsicher falsch, weil Sie tiefer ist als diejenige von Medwin.ch\n\n\nProbable Errors in Medwin: 0\nIn den folgenden Fällen ist die Swissmedic-Packungsnummer von Medwin.ch\nziemlich sicher falsch, weil Sie tiefer ist als diejenige von ODDB.org.\n\n\nErrors:\nkey => value"
    assert_equal(expected, @plugin.report)
  end
  def test_update_package
    package = flexmock('package', 
                       :barcode    => 'barcode',
                       :pharmacode => 'pharmacode',
                       :pointer    => 'pointer'
                      )
    meddata = flexmock('meddata', 
                       :search => ['result'],
                       :detail => {'key' => 'detail'}
                      )
    assert_equal([{"key"=>"detail"}], @plugin.update_package(meddata, package))
  end
  def test_update_package__result_empty
    package = flexmock('package', 
                       :barcode    => 'barcode',
                       :pharmacode => 'pharmacode',
                       :pointer    => 'pointer',
                       :"registration.package_count" => 1
                      )
    meddata = flexmock('meddata', 
                       :search => [],
                       :detail => {'key' => 'detail'}
                      )
    assert_equal(nil, @plugin.update_package(meddata, package))
  end
  def test_update_package__ean13__medwin_error
    package = flexmock('package', 
                       :barcode    => '1234567890124',
                       :pharmacode => 'pharmacode',
                       :pointer    => 'pointer'
                      )
    meddata = flexmock('meddata', 
                       :search => ['result'],
                       :detail => {:ean13 => '1234567890123'}
                      )
    assert_equal([{:medwin_ikscd=>"012"}], @plugin.update_package(meddata, package))
  end
  def test_update_package__ean13_oddb_error
    package = flexmock('package', 
                       :barcode    => '1234567890122',
                       :pharmacode => 'pharmacode',
                       :pointer    => 'pointer'
                      )
    meddata = flexmock('meddata', 
                       :search => ['result'],
                       :detail => {:ean13 => '1234567890123'}
                      )
    assert_equal([{:medwin_ikscd=>"012"}], @plugin.update_package(meddata, package))
  end
  def stderr_null
    require 'tempfile'
    $stderr = Tempfile.open('stderr')
    yield
    $stderr.close
    $stderr = STDERR
  end
  def replace_constant(constant, temp)
    stderr_null do
      keep = eval constant
      eval "#{constant} = temp"
      yield
      eval "#{constant} = keep"
    end
  end
  def test_update
    package = flexmock('package', 
                       :out_of_trade => nil,
                       :barcode      => 'barcode',
                       :pharmacode   => 'pharmacode',
                       :pointer      => 'pointer'
                      )
    flexmock(@app) do |a|
      a.should_receive(:each_package).and_yield(package)
    end
    meddata = flexmock('meddata', 
                       :search => ['result'],
                       :detail => {'key' => 'detail'}
                      )
    server  = flexmock('server') do |s|
      s.should_receive(:session).and_yield(meddata)
    end
    replace_constant('ODDB::MedwinPackagePlugin::MEDDATA_SERVER', server) do
      assert_equal(nil, @plugin.update)
    end
  end
  def test_update_package_trade_status
    package = flexmock('package', 
                       :barcode      => 'barcode',
                       :out_of_trade => nil
                      )
    meddata = flexmock('meddata', :search => ['result'])
    flexmock(@plugin, :sleep => 'sleep')
    assert_equal('sleep', @plugin.update_package_trade_status(meddata, package))
  end
  def test_update_package_trade_status__result_empty
    package = flexmock('package', 
                       :barcode      => 'barcode',
                       :pharmacode   => 'pharmacode',
                       :out_of_trade => nil,
                       :pointer      => 'pointer',
                       :"registration.package_count" => 1
                      )
    meddata = flexmock('meddata', :search => [])
    server  = flexmock('server') do |s|
      s.should_receive(:session).and_yield(meddata)
    end
    flexmock(@plugin, :sleep => 'sleep')
    replace_constant('ODDB::MedwinPackagePlugin::MEDDATA_SERVER', server) do
      expected = [{:out_of_trade => true}]
      assert_equal(expected, @plugin.update_package_trade_status(meddata, package))
    end
  end
  def test_update_package_trade_status__out_of_trade
    package = flexmock('package', 
                       :barcode      => 'barcode',
                       :out_of_trade => true,
                       :pointer      => 'pointer'
                      )
    meddata = flexmock('meddata', :search => ['result'])
    flexmock(@plugin, :sleep => 'sleep')
    expected = [{:out_of_trade => false, :refdata_override => false}]
    assert_equal(expected, @plugin.update_package_trade_status(meddata, package))
  end
  def test_update_package_trade_status__error
    package = flexmock('package', 
                       :barcode      => 'barcode',
                       :pharmacode   => 'pharmacode',
                       :out_of_trade => nil,
                       :pointer      => 'pointer',
                       :"registration.package_count" => 1
                      )
    meddata = flexmock('meddata', :search => [])
    server  = flexmock('server') do |s|
      s.should_receive(:session).and_raise(ODDB::MedData::OverflowError)
    end
    flexmock(@plugin, :sleep => 'sleep')
    replace_constant('ODDB::MedwinPackagePlugin::MEDDATA_SERVER', server) do
      expected = [{:out_of_trade => true}]
      assert_equal(expected, @plugin.update_package_trade_status(meddata, package))
    end
  end
  def test_update_trade_status
    package = flexmock('package', 
                       :barcode      => 'barcode',
                       :out_of_trade => nil
                      )
    meddata = flexmock('meddata', :search => ['result'])
    server  = flexmock('server') do |s|
      s.should_receive(:session).and_yield(meddata)
    end
    flexmock(@plugin, :sleep => 'sleep')
    replace_constant('ODDB::MedwinPackagePlugin::MEDDATA_SERVER', server) do
      assert_equal(nil, @plugin.update_trade_status)
    end
  end
end
