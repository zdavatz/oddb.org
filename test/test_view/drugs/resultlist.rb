#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::Drugs::TestResultList -- oddb.org -- 17.11.2011 -- mhatakeyama@ywesee.com
# ODDB::View::Drugs::TestResultList -- oddb.org -- 05.03.2003 -- hwyss@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/drugs/resultlist'
require 'view/drugs/rootresultlist'
require 'util/language'
require 'htmlgrid/span'
require 'view/pager'
require 'model/sequence'

module ODDB
  module View
    module AdditionalInformation
      Registration = self.class
    end
  end
end

module ODDB
	module View
		module Drugs
class ResultList < HtmlGrid::List
	public :init
	attr_reader :model
end
class RootResultList < View::Drugs::ResultList
#	public :hash_insert
end

class StubResultListCompany
	attr_accessor :name, :cl_status 
	def initialize(name, cl_status)
		@name = name
		@cl_status = cl_status
	end
end
class StubResultListPackage
	def barcode
		'7680123450124'
	end
	def company
		StubResultListCompany.new("ywesee","true")
	end
	def company_name
		company.name
	end
	def method_missing(*args)
		nil
	end
	def price_public
		67890
	end
	def price_exfactory
		12345
	end
	def active_agents
		[]
	end
	def substances
		[]
	end
	def registration
		self
	end
	def iksnr
		'1234567'
	end
end
class StubResultListModel
	attr_accessor :package_count
	def initialize
		@package_count = 12
	end
	def code
		'A01AA01'
	end
	def packages
		[StubResultListPackage.new]
	end
	def description(foo)
		'foo'
	end
	def has_ddd?
		false
	end
end
class StubResultListLookandfeel
	def method_missing(*args)
		nil
	end
	def lookup(key, *args)
		key.to_s
	end
	def attributes(key)
		{}
	end
	def format_price(*args)
		'678.90'
	end
end
class StubResultListSession
	attr_accessor :event
	def state
		StubResultListState.new
	end
	def user
		RootUser.new
	end
	def lookandfeel
		StubResultListLookandfeel.new
	end
end
class StubResultListState
	def pages
		nil
	end
end
class RootUser
end

