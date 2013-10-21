#!/usr/bin/env ruby
# encoding: utf-8
# ODDB::State::Drugs::TestCompare -- oddb.org -- 01.06.2011 -- mhatakeyama@ywesee.com

$: << File.expand_path("../../../src", File.dirname(__FILE__))

gem 'minitest'
require 'minitest/autorun'
require 'flexmock'
require 'state/drugs/compare'
require 'view/http_404'

module ODDB
	module State
		module Drugs

class TestPackageFacade <Minitest::Test
  include FlexMock::TestCase
  def setup
    @original = flexmock('original')
    @package  = flexmock('package')
    @facade   = ODDB::State::Drugs::Compare::Comparison::PackageFacade.new(@package, @original)
  end
  def size
    1
  end
  def test_price_difference
    flexmock(@original, 
             :price_public          => 1,
             :"comparable_size.qty" => 1
            )
    flexmock(@package, 
             :price_public          => 3,
             :"comparable_size.qty" => 1 
            )
    assert_in_delta(2.0, @facade.price_difference, 0.001)
  end
  def test_price_difference__nil
    flexmock(@original, 
             :price_public          => -1,
             :"comparable_size.qty" => 1
            )
    flexmock(@package, 
             :price_public          => 3,
             :"comparable_size.qty" => 1 
            )
    assert_nil(@facade.price_difference)
  end
  def test_compare1
    flexmock(@original, :price_public => 1.5)
    flexmock(@package,  :price_public => -3.5)

    result = @facade <=> @original
    assert_equal(4, result)
  end
  def test_compare2
    other = flexmock('other',
                     :price_public => 1,
                     :price_difference => 0,
                     :comparable_size => size,
                     :name_base => 'A'
                    )
    size = flexmock('size', 
                    :qty => 1,
                    :<=> => 0
                   )
    flexmock(@original, 
             :price_public     => 1,
             :comparable_size  => size,
             :name_base        => 'B'
            )
    flexmock(@package,
             :price_public     => 1,
             :comparable_size  => size,
             :name_base        => 'B'
            )

    result = @facade <=> other
    assert_equal(1, result)
  end

end

class TestComparison <Minitest::Test
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

class TestCompare <Minitest::Test
  include FlexMock::TestCase
  def setup
    @lnf     = flexmock('lookandfeel', :lookup => 'lookup')
    @app     = flexmock('app')
    @session = flexmock('session', 
                        :app         => @app,
                        :lookandfeel => @lnf
                       ).by_default
    @model   = flexmock('model',
                       :atc_class => 'atc_class'
                        )
    @state   = ODDB::State::Drugs::Compare.new(@session, @model)
  end
  def test_init__pointer
    package = flexmock('package', 
                       :name_base => 'name_base',
                       :is_a?     => true,
                       :atc_class => 'atc_class'
                      )
    flexmock(package, :comparables => [package])
    pointer = flexmock('pointer', 
                       :resolve => package,
                       :is_a?   => true
                      )
    @session.should_receive(:user_input).once.and_return(false)
    skip("Don't know what/how we want to test here")
    assert_equal(ODDB::View::Drugs::Compare, @state.init)
  end
  def test_init__ean13
    package = flexmock('package', 
                       :name_base => 'name_base',
                       :is_a?     => true,
                       :atc_class => 'atc_class'
                      )
    @model.should_receive(:atc_class => 'atc_class')
    @session.should_receive(:user_input).once.and_return(false)
    flexmock(package, :comparables => [package])
    flexmock(@app, :package_by_ikskey => package)
    ean13 = flexmock('ean13', 
                       :model => @model,
                       :is_a? => true,
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
    @session.should_receive(:user_input).once.and_return(pointer)
    skip("Niklaus does not know why it return ODDB::View::Http404")
    assert_equal(ODDB::View::Drugs::EmptyCompare, @state.init)
  end
  def test_init__search_query
    flexmock(@session, :user_input) do |session|
      session.should_receive(:user_input).once.with(:pointer).and_return(nil)
      session.should_receive(:user_input).once.with(:ean13).and_return(nil)
      session.should_receive(:user_input).once.with(:search_query).and_return('term')
    end
    package = flexmock('package')
    flexmock(ODDB::Package, :find_by_name_with_size => package)
    assert_equal(ODDB::View::Http404, @state.init)
  end
  def test_no_alternatives
    package = flexmock('package', 
                       :name_base => 'name_base',
                       :is_a?     => true,
                       :atc_class => nil 
                      )
    flexmock(package, :comparables => [nil])
    pointer = flexmock('pointer', 
                       :resolve => package,
                       :is_a?   => true
                      )
    @session.should_receive(:user_input).once.and_return(pointer)
    skip("Niklaus does not know why it return ODDB::View::Http404")
    assert_equal(ODDB::View::Drugs::EmptyCompare, @state.init)
  end  
  def test_init__error1
    flexmock(@session).should_receive(:user_input).and_raise(Persistence::UninitializedPathError.new(1,2))
    assert_equal(ODDB::View::Http404, @state.init)
  end
  def stdout_null
    require 'tempfile'
    $stdout = Tempfile.open('stdout')
    yield
    $stdout.close
    $stdout = STDERR
  end
  def test_init__error2
    flexmock(@session, :user_input) do |session|
      session.should_receive(:user_input).once.with(:pointer).and_return(nil)
      session.should_receive(:user_input).once.with(:ean13).and_return(nil)
      session.should_receive(:user_input).once.with(:search_query).and_return('term')
    end
    package = flexmock('package', :is_a? => true)
    flexmock(ODDB::Package, :find_by_name_with_size => package)
    flexmock(@lnf).should_receive(:lookup).and_raise(StandardError)
    stdout_null do 
      assert_equal(ODDB::View::Http404, @state.init)
    end
  end
end

		end # Drugs
	end # State
end # ODDB
