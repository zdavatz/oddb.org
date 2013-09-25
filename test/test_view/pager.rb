#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::View::TestPager -- oddb.org -- 22.06.2011 -- mhatakeyama@ywesee.com
# ODDB::View::TestPager -- oddb.org -- 29.08.2003 -- ywesee@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'view/pager'
require 'stub/cgi'

module ODDB
	module View
		class Pager < HtmlGrid::List
			public :page_link
		end

		class TestPager	<Minitest::Test
      include FlexMock::TestCase
			class StubSession
				attr_accessor :page, :event, :dictionary
				def attributes(key)
					{}
				end
        def disabled?(key)
          false
        end
        def enabled?(key)
          true
        end
				def event_url(event, values)
					([
						"http://www.oddb.org/de/gcc",
						event,
					] + values.to_a.flatten ).join('/')
				end
				alias :_event_url :event_url
				def state
					self
				end
				def lookandfeel
					self
				end
				def lookup(key, *args)
					(@dictionary ||= {})[key].to_s
				end
        def user_agent
          'TEST'
        end
			end
			def setup
				@session = StubSession.new
				@session.page = 0
				@model = [0, 1, 2, 3, 4, 5]
				@view = View::Pager.new(@model, @session)
			end
			def test_page_link1
				result = @view.page_link(:to_s, 1)
				assert_instance_of(HtmlGrid::Link, result)
				assert_equal("1", result.value)
				url = /http:\/\/www.oddb.org\/de\/gcc\/result(\/state_id\/\d+)?\/page\/1/
				assert(url.match(result.attributes['href']), result.attributes['href'])
			end
			def test_page_link2
				@session.page = 1
				result = @view.page_link(:to_s, 1)
				assert_equal("1", result)
			end
			def test_to_html
				result = @view.to_html(CGI.new)
				refute_nil(result.index('<TD class="pager">0</TD>'), "Page-Number without link did not have css-class")
				assert_nil(result.index('<TD class="pager-bg">'), "The pager should not have alternate bg-classes")
			end
      def test_compose_header
        page = flexmock('page', :previous => 'previous')
        @view.instance_eval('@page = page')
        offset = [0,0]
        assert_equal([2,0], @view.compose_header(offset))
      end
		end
	end
end
