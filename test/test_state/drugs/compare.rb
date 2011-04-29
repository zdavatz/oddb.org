#!/usr/bin/env ruby
# ODDB::State::Drugs::TestCompare -- oddb.org -- 29.04.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

require 'test/unit'
require 'flexmock'
require 'state/drugs/compare'
require 'view/http_404'

module ODDB
	module State
		module Drugs

class TestComparison < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @package      = flexmock('package')
    flexmock(@package, :comparables => [@package])
    @comparison   = ODDB::State::Drugs::Compare::Comparison.new(@package)
  end
  def test_each
    @comparison.each do |pack|
      assert_kind_of(ODDB::State::Drugs::Compare::Comparison::PackageFacade, pack)
    end
  end
  def test_empty
    assert_equal(false, @comparison.empty?)
  end
  def test_atc_class
    flexmock(@package, :atc_class => 'atc_class')
    assert_equal('atc_class', @comparison.atc_class)
  end
  def test_name_base
    flexmock(@package, :name_base => 'name_base')
    assert_equal('name_base', @comparison.name_base)
  end
  def test_sort_by
    previous = @comparison.comparables.dup
    @comparison.sort_by! do |pack|
    end
    assert_equal(@comparison.comparables, previous)
  end
end

class TestCompare < Test::Unit::TestCase
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @app     = flexmock('app')
    @session = flexmock('session', 
                        :app         => @app,
                        :lookandfeel => @lnf
                       )
    @model   = flexmock('model')
    @state   = ODDB::State::Drugs::Compare.new(@session, @model)
  end
  def test_init__pointer
    package = flexmock('package', 
                       :name_base => 'name_base',
                       :is_a?     => true,
                       :atc_class => 'atc_clas'
                      )
    flexmock(package, :comparables => [package])
    pointer = flexmock('pointer', 
                       :resolve => package,
                       :is_a?   => true
                      )
    flexmock(@session, :user_input => pointer)
    assert_equal(ODDB::View::Drugs::Compare, @state.init)
  end
  def test_init__ean13
    package = flexmock('package', 
                       :name_base => 'name_base',
                       :is_a?     => true,
                       :atc_class => 'atc_clas'
                      )
    flexmock(package, :comparables => [package])
    flexmock(@app, :package_by_ikskey => package)
    ean13 = flexmock('ean13', 
                       :is_a? => false,
                       :to_s  => 'to_s'
                      )
    flexmock(@session, :user_input => ean13)
    assert_equal(ODDB::View::Drugs::Compare, @state.init)
  end
  def test_init__model_nil
    flexmock(@session, :user_input => nil)
    assert_equal(ODDB::View::Http404, @state.init)
  end
  def test_init__model_atc_nil
    package = flexmock('package', 
                       :name_base => 'name_base',
                       :is_a?     => true,
                       :atc_class => nil 
                      )
    flexmock(package, :comparables => [package])
    pointer = flexmock('pointer', 
                       :resolve => package,
                       :is_a?   => true
                      )
    flexmock(@session, :user_input => pointer)
    assert_equal(ODDB::View::Drugs::EmptyCompare, @state.init)
  end
end

		end # Drugs
	end # State
end # ODDB