class TestResultList <Minitest::Test
  include FlexMock::TestCase
	class StubSession
		attr_accessor :pages
		attr_accessor :dictionary
		def attributes(key)
			{}
		end
		def event_url(url, name)
		end
		def language()
		end
		def lookup(key, *args)
			(@dictionary ||= {})[key].to_s
		end
		def lookandfeel
			self
		end
		def state()
			self
		end
		def user
			RootUser.new
		end
		def format_price(num)
			'678.90'
		end
	end
	class StubAtc
		attr_accessor :packages, :package_count
		def code
		end
		def description(key)
		end
		def has_ddd?
			false
		end
	end
	class StubPackage
		attr_accessor :pointer, :name_base, :generic_type
		attr_accessor :barcode, :price_exfactory, :price_public
		attr_accessor :active_agents, :company, :ikscat
		attr_accessor :fachinfo, :limitation_text
		def sl_entry
			self
		end
		def substances
			active_agents
		end
		def method_missing(*args)
		end
	end
	class StubCompany
		attr_accessor :fi_status
		def method_missing(*args)
		end
	end
	class StubFachinfo
		attr_accessor :pointer
	end
	class StubLimitationText
		attr_accessor :pointer
		include SimpleLanguage
	end
	def setup
		@package = StubPackage.new
		@package.name_base = 'foo'
		@package.active_agents = []
		@model = StubAtc.new
		@model.packages = [@package]
		@session = StubSession.new
    flexstub(@session) do |ses|
      ses.should_receive(:result_list_components).and_return({})
      ses.should_receive(:persistent_user_input).and_return('persistent_user_input')
      ses.should_receive(:allowed?).and_return(true)
      ses.should_receive(:disabled?)
      ses.should_receive(:cookie_set_or_get)
      ses.should_receive(:enabled?)
      ses.should_receive(:_event_url)
    end
    flexstub(@model) do |mod|
      mod.should_receive(:empty?)
      mod.should_receive(:overflow?).and_return(true)
      mod.should_receive(:parent_code)
      mod.should_receive(:pointer)
    end
    registration = flexmock('registration', 
                            :pointer => 'pointer',
                            :iksnr   => 'iksnr'
                           )
    flexstub(@package) do |pac|
      pac.should_receive(:registration).and_return(registration)
    end
    skip("Niklaus needs more time to mock up this example!")
		@list = View::Drugs::ResultList.new([@model], @session)
	end
	def test_fachinfo
    # This is actually the test of fachinfo method of AdditionalInformation module

		link = @list.fachinfo(@package, @session)
		assert_instance_of(HtmlGrid::Link, link)
	end
	def test_limitation_text
    flexstub(ODBA.cache) do |c|
      c.should_receive(:next_id).and_return(123)
    end
		li = StubLimitationText.new
		@session.dictionary = { :limitation_text_short=> '!'}
		assert_nil(@list.limitation_text(@package, @session))
		@package.sl_entry.limitation_text = li
		link = @list.limitation_text(@package, @session)
		assert_instance_of(HtmlGrid::Link, link)
		@package.sl_entry.limitation_text = nil
		assert_nil(@list.limitation_text(@package, @session))
	end
  def test_active_agents
    active_agent = flexmock('active_agent')
    flexmock(@model, :active_agents => [active_agent, active_agent])
    assert_kind_of(HtmlGrid::Link, @list.active_agents(@model, @session))
  end
  def test_active_agents__size_1
    active_agent = flexmock('active_agent')
    flexmock(@model, :active_agents => [active_agent])
    assert_kind_of(HtmlGrid::Link, @list.active_agents(@model, @session))
  end
  def test_explain_atc
    assert_kind_of(HtmlGrid::Link, @list.explain_atc(@model))
  end
  def test_galenic_form
    galenic_form = flexmock('galenic_form', :language => 'language')
    flexmock(@model, :galenic_forms => [galenic_form])
    flexmock(@session, :language => 'language')
    assert_equal('language', @list.galenic_form(@model, @session))
  end
  def test_registration_date
    flexmock(@model, :inactive_date => 'inactive_date')
    flexmock(@session, :format_date => 'format_date')
    assert_kind_of(HtmlGrid::Span, @list.registration_date(@model, @session))
  end
  def test_resultview_switch
    assert_kind_of(HtmlGrid::Link, @list.resultview_switch(@model, @session))
  end
  def test_compose_list
    flexmock(@list, :full_colspan => 2)
    model = [@model]
    flexmock(model, :overflow? => true)
    assert_equal([@model], @list.compose_list(model))
  end
end
		end
	end
end

class TestAtcHeader <Minitest::Test
  include FlexMock::TestCase
  def setup
    lookandfeel = flexmock('lookandfeel', 
                           :lookup     => 'lookup',
                           :attributes => {},
                           :language   => 'language',
                           :disabled?  => nil,
                           :_event_url => '_event_url'
                          )
    atc_class   = flexmock('atc_class', 
                           :has_ddd?    => nil,
                           :parent_code => nil
                          )
    @state      = flexmock('state')
    @app        = flexmock('app', :atc_class => atc_class)
    @session    = flexmock('session', 
                           :allowed?    => nil,
                           :lookandfeel => lookandfeel,
                           :app         => @app,
                           :state       => @state,
                           :persistent_user_input => 'code'
                          )
    @model      = flexmock('model', 
                           :overflow?     => true,
                           :code          => 'code',
                           :description   => 'description',
                           :package_count => 'package_count',
                           :has_ddd?      => nil,
                           :parent_code   => nil
                          )
  end
  def test_init
    flexmock(@session, :cookie_set_or_get => 'atc')
    @header     = ODDB::View::Drugs::AtcHeader.new(@model, @session)
    assert_equal({}, @header.init)
  end
  def test_pages
    flexmock(@session, 
             :cookie_set_or_get => 'pages',
             :event             => 'event'
            )
    flexmock(@state, 
             :pages => ['page', 'page'],
             :page  => 'page'
            )
    @header     = ODDB::View::Drugs::AtcHeader.new(@model, @session)
    assert_kind_of(ODDB::View::Pager, @header.pages(@model, @session))
  end
end

