#!/usr/bin/env ruby
# ODDB::TestHttpSession -- oddb.org -- 13.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'util/http'

module ODDB
  class StubHttpFile
    include HttpFile
  end
end

module ODDB
  class TestHttpFile < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @file = ODDB::StubHttpFile.new
    end
    def test_http_body
      response = flexmock('response') do |r|
        r.should_receive(:is_a?).with(Net::HTTPOK).and_return(true)
        r.should_receive(:body).and_return('body')
      end
      session = flexmock('session', :get => response)
      assert_equal('body', @file.http_body('server', 'source', session))
    end
    def test_http_file
      response = flexmock('response') do |r|
        r.should_receive(:is_a?).with(Net::HTTPOK).and_return(true)
        r.should_receive(:body).and_return('body')
      end
      session = flexmock('session', :get => response)
      flexmock(FileUtils, :mkdir_p => nil)
      file = []
      flexmock(File) do |f|
        f.should_receive(:open).and_yield(file)
      end
      assert(@file.http_file('server', 'source', 'target', session))
      assert_equal(['body'], file)
    end
  end

  class HttpSession < SimpleDelegator
    class TestResponseWrapper < Test::Unit::TestCase
      include FlexMock::TestCase
      def setup
        @response = flexmock('response')
        @wrapper  = ODDB::HttpSession::ResponseWrapper.new(@response)
      end
      def test_charset
        flexmock(@response) do |r|
          r.should_receive(:[]).with('Content-Type').and_return('charset=utf-8;')
        end
        assert_equal('utf-8', @wrapper.charset)
      end
      def test_body
        flexmock(@response) do |r|
          r.should_receive(:[]).with('Content-Type').and_return('charset=utf-8;')
          r.should_receive(:body).and_return('body')
        end
        assert_equal('body', @wrapper.body)
      end
      def test_body__charset_nil
        flexmock(@response) do |r|
          r.should_receive(:[]).with('Content-Type').and_return('charset=ascii')
          r.should_receive(:body).and_return('body')
        end
        assert_equal('body', @wrapper.body)
      end
      def test_body__charset_nil_error
        flexmock(@response) do |r|
          r.should_receive(:[]).with('Content-Type').and_return('charset=ascii')
          r.should_receive(:body).and_return('body')
        end
        flexmock(Iconv).new_instances do |i|
          i.should_receive(:iconv).and_raise(StandardError)
        end
        assert_equal('body', @wrapper.body)
      end
    end
  end # HttpSession

  class TestHttpSession < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @http        = flexmock('http')
      flexmock(Net::HTTP, :new => @http)
      @http_server = flexmock('http_server')
      @session     = ODDB::HttpSession.new(@http_server)
    end
    def test_get_headers
      expected = [
        ["Host", @http_server],
        ["User-Agent",
        "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_4_11; de-de) AppleWebKit/525.18 (KHTML, like Gecko) Version/3.1.2 Safari/525.22"],
        ["Accept",
        "text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,video/x-mng,image/png,image/jpeg,image/gif;q=0.2,*/*;q=0.1"],
        ["Accept-Language", "de-ch,en-us;q=0.7,en;q=0.3"],
        ["Accept-Charset", "UTF-8"],
        ["Keep-Alive", "300"],
        ["Connection", "keep-alive"]
      ]
      assert_equal(expected, @session.get_headers) 
    end
    def test_post_headers
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
        ['Content-Type', 'application/x-www-form-urlencoded']
      ]
      assert_equal(expected, @session.post_headers)
    end
    def test_post_body
      pair1 = ['aaa', 'bbb']
      pair2 = ['ccc', 'ddd']
      data  = [pair1, pair2]
      assert_equal('aaa=bbb&ccc=ddd', @session.post_body(data))
    end
    def test_get
      flexmock(@http, :get => 'get')
      assert_equal('get', @session.get('args'))
    end
    def test_post__error
      pair1 = ['aaa', 'bbb']
      pair2 = ['ccc', 'ddd']
      data  = [pair1, pair2]
      flexmock(@http, :post => 'response')
      assert_raise(RuntimeError) do 
        @session.post('path', data) 
      end
    end
  end
end # ODDB


