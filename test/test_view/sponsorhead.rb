#!/usr/bin/env ruby
# TestSponsorHead -- oddb -- 30.07.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'date'
require 'test/unit'
require 'stub/cgi'
require 'view/sponsorhead'

class TestSponsorHead < Test::Unit::TestCase
	class StubHeadSession
		attr_writer :enabled, :attributes
		attr_accessor :sponsor
		def initialize
			@attributes = {}
			@enabled = true
		end
		def app
			self
		end
		def attributes(key)
			@attributes
		end
		def enabled?(key, default=nil)
			@enabled
		end
		def format_date(date)
			date.strftime("%d.%m.%Y")
		end
		def lookandfeel
			self
		end
		def resource_global(key, str = nil)
			[key, str].join('/')
		end
		def resource_localized(key, str = nil)
			[key, str].join('/')
		end
		def lookup(key, name=nil)
			key.to_s.upcase
		end
	end
	class StubCompany
		attr_accessor :represents, :sponsor_until
		def company
			self
		end
		def name
			"sponsorlogo"
		end
		def logo_filename
			"sponsorlogo"
		end
		def represents?(arg)
			@represents
		end
	end
	class StubPackage
		attr_accessor :company
		def packages
			[self]
		end
	end

	def setup
		@session = StubHeadSession.new
		@comp = StubCompany.new
		@comp.represents = true
		@other = StubCompany.new
		@other.represents = false
		@pac = StubPackage.new
		@pac.company = @comp
	end
	def test_empty_model
		view = ODDB::SponsorHead.new([], @session)
		expected = '<TABLE cellspacing="0" class="composite"><TR><TD class="logo"><IMG class="logo" src="logo/" alt="LOGO"></TD><TD class="logo-r">&nbsp;</TD></TR></TABLE>'
		assert_equal(expected, view.to_html(CGI.new))
	end
	def test_model_no_sponsor
		view = ODDB::SponsorHead.new([@pac], @session)
		expected = '<TABLE cellspacing="0" class="composite"><TR><TD class="logo"><IMG class="logo" src="logo/" alt="LOGO"></TD><TD class="logo-r">&nbsp;</TD></TR></TABLE>'
		assert_equal(expected, view.to_html(CGI.new))

	end
	def test_model_nonmatching_sponsor
		@session.sponsor = @other
		view = ODDB::SponsorHead.new([@pac], @session)
		expected = '<TABLE cellspacing="0" class="composite"><TR><TD class="logo"><IMG class="logo" src="logo/" alt="LOGO"></TD><TD class="logo-r">&nbsp;</TD></TR></TABLE>'
		assert_equal(expected, view.to_html(CGI.new))
	end
	def test_matching_sponsor_no_date
		@session.sponsor = @comp
		view = ODDB::SponsorHead.new([@pac], @session)
		expected = '<TABLE cellspacing="0" class="composite"><TR><TD class="logo"><IMG class="logo" src="logo/" alt="LOGO"></TD><TD class="logo-r">&nbsp;</TD></TR></TABLE>'
		assert_equal(expected, view.to_html(CGI.new))
	end
	def test_sponsor_time_over
		@session.sponsor = @comp
		@comp.sponsor_until = Date.new(2002,12,31)
		view = ODDB::SponsorHead.new([@pac], @session)
		expected = '<TABLE cellspacing="0" class="composite"><TR><TD class="logo"><IMG class="logo" src="logo/" alt="LOGO"></TD><TD class="logo-r">&nbsp;</TD></TR></TABLE>'
		assert_equal(expected, view.to_html(CGI.new))
	end
	def test_display_sponsor
		@session.sponsor = @comp
		@comp.sponsor_until = Date.today
		view = ODDB::SponsorHead.new([@pac], @session)
		expected = '<TABLE cellspacing="0" class="composite"><TR><TD class="logo"><IMG class="logo" src="logo/" alt="LOGO"></TD><TD class="logo-r"><IMG src="sponsor/sponsorlogo" alt="sponsorlogo">SPONSOR_UNTIL</TD></TR></TABLE>'
		assert_equal(expected, view.to_html(CGI.new))
	end
end
