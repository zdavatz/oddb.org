#!/usr/bin/env ruby
# State::Companies::TestCompanyList -- oddb -- 13.10.2003 -- maege@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
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
		@state = State::Companies::CompanyList.new(@session, @company)
		expected = ['a-d', 'm-p', 'u-z', 'unknown']
		assert_equal(expected, @state.intervals)
	end
	def test_default_interval
		@state = State::Companies::CompanyList.new(@session, @company)
		assert_equal('a-d', @state.default_interval)
	end
	def test_user_input
		@session.user_input = { :range	=>	'u-z' } 
		@state = State::Companies::CompanyList.new(@session, @company)
		assert_equal( 'u-züÜúÚùÙûÛ', @state.range )
	end
	def test_sent_model
		@session.user_input = { :range	=>	'u-z' } 
		@state = State::Companies::TestCompanyList.new(@session, @company)
		expected = [ @company1, @company5 ]
		assert_equal( expected, @state.sent_model )
	end
end
		end
	end
end
