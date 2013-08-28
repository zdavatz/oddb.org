#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestSponsorHead -- oddb.org -- 29.06.2011 -- mhatakeyama@ywesee.com 
# ODDB::View::TestSponsorHead -- oddb.org -- 30.07.2003 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'stub/odba'
require 'date'
require 'test/unit'
require 'flexmock'
require 'stub/cgi'
require 'model/sponsor'
require 'view/sponsorhead'

module ODDB
  class Session
    DEFAULT_FLAVOR = 'gcc'
  end
	module View
    class StubSponsorMethods
      include ODDB::View::SponsorMethods
      def initialize(model, session)
        @modle = model
        @session = session
        @lookandfeel = session.lookandfeel
      end
    end
    class TestSponsorMethods < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @zones    = flexmock('zones',
                            :sort_by => [],
                            )
        @lnf     = flexmock('lookandfeel', 
                            :lookup     => 'lookup',
                            :enabled?   => nil,
                            :disabled?   => false,
                            :attributes => {},
                            :resource   => 'resource',
                            :zones      => @zones,
                           )
        user     = flexmock('user', :valid? => nil)
        @session = flexmock('session', 
                            :lookandfeel => @lnf,
                            :user => user,
                            :flavor => Session::DEFAULT_FLAVOR,
                            :get_cookie_input => 'get_cookie_input',
                            :sponsor => user,
                           )
        @model   = flexmock('model')
        @view    = ODDB::View::StubSponsorMethods.new(@model, @session)
      end
      def test_head
        assert_kind_of(ODDB::View::LogoHead, @view.head(@model, @session))
      end
      def test_head__sponsorlogo
        flexmock(@lnf, 
                 :resource_localized => 'resource_localized',
                 :enabled?   => true,
                 :languages  => ['language'],
                 :currencies => ['currency'],
                 :language   => 'language'
                )
        state = flexmock('state', :zone => 'zone')
        flexmock(@session, 
                 :state    => state,
                 :currency => 'currency'
                )
        # TODO: assert_kind_of(ODDB::View::SponsorHead, @view.head(@model, @session))
      end
    end
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
				def currencies
					['CHF']
				end
				def currency
					'CHF'
				end
				def enabled?(key, default=nil)
					@enabled && (key != :google_adsense)
				end
				def _event_url(url)
				end
				def format_date(date)
					date.strftime("%d.%m.%Y")
				end
				def language
					'de'
				end
				def languages
					['de']
				end
				def lookandfeel
					self
				end
				def lookup(key, name=nil)
					key.to_s.upcase
				end
				def resource_global(key, str = nil)
					[key, str].join('/')
				end
				def resource_localized(key, str = nil)
					[key, str].join('/')
				end
				def user
					self
				end
        def user_agent
          'TEST'
        end
				def state
					self
				end
				def valid?
					false
				end
				def zone
					:drugs
				end
				def zones
					[:drugs]
				end
        def flavor
          Session::DEFAULT_FLAVOR
        end
        def get_cookie_input(param)
          'get_cookie_input:_'+param.to_s
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
				def logo_filename(language)
					"sponsorlogo"
				end
				def valid?
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
				@sponsor = ODDB::Sponsor.new
				@sponsor.company = @comp
				@sponsor.logo_filenames.store(:default, 'sponsorlogo')
				@other = StubCompany.new
				@other.represents = false
				@pac = StubPackage.new
				@pac.company = @comp
        @logo_pattern = '<IMG src="sponsor/sponsorlogo" alt="sponsorlogo"><SPAN class="sponsor  right">SPONSOR_UNTIL</SPAN>'
			end
			def test_empty_model
				view = View::SponsorHead.new([], @session)
				assert_nil(@logo_pattern.match(view.to_html(CGI.new)))
			end
			def test_model_no_sponsor
				view = View::SponsorHead.new([@pac], @session)
				assert_nil(@logo_pattern.match(view.to_html(CGI.new)))
			end
			def test_model_nonmatching_sponsor
				@session.sponsor = @other
				view = View::SponsorHead.new([@pac], @session)
				assert_nil(@logo_pattern.match(view.to_html(CGI.new)))
			end
			def test_matching_sponsor_no_date
				@session.sponsor = @sponsor
				view = View::SponsorHead.new([@pac], @session)
				assert_nil(@logo_pattern.match(view.to_html(CGI.new)))
			end
			def test_sponsor_time_over
				@session.sponsor = @sponsor
				@sponsor.sponsor_until = Date.new(2002,12,31)
				view = View::SponsorHead.new([@pac], @session)
				assert_nil(@logo_pattern.match(view.to_html(CGI.new)))
			end
			def test_display_sponsor
				@session.sponsor = @sponsor
				@sponsor.sponsor_until = Date.today
				view = View::SponsorHead.new([@pac], @session)
				html = view.to_html(CGI.new)
        assert(html.index(@logo_pattern), 'must find logo_pattern in html output') 
			end
		end
	end
end
