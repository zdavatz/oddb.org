#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestDosingPlugin -- oddb.org -- 26.06.2012 -- yasaka@ywesee.com

require 'pathname'

require 'minitest/autorun'
require 'flexmock/minitest'

root = Pathname.new(__FILE__).realpath.parent.parent.parent
$: << root.join('test').join('test_plugin')
$: << root.join('src')

require 'plugin/dosing'

module ODDB
  class DosingPlugin < Plugin
    attr_accessor :links, :checked, :activated
    private
    def _index
      return @links
    end
  end
end

module ODDB
  class TestDosingPlugin <Minitest::Test
    SHORT_URI = '/popup_niere.php?monoid=56789'
    FULL_URI  = 'http://dosing.de' + SHORT_URI
    def setup
      @app = FlexMock.new 'app'
      @app.should_receive(:update).and_return do |pointer, hash|
        assert_equal 'atc-pointer', pointer
        assert hash.has_key?(:ni_id)
      end
      @plugin = DosingPlugin.new @app
      @atc = flexmock('atc')
      @atc.should_receive(:odba_id).and_return(@atc.object_id)
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
          :uri  => SHORT_URI
        })
      ]
      @plugin.update_ni_id
      assert_equal(1, @plugin.checked)
      assert_equal(1, @plugin.activated)
    end
    def test_update_ni_id_with_no_match_atc
      @atc.should_receive(:code).and_return('ABC1234')
      @atc.should_receive(:description).and_return('desc')
      @atc.should_receive(:to_s).and_return('foo')
      @app.should_receive(:atc_classes).and_return({ :no_match => @atc })
      @plugin.links = [
        flexmock('link', {
          :text => 'bar',
          :uri  => SHORT_URI
        })
      ]
      @plugin.update_ni_id
      assert_equal(0, @plugin.checked)
      assert_equal(0, @plugin.activated)
      @atc.should_receive(:to_s).and_return('Boo')
      @plugin.update_ni_id
      assert_equal(0, @plugin.checked)
      assert_equal(0, @plugin.activated)
    end
    def test_update_ni_id_with_empty_atc_desc
      @atc.should_receive(:code).and_return('ABC1234')
      @atc.should_receive(:description).and_return('')
      @app.should_receive(:atc_classes).and_return({ :empty => @atc })
      @plugin.update_ni_id
      assert_equal(0, @plugin.checked)
      assert_equal(0, @plugin.activated)
    end
    def test_update_ni_id_with_unexpected_uri
      @atc.should_receive(:code).and_return('ABC1234')
      @atc.should_receive(:description).and_return('desc')
      @atc.should_receive(:ni_id).and_return('old_ni_id')
      @atc.should_receive(:to_s).and_return('foo')
      @app.should_receive(:atc_classes).and_return({ :good => @atc }).by_default
      @plugin.links = [
        flexmock('link', {
          :text => 'foo',
          :uri  => FULL_URI
        })
      ]
      @plugin.update_ni_id
      assert_equal(1, @plugin.checked)
      assert_equal(0, @plugin.activated)
      @plugin.links = [
        flexmock('link', {
          :text => 'foo',
          :uri  => FULL_URI+ '*G' # index anchor
        })
      ]
      atc_no_link = flexmock('atc_no_link')
      atc_no_link.should_receive(:odba_id).and_return(atc_no_link.object_id)
      atc_no_link.should_receive(:pointer).and_return('atc-pointer')
      atc_no_link.should_receive(:code).and_return('ABC5678')
      atc_no_link.should_receive(:description).and_return('desc')
      atc_no_link.should_receive(:ni_id).and_return('a_ni_id')
      @app.should_receive(:atc_classes).and_return({ :good => @atc, :atc_no_link => atc_no_link })
      @plugin.update_ni_id
      assert_equal(1, @plugin.checked)
      assert_equal(0, @plugin.activated)
    end
    def test_report
      @atc.should_receive(:code).and_return('ABC1234')
      @atc.should_receive(:description).and_return('desc')
      @atc.should_receive(:ni_id).and_return('old_ni_id')
      @atc.should_receive(:to_s).and_return('foo')
      @app.should_receive(:atc_classes).and_return({ :good => @atc })
      @plugin.update_ni_id
      report = @plugin.report
      [ /^Checked ATC classes/,
        /^Activated Niere Link/,
        /^Non-linked ATC classes/,
      ].each do |line|
        assert_match(line, report)
      end
    end
  end
end
