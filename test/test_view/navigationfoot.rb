#!/usr/bin/env ruby
# View::TestNavigationFoot -- oddb -- 20.11.2002 -- hwyss@ywesee.com 

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'view/navigationfoot.rb'
require 'custom/lookandfeelbase'
require 'util/validator'
#require 'stub/oddbapp'
#require 'stub/session'
require 'sbsm/state'
require 'stub/cgi'

module ODDB
	class GalenicGroup
		def GalenicGroup.reset_oid
			@oid=0
		end
	end
	module View
		class StubFooState < SBSM::State
			DIRECT_EVENT = :foo
		end
		class StubBarState < SBSM::State
			DIRECT_EVENT = :bar
		end
		class StubBazState < SBSM::State
			DIRECT_EVENT = :baz	
		end

		class TestNavigationFoot < Test::Unit::TestCase
			class StubLookandfeel < LookandfeelBase
				DICTIONARIES = {
					"de"	=>	{
						:foo								=>	"Foo",
					:bar								=>	"Bar",
					:baz								=>	"Baz",
					:date_format				=> "%d.%m.%Y",
					:navigation_divider => "&nbsp;|&nbsp;",
				}
			}
			def direct_event
				:foo
			end
			def event_url(event)
				"/de/gcc/#{event}"
			end
			def navigation
				[StubFooState, StubBarState, StubBazState]
			end
		end
			class StubSession
				attr_accessor :lookandfeel, :app, :flavor, :language
				def default_language
					"de"
				end
			end
			class StubApp
				attr_accessor :last_update
			end

			def setup
				GalenicGroup.reset_oid
				@app = StubApp.new
				@app.last_update = Time.now
				@session = StubSession.new
				@session.flavor = 'gcc'
				@session.language = 'de'
				@session.app = @app
				@session.lookandfeel = StubLookandfeel.new(@session)
				@view = View::NavigationFoot.new(nil, @session)
			end
			def test_to_html
				result = ''
				assert_nothing_raised {
					result << @view.to_html(CGI.new)
				}
				expected = [
					'<TABLE cellspacing="0" class="navigation-foot" valign="bottom">',
					'<TD><A name="foo" class="navigation">Foo</A></TD>',
					'<TD>&nbsp;|&nbsp;</TD>',
					'<TD><A name="bar" href="/de/gcc/bar" class="navigation">Bar</A></TD>',
					'<TD><A name="baz" href="/de/gcc/baz" class="navigation">Baz</A></TD>',
				]
				expected.each { |line|
					assert(result.index(line), "expected #{line} in \n#{result}")
				}
			end
		end
	end
end
