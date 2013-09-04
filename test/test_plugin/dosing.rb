#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestDosingPlugin -- oddb.org -- 26.06.2012 -- yasaka@ywesee.com

require 'pathname'
require 'test/unit'
require 'flexmock'

root = Pathname.new(__FILE__).realpath.parent.parent.parent
$: << root.join('test').join('test_plugin')
$: << root.join('src')

require 'plugin/dosing'

module ODDB
  class DosingPlugin < Plugin
    attr_accessor :links,
                  :checked, :activated, :nonlinked
    private
    def _index
      return @links
    end
  end
end

module ODDB
  class TestDosingPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @app = FlexMock.new 'app'
      @app.should_receive(:update).and_return do |pointer, hash|
        assert_equal 'atc-pointer', pointer
        assert hash.has_key?(:ni_id)
      end
      @plugin = DosingPlugin.new @app
      @atc = flexmock('atc')
      @atc.should_receive(:pointer).and_return('atc-pointer')
    end
    def teardown
      super # to clean up FlexMock
      #pass
    end
    def test_update_ni_id_with_valid_atc
      @atc.should_receive(:code).and_return('ABC1234')
      @atc.should_receive(:description).and_return('desc')
      @atc.should_receive(:to_s).and_return('foo')
      @app.should_receive(:atc_classes).and_return({ :good => @atc })
      @plugin.links = [
        flexmock('link', {
          :text => 'foo',
          :uri  => 'http://dosing.de/Niere/arzneimittel/NI_56789.html'
        })
      ]
      @plugin.update_ni_id
      assert_equal(@plugin.checked,   1)
      assert_equal(@plugin.activated, 1)
      assert_equal(@plugin.nonlinked, 0)
    end
    def test_update_ni_id_with_no_match_atc
      @atc.should_receive(:code).and_return('ABC1234')
      @atc.should_receive(:description).and_return('desc')
      @atc.should_receive(:to_s).and_return('foo')
      @app.should_receive(:atc_classes).and_return({ :no_match => @atc })
      @plugin.links = [
        flexmock('link', {
          :text => 'bar',
          :uri  => 'http://dosing.de/Niere/arzneimittel/NI_56789.html'
        })
      ]
      @plugin.update_ni_id
      assert_equal(@plugin.checked,   1)
      assert_equal(@plugin.activated, 0)
      assert_equal(@plugin.nonlinked, 1)
      @atc.should_receive(:to_s).and_return('Boo')
      @plugin.update_ni_id
      assert_equal(@plugin.checked,   2)
      assert_equal(@plugin.activated, 0)
      assert_equal(@plugin.nonlinked, 2)
    end
    def test_update_ni_id_with_empty_atc_desc
      @atc.should_receive(:code).and_return('ABC1234')
      @atc.should_receive(:description).and_return('')
      @app.should_receive(:atc_classes).and_return({ :empty => @atc })
      @plugin.update_ni_id
      assert_equal(@plugin.checked,   0)
      assert_equal(@plugin.activated, 0)
      assert_equal(@plugin.nonlinked, 0)
    end
    def test_update_ni_id_with_unexpected_uri
      @atc.should_receive(:code).and_return('ABC1234')
      @atc.should_receive(:description).and_return('desc')
      @atc.should_receive(:to_s).and_return('foo')
      @app.should_receive(:atc_classes).and_return({ :good => @atc })
      @plugin.links = [
        flexmock('link', {
          :text => 'foo',
          :uri  => 'http://dosing.de/Niere/arzneimittel/NI_12.html'
        })
      ]
      @plugin.update_ni_id
      assert_equal(@plugin.checked,   1)
      assert_equal(@plugin.activated, 0)
      assert_equal(@plugin.nonlinked, 1)
      @plugin.links = [
        flexmock('link', {
          :text => 'foo',
          :uri  => 'http://dosing.de/Niere/nierelst.htm#G' # index anchor
        })
      ]
      @plugin.update_ni_id
      assert_equal(@plugin.checked,   2)
      assert_equal(@plugin.activated, 0)
      assert_equal(@plugin.nonlinked, 2)
    end
  end
end
