#!/usr/bin/env ruby
# ODDB::State::TestPageFacade -- oddb.org -- 23.06.2011 -- mhatakeyama@ywesee.com
# ODDB::State::TestPageFacade -- oddb.org -- 01.06.2004 -- mhuggler@ywesee.com

$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/page_facade'

module ODDB 
	module State
		class TestPageFacade < Test::Unit::TestCase
      include FlexMock::TestCase
			def setup
				@page = State::PageFacade.new(7)
        @page.model = flexmock('model', :missing => 'missing')
			end
			def test_next
				result = @page.next
				assert_instance_of(State::PageFacade, result)
				assert_equal(8, result.to_i)
				assert_equal("9", result.to_s)
			end
			def test_previous
				result = @page.previous
				assert_instance_of(State::PageFacade, result)
				assert_equal(6, result.to_i)
				assert_equal("7", result.to_s)
			end
			def test_to_i
				assert_equal(7, @page.to_i)
			end
			def test_to_s
				assert_equal("8", @page.to_s) 
			end
      def test_method_missing
        assert_equal('missing', @page.missing)
      end
      def test_respond_to
        assert_equal(false, @page.respond_to?('method_name'))
      end
		end

    class TestOffsetPageFacade < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @facade  = ODDB::State::OffsetPageFacade.new(1)
        @facade.offset = 10
        @facade.size   = 2
      end
      def test_content
        assert_equal("11 - 12", @facade.content)
      end
    end

    class StubSuper 
      def init
        'super'
      end
    end
    class StubOffsetPaging < StubSuper
      include ODDB::State::OffsetPaging
      include FlexMock::TestCase
      def initialize
        @session = flexmock('session', :user_input => 0)
      end
      def load_model
        flexmock('model', 
                 :size => 1,
                 :[]   => []
                )
      end
    end

    class TestOffsetPaging < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @paging = ODDB::State::StubOffsetPaging.new
      end
      def test_init
        assert_equal(1, @paging.init)
      end
      def test_page
        @paging.init
        assert_equal([], @paging.page)
      end
      def test_filter
        @paging.init
        assert_equal([], @paging.filter('model'))
      end
    end
	end
end
