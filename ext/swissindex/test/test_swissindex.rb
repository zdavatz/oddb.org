#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::Swissindex::SwissindexPharma -- oddb.org -- 01.11.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../src', File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'swissindex'

module ODDB
	module Swissindex

		class TestSwissindex <Minitest::Test
      include FlexMock::TestCase
			def test_session
        ODDB::Swissindex.session do |pharma|
          assert_kind_of(ODDB::Swissindex::SwissindexPharma, pharma)
        end
			end
		end # SwissindexTest

    class TestSwissindexNonpharma <Minitest::Test
      include FlexMock::TestCase
      def setup
        @nonpharma = ODDB::Swissindex::SwissindexNonpharma.new
        @ssl  = flexmock('http', :verify_mode= => nil)
        @auth = flexmock('http', :ssl => @ssl)
        @http = flexmock('http', :auth => @auth)
      end
      def test_search_item
        nonpharma = {:item => {'key' => 'item'}}
        response = flexmock('response', :to_hash => {:nonpharma => nonpharma}) 
        wsdl = flexmock('wsdl', :document= => nil)
        client = flexmock('client') do |c|
          c.should_receive(:request).and_yield.and_return(response)
        end
        soap = flexmock('soap', :xml= => nil)
        flexmock(@nonpharma, :soap => soap)
        flexmock(Savon::Client).should_receive(:new).and_yield(wsdl, @http).and_return(client)
        pharmacode = '1234567'
        assert_equal({'key' => 'item'}, @nonpharma.search_item(pharmacode))
      end
       def test_search_item__array
        nonpharma = {:item => [{:gtin => '223'}, {:gtin => '123'}]}
        response = flexmock('response', :to_hash => {:nonpharma => nonpharma}) 
        wsdl = flexmock('wsdl', :document= => nil)
        client = flexmock('client') do |c|
          c.should_receive(:request).and_yield.and_return(response)
        end
        soap = flexmock('soap', :xml= => nil)
        flexmock(@nonpharma, :soap => soap)
        flexmock(Savon::Client).should_receive(:new).and_yield(wsdl, @http).and_return(client)
        pharmacode = '1234567'
        assert_equal({:gtin => '223'}, @nonpharma.search_item(pharmacode))
      end

      def test_search_item__nil
        response = flexmock('response', :to_hash => {:nonpharma => nil}) 
        wsdl = flexmock('wsdl', :document= => nil)
        client = flexmock('client') do |c|
          c.should_receive(:request).and_return(response)
        end
        flexmock(Savon::Client).should_receive(:new).and_yield(wsdl, @http).and_return(client)
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
        flexmock(Savon::Client).should_receive(:new).and_yield(wsdl, @http).and_return(client)
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
      def test_merge_swissindex_migel
        swissindex_item = {
          :gtin => 'ean_code',
          :dt   => 'datetime',
          :lang => 'language',
          :dscr => 'article_name',
          :addscr => 'size',
          :comp => {:name => 'companyname', :gln => 'companyean'},
          :key  => 'value'
        }
        migel_line = [
          'pharmacode',
          'article_name_migel',
          'companyname_migel',
          'ppha',
          'ppub',
          'factor',
          'pzr'
        ]
        expected = {
          :ean_code     => 'ean_code',
          :datetime     => 'datetime',
          :language     => 'language',
          :article_name => 'article_name',
          :size         => 'size',
          :companyname  => 'companyname', 
          :companyean   => 'companyean',
          :pharmacode   => 'pharmacode',
          :ppha         => 'ppha',
          :ppub         => 'ppub',
          :factor       => 'factor',
          :pzr          => 'pzr',
          :key          => 'value'
        }
        assert_equal(expected, @nonpharma.merge_swissindex_migel(swissindex_item, migel_line))
      end
      def test_search_migel_table
        # for swissindex
        return_values = {
          :gtin => 'ean_code',
          :dt   => 'datetime',
          :lang => 'language',
          :dscr => 'article_name',
          :addscr => 'size',
          :comp => {:name => 'companyname', :gln => 'companyean'}
        }
        nonpharma = {:item => return_values}
        response = flexmock('response', :to_hash => {:nonpharma => nonpharma}) 
        wsdl = flexmock('wsdl', :document= => nil)
        client = flexmock('client') do |c|
          c.should_receive(:request).and_yield.and_return(response)
        end
        soap = flexmock('soap', :xml= => nil)
        flexmock(@nonpharma, :soap => soap)
        flexmock(Savon::Client).should_receive(:new).and_yield(wsdl, @http).and_return(client)

        # for migel
        td = flexmock('td', :inner_text => '1234567')
        flexmock(Mechanize).new_instances do |agent|
          agent.should_receive(:get)
          agent.should_receive(:"page.search").and_return([td, td])
        end
        migel_code = '12.34.56.78.9'
        expected = [
          {:pharmacode=>"1234567",
            :article_name=>nil,
            :companyname=>nil,
            :ppha=>nil,
            :ppub=>nil,
            :factor=>nil,
            :pzr=>nil},
          {:pharmacode=>"1234567",
            :article_name=>nil,
            :companyname=>nil,
            :ppha=>nil,
            :ppub=>nil,
            :factor=>nil,
            :pzr=>nil}
        ]
        assert_equal(expected, @nonpharma.search_migel_table(migel_code))
      end
      def test_search_migel_table__no_swissindex_item
        # for migel
        td = flexmock('td', :inner_text => '1234567')
        flexmock(Mechanize).new_instances do |agent|
          agent.should_receive(:get)
          agent.should_receive(:"page.search").and_return([td])
        end
        migel_code = '12.34.56.78.9'
        expected = [
          {:ppub     => nil,
           :factor   => nil,
           :pzr      => nil, 
           :ppha     => nil,
           :article_name  => nil,
           :companyname   => nil,
           :pharmacode    => "1234567"},
        ]
        
        assert_equal(expected, @nonpharma.search_migel_table(migel_code))
      end
      def test_search_migel_table__error
        # for migel
        td = flexmock('td', :inner_text => '1234567')
        flexmock(Mechanize).new_instances do |agent|
          agent.should_receive(:get).and_raise(Timeout::Error)
          agent.should_receive(:"page.search").and_return([td])
        end
        migel_code = '12.34.56.78.9'
        flexmock(@nonpharma, 
                 :puts  => nil,
                 :sleep => nil
                ) 
        assert_equal([], @nonpharma.search_migel_table(migel_code))
      end
      def test_search_item_with_swissindex_migel
        # for swissindex
        return_values = {
          :gtin => 'ean_code',
          :dt   => 'datetime',
          :lang => 'language',
          :dscr => 'article_name',
          :addscr => 'size',
          :comp => {:name => 'companyname', :gln => 'companyean'}
        }
        nonpharma = {:item => return_values}
        response = flexmock('response', :to_hash => {:nonpharma => nonpharma}) 
        wsdl = flexmock('wsdl', :document= => nil)
        client = flexmock('client') do |c|
          c.should_receive(:request).and_yield.and_return(response)
        end
        soap = flexmock('soap', :xml= => nil)
        flexmock(@nonpharma, :soap => soap)
        flexmock(Savon::Client).should_receive(:new).and_yield(wsdl, @http).and_return(client)

        # for migel
        td = flexmock('td', :inner_text => '1234567')
        flexmock(Mechanize).new_instances do |agent|
          agent.should_receive(:get)
          agent.should_receive(:"page.search").and_return([td])
        end
        pharmacode = '1234567'
        expected = {
           :article_name => 'article_name',
           :language     => 'language',
           :companyname  => 'companyname',
           :companyean   => 'companyean',
           :datetime     => 'datetime',
           :ean_code     => 'ean_code',
           :size         => 'size',
           :ppub     => nil,
           :factor   => nil,
           :pzr      => nil, 
           :ppha     => nil,
           :pharmacode    => "1234567",
        }
        assert_equal(expected, @nonpharma.search_item_with_swissindex_migel(pharmacode))
      end

      def test_search_item_with_swissindex_migel__only_migel
        # for migel
        td = flexmock('td', :inner_text => '1234567')
        flexmock(Mechanize).new_instances do |agent|
          agent.should_receive(:get)
          agent.should_receive(:"page.search").and_return([td])
        end
        pharmacode = '1234567'
        expected = {
           :ppub     => nil,
           :factor   => nil,
           :pzr      => nil, 
           :ppha     => nil,
           :article_name  => nil,
           :companyname   => nil,
           :pharmacode    => "1234567",
        }
        assert_equal(expected, @nonpharma.search_item_with_swissindex_migel(pharmacode))
      end
    end # TestSwinssindexNonpharma

    class TestSwissindexPharma <Minitest::Test
      include FlexMock::TestCase
      def setup
        @pharma = ODDB::Swissindex::SwissindexPharma.new
        @ssl  = flexmock('http', :verify_mode= => nil)
        @auth = flexmock('http', :ssl => @ssl)
        @http = flexmock('http', :auth => @auth)
      end
      def test_search_item
        pharma = {:item => {'key' => 'item'}}
        response = flexmock('response', :to_hash => {:pharma => pharma}) 
        wsdl = flexmock('wsdl', :document= => nil)
        client = flexmock('client') do |c|
          c.should_receive(:request).and_yield.and_return(response)
        end
        flexmock(Savon::Client).should_receive(:new).and_yield(wsdl, @http).and_return(client)
        soap = flexmock('soap', :xml= => nil)
        flexmock(@pharma, :soap => soap)
        pharmacode = '1234567'
        assert_equal({'key' => 'item'}, @pharma.search_item(pharmacode, :get_by_gtin))
      end
      def test_search_item__array
        pharma = {:item => [{:gtin => 223}, {:gtin => 123}]}
        response = flexmock('response', :to_hash => {:pharma => pharma}) 
        wsdl = flexmock('wsdl', :document= => nil)
        client = flexmock('client') do |c|
          c.should_receive(:request).and_yield.and_return(response)
        end
        flexmock(Savon::Client).should_receive(:new).and_yield(wsdl, @http).and_return(client)
        soap = flexmock('soap', :xml= => nil)
        flexmock(@pharma, :soap => soap)
        pharmacode = '1234567'
        assert_equal({:gtin => 223}, @pharma.search_item(pharmacode, :get_by_gtin))
      end

      def test_search_item__get_by_pharmacode
        pharma = {:item => {'key' => 'item'}}
        response = flexmock('response', :to_hash => {:pharma => pharma}) 
        wsdl = flexmock('wsdl', :document= => nil)
        client = flexmock('client') do |c|
          c.should_receive(:request).and_yield.and_return(response)
        end
        flexmock(Savon::Client).should_receive(:new).and_yield(wsdl, @http).and_return(client)
        soap = flexmock('soap', :xml= => nil)
        flexmock(@pharma, :soap => soap)
        pharmacode = '1234567'
        assert_equal({'key' => 'item'}, @pharma.search_item(pharmacode, :get_by_pharmacode))
      end

      def test_search_item__nil
        response = flexmock('response', :to_hash => {:pharma => nil}) 
        wsdl = flexmock('wsdl', :document= => nil)
        client = flexmock('client') do |c|
          c.should_receive(:request).and_return(response)
        end
        flexmock(Savon::Client).should_receive(:new).and_yield(wsdl, @http).and_return(client)
        pharmacode = '1234567'
        assert_equal({}, @pharma.search_item(pharmacode))
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
        flexmock(Savon::Client).should_receive(:new).and_yield(wsdl, @http).and_return(client)
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
