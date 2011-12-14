#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Companies::TestCompanyList -- oddb.org -- 28.06.2011 -- mhatakeyama@ywesee.com
# ODDB::State::Companies::TestCompanyList -- oddb.org -- 13.10.2003 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'define_empty_class'
require 'state/companies/companylist'

module ODDB
	module State
		module Companies
class TestCompanyList < State::Companies::CompanyList
	attr_accessor :filter
	attr_reader :sent_model
	def init
		super
		@sent_model = @filter.call(@model)
	end
end

class TestCompanyListState < Test::Unit::TestCase
  include FlexMock::TestCase
	class StubSession
		attr_accessor :user, :user_input
		def app
			@app ||= StubApp.new
		end
		def user_input(*keys)
			if(keys.size > 1)
				res = {}
				keys.each { |key|
					res.store(key, user_input(key))
				}
				res
			else
				key = keys.first
				(@user_input ||= {
					:pointer	=>	StubPointer.new
				})[key]
			end
		end
	end
	class StubApp
		attr_accessor :companies
		def initialize
			@companies ||= {}
		end
	end
	class StubPointer; end
	class StubCompany
		attr_accessor :name
    alias :to_s :name
	end

	def setup
		@session = StubSession.new
		@company1 = StubCompany.new 
		@company2 = StubCompany.new 
		@company3 = StubCompany.new 
		@company4 = StubCompany.new 
		@company5 = StubCompany.new 
		@company1.name = 'Ywesee'
		@company2.name = 'àlacarte'
		@company3.name = 'Ött'
		@company4.name = '3m'
		@company5.name = 'Ütt'
		@session.app.companies = {
			@company1.name	=>	@company1,
			@company2.name	=>	@company2,
			@company3.name	=>	@company3,
			@company4.name	=>	@company4,
			@company5.name	=>	@company5,
		}
		@session.user = State::Companies::RootUser.new
	end
	def test_intervals
		company1 = StubCompany.new 
		company2 = StubCompany.new 
		company3 = StubCompany.new 
		company1.name = 'aaa'
		company2.name = 'mmm'
		company3.name = 'uuu'

    @company = [company1, company2, company3, @company4]
		@state = State::Companies::CompanyList.new(@session, @company)
		expected = ['a-d', 'm-p', 'u-z', '|unknown']
		assert_equal(expected, @state.intervals)
	end
	def test_default_interval
    @company = []
		@state = State::Companies::CompanyList.new(@session, @company)
		assert_equal('a-d', @state.default_interval)
	end
	def test_user_input
		@session.user_input = { :range	=>	'u-z' } 
    @company = [@company1, @company2, @company3, @company4, @company5]
    flexmock(@session) do |sta|
      sta.should_receive(:event)
      sta.should_receive(:allowed?).and_return(true)
    end
		@state = State::Companies::CompanyList.new(@session, @company)

		@session.app.companies = {
			@company1.name	=>	@company1,
			@company2.name	=>	@company2,
			@company3.name	=>	@company3,
			@company4.name	=>	@company4,
			@company5.name	=>	@company5,
      "a" => @company5,
      "b" => @company5,
      "c" => @company5,
      "d" => @company5,
      "e" => @company5,
      "f" => @company5,
      "g" => @company5,
      "h" => @company5,
      "i" => @company5,
      "j" => @company5,
      "k" => @company5,
      "l" => @company5,
      "m" => @company5,
      "n" => @company5,
      "o" => @company5,
      "p" => @company5,
      "q" => @company5,
      "r" => @company5,
      "s" => @company5,
      "t" => @company5,
      "u" => @company5,
      "v" => @company5,
      "w" => @company5,
      "x" => @company5,
      "y" => @company5,
      "z" => @company5,
		}
    @state.init
    #expected = ODDB::State::Companies::CompanyList::RANGE_PATTERNS["u-z"]
    expected = 'u-zÜÚÛÙŲǗǓǙǛŨŬŮǕṼẂŴẀẄẆẌẊŸẎỸỲŶÝȲŽŹẐŻüúûùųǘǔǚǜũŭůǖṽẃŵẁẅẇẍẋÿẏỹỳŷýȳžźẑż'
		assert_equal( expected, @state.range )
	end
end

class TestCompanyResult < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @session = flexmock('session', 
                        :lookandfeel => @lnf,
                        :allowed? => nil
                       )
    @model   = flexmock('model', :size => 1)
    @state   = ODDB::State::Companies::CompanyResult.new(@session, @model)
  end
  def test_init
    assert_nil(@state.init)
  end
end

class TestCompanyList2 < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    company  = flexmock('company', :listed? => nil)
    @app     = flexmock('app', :companies => {'key' => company})
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    user     = flexmock('user', :model => 'model')
    @session = flexmock('session', 
                        :app => @app,
                        :lookandfeel => @lnf,
                        :event    => 'event',
                        :allowed? => nil,
                        :user     => user
                       )
    @model   = flexmock('model')
    @list    = ODDB::State::Companies::CompanyList.new(@session, @model)
  end
  def test_init
    assert_nil(@list.init)
  end
  def test_direct_event
    assert_equal(:companylist, @list.direct_event)
  end
end
		end
	end
end
