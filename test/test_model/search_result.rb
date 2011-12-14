#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::TestSearchResult -- oddb.org -- 15.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path('..', File.dirname(__FILE__))
$: << File.expand_path("../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'model/search_result'

module ODDB
  class TestAtcFacade < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @result  = flexmock('result')
      @session = flexmock('session')
      @atc     = flexmock('atc')
      @facade  = ODDB::AtcFacade.new(@atc, @session, @result)
    end
    def test_active_packages
      flexmock(@atc, :active_packages => 'active_packages')
      assert_equal('active_packages', @facade.active_packages)
    end
    def test_code
      flexmock(@atc, :code => 'code')
      assert_equal('code', @facade.code)
    end
    def test_description
      flexmock(@atc, :description => 'description')
      assert_equal('description', @facade.description)
    end
    def test_odba_id
      flexmock(@atc, :odba_id => 'odba_id')
      assert_equal('odba_id', @facade.odba_id)
    end
    def test_packages
      package1 = flexmock('package1', 
                          :expired?        => nil,
                          :generic_type    => :original,
                          :name_base       => 'package1',
                          :galenic_forms   => [],
                          :dose            => 'dose',
                          :comparable_size => 1
                         )
      package2 = flexmock('package2', 
                          :expired?        => nil,
                          :generic_type    => :original,
                          :name_base       => 'package2',
                          :galenic_forms   => [],
                          :dose            => 'dose',
                          :comparable_size => 1
                         )

      active_packages = [package2, package1]
      flexmock(@atc, :active_packages => active_packages)
      expected = [package1, package2]
      assert_equal(expected, @facade.packages)
    end
    def test_empty?
      flexmock(@atc, :active_packages => [])
      assert(@facade.empty?)
    end
    def test_has_ddd?
      flexmock(@atc, :has_ddd? => true)
      assert(@facade.has_ddd?)
    end
    def test_overflow?
      flexmock(@result, :overflow? => true)
      assert(@facade.overflow?)
    end
    def test_pointer
      flexmock(@atc, :pointer => 'pointer')
      assert_equal('pointer', @facade.pointer)
    end
    def test_package_count
      flexmock(@atc, :package_count => 'package_count')
      assert_equal('package_count', @facade.package_count)
    end
    def test_parent_code
      flexmock(@atc, :parent_code => 'parent_code')
      assert_equal('parent_code', @facade.parent_code)
    end
    def test_sequences
      flexmock(@atc, :sequences => 'sequences')
      assert_equal('sequences', @facade.sequences)
    end
  end

  class TestSearchResult < Test::Unit::TestCase
    include FlexMock::TestCase
    def setup
      @result = ODDB::SearchResult.new
    end
    def test_atc_facades
      atc_class = flexmock('atc_class')
      @result.instance_eval('@atc_classes = [atc_class]')
      result = @result.atc_facades
      assert_equal(1, result.length)
      assert_kind_of(ODDB::AtcFacade, result[0])
    end
    def test_empty?
      assert(@result.empty?)
    end
    def test_filter!
      atc_class = flexmock('atc_class', :filter => 'filter')
      @result.instance_eval('@atc_classes = [atc_class]')
      assert_equal(['filter'], @result.filter!('filter_proc'))
    end
    def test_package_count
      atc_class = flexmock('atc_class', :package_count => 1)
      @result.instance_eval('@atc_classes = [atc_class]')
      assert_equal(1, @result.package_count)
    end
    def test_overflow?
      atc_class = flexmock('atc_class', :package_count => 1)
      @result.instance_eval('@atc_classes = [atc_class]')
      assert_equal(false, @result.overflow?)
    end
    def test_set_relevance
      relevance = 1.23
      odba_id   = 0
      assert_in_delta(1.23, @result.set_relevance(odba_id, relevance), 1e-10)
    end
    def test_delete_empty_packages
      # This is a testcase for a private method
      atc_class = flexmock('atc_class', :active_packages => [])
      assert_equal([], @result.instance_eval('delete_empty_packages([atc_class])'))
    end
    def test_atc_sorted__already
      @result.instance_eval('@atc_sorted = "atc_sorted"')
      assert_equal('atc_sorted', @result.atc_sorted)
    end
    def test_atc_sorted
      atc_class = flexmock('atc_class', 
                           :package_count => 1,
                           :active_packages => ['package']
                          )
      @result.instance_eval('@atc_classes = [atc_class]')
      result = @result.atc_sorted
      assert_equal(1, result.length)
      assert_kind_of(ODDB::AtcFacade, result[0])
    end
    def test_atc_sorted__overflow
      atc_class = flexmock('atc_class', 
                           :package_count => 1,
                           :active_packages => ['package'],
                           :description   => 'description'
                          )
      @result.instance_eval('@atc_classes = [atc_class, atc_class]')
      @result.instance_eval('@display_limit = 0')
      result = @result.atc_sorted
      assert_equal(2, result.length)
      assert_kind_of(ODDB::AtcFacade, result[0])
    end
    def test_atc_sorted__search_type_substance
      active_agent = flexmock('active_agent', :same_as? => nil)
      package   = flexmock('package', 
                           :expired?        => nil,
                           :generic_type    => :original,
                           :name_base       => 'name_base',
                           :galenic_forms   => [],
                           :dose            => 'dose',
                           :comparable_size => 1,
                           :active_agents   => [active_agent]
                          )
      atc_class = flexmock('atc_class', 
                           :package_count => 1,
                           :active_packages => [package]
                          )
      @result.instance_eval('@atc_classes = [atc_class]')
      @result.instance_eval('@search_type = :substance')
      result = @result.atc_sorted
      assert_equal(1, result.length)
      assert_kind_of(ODDB::AtcFacade, result[0])
    end
    def test_atc_sorted__relevance_not_empty
      atc_class = flexmock('atc_class', 
                           :package_count => 1,
                           :active_packages => ['package']
                          )
      @result.instance_eval('@atc_classes = [atc_class]')
      @result.instance_eval('@relevance = {"key" => "value"}')
      result = @result.atc_sorted
      assert_equal(1, result.length)
      assert_kind_of(ODDB::AtcFacade, result[0])
    end
    def test_atc_sorted__relevance_not_empty_interaction
      atc_class = flexmock('atc_class', 
                           :package_count => 1,
                           :active_packages => ['package'],
                           :sequences     => ['sequence']
                          )
      @result.instance_eval('@atc_classes = [atc_class]')
      @result.instance_eval('@relevance = {"key" => "value"}')
      @result.instance_eval('@search_type = :interaction')
      result = @result.atc_sorted
      assert_equal(1, result.length)
      assert_kind_of(ODDB::AtcFacade, result[0])
    end
    def std_null
      require 'tempfile'
      $stderr = Tempfile.open('stderr')
      $stdout = Tempfile.open('stdout')
      yield
      $stderr.close
      $stdout.close
      $stderr = STDERR
      $stdout = STDOUT
    end
    def test_atc_sorted__error
      atc_class = flexmock('atc_class') do |a|
        a.should_receive(:package_count).and_raise(StandardError)
      end
      @result.instance_eval('@atc_classes = [atc_class]')
      std_null do 
        result = @result.atc_sorted
        assert_equal(1, result.length)
        assert_kind_of(ODDB::AtcFacade, result[0])
      end
    end
    def test_each
      atc_class = flexmock('atc_class', 
                           :package_count => 1,
                           :active_packages => ['package']
                          )
      @result.instance_eval('@atc_classes = [atc_class]')
      @result.each do |atc|
        assert_kind_of(ODDB::AtcFacade, atc)
      end
    end

  end
end
