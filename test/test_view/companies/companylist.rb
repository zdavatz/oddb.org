#!/usr/bin/env ruby
# ODDB::View::Companies::TestCompanyList -- oddb.org -- 11.04.2011 -- mhatakeyama@ywesee.com
# ODDB::View::Companies::TestCompanyList -- oddb.org -- 30.07.2003 -- hwyss@ywesee.com 

$: << File.expand_path('../..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'view/companies/companylist'
require 'flexmock'

module ODDB
	module View
		module Companies
module CompanyList
	attr_reader :model
	public :sort_model
end

class TestCompanyList < Test::Unit::TestCase
  include FlexMock::TestCase
	class StubModel
		attr_reader :name
		def initialize(name)
			@name = name
		end
		def method_missing(*args)
			"foo"
		end
	end
	class StubSession
		attr_accessor :event
		def app
			self
		end
		def attributes(*args)
			{}
		end
		def lookandfeel
			self
		end
		def lookup(*args)
			"foo"
		end
		def navigation
			[]
		end
		def enabled?(*args)
			true
		end
		def event_url(*args)
			"bar"
		end
		def resource_localized(*args)
			true
		end
		def state
			self
		end
		def id
			12345
		end
	end

	def setup
		@session = StubSession.new
	end
	def test_no_double_sort
		comp1 = StubModel.new("foo")
		comp2 = StubModel.new("bar")
		comp3 = StubModel.new("fru")
		orig = [comp1, comp2, comp3]
		@session.event = :sort
    flexstub(@session) do |s|
      s.should_receive(:_event_url)
    end
		list = View::Companies::UnknownCompanyList.new(orig, @session)
		assert_equal(orig, list.model)
	end
end

class TestEmptyResultForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def test_title_none_found
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :_event_url => '_event_url',
                        :disabled?  => nil,
                        :base_url   => 'base_url'
                       ) 
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :zone        => 'zone',
                        :persistent_user_input => 'persistent_user_input'
                       )
    @model   = flexmock('model')
    @form    = ODDB::View::Companies::EmptyResultForm.new(@model, @session)
    assert_equal('lookup', @form.title_none_found(@model, @session))
  end
end

class TestRootEmptyResultForm < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :attributes => {},
                        :lookup     => 'lookup',
                        :_event_url => '_event_url',
                        :disabled?  => nil,
                        :base_url   => 'base_url'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :zone        => 'zone',
                        :persistent_user_input => 'persistent_user_input'
                       )
    @model   = flexmock('model')
    @form    = ODDB::View::Companies::RootEmptyResultForm.new(@model, @session)
  end
  def test_new_company
    assert_kind_of(HtmlGrid::Button, @form.new_company(@model, @session))
  end
end

=begin
class TestRootCompaniesComposite < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', 
                        :lookup     => 'lookup',
                        :attributes => {},
                        :event_url  => 'event_url',
                        :_event_url => '_event_url',
                        :disabled?  => nil
                       )
    state    = flexmock('state', 
                        :intervals => ['interval'],
                        :interval  => 'interval'
                       )
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :zone        => 'zone',
                        :event       => 'event',
                        :state       => state
                       )
    @model   = flexmock('model', :name => 'name')
    @form    = ODDB::View::Companies::RootCompaniesComposite.new([@model], @session)
  end
  def test_company_list
  end
end
=end

		end
	end
end
