#!/usr/bin/env ruby
# TestRecentRegs -- oddb -- 03.09.2003 -- mhuggler@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'state/drugs/recentregs'
require 'model/registration'


module ODDB
	module State
		module Drugs
class RecentRegs
	attr_accessor :session, :model
end
		end
	end
end

class TestRecentRegs < Test::Unit::TestCase
	class StubPackage
		attr_reader :ikscd
		attr_accessor :generic_type
		def initialize(ikscd)
			@ikscd = sprintf('%03d', ikscd.to_i)
		end
		def name_base
			''
		end
		def dose
			2
		end
		def galenic_form
			''
		end
		def generic_type
			''
		end
		def comparable_size
			2
		end
	end
	class StubSequence
		attr_accessor :packages
		def initialize(seqnr)
			@seqnr = sprintf('%02d', seqnr.to_i)
			@packages = {}
		end
	end
	class StubRegistration
		attr_reader :iksnr
		attr_accessor :registration_date
		attr_accessor :sequences
		def initialize(iksnr, registration_date)
			@iksnr = iksnr
			@registration_date = registration_date
			@sequences = {}
		end
		def each_package(&block)
			@sequences.each_value { |seq|
				seq.packages.each_value(&block)
			}
		end
	end
	class StubApp
		attr_accessor :registrations, :log_groups
		def log_group(key)
			self
		end
		def newest_date
			Date.today
		end
	end	
	class StubSession
		attr_accessor :app
		def valid_values(arg)
			[]
		end
		def language
			:to_s
		end
	end
	def setup
		@app = StubApp.new
		@session = StubSession.new
		@session.app = @app
		@date = Date.new(Date.today.year, Date.today.month)
		@package1 = StubPackage.new(30)
		@package2 = StubPackage.new(31)
		@package3 = StubPackage.new(32)
		@package4 = StubPackage.new(33)
		@package1.generic_type = :a
		@package2.generic_type = :b
		@package3.generic_type = :c
		@package4.generic_type = :d
		@registrations = {
			1 => StubRegistration.new(1, Date.today),
			2 => StubRegistration.new(2, (Date.today << 1)),
			3 => StubRegistration.new(3, (Date.today << 2)),
			4 => StubRegistration.new(4, Date.today),
		}
		@registrations[1].sequences = {
			10	=>	StubSequence.new(10),
		}
		@registrations[4].sequences = {
			11	=>	StubSequence.new(11),
		}
		@registrations[1].sequences[10].packages = {
			30	=>	@package1,
			31	=>	@package2,
		}
		@registrations[4].sequences[11].packages = {
			32	=>	@package3,
			33	=>	@package4,
		}
		@app.registrations = @registrations
		@state = ODDB::State::Drugs::RecentRegs.new(@session, nil)
	end
	def test_month_range
		date = Date.new(1983,8,1)
		month = @state.month_range(date)
		assert_equal(true, month.include?(Date.new(1983,8,26)))
		assert_equal(false, month.include?(Date.new(1983,7,31)))
		assert_equal(false, month.include?(Date.new(1983,9,1)))
		date2 = Date.new(1983,8,17)
		month2 = @state.month_range(date2)
		assert_equal(month, month2)
	end
	def test_regs_by_month
		month = @state.month_range(Date.today)
		regs = @state.regs_by_month(month)
		expected = [
			@registrations[1], 
			@registrations[4], 
		]
		assert_equal(expected, regs)
	end
	def test_pack_month
		regs = [
			@registrations[1],
			@registrations[4],
		]
		pack = ODDB::State::Drugs::RecentRegs::PackageMonth.new(Date.today, regs, @session)
		expected = [
			@package1, 
			@package2, 
			@package4, 
			@package3, 
		]
		assert_equal(expected, pack.packages)
		pack = @state.create_package_month(Date.today)
		assert_instance_of( ODDB::State::Drugs::RecentRegs::PackageMonth, pack)
		assert_equal(expected, pack.packages)
	end
end
