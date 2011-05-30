#!/usr/bin/env ruby
# ODDB::Swissindex::SwissindexPharma -- oddb.org -- 30.05.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'swissindex'

module ODDB
	module Swissindex

		class TestSwissindex < Test::Unit::TestCase
      include FlexMock::TestCase
			def test_session
        ODDB::Swissindex.session do |pharma|
          assert_kind_of(ODDB::Swissindex::SwissindexPharma, pharma)
        end
			end
		end # SwissindexTest

    class TestSwissindexNonpharma < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @nonpharma = ODDB::Swissindex::SwissindexNonpharma.new
      end
      def test_search_item
        nonpharma = {:item => 'item'}
        response = flexmock('response', :to_hash => {:nonpharma => nonpharma}) 
        wsdl = flexmock('wsdl', :document= => nil)
        client = flexmock('client') do |c|
          c.should_receive(:request).and_yield.and_return(response)
        end
        soap = flexmock('soap', :xml= => nil)
        flexmock(@nonpharma, :soap => soap)
        flexmock(Savon::Client).should_receive(:new).and_yield(wsdl, 'http').and_return(client)
        pharmacode = '1234567'
        assert_equal('item', @nonpharma.search_item(pharmacode))
      end
      def test_search_item__nil
        response = flexmock('response', :to_hash => {:nonpharma => nil}) 
        wsdl = flexmock('wsdl', :document= => nil)
        client = flexmock('client') do |c|
          c.should_receive(:request).and_return(response)
        end
        flexmock(Savon::Client).should_receive(:new).and_yield(wsdl, 'http').and_return(client)
        pharmacode = '1234567'
        assert_nil(@nonpharma.search_item(pharmacode))
      end
      def stdout_null
        require 'tempfile'
        $stdout = Tempfile.open('stderr')
        yield
        $stdout.close
        $stdout = STDERR
      end
      def test_search_item__error
        response = flexmock('response', :to_hash => {:nonpharma => nil}) 
        wsdl = flexmock('wsdl', :document= => nil)
        client = flexmock('client') do |c|
          c.should_receive(:request).and_raise(StandardError)
        end
        flexmock(Savon::Client).should_receive(:new).and_yield(wsdl, 'http').and_return(client)
        flexmock(@nonpharma, 
                 :sleep => nil,
                 :server => 'server'
                )
        pharmacode = '1234567'
        stdout_null do 
          assert_nil(@nonpharma.search_item(pharmacode))
        end
      end
      def test_search_migel
        td = flexmock('td', :inner_text => '1234567')
        flexmock(Mechanize).new_instances do |agent|
          agent.should_receive(:get)
          agent.should_receive(:"page.search").and_return([td])
        end
        pharmacode = '1234567'
        assert_equal(['1234567'], @nonpharma.search_migel(pharmacode))
      end
      def test_search_migel__error
        flexmock(Mechanize).new_instances do |agent|
          agent.should_receive(:get).and_raise(StandardError)
        end
        flexmock(@nonpharma, :sleep => nil)
        pharmacode = '1234567'
        stdout_null do 
          assert_equal([], @nonpharma.search_migel(pharmacode))
        end
      end
      def test_search_migel_position_number
        td = flexmock('td', :inner_text => 'pos_num')
        flexmock(Mechanize).new_instances do |agent|
          agent.should_receive(:get)
          agent.should_receive(:"page.search").and_return([0,1,2,3,4,5,td])
        end
        pharmacode = '1234567'
        assert_equal('pos_num', @nonpharma.search_migel_position_number(pharmacode))
      end
      def test_search_migel_position_number__error
        flexmock(Mechanize).new_instances do |agent|
          agent.should_receive(:get).and_raise(StandardError)
        end
        flexmock(@nonpharma, :sleep => nil)
        pharmacode = '1234567'
        stdout_null do
          assert_nil(@nonpharma.search_migel_position_number(pharmacode))
        end
      end
    end # TestSwinssindexNonpharma

    class TestSwissindexPharma < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @pharma = ODDB::Swissindex::SwissindexPharma.new
      end
      def test_search_item
        pharma = {:item => 'item'}
        response = flexmock('response', :to_hash => {:pharma => pharma}) 
        wsdl = flexmock('wsdl', :document= => nil)
        client = flexmock('client') do |c|
          c.should_receive(:request).and_yield.and_return(response)
        end
        flexmock(Savon::Client).should_receive(:new).and_yield(wsdl, 'http').and_return(client)
        soap = flexmock('soap', :xml= => nil)
        flexmock(@pharma, :soap => soap)
        pharmacode = '1234567'
        assert_equal('item', @pharma.search_item(pharmacode))
      end
      def test_search_item__nil
        response = flexmock('response', :to_hash => {:pharma => nil}) 
        wsdl = flexmock('wsdl', :document= => nil)
        client = flexmock('client') do |c|
          c.should_receive(:request).and_return(response)
        end
        flexmock(Savon::Client).should_receive(:new).and_yield(wsdl, 'http').and_return(client)
        pharmacode = '1234567'
        assert_nil(@pharma.search_item(pharmacode))
      end
      def stdout_null
        require 'tempfile'
        $stdout = Tempfile.open('stderr')
        yield
        $stdout.close
        $stdout = STDERR
      end
      def test_search_item__error
        wsdl = flexmock('wsdl', :document= => nil)
        client = flexmock('client') do |c|
          c.should_receive(:request).and_raise(StandardError)
        end
        flexmock(Savon::Client).should_receive(:new).and_yield(wsdl, 'http').and_return(client)
        flexmock(@pharma, 
                 :sleep => nil,
                 :server => 'server'
                )
        pharmacode = '1234567'
        stdout_null do 
          assert_nil(@pharma.search_item(pharmacode))
        end
      end

    end
	end # Swissindex

end # ODDB
