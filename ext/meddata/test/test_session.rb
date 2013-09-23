#!/usr/bin/env ruby
# ODDB::MedData::TestSession -- 14.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('../..', File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'meddata/src/session'

module ODDB
  module MedData
    class StubSession < Session
      def get(arg)
        raise Timeout::Error.new('timeout error')
      end
    end
  end
end

module ODDB
  module MedData
    class TestSession <Minitest::Test
      include FlexMock::TestCase
      def setup
        @response = flexmock('response') do |r|
          r.should_receive(:[]).with('set-cookie').and_return('cookie_header')
          r.should_receive(:body).and_return('body')
        end
        @http = flexmock('http', :get => @response) 
        flexmock(Net::HTTP, :new => @http)
        @http_server = flexmock('http_server')
        ODDB::MedData::Session::HTTP_PATHS.store  :search_type_test, 'http_path'
        ODDB::MedData::Session::FORM_KEYS.store   :search_type_test, [ [:name, 'txtSearchName'] ]
        ODDB::MedData::Session::DETAIL_KEYS.store :search_type_test, 'detail_key'

        @session = ODDB::MedData::Session.new(:search_type_test, @http_server)
      end
      def test_initialize__timeout_error
        @response = flexmock('response') do |r|
          r.should_receive(:[]).with('set-cookie').and_return('cookie_header')
          r.should_receive(:body).and_return('body')
        end
        @http = flexmock('http', :get => @response) 
        flexmock(Net::HTTP, :new => @http)
        @http_server = flexmock('http_server')
        ODDB::MedData::Session::HTTP_PATHS.store  :search_type_test, 'http_path'
        ODDB::MedData::Session::FORM_KEYS.store   :search_type_test, [ [:name, 'txtSearchName'] ]
        ODDB::MedData::Session::DETAIL_KEYS.store :search_type_test, 'detail_key'

        assert_raise(Timeout::Error) do 
          ODDB::MedData::StubSession.new(:search_type_test, @http_server)
        end
      end
      def test_handle_resp
        assert_nil(@session.handle_resp!(@response))
      end
      def test_post_hash
        criteria = {}
        expected = [
          ["__EVENTTARGET", ""],
          ["__EVENTARGUMENT", ""],
          ["btnSearch", "Suche"],
          ["hiddenlang", "de"]
        ]
        assert_equal(expected, @session.post_hash(criteria))
      end
      def test_post_hash__ctl
        criteria = {}
        expected = [
          ["__EVENTTARGET", "detail_key:ctl:ctl00"],
          ["__EVENTARGUMENT", ""],
          ["hiddenlang", "de"]
        ]
        assert_equal(expected, @session.post_hash(criteria, 'ctl'))
      end
      def test_post_hash__viewstate
        flexmock(@response, :body => 'VIEWSTATE value="viewstate"')
        @session.handle_resp!(@response)
        criteria = {}
        expected = [
          ["__EVENTTARGET", ""],
          ["__EVENTARGUMENT", ""],
          ["btnSearch", "Suche"],
          ["__VIEWSTATE", "viewstate"],
          ["hiddenlang", "de"]
        ]
        assert_equal(expected, @session.post_hash(criteria))
      end
      def test_post_hash__eventvalidation
        flexmock(@response, :body => 'EVENTVALIDATION value="eventvalidation"')
        @session.handle_resp!(@response)
        criteria = {}
        expected = [
          ["__EVENTTARGET", ""],
          ["__EVENTARGUMENT", ""],
          ["btnSearch", "Suche"],
          ["__EVENTVALIDATION", "eventvalidation"],
          ["hiddenlang", "de"]
        ]
        assert_equal(expected, @session.post_hash(criteria))
      end
      def test_post_hash__criteria_key
        criteria = {:name => 'value'}
        expected = [
          ["__EVENTTARGET", ""],
          ["__EVENTARGUMENT", ""],
          ["btnSearch", "Suche"],
          ["txtSearchName", "value"],
          ["hiddenlang", "de"]
        ]
        assert_equal(expected, @session.post_hash(criteria))
      end
      def test_post_header
        expected = [
          ["Host", @http_server],
          ["User-Agent",
           "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_4_11; de-de) AppleWebKit/525.18 (KHTML, like Gecko) Version/3.1.2 Safari/525.22"],
          ["Accept",
           "text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1"],
          ["Accept-Language", "de-ch,en-us;q=0.7,en;q=0.3"],
          ["Accept-Charset", "UTF-8"],
          ["Keep-Alive", "300"],
          ["Connection", "keep-alive"],
          ["Content-Type", "application/x-www-form-urlencoded"],
          ["Cookie", "cookie_header"]
        ]
        assert_equal(expected, @session.post_headers)
      end
      def stderr_null
        require 'tempfile'
        $stderr = Tempfile.open('stderr')
        yield
        $stderr.close
        $stderr = STDERR
      end
      def test_get_result_list
        criteria = {}
        response = Net::HTTPFound.new(1,2,3)
        flexmock(@http, 
                 :post => response, 
                 :get  => @response
                )
        uri = flexmock('uri', :request_uri => 'request_uri')
        flexmock(URI, :parse => uri)
        stderr_null do 
          assert_equal('body', @session.get_result_list(criteria))
        end
      end
      def test_get_result_list__errno_enetunreach
        criteria = {}
        response = Net::HTTPFound.new(1,2,3)
        flexmock(@http, 
                 :post => response, 
                 :get  => @response
                )
        uri = flexmock('uri', :request_uri => 'request_uri')
        flexmock(URI, :parse => uri)
        flexmock(@response) do |r|
          r.should_receive(:body).and_raise(Errno::ENETUNREACH)
        end
        flexmock(@session, 
                 :sleep => nil,
                 :flexmock_original_behavior_for_should_receive => nil
                )
        stderr_null do 
          assert_raise(Errno::ENETUNREACH) do 
            @session.get_result_list(criteria)
          end
        end
      end
      def test_get_result_list__runtime_error
        criteria = {}
        response = Net::HTTPFound.new(1,2,3)
        flexmock(@http, 
                 :post => response, 
                 :get  => @response
                )
        uri = flexmock('uri', :request_uri => 'request_uri')
        flexmock(URI, :parse => uri)
        flexmock(@response) do |r|
          r.should_receive(:body).and_raise(RuntimeError)
        end
        flexmock(@session, 
                 :sleep => nil,
                 :flexmock_original_behavior_for_should_receive => nil
                )
        stderr_null do 
          assert_raise(RuntimeError) do 
            @session.get_result_list(criteria)
          end
        end
      end
      def stdout_null
        require 'tempfile'
        $stdout = Tempfile.open('stdout')
        yield
        $stdout.close
        $stdout = STDOUT
      end
      def test_get_result_list__internal_server_error
        criteria = {}
        response = Net::HTTPFound.new(1,2,3)
        flexmock(@http, 
                 :post => response, 
                 :get  => @response
                )
        uri = flexmock('uri', :request_uri => 'request_uri')
        flexmock(URI, :parse => uri)
        flexmock(@response) do |r|
          r.should_receive(:body).and_raise(RuntimeError, 'InternalServerError')
        end
        flexmock(@session, 
                 :sleep => nil,
                 :flexmock_original_behavior_for_should_receive => nil
                )
        stderr_null{stdout_null{
          assert_raise(RuntimeError) do 
            @session.get_result_list(criteria)
          end
        }}
        
      end
      def test_detail_html
        response = Net::HTTPFound.new(1,2,3)
        flexmock(@http, 
                 :post => response, 
                 :get  => @response
                )
        uri = flexmock('uri', :request_uri => 'request_uri')
        flexmock(URI, :parse => uri)
        stderr_null do 
          assert_equal('body', @session.detail_html(nil))
        end
      end
      def test_detail_html__errno__econnreset
        response = Net::HTTPFound.new(1,2,3)
        flexmock(@http, 
                 :post => response, 
                 :get  => @response
                )
        uri = flexmock('uri', :request_uri => 'request_uri')
        flexmock(URI, :parse => uri)
        flexmock(@response) do |r|
          r.should_receive(:body).and_raise(Errno::ECONNRESET)
        end
        flexmock(@session, 
                 :sleep => nil,
                 :flexmock_original_behavior_for_should_receive => nil
                )

        stderr_null do 
          assert_raise(Errno::ECONNRESET) do 
            @session.detail_html(nil)
          end
        end
      end

    end
  end # MedData
end # ODDB
