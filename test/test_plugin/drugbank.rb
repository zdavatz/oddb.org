#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestDrugbankPlugin -- oddb.org -- 25.06.2012 -- yasaka@ywesee.com

require 'pathname'
require 'test/unit'
require 'flexmock'

root = Pathname.new(__FILE__).realpath.parent.parent.parent
$: << root.join('test').join('test_plugin')
$: << root.join('src')

require 'plugin/drugbank'

module ODDB
  class DrugbankPlugin < Plugin
    attr_accessor :links,
                  :checked, :activated, :nonlinked
    private
    def _search_with atc
      return @links
    end
  end
end

module ODDB
  class TestDrugbankPlugin < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @app = FlexMock.new 'app'
      @app.should_receive(:update).and_return do |pointer, hash|
        assert_equal 'atc-pointer', pointer
        assert hash.has_key?(:db_id)
      end
      @plugin = DrugbankPlugin.new @app
      @atc = flexmock('atc')
      @atc.should_receive(:pointer).and_return('atc-pointer')
    end
    def teardown
      #pass
    end
    def test_update_db_id_with_valid_atc
      @atc.should_receive(:code).and_return('ABC1234')
      @atc.should_receive(:description).and_return('desc')
      @app.should_receive(:atc_classes).and_return({ :good => @atc })
      @plugin.links = [
        flexmock('link', { :uri => '/drugs/DB56789' })
      ]
      @plugin.update_db_id
      assert_equal(@plugin.checked,   1)
      assert_equal(@plugin.activated, 1)
      assert_equal(@plugin.nonlinked, 0)
    end
    def test_update_db_id_with_short_atc_code
      @atc.should_receive(:code).and_return('ABC')
      @atc.should_receive(:description).and_return('desc')
      @app.should_receive(:atc_classes).and_return({ :short => @atc })
      @plugin.update_db_id
      assert_equal(@plugin.checked,   0)
      assert_equal(@plugin.activated, 0)
      assert_equal(@plugin.nonlinked, 0)
    end
    def test_update_db_id_with_empty_atc_desc
      @atc.should_receive(:code).and_return('ABC1234')
      @atc.should_receive(:description).and_return('')
      @app.should_receive(:atc_classes).and_return({ :empty => @atc })
      @plugin.update_db_id
      assert_equal(@plugin.checked,   0)
      assert_equal(@plugin.activated, 0)
      assert_equal(@plugin.nonlinked, 0)
    end
    def test_update_db_id_with_no_id_found
      @atc.should_receive(:code).and_return('ABC1234')
      @atc.should_receive(:description).and_return('desc')
      @app.should_receive(:atc_classes).and_return({ :nolink => @atc })
      @plugin.links = [
        flexmock('link', { :uri => '/foo/CC1234/' }),
        flexmock('link', { :uri => '/DB/00000/' }),
        flexmock('link', { :uri => '/drugs/DB0000/' })
      ]
      @plugin.update_db_id
      assert_equal(@plugin.checked,   1)
      assert_equal(@plugin.activated, 0)
      assert_equal(@plugin.nonlinked, 1)
    end
    def test_update_db_id_with_multi_links
      @atc.should_receive(:code).and_return('ABC1234')
      @atc.should_receive(:description).and_return('desc')
      @app.should_receive(:atc_classes).and_return({ :multi => @atc })
      @app.should_receive(:update).and_return do |pointer, hash|
        assert_equal 'atc-pointer', pointer
        assert_equal :db_id, hash.keys.first
        assert_equal Array, hash[:db_id].class
        assert_equal 2, hash[:db_id].length
      end
      @plugin.links = [
        flexmock('link', { :uri => '/drugs/DB12345' }),
        flexmock('link', { :uri => '/drugs/DB56789/' })
      ]
      @plugin.update_db_id
      assert_equal(@plugin.checked,   1)
      assert_equal(@plugin.activated, 1)
      assert_equal(@plugin.nonlinked, 0)
    end
    def test_report
      report = @plugin.report
      assert_equal 3, report.split("\n").length
    end
  end
end
