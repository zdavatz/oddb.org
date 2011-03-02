#!/usr/bin/env ruby
# State::Companies::TestMergeCompanies -- oddb -- 13.10.2003 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/companies/mergecompanies'
require 'model/registration'

=begin
module ODDB
  module State
    module View
      class Companies; end
    end
  end
end
=end
module ODDB
	module State
		module Companies
class TestMergeCompaniesState < Test::Unit::TestCase
	class StubSession
		attr_accessor :user_input
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
		attr_reader :merge_called
		def initialize
			@merge_called = false
			@companies ||= {}
		end
		def company_by_name(name)
			@companies.each_value { |company|
				if company.name == name
					return company
				end
			}		
			nil
		end
		def merge_companies(source, target)
			@merge_called = true
		end
	end
	class StubPointer; end
	class StubCompany
		attr_accessor :name, :registrations
		def initialize
			@registrations = []
		end
		def add_registration(registration)
			@registrations.push(registration).last
		end
		def pointer
		end
	end

	def setup
		@session = StubSession.new
		@company = StubCompany.new 
		@company2 = StubCompany.new
		@company.name = 'ywesee'
		@company2.name = 'ehz'
		@session.app.companies = {
			'2'	=>	@company,
			'1'	=>	@company2,
		}
		@state = State::Companies::MergeCompanies.new(@session, @company)
		@reg = Registration.new(10)
		@reg2 = Registration.new(11)
		@company.add_registration(@reg)
		@company.add_registration(@reg2)
	end	
	def test_no_target
		newstate = @state.trigger(:merge)
		assert_equal(false, @session.app.merge_called)
		assert_equal(@state, newstate)
		assert_equal(true, @state.errors.values.any?{|err|
			err.message == 'e_unknown_company'
		})
	end
	def test_same_target
		company = @session.user_input = {:company_form => 'ywesee'}
		newstate = @state.trigger(:merge)
		assert_equal(false, @session.app.merge_called)
		assert_equal(@state, newstate)
		assert_equal(true, @state.errors.values.any?{|err|
			err.message == 'e_selfmerge_company'
		})
	end
	def test_target
		@session.user_input = {:company_form => 'ehz'}
		newstate = @state.trigger(:merge)
		assert_equal(true, @session.app.merge_called)
		assert_equal(State::Companies::Company, newstate.class)
	end
end
		end
	end
end
